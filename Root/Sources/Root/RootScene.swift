//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/30.
//

import SwiftUI

public struct RootScene: Scene {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    public init() {}

    public var body: some Scene {
        WindowGroup {
            RootView()
        }
        #if os(macOS)
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button("About") {
                    appDelegate.showAboutPanel()
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("Acknowledgments") {
                    appDelegate.showAcknowledgmentPanel()
                }
            }
        }
        #endif
    }
}

// ref: https://stackoverflow.com/questions/64624261/swiftui-change-about-view-in-macos-app
#if os(macOS)
private class AppDelegate: NSObject, NSApplicationDelegate {
    private var aboutBoxWindowController: NSWindowController?
    private var acknowledgmentWindowController: NSWindowController?

    func showAboutPanel() {
        if aboutBoxWindowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .miniaturizable, /* .resizable,*/ .titled]
            let window = NSWindow()
            window.styleMask = styleMask
            window.title = ""
            window.contentView = NSHostingView(rootView: AboutView())
            window.center()
            aboutBoxWindowController = NSWindowController(window: window)
        }

        aboutBoxWindowController?.showWindow(aboutBoxWindowController?.window)
    }

    func showAcknowledgmentPanel() {
        if acknowledgmentWindowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .miniaturizable, /* .resizable,*/ .titled]
            let window = NSWindow()
            window.styleMask = styleMask
            window.title = "Acknowledgments"
            window.contentView = NSHostingView(rootView: AcknowledgmentsView())
            window.center()
            acknowledgmentWindowController = NSWindowController(window: window)
        }

        acknowledgmentWindowController?.showWindow(acknowledgmentWindowController?.window)
    }
}
#endif
