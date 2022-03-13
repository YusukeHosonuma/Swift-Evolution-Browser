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
    @Environment(\.authState) var authState: AuthState!
    @Environment(\.proposalStore) var proposalStore: ProposalStore!
    
    // ⚠️
    // Bug: initialized each time on macOS. (But display delay is not due to it)
    // ref: https://stackoverflow.com/questions/71345489/swiftui-macos-navigationview-onchangeof-bool-action-tried-to-update-multipl
    @StateObject var viewModel: ProposalListViewModel = .init(proposalFilter: Filter.filter)

    public init() {}

    public var body: some View {
        Group {
            if viewModel.isError {
                VStack {
                    Text("Network error")
                    Button("Retry") {
                        Task {
                            await viewModel.onTapRetry()
                        }
                    }
                    .padding()
                }
            } else {
                proposalList()
                    .sheet(isPresented: $viewModel.isPresentAuthView) {
                        LoginView()
                    }
                    .searchable(
                        text: $viewModel.searchQuery,
                        placement: .automatic,
                        prompt: Text("Search..."),
                        suggestions: {
                            let statusLabels = ProposalEntity.Status.allCases.map(\.label)
                            if viewModel.swiftVersions.contains(viewModel.searchQuery) || statusLabels.contains(viewModel.searchQuery) {
                                EmptyView()
                            } else {
                                if viewModel.searchQuery.contains("Swift") {
                                    ForEach(viewModel.swiftVersions, id: \.self) { version in
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
        }
        .task {
            await viewModel.onAppear(
                authState: authState,
                sharedProposal: proposalStore
            )
        }
    }
    
    func proposalList() -> some View {
        List(viewModel.proposals, id: \.id) { proposal in
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
        .listStyle(SidebarListStyle())
    }
}

@MainActor
final class ProposalListViewModel: ObservableObject {
    @Published var proposals: [ProposalEntity] = []
    @Published var searchQuery = ""
    @Published var isPresentAuthView: Bool = false
    @Published var swiftVersions: [String] = []
    @Published var isError: Bool = true
    
    private var sharedProposal: ProposalStore!
    private var authState: AuthState!
    
    private var proposalFilter: (ProposalEntity) -> Bool
    private var cancellable: [AnyCancellable] = []
    
    private var initialized = false
    
    nonisolated init(proposalFilter: @escaping (ProposalEntity) -> Bool) {
        self.proposalFilter = proposalFilter
    }
    
    // MARK: Lifecycle
        
    func onAppear(
        authState: AuthState,
        sharedProposal: ProposalStore
    ) async {
        self.authState = authState
        self.sharedProposal = sharedProposal

        sharedProposal.proposals
            .combineLatest($searchQuery)
            .sink { [weak self] proposals, query in
                guard let self = self else { return }
                
                if let proposals = proposals {
                    self.isError = false
                    self.proposals = self.filteredProposals(query: query, proposals: proposals)
                        .filter(self.proposalFilter)
                } else {
                    self.isError = true
                }
            }
            .store(in: &cancellable)
        
        sharedProposal.swiftVersions
            .assign(to: &$swiftVersions)
        
        // Fire
        searchQuery = ""
    }
    
    // MARK: Actions
    
    func onTapRetry() async {
        await sharedProposal.refresh()
    }
    
    func onTapStar(proposal: ProposalEntity) async {
        if let _ = authState.user.value {
            await sharedProposal.onTapStar(proposal: proposal)
        } else {
            self.isPresentAuthView = true
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
