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
    
    // Use if needed.
    // @Environment(\.dismissSearch) var dismissSearch
    
    // ⚠️ Bug
    //
    // [macOS]
    // Initialized each time like @ObservedObject.
    // https://stackoverflow.com/questions/71345489/swiftui-macos-navigationview-onchangeof-bool-action-tried-to-update-multipl
    //
    // [iOS]
    // Double generated with View.
    // https://developer.apple.com/forums/thread/655159
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
        .sheet(isPresented: $viewModel.isPresentAuthView) {
            LoginView()
        }
        .task {
            await viewModel.onAppear(authState: authState, sharedProposal: proposalStore)
        }
    }

    func contentView(_ content: ProposalListViewModel.Content) -> some View {

        // FIXME: キーボードでエンターして確定するとキーワードが消えちゃう（謎）
        proposalList(content.filteredProposals)
            .searchable(
                text: Binding(get: { content.searchQuery }, set: { viewModel.onChangeQuery($0) }),
                placement: .navigationBarDrawer,
                prompt: Text("Search..."),
                suggestions: {
                    ForEach(content.suggestions, id: \.0.self) { (title, completion) in
                        Text(title).searchCompletion(completion)
                    }
                }
            )
            .onSubmit(of: .search) {
                // Do something if needed.
            }
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
        var filteredProposals: [Proposal] // For display
        var allProposals: [Proposal]      // For data-source
        var searchQuery: String = ""
        
        internal init(proposals: [Proposal]) {
            self.filteredProposals = proposals
            self.allProposals = proposals
        }

        var swiftVersions: [String] {
            allProposals.swiftVersions()
        }
        
        var suggestions: [(String, String)] {
            allProposals.suggestions(query: searchQuery)
        }
    }
    
    private let globalFilter: (Proposal) -> Bool
    private var sharedProposal: ProposalStore!
    private var authState: AuthState!
    private var cancellable: Set<AnyCancellable> = []

    nonisolated init(globalFilter: @escaping (Proposal) -> Bool) {
        self.globalFilter = globalFilter
    }
    
    // MARK: Lifecycle

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
                    if case .success(var content) = self.state {
                        content.filteredProposals = proposals.filter { proposal in
                            content.filteredProposals.contains { $0.id == proposal.id }
                        }
                        content.allProposals = proposals
                        self.state = .success(content)
                    } else {
                        self.state = .success(
                            Content(
                                proposals: proposals.filter(self.globalFilter)
                            )
                        )
                    }
                }
            }
            .store(in: &cancellable)
    }()

    func onAppear(
        authState: AuthState,
        sharedProposal: ProposalStore
    ) async {
        self.authState = authState
        self.sharedProposal = sharedProposal
        _ = self.initialize
    }
    
    // MARK: Actions - Success
    
    func onChangeQuery(_ query: String) {
        guard case .success(var content) = state else { return }
        
        content.searchQuery = query
        content.filteredProposals = content.allProposals.apply(query: query).filter(globalFilter)
        state = .success(content)
    }

    func onTapStar(proposal: Proposal) async {
        if let _ = authState.user {
            await sharedProposal.onTapStar(proposal: proposal)
        } else {
            isPresentAuthView = true
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
    
    // MARK: Actions - Error
    
    func onTapRetry() async {
        self.state = .loading
        do {
            try await sharedProposal.refresh()
        } catch {
            self.state = .error
        }
    }
}
