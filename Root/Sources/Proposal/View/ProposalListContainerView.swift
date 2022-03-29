//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/04.
//

import Auth
import Combine
import Core
import SFReadableSymbols
import SwiftUI
#if os(iOS)
import UIKit
#endif

#if os(macOS)
private let searchFieldPlacement: SearchFieldPlacement = .automatic
#else
private let searchFieldPlacement: SearchFieldPlacement = .navigationBarDrawer(displayMode: .automatic)
#endif

public struct ProposalListContainerView: View {
    @EnvironmentObject var viewModel: ProposalListViewModel

    // ⚠️ Bug
    //
    // [macOS]
    // Initialized each time like @ObservedObject.
    // https://stackoverflow.com/questions/71345489/swiftui-macos-navigationview-onchangeof-bool-action-tried-to-update-multipl
    //
    // [iOS]
    // Double generated with View.
    // https://developer.apple.com/forums/thread/655159
    //
    // @StateObject var viewModel: ProposalListViewModel = .init(globalFilter: Filter.filter)

    public init() {}

    public var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    // 💡 [iOS 15.4]
                    // 初期表示で Navigation タイトルの表示が切り替わってしまう問題への対処
                    .searchable(text: .constant(""))
            case .error:
                VStack {
                    Text("Network error")
                    Button("Retry") {
                        Task {
                            await viewModel.onTapRetry()
                        }
                    }
                    .padding()
                    // 💡 [iOS 15.4]
                    // 初期表示で Navigation タイトルの表示が切り替わってしまう問題への対処
                    // （こちらは無くても動いてそうだが一応）
                    .searchable(text: .constant(""))
                }
            case let .success(content):
                contentView(content)
            }
        }
        .toolbar {
            ToolbarItem {
                #if os(macOS)
                Picker(selection: $viewModel.sort) {
                    Label("Latest", symbol: "􀄨")
                        .tag(Sort.latest)
                    Label("Oldest", symbol: "􀄩")
                        .tag(Sort.oldest)
                } label: {
                    Image(symbol: "􀄬")
                }
                #else
                Menu {
                    Picker(selection: $viewModel.sort) {
                        Label("Latest", symbol: "􀄨")
                            .tag(Sort.latest)
                        Label("Oldest", symbol: "􀄩")
                            .tag(Sort.oldest)
                    } label: {
                        // ref: https://stackoverflow.com/questions/69381385/swiftui-custom-picker-label-not-rendering
                        EmptyView()
                    }
                } label: {
                    Image(symbol: "􀄬")
                }
                #endif
            }
        }
        .alert("Network Error", isPresented: $viewModel.isPresentNetworkErrorAlert) {}
        .sheet(isPresented: $viewModel.isPresentAuthView) {
            LoginView()
        }
        #if os(iOS)
        .onReceive(viewModel.$toHideKeyboard) {
            if $0 {
                UIApplication.hideKeyboard()
                viewModel.toHideKeyboard = false
            }
        }
        #endif
        .task {
            await viewModel.onAppear()
        }
    }

    func contentView(_ content: ProposalListViewModel.Content) -> some View {
        ProposalListView(proposals: content.filteredProposals) { proposal in
            Task {
                await viewModel.onTapStar(proposal: proposal)
            }
        }
        .searchable(
            text: Binding(get: {
                // 💡 `content.searchQuery`を直接返すと、submit 時に検索テキストがクリアされる問題の回避
                guard case let .success(content) = viewModel.state else { return "" }
                return content.searchQuery
            }, set: { query in
                viewModel.onChangeQuery(query)
            }),
            placement: searchFieldPlacement,
            prompt: Text("Search Proposal"),
            suggestions: {
                if content.searchQuery.isEmpty {
                    //
                    // 🔍 Search by xxx
                    //
                    Label("Search by Swift version", symbol: "􀫊")
                        .searchCompletion("Swift")
                    Label("Search by Status", symbol: "􀋉")
                        .searchCompletion("Status")
                    //
                    // 🕒 Histories
                    //
                    ForEach(content.searchHistories, id: \.self) {
                        Label($0, symbol: "􀐫")
                            .searchCompletion($0)
                    }
                } else {
                    //
                    // Suggestions
                    //
                    ForEach(content.suggestions) {
                        Text($0.keyword).searchCompletion($0.completion)
                    }
                }
            }
        )
        .refreshable {
            await viewModel.onRefresh()
        }
        .onSubmit(of: .search) {
            viewModel.onSubmitSearch()
        }
    }
}

enum Sort {
    case latest
    case oldest
}

@MainActor
public final class ProposalListViewModel: ObservableObject {
    @Published var state: State = .loading
    @Published var isPresentNetworkErrorAlert = false
    @Published var isPresentAuthView = false
    @Published var toHideKeyboard = false
    @Published var sort: Sort = .latest

    enum State: Equatable {
        case loading
        case error
        case success(Content)
    }

    // TODO: Refactor - remove enum state management.

    struct Content: Equatable {
        var allProposals: [Proposal]
        var searchQuery: String = ""
        var searchHistories: [String]
        var sort: Sort = .latest

        init(proposals: [Proposal], searchHistories: [String]) {
            allProposals = proposals
            self.searchHistories = searchHistories
        }

        var filteredProposals: [Proposal] {
            let xs = allProposals.search(by: searchQuery)
            switch sort {
            case .latest:
                return xs.sorted { $0.id > $1.id }
            case .oldest:
                return xs.sorted { $0.id < $1.id }
            }
        }

        var suggestions: [Suggestion] {
            allProposals.suggestions(by: searchQuery)
        }
    }

    private let globalFilter: (Proposal) -> Bool
    private var dataSource: ProposalDataSource
    private var authState: AuthState

    #if os(iOS)
    private var feedbackGenerator: UIImpactFeedbackGenerator!
    #endif

    private var cancellable: Set<AnyCancellable> = []

    public nonisolated init(
        globalFilter: @escaping (Proposal) -> Bool,
        authState: AuthState,
        dataSource: ProposalDataSource
    ) {
        self.globalFilter = globalFilter
        self.authState = authState
        self.dataSource = dataSource
    }

    // MARK: Lifecycle

    private lazy var initialize: () = {
        #if os(iOS)
        feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        #endif

        $sort
            .map { [weak self] in
                guard let self = self, case var .success(content) = self.state else { return .error }
                content.sort = $0
                return .success(content)
            }
            .assign(to: &$state)

        dataSource.proposals
            .receive(on: DispatchQueue.main)
            .map { [weak self] proposalData in
                guard let self = self else { return .error }

                switch proposalData {
                case .loading:
                    return .loading
                case .error:
                    return .error
                case var .success(proposals, searchHistories):
                    proposals = proposals.filter(self.globalFilter)
                    if case var .success(content) = self.state {
                        content.allProposals = proposals
                        content.searchHistories = searchHistories
                        return .success(content)
                    } else {
                        return .success(.init(
                            proposals: proposals,
                            searchHistories: searchHistories
                        ))
                    }
                }
            }
            .assign(to: &$state)
    }()

    func onAppear() async {
        _ = initialize
        #if os(iOS)
        feedbackGenerator.prepare()
        #endif
    }

    // MARK: Actions - Success

    func onChangeQuery(_ query: String) {
        guard case var .success(content) = state else { return }

        content.searchQuery = query
        state = .success(content)

        if content.allProposals.isMatchKeyword(query: query) {
            #if os(iOS)
            toHideKeyboard = true
            #endif
            if authState.isLogin {
                Task {
                    await dataSource.addSearchHistory(query)
                }
            }
        }
    }

    func onSubmitSearch() {
        guard case let .success(content) = state else { return }

        if authState.isLogin {
            if content.searchQuery != "Swift", content.searchQuery != "Status" {
                Task {
                    await dataSource.addSearchHistory(content.searchQuery)
                }
            }
        }
    }

    func onTapStar(proposal: Proposal) async {
        if let _ = authState.user {
            #if os(iOS)
            feedbackGenerator.impactOccurred()
            #endif
            await dataSource.toggleStar(proposal: proposal)
        } else {
            isPresentAuthView = true
        }
    }

    func onRefresh() async {
        do {
            // Note:
            // Wait at least 1 seconds. (for UX)
            async let wait1: () = try Task.sleep(seconds: 1)
            async let wait2: () = try dataSource.refresh()
            let _ = try await (wait1, wait2)
        } catch {
            isPresentNetworkErrorAlert = true
        }
    }

    // MARK: Actions - Error

    func onTapRetry() async {
        state = .loading
        do {
            try await dataSource.refresh()
        } catch {
            state = .error
        }
    }
}
