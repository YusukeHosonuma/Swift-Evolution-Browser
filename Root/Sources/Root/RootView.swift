//
//  ContentView.swift
//  Shared
//
//  Created by 細沼祐介 on 2022/03/09.
//

import SwiftUI
import Proposal
import Auth

#if os(iOS)
import GoogleSignIn
#endif

fileprivate enum Item: Hashable {
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

fileprivate extension View {
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
    )}
        
    public init() {}
    
    public var body: some View {
        content()
            .environmentObject(authState)
            .environment(\.ProposalDataSource, proposalDataSource)
            .task {
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
                    menuItemAll()
                }
                .tag(Item.all)

                //
                // Stared
                //
                NavigationLink {
                    NavigationView {
                        ProposalListContainerView()
                            .environmentObject(proposalListViewModelStared)
                    }
                } label: {
                    menuItemStared()
                }
                .tag(Item.star)
                
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
                        .navigationBarTitleDisplayMode(.inline)
                        .appToolbar()
                    
                    // Note: show when no selected.
                    Text("Please select proposal from sidebar.")
                }
                .tabItem {
                    menuItemAll()
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
                        .navigationBarTitleDisplayMode(.inline)
                        .appToolbar()
                    
                    // Note: show when no selected.
                    Text("Please select proposal from sidebar.")
                }
                .tabItem {
                    menuItemStared()
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
    
    func menuItemAll() -> some View {
        Label {
            Text("All")
        } icon: {
            Image(systemName: "list.bullet")
        }
    }
    
    func menuItemStared() -> some View {
        Label {
            Text("Stared")
        } icon: {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
        }
    }
}
