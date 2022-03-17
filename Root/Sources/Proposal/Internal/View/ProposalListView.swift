//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/04.
//

import SwiftUI
import Combine
import Core
import Auth
import Algorithms

protocol ProposalFilter {
    static func filter(entity: ProposalEntity) -> Bool
}

enum NoFilter: ProposalFilter {
    static func filter(entity: ProposalEntity) -> Bool {
        true
    }
}

enum StaredFilter: ProposalFilter {
    static func filter(entity: ProposalEntity) -> Bool {
        entity.star
    }
}

struct ProposalListView<Filter: ProposalFilter>: View {
    @EnvironmentObject var authState: AuthState
    @Environment(\.proposalStore) var proposalStore: ProposalStore!
    
    // ⚠️
    // Bug: initialized each time on macOS. (But display delay is not due to it)
    // ref: https://stackoverflow.com/questions/71345489/swiftui-macos-navigationview-onchangeof-bool-action-tried-to-update-multipl
    @StateObject var viewModel: ProposalListViewModel = .init(proposalFilter: Filter.filter)

    private let scrollToTopID: String
    
    init(scrollToTopID: String) {
        self.scrollToTopID = scrollToTopID
    }
    
    public var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .error:
                VStack {
                    Text("Network error")
                    Button("Retry") {
                        Task {
                            await viewModel.onTapRetry()
                        }
                    }
                    .padding()
                }
            case .success(let content):
                contentView(contentBinding: .init(get: { content }, set: { viewModel.state = .success($0) }))
            }
        }
        .task {
            await viewModel.onAppear(
                authState: authState,
                sharedProposal: proposalStore
            )
        }
    }

    func contentView(contentBinding: Binding<ProposalListViewModel.Content>) -> some View {
        let content = contentBinding.wrappedValue
        return proposalList(content.proposals)
            .sheet(isPresented: contentBinding.isPresentAuthView) {
                LoginView()
            }
            .searchable(
                text: Binding(get: { content.searchQuery }, set: { viewModel.onChangeQuery($0) }),
                placement: .automatic,
                prompt: Text("Search..."),
                suggestions: {
                    let statusLabels = ProposalEntity.Status.allCases.map(\.label)
                    if content.swiftVersions.contains(content.searchQuery) || statusLabels.contains(content.searchQuery) {
                        EmptyView()
                    } else {
                        if content.searchQuery.contains("Swift") {
                            ForEach(content.swiftVersions, id: \.self) { version in
                                Text(version)
                                    .searchCompletion(version)
                            }
                        } else {
                            Text("Swift").searchCompletion("Swift ")
                            ForEach(statusLabels, id: \.self) { label in
                                Text(label).searchCompletion(label)
                            }
                        }
                    }
                }
            )
    }
    
    func proposalList(_ proposals: [ProposalEntity]) -> some View {
        List {
            ForEach(proposals, id: \.id) { proposal in
                NavigationLink {
                    ProposalDetailView(url: proposal.proposalURL)
                } label: {
                    ProposalRowView(proposal: proposal, starTapped: {
                        Task {
                            await viewModel.onTapStar(proposal: proposal)
                        }
                    })
                }
            }
            .id(scrollToTopID)
        }
    }
}

@MainActor
final class ProposalListViewModel: ObservableObject {
    
    @Published var state: State = .loading

    enum State: Equatable {
        case loading
        case error
        case success(Content)
    }
    
    struct Content: Equatable {
        var proposals: [ProposalEntity]
        var searchQuery: String
        var isPresentAuthView: Bool
        let swiftVersions: [String]
        
        internal init(
            proposals: [ProposalEntity],
            swiftVersions: [String],
            searchQuery: String = "",
            isPresentAuthView: Bool = false
        ) {
            self.proposals = proposals
            self.searchQuery = searchQuery
            self.isPresentAuthView = isPresentAuthView
            self.swiftVersions = swiftVersions
        }
    }
    
    private var sharedProposal: ProposalStore!
    private var authState: AuthState!
    
    private var proposalFilter: (ProposalEntity) -> Bool
    private var cancellable: [AnyCancellable] = []
    
    private var initialized = false
    
    nonisolated init(proposalFilter: @escaping (ProposalEntity) -> Bool) {
        self.proposalFilter = proposalFilter
    }
    
    // MARK: Lifecycle
        
    func onChangeQuery(_ query: String) {
        guard case .success(var content) = self.state else { return }
        content.searchQuery = query
        content.proposals = self.filteredProposals(query: query, proposals: sharedProposal.proposals.value!).filter(self.proposalFilter)
        self.state = .success(content)
    }
    
    func onAppear(
        authState: AuthState,
        sharedProposal: ProposalStore
    ) async {
        self.authState = authState
        self.sharedProposal = sharedProposal

        sharedProposal.proposals
            .sink { [weak self] proposals in
                guard let self = self else { return }

                guard let proposals = proposals else {
                    self.state = .error
                    return
                }
                
                if proposals.isEmpty {
                    self.state = .loading
                } else {
                    let proposals = self.filteredProposals(query: "", proposals: proposals).filter(self.proposalFilter)
                    self.state = .success(
                        Content(
                            proposals: proposals,
                            swiftVersions: proposals.swiftVersions()
                        )
                    )
                }
            }
            .store(in: &cancellable)
    }
    
    // MARK: Actions
    
    func onTapRetry() async {
        await sharedProposal.refresh()
    }
    
    func onTapStar(proposal: ProposalEntity) async {
        if let _ = authState.user {
            await sharedProposal.onTapStar(proposal: proposal)
        } else {
            self.state = self.onTapStarReduce(self.state)
        }
    }
    
    // Reducer のスーパー劣化版！
    func onTapStarReduce(_ current: State) -> State {
        switch current {
        case .loading, .error:
            return current
            
        case .success(var content):
            content.isPresentAuthView = true
            return .success(content)
        }
    }
    
    // MARK: Private
    
    private func filteredProposals(query: String, proposals: [ProposalEntity]) -> [ProposalEntity] {
        guard !query.isEmpty else { return proposals }
        return proposals.filter {
            var isVersionMatch = false
            if case .implemented(let version) = $0.status {
                var versionString = query
                if query.contains("Swift"), let last = query.split(separator: " ").last {
                    versionString = String(last)
                }
                isVersionMatch = version == versionString
            }
            
            return $0.title.contains(query)
                || $0.status.label == query
                || isVersionMatch
        }
    }
}

private extension Array where Element == ProposalEntity {
    func swiftVersions() -> [String] {
        self
            .compactMap {
                if case .implemented(let version) = $0.status {
                    return version.isEmpty ? nil : "Swift \(version)"
                } else {
                    return nil
                }
            }
            .uniqued()
            .asArray()
    }
}
