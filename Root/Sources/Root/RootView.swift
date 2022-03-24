//
//  ContentView.swift
//  Shared
//
//  Created by Yusuke Hosonuma on 2022/03/09.
//

import Auth
import Core
import Proposal
import SwiftUI
#if os(iOS)
import GoogleSignIn
#endif

private enum Item: Int, Hashable {
    case all
    case star

    var scrollToTopID: String {
        switch self {
        case .all:
            return "SCROLL_TO_TOP_ALL"
        case .star:
            return "SCROLL_TO_TOP_STAR"
        }
    }
}

//
// ⚙️ Global Objects
//

private let authState = AuthState()

private let userService: UserService = UserServiceFirestore(authState: authState)

private let proposalDataSource: ProposalDataSource = ProposalDataSourceImpl(
    proposalAPI: ProposalAPIClient(),
    userService: userService
)

// 💡 Note:
// For avoid to `@StateObject` bugs in iOS and macOS.

private let proposalListViewModelAll = ProposalListViewModel(
    globalFilter: { _ in true },
    authState: authState,
    dataSource: proposalDataSource
)

private let proposalListViewModelStared = ProposalListViewModel(
    globalFilter: { $0.star },
    authState: authState,
    dataSource: proposalDataSource
)

//
// 💾 Storage
//
private let storageSelectedProposalIDAll =
    UserDefaultStorage<String?>(key: "selectedProposalIDAll", nil)
private let storageSelectedProposalIDStared =
    UserDefaultStorage<String?>(key: "selectedProposalIDStared", nil)

//
// 💻 Root view
//
public struct RootView: View {
    @AppStorage("selectedTab") private var selectedTab: Item = .all

    #if os(macOS)
    // Note:
    // Adopt to data type of List's `selection`.
    private var selectionHandler: Binding<Item?> {
        .init(
            get: { self.selectedTab },
            set: {
                if let value = $0 {
                    self.selectedTab = value
                }
            }
        )
    }
    #else
    @State private var tappedTwice: Bool = false

    // Note:
    // For scroll to top when tab is tapped.
    private var selectionHandler: Binding<Item> {
        .init(
            get: { self.selectedTab },
            set: {
                if $0 == self.selectedTab {
                    tappedTwice = true
                }
                self.selectedTab = $0
            }
        )
    }
    #endif

    public init() {}

    public var body: some View {
        content()
            .environmentObject(authState)
            .task {
                await authState.onInitialize()
                await proposalDataSource.onInitialize()
            }
            .onOpenURL { url in
                #if os(iOS)
                GIDSignIn.sharedInstance.handle(url)
                #endif
            }
    }

    func content() -> some View {
        #if os(macOS)
        NavigationView {
            List(selection: selectionHandler) {
                //
                // All Proposals
                //
                NavigationLink {
                    NavigationView {
                        allView()
                    }
                } label: {
                    Label("All", systemImage: "list.bullet")
                }
                .itemTag(.all)

                //
                // Stared
                //
                NavigationLink {
                    NavigationView {
                        staredView()
                    }
                } label: {
                    Label { Text("Stared") } icon: {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                    }
                }
                .itemTag(.star)
            }
            .listStyle(SidebarListStyle())
        }
        .appToolbar()
        #else
        ScrollViewReader { proxy in
            TabView(selection: selectionHandler) {
                //
                // All Proposals
                //
                NavigationView {
                    allView()
                    noneSelectedView()
                }
                .tabItem {
                    Label("All", systemImage: "list.bullet")
                }
                .itemTag(.all)

                //
                // Stared
                //
                NavigationView {
                    staredView()
                    noneSelectedView()
                }
                .tabItem {
                    Label("Shared", systemImage: "star.fill")
                }
                .itemTag(.star)
            }
            .onChange(of: tappedTwice) { tapped in
                if tapped {
                    withAnimation {
                        proxy.scrollTo(self.selectedTab.scrollToTopID)
                    }
                    tappedTwice = false
                }
            }
        }
        #endif
    }

    func allView() -> some View {
        ProposalListContainerView()
            .environmentObject(proposalListViewModelAll)
            .environmentObject(storageSelectedProposalIDAll)
        #if os(iOS)
            .navigationTitle("All Proposals")
            .scrollToTop(.all)
            .appToolbar()
        #endif
    }

    func staredView() -> some View {
        ProposalListContainerView()
            .environmentObject(proposalListViewModelStared)
            .environmentObject(storageSelectedProposalIDStared)
        #if os(iOS)
            .navigationTitle("Stared")
            .scrollToTop(.star)
            .appToolbar()
        #endif
    }

    // Note: show when no selected on iPad.
    func noneSelectedView() -> some View {
        Text("Please select proposal from sidebar.")
    }
}

// MARK: Private

private extension View {
    func scrollToTop(_ item: Item) -> some View {
        environment(\.scrollToTopID, item.scrollToTopID)
    }
}

private extension View {
    func itemTag(_ tag: Item) -> some View {
        // ⚠️ SwiftUI Bug:
        // iOS では型レベル（Optional<Item>）で一致させないと動かないが、
        // macOS では逆に型レベルで一致させると動かない。
        // #if os(iOS)
        // self.tag(Optional.some(tag))
        // #else
        // self.tag(tag)
        // #endif
        self.tag(tag)
    }
}
