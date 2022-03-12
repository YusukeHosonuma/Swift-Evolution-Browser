//
//  ContentView.swift
//  Shared
//
//  Created by 細沼祐介 on 2022/03/09.
//

import SwiftUI
import Proposal

#if os(iOS)
import GoogleSignIn
#endif

public struct RootView: View {
    private let component: RootComponent

    enum Item {
        case all
        case star
    }

    @State var selectedItem: Item? = .all
    
    public init(component: RootComponent) {
        self.component = component
    }

    public var body: some View {
        content
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

    var content: some View {
        #if os(macOS)
        NavigationView {
            List(selection: $selectedItem) {
                NavigationLink(destination: AllProposalListView()) {
                    HStack {
                        Image(systemSymbol: .listBullet)
                        Text("All")
                    }
                }
                .tag(Item.all)
                NavigationLink(destination: StaredProposalListView()) {
                    HStack {
                        Image(systemSymbol: .starFill)
                        Text("Stared")
                    }
                }
                .tag(Item.star)
            }
            .listStyle(SidebarListStyle())
        }
        .appToolbar()
        #else
        TabView {
            NavigationView {
                AllProposalListView().appToolbar()
            }
            .tabItem {
                Image(systemSymbol: .listBullet)
            }
            .tag(Item.all)

            NavigationView {
                StaredProposalListView().appToolbar()
            }
            .tabItem {
                Image(systemSymbol: .starFill)
            }
            .tag(Item.star)
        }
        #endif
    }
}
