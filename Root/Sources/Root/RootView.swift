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

private enum Item: String, Hashable {
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

extension Item: StorageValue {
    var rawString: String { rawValue }
    init?(rawString: String?) {
        guard let rawString = rawString, let item = Item(rawValue: rawString) else { return nil }
        self = item
    }
}

private extension View {
    func itemTag(_ tag: Item) -> some View {
        // ⚠️ SwiftUI Bug:
        // iOS では型レベル（Optional<Item>）で一致させないと動かないが、
        // macOS では逆に型レベルで一致させると動かない。
        #if os(iOS)
        self.tag(Optional.some(tag))
        #else
        self.tag(tag)
        #endif
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
private let storageSelectedTab =
    UserDefaultStorage<Item>(key: "selectedTab", .all)
private let storageSelectedProposalIDAll =
    UserDefaultStorage<String>(key: "selectedProposalIDAll", nil)
private let storageSelectedProposalIDStared =
    UserDefaultStorage<String>(key: "selectedProposalIDStared", nil)

//
// 💻 Root view
//
public struct RootView: View {
    @State private var tappedTwice: Bool = false
    @ObservedObject private var selectedTab: UserDefaultStorage<Item> = storageSelectedTab

    #if os(iOS)
    // Note:
    // For scroll to top when tab is tapped.
    private var selectionHandler: Binding<Item?> { Binding(
        get: { self.selectedTab.value },
        set: {
            if $0 == self.selectedTab.value {
                tappedTwice = true
            }
            self.selectedTab.value = $0
        }
    ) }
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
            List(selection: $selectedTab.value) {
                //
                // All Proposals
                //
                NavigationLink {
                    NavigationView {
                        ProposalListContainerView()
                            .environmentObject(proposalListViewModelAll)
                            .environmentObject(storageSelectedProposalIDAll)
                    }
                } label: {
                    Label {
                        Text("All")
                    } icon: {
                        Image(systemName: "list.bullet")
                    }
                }
                // .tag(Item.all)
                .itemTag(.all)

                //
                // Stared
                //
                NavigationLink {
                    NavigationView {
                        ProposalListContainerView()
                            .environmentObject(proposalListViewModelStared)
                            .environmentObject(storageSelectedProposalIDStared)
                    }
                } label: {
                    Label {
                        Text("Stared")
                    } icon: {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                    }
                }
                // .tag(Item.star)
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
                    ProposalListContainerView()
                        .environment(\.scrollToTopID, Item.all.scrollToTopID)
                        .environmentObject(proposalListViewModelAll)
                        .environmentObject(storageSelectedProposalIDAll)
                        .navigationTitle("All Proposals")
                        .appToolbar()

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
                    ProposalListContainerView()
                        .environment(\.scrollToTopID, Item.star.scrollToTopID)
                        .environmentObject(proposalListViewModelStared)
                        .environmentObject(storageSelectedProposalIDStared)
                        .navigationTitle("Stared")
                        .appToolbar()

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
                if let selection = self.selectedTab.value, tapped {
                    withAnimation {
                        proxy.scrollTo(selection.scrollToTopID)
                    }
                    tappedTwice = false
                }
            })
        }
        #endif
    }
}
