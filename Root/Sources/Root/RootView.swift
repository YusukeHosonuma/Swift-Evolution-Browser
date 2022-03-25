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

private enum Item: Int {
    case all
    case star
    case setting
}

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

    private let component = Component.shared

    public init() {}

    public var body: some View {
        content()
            .environmentObject(component.authState)
            .task {
                await component.ignite()
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
            List {
                //
                // 📝 All Proposals
                //
                NavigationLink(tag: Item.all, selection: selectionHandler, destination: {
                    allProposalView()
                }) {
                    Label("All", systemImage: "list.bullet")
                }

                //
                // ⭐️ Stared
                //
                NavigationLink(tag: Item.star, selection: selectionHandler, destination: {
                    staredView()
                }) {
                    Label { Text("Stared") } icon: {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                    }
                }

                //
                // ⚙️ Setting
                //
                NavigationLink(tag: Item.setting, selection: selectionHandler, destination: {
                    SettingView()
                }) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .listStyle(SidebarListStyle())
        }
        .appToolbar()
        #else
        ScrollViewReader { proxy in
            TabView(selection: selectionHandler) {
                //
                // 📝 All Proposals
                //
                allProposalView()
                    .tabItem {
                        Label("All", systemImage: "list.bullet")
                    }
                    .itemTag(.all)

                //
                // ⭐️ Stared
                //
                staredView()
                    .tabItem {
                        Label("Shared", systemImage: "star.fill")
                    }
                    .itemTag(.star)

                //
                // ⚙️ Setting
                //
                NavigationView {
                    SettingView()
                        .navigationTitle("Settings")
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .itemTag(.setting)
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

    func allProposalView() -> some View {
        NavigationView {
            ProposalListContainerView()
                .environmentObject(component.proposalListViewModelAll)
                .environmentObject(component.storageSelectedProposalIDAll)
            #if os(iOS)
                .navigationTitle("All Proposals")
                .scrollToTop(.all)
                .appToolbar()
            #endif

            #if os(iOS)
            noneSelectedView()
            #endif
        }
    }

    func staredView() -> some View {
        NavigationView {
            ProposalListContainerView()
                .environmentObject(component.proposalListViewModelStared)
                .environmentObject(component.storageSelectedProposalIDStared)
            #if os(iOS)
                .navigationTitle("Stared")
                .scrollToTop(.star)
                .appToolbar()
            #endif

            #if os(iOS)
            noneSelectedView()
            #endif
        }
    }

    // 💡 Note: Show when no selected on iPad.
    func noneSelectedView() -> some View {
        Text("Please select proposal from sidebar.")
    }
}

// MARK: Private

private extension Item {
    var scrollToTopID: String {
        switch self {
        case .all:
            return "SCROLL_TO_TOP_ALL"
        case .star:
            return "SCROLL_TO_TOP_STAR"
        case .setting:
            preconditionFailure()
        }
    }
}

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
