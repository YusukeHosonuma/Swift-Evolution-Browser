//
//  ContentView.swift
//  Shared
//
//  Created by 細沼祐介 on 2022/03/09.
//

import SwiftUI
import Proposal
import SFSafeSymbols

#if os(iOS)
import GoogleSignIn
#endif

fileprivate enum Item {
    case all
    case star
}

fileprivate extension View {
    func itemTag(_ tag: Item) -> some View {
        self.tag(tag)
    }
}

public struct RootView: View {
    private let component: RootComponent

    @State private var selectedItem: Item? = .all
    
    public init(component: RootComponent) {
        self.component = component
    }

    public var body: some View {
        content()
            .environment(\.authState, component.authState)
            .environment(\.proposalStore, component.proposalComponent.proposalStore)
            .task {
                await component.onInitialize()
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
            List(selection: $selectedItem) {
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
        TabView {
            NavigationView {
                AllProposalListView()
                    .navigationTitle("All Proposals")
                    .appToolbar()

                // Note: show when no selected.
                Text("Please select proposal from sidebar.")
            }
            .tabItem {
                menuItemAll()
            }
            .itemTag(.all)

            NavigationView {
                StaredProposalListView()
                    .navigationTitle("Stared")
                    .appToolbar()
            }
            .tabItem {
                menuItemStared()
            }
            .itemTag(.star)
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
