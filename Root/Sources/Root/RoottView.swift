//
//  ContentView.swift
//  Shared
//
//  Created by 細沼祐介 on 2022/03/09.
//

import SwiftUI
import Proposal
import SFSafeSymbols
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
    func itemTag(_ tag: Item) -> some View {
        self.tag(tag)
    }
}

// Global Objects

private let authState = AuthState()
private let proposalStore: ProposalStore = SharedProposal(
    proposalAPI: ProposalAPIClient(),
    authState: authState
)

public struct RootView: View {
    @State private var selection: Item = .all
    @State private var tappedTwice: Bool = false
    
    private var selectionHandler: Binding<Item> { Binding(
        get: { self.selection },
        set: {
            if $0 == self.selection {
                tappedTwice = true
            }
            self.selection = $0
        }
    )}
    
    public var body: some View {
        content()
            .environmentObject(authState)
            .environment(\.proposalStore, proposalStore)
            .task {
                await proposalStore.onInitialize()
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
                NavigationLink {
                    NavigationView {
                        AllProposalListView()
                    }
                } label: {
                    menuItemAll()
                }
                .tag(Item.all)

                NavigationLink {
                    NavigationView {
                        StaredProposalListView()
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
                NavigationView {
                    AllProposalListView(scrollToTopID: Item.all.scrollToTopID)
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

                NavigationView {
                    StaredProposalListView(scrollToTopID: Item.star.scrollToTopID)
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
                if tapped {
                    withAnimation {
                        proxy.scrollTo(self.selection.scrollToTopID)
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
            Image(systemSymbol: .listBullet)
        }
    }
    
    func menuItemStared() -> some View {
        Label {
            Text("Stared")
        } icon: {
            Image(systemSymbol: .starFill)
                .foregroundColor(.yellow)
        }
    }
}
