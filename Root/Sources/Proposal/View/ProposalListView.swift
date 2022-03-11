//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/04.
//

import SwiftUI
import Combine
import Core

public struct ProposalListView<FirebaseAuthViewBuilder: FirebaseAuthViewBuildable>: View {
    @ObservedObject var viewModel: ProposalListViewModel<FirebaseAuthViewBuilder>
    
    @Environment(\.authState) var authState: AuthState!
    @Environment(\.proposalStore) var proposalStore: ProposalStore!

    public init(
        firebaseAuthViewBuilder: FirebaseAuthViewBuilder,
        proposalFilter: @escaping (ProposalEntity) -> Bool
    ) {
        self.viewModel = ProposalListViewModel(
            firebaseAuthViewBuilder: firebaseAuthViewBuilder,
            proposalFilter: proposalFilter
        )
    }
    
    public var body: some View {
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
        .sheet(isPresented: $viewModel.isPresentAuthView) {
            viewModel.firebaseAuthView(isPresent: $viewModel.isPresentAuthView)
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
        .task {
            await viewModel.onAppear(
                authState: authState,
                sharedProposal: proposalStore
            )
        }
    }
}

@MainActor
final class ProposalListViewModel<FirebaseAuthViewBuilder: FirebaseAuthViewBuildable>: ObservableObject {
    @Published var proposals: [ProposalEntity] = []
    @Published var searchQuery = ""
    @Published var isPresentAuthView: Bool = false
    @Published var swiftVersions: [String] = []
    
    private var sharedProposal: ProposalStore!
    private var authState: AuthState!
    
    private let firebaseAuthViewBuilder: FirebaseAuthViewBuilder
    private var proposalFilter: (ProposalEntity) -> Bool
    private var cancellable: [AnyCancellable] = []
    
    nonisolated init(
//        sharedProposal: ProposalStore,
        firebaseAuthViewBuilder: FirebaseAuthViewBuilder,
        proposalFilter: @escaping (ProposalEntity) -> Bool
    ) {
//        self.sharedProposal = sharedProposal
        self.proposalFilter = proposalFilter
        self.firebaseAuthViewBuilder = firebaseAuthViewBuilder
    }
    
    func onAppear(
        authState: AuthState,
        sharedProposal: ProposalStore
    ) async {
        
        // DI
        self.authState = authState
        self.sharedProposal = sharedProposal
        
        sharedProposal.proposals
            .combineLatest($searchQuery)
            .map { proposals, query in
                let xs = self.filteredProposals(query: query, proposals: proposals)
                let ys = xs.filter(self.proposalFilter)
                return ys
            }
            .assign(to: &$proposals)
        
        sharedProposal.proposals
            .map { proposals in
                proposals
                    .compactMap {
                        if case .implemented(let version) = $0.status {
                            return version.isEmpty ? nil : "Swift \(version)"
                        } else {
                            return nil
                        }
                    }
                    .removingDuplicates()
            }
            .assign(to: &$swiftVersions)
        
        // Fire
        searchQuery = ""
    }
    
    func onTapStar(proposal: ProposalEntity) async {
        if let _ = authState.user.value {
            await sharedProposal.onTapStar(proposal: proposal)
        } else {
            self.isPresentAuthView = true
        }
    }
    
    func firebaseAuthView(isPresent: Binding<Bool>) -> some View {
        firebaseAuthViewBuilder.makeView(isPresent)
    }
    
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

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
