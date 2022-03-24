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
    @State private var tappedTwice: Bool = false

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
                    Label {
                        Text("All")
                    } icon: {
                        Image(systemName: "list.bullet")
                    }
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
                    Label {
                        Text("Stared")
                    } icon: {
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

                    // Note: show when no selected on iPad.
                    Text("Please select proposal from sidebar.")
                }
                .tabItem {
                    Label {
                        Text("All")
                    } icon: {
                        Image(systemName: "list.bullet")
                    }
                }
                .itemTag(.all)

                //
                // Stared
                //
                NavigationView {
                    staredView()

                    // Note: show when no selected on iPad.
                    Text("Please select proposal from sidebar.")
                }
                .tabItem {
                    Label {
                        Text("Stared")
                    } icon: {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                    }
                }
                .itemTag(.star)
            }
            .onChange(of: tappedTwice, perform: { tapped in
                if tapped {
                    withAnimation {
                        proxy.scrollTo(self.selectedTab.scrollToTopID)
                    }
                    tappedTwice = false
                }
            })
        }
        #endif
    }

    func allView() -> some View {
        ProposalListContainerView()
            .environmentObject(proposalListViewModelAll)
            .environmentObject(storageSelectedProposalIDAll)
        #if os(iOS)
            .environment(\.scrollToTopID, Item.all.scrollToTopID)
            .navigationTitle("All Proposals")
            .appToolbar()
        #endif
    }
    
    func staredView() -> some View {
        ProposalListContainerView()
            .environmentObject(proposalListViewModelStared)
            .environmentObject(storageSelectedProposalIDStared)
        #if os(iOS)
            .environment(\.scrollToTopID, Item.star.scrollToTopID)
            .navigationTitle("Stared")
            .appToolbar()
        #endif
    }
}
