//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/30.
//

import SwiftUI
import SwiftUICommon

#if DEBUG && os(iOS)
import SwiftUISimulator
#endif

public struct RootScene: Scene {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    #if DEBUG && os(iOS)
    @State private var isEnabledDebugFilename = false
    #endif

    public init() {}

    public var body: some Scene {
        WindowGroup {
            #if DEBUG && os(iOS)
            SimulatorView {
                Menu {
                    Toggle(isOn: $isEnabledDebugFilename) {
                        Label("Filename", symbol: "􀕹")
                    }
                } label: {
                    Label("Debug", symbol: "􀌜")
                }
            } content: {
                RootView()
                    .environment(\.simulatorDebugFilename, isEnabledDebugFilename)
            }
            #else
            RootView()
            #endif
        }
        #if os(macOS)
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button("About") {
                    appDelegate.showAboutWindow()
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("Acknowledgments") {
                    appDelegate.showAcknowledgmentWindow()
                }
            }
        }
        #endif
    }
}

// ref: https://stackoverflow.com/questions/64624261/swiftui-change-about-view-in-macos-app
#if os(macOS)
private final class AppDelegate: NSObject, NSApplicationDelegate {
    private let aboutWindow: WindowController = .init(title: "", content: AboutView())
    private let acknowledgmentWindow: WindowController = .init(title: "Acknowledgments", content: AcknowledgmentsView())

    func showAboutWindow() {
        aboutWindow.show()
    }

    func showAcknowledgmentWindow() {
        acknowledgmentWindow.show()
    }
}
#endif
