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
    private let _component: RootComponent
    
    public init(component: RootComponent) {
        _component = component
    }

    public var body: some View {
        content
            .environment(\.authState, _component.authState)
            .environment(\.proposalStore, _component.proposalComponent.proposalStore)
            .task {
                await _component.onInitialize()
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
            List {
                NavigationLink(destination: AllProposalListView()) {
                    HStack {
                        Image(systemSymbol: .listBullet)
                        Text("All")
                    }
                }
                NavigationLink(destination: StaredProposalListView()) {
                    HStack {
                        Image(systemSymbol: .starFill)
                        Text("Stared")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .appToolbar()
        }
        #else
        TabView {
            NavigationView {
                AllProposalListView().appToolbar()
            }
            .tabItem {
                Image(systemSymbol: .listBullet)
            }
            NavigationView {
                StaredProposalListView().appToolbar()
            }
            .tabItem {
                Image(systemSymbol: .starFill)
            }
        }
        #endif
    }
}
