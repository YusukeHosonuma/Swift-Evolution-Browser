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

protocol ProposalFilter {
    static func filter(entity: Proposal) -> Bool
}

enum NoFilter: ProposalFilter {
    static func filter(entity: Proposal) -> Bool {
        true
    }
}

enum StaredFilter: ProposalFilter {
    static func filter(entity: Proposal) -> Bool {
        entity.star
    }
}

struct ProposalListView<Filter: ProposalFilter>: View {
    @EnvironmentObject var authState: AuthState
    @Environment(\.proposalStore) var proposalStore: ProposalStore!
    
    // ⚠️
    // Bug: initialized each time on macOS. (But display delay is not due to it)
    // ref: https://stackoverflow.com/questions/71345489/swiftui-macos-navigationview-onchangeof-bool-action-tried-to-update-multipl
    @StateObject var viewModel: ProposalListViewModel = .init(globalFilter: Filter.filter)

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
                contentView(content)
            }
        }
        .alert("Network Error", isPresented: $viewModel.isPresentNetworkErrorAlert) {}
        .task {
            await viewModel.onAppear(authState: authState, sharedProposal: proposalStore)
        }
    }

    func contentView(_ content: ProposalListViewModel.Content) -> some View {
        proposalList(content.proposals)
            .sheet(isPresented: $viewModel.isPresentAuthView) {
                LoginView()
            }
            .searchable(
                text: Binding(get: { content.searchQuery }, set: { viewModel.onChangeQuery($0) }),
                placement: .automatic,
                prompt: Text("Search..."),
                suggestions: {
                    let statusLabels = Proposal.Status.allCases.map(\.label)
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
    
    func proposalList(_ proposals: [Proposal]) -> some View {
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
                .contextMenu {
                    Link("Open in browser", destination: proposal.proposalURL)
                }
            }
            .id(scrollToTopID)
        }
        .listStyle(.sidebar)
        .refreshable {
            await viewModel.onRefresh()
        }
    }
}

@MainActor
final class ProposalListViewModel: ObservableObject {
    
    @Published var state: State = .loading
    @Published var isPresentNetworkErrorAlert = false
    @Published var isPresentAuthView = false
    
    enum State: Equatable {
        case loading
        case error
        case success(Content)
    }
    
    struct Content: Equatable {
        var proposals: [Proposal]
        var searchQuery: String = ""

        let allProposals: [Proposal]
        var swiftVersions: [String] { allProposals.swiftVersions() }
        
        internal init(proposals: [Proposal]) {
            self.proposals = proposals
            self.allProposals = proposals
        }
    }

    private let globalFilter: (Proposal) -> Bool
    private var sharedProposal: ProposalStore!
    private var authState: AuthState!
    private var cancellable: Set<AnyCancellable> = []

    nonisolated init(globalFilter: @escaping (Proposal) -> Bool) {
        self.globalFilter = globalFilter
    }
    
    lazy var initialize: () = {
        sharedProposal.proposals
            .receive(on: DispatchQueue.main)
            .sink { [weak self] proposals in
                guard let self = self else { return }

                guard let proposals = proposals else {
                    self.state = .error
                    return
                }
                
                if proposals.isEmpty {
                    self.state = .loading
                } else {
                    self.state = .success(
                        Content(
                            proposals: proposals.apply(query: "").filter(self.globalFilter)
                        )
                    )
                }
            }
            .store(in: &cancellable)
    }()
    
    // MARK: Lifecycle
    
    func onChangeQuery(_ query: String) {
        guard case .success(var content) = state else { return }
        
        // FIXME: キーボードでエンターして確定するとキーワードが消えちゃう
        content.searchQuery = query
        content.proposals = content.allProposals.apply(query: query).filter(globalFilter)
        state = .success(content)
    }

    func onAppear(
        authState: AuthState,
        sharedProposal: ProposalStore
    ) async {
        self.authState = authState
        self.sharedProposal = sharedProposal
        _ = self.initialize
    }
    
    // MARK: Actions
    
    func onTapRetry() async {
        self.state = .loading
        do {
            try await sharedProposal.refresh()
        } catch {
            self.state = .error
        }
    }

    func onRefresh() async {
        do {
            // Note:
            // Wait at least 1 seconds. (for UX)
            async let _wait1 = try Task.sleep(seconds: 1)
            async let _wait2 = try sharedProposal.refresh()
            let _ = try await (_wait1, _wait2)
        } catch {
            self.isPresentNetworkErrorAlert = true
        }
    }
    
    func onTapStar(proposal: Proposal) async {
        if let _ = authState.user {
            await sharedProposal.onTapStar(proposal: proposal)
        } else {
            isPresentAuthView = true
        }
    }
}
