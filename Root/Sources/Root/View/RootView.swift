//
//  ContentView.swift
//  Shared
//
//  Created by Yusuke Hosonuma on 2022/03/09.
//

import Auth
import Core
import Defaults
import Proposal
import Setting
import SFReadableSymbols
import SwiftUI
#if os(iOS)
import GoogleSignIn
#endif

//
// 💻 Root view
//
public struct RootView: View {
    @Default(.selectedTab) private var selectedTab

    #if os(iOS)
    @State private var tappedTwice: Bool = false

    // Note:
    // For scroll to top when tab is tapped.
    private var selectionHandler: Binding<Item?> {
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
            .debugFilename()
    }

    func content() -> some View {
        #if os(macOS)
        NavigationView {
            List {
                //
                // 📝 All Proposals
                //
                NavigationLink(tag: Item.all, selection: $selectedTab, destination: {
                    allProposalView()
                }) {
                    Label(LocalizedStringKey("All"), symbol: "􀋲")
                }

                //
                // ⭐️ Stared
                //
                NavigationLink(tag: Item.star, selection: $selectedTab, destination: {
                    staredView()
                }) {
                    Label { Text(LocalizedStringKey("Star")) } icon: {
                        Image(symbol: "􀋃").foregroundColor(.yellow)
                    }
                }

                //
                // ⚙️ Setting
                //
                NavigationLink(tag: Item.setting, selection: $selectedTab, destination: {
                    SettingView()
                        .environmentObject(component.settingViewModel)
                }) {
                    Label(LocalizedStringKey("Settings"), symbol: "􀣋")
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
                        Label(LocalizedStringKey("All"), symbol: "􀋲")
                    }
                    .itemTag(.all)

                //
                // ⭐️ Stared
                //
                staredView()
                    .tabItem {
                        Label(LocalizedStringKey("Star"), symbol: "􀋃")
                    }
                    .itemTag(.star)

                //
                // ⚙️ Setting
                //
                NavigationView {
                    SettingView()
                        .navigationTitle(LocalizedStringKey("Settings"))
                        .environmentObject(component.settingViewModel)
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label(LocalizedStringKey("Settings"), symbol: "􀣋")
                }
                .itemTag(.setting)
            }
            .onChange(of: tappedTwice) { tapped in
                if tapped, let selected = self.selectedTab {
                    withAnimation {
                        proxy.scrollTo(selected.scrollToTopID)
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
                .navigationTitle(LocalizedStringKey("All Proposals"))
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
                .navigationTitle(LocalizedStringKey("Stared"))
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
        Text(LocalizedStringKey("Please select proposal from sidebar."))
    }
}

// MARK: Private

private extension Defaults.Keys {
    static let selectedTab = Key<Item?>("root-view.selected-tab", default: .all)
}

private enum Item: Int, Defaults.Serializable {
    case all
    case star
    case setting
}

private extension Item {
    var scrollToTopID: String {
        switch self {
        case .all:
            return "SCROLL_TO_TOP_ALL"
        case .star:
            return "SCROLL_TO_TOP_STAR"
        case .setting:
            return ""
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
        // 💡 Note: Adopt to selection's `Binding<T>` type.
        #if os(macOS)
        self.tag(tag)
        #else
        self.tag(Optional.some(tag))
        #endif
    }
}
