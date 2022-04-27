//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/30.
//

import SwiftUI
import SwiftUICommon

#if DEBUG
import SwiftUISimulator
#endif

public struct RootScene: Scene {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    #if DEBUG
    @State private var isEnableDebugFilename = false
    #endif

    public init() {}

    public var body: some Scene {
        WindowGroup {
            #if DEBUG
            SimulatorView(debugMenu: {
                Toggle(isOn: $isEnableDebugFilename) {
                    Label("Debug View", systemImage: "ant.circle")
                }
            }) {
                RootView()
                    .environment(\.debugFilename, isEnableDebugFilename)
            }
            // SimulatorView(
            //     defaultDevices: [.iPhone11, .iPhone13ProMax], // Set<Device>
            //     defaultLocaleIdentifiers: ["it", "fr"], // Set<String>
            //     defaultCalendarIdentifiers: [.gregorian, .iso8601], // Set<Calendar.Identifier>
            //     defaultTimeZones: [.europeParis, .europeBerlin] // Set<TimeZones>
            // ) {
            //     RootView()
            // }
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
