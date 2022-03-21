//
//  ContentView.swift
//  Shared
//
//  Created by Yusuke Hosonuma on 2022/03/09.
//

import Auth
import Proposal
import SwiftUI

#if os(iOS)
import GoogleSignIn
#endif

private enum Item: Hashable {
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
    func itemTag(_ tag: Item?) -> some View {
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
// 💻 Root
//

public struct RootView: View {
    @State private var selection: Item? = .all
    @State private var tappedTwice: Bool = false

    // Note:
    // For scroll to top when tab is tapped.
    private var selectionHandler: Binding<Item?> { Binding(
        get: { self.selection },
        set: {
            if $0 == self.selection {
                tappedTwice = true
            }
            self.selection = $0
        }
    ) }

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
            List(selection: $selection) {
                //
                // All Proposals
                //
                NavigationLink {
                    NavigationView {
                        ProposalListContainerView()
                            .environmentObject(proposalListViewModelAll)
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
                        ProposalListContainerView()
                            .environmentObject(proposalListViewModelStared)
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
                    ProposalListContainerView()
                        .environment(\.scrollToTopID, Item.all.scrollToTopID)
                        .environmentObject(proposalListViewModelAll)
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
                if let selection = self.selection, tapped {
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
