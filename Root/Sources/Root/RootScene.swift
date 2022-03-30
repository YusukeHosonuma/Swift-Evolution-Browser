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
private final class AppDelegate: NSObject, NSApplicationDelegate {
    private var aboutPanel: Panel = .init(title: "", content: AboutView())
    private var acknowledgmentPanel: Panel = .init(title: "Acknowledgments", content: AcknowledgmentsView())

    func showAboutPanel() {
        aboutPanel.show()
    }

    func showAcknowledgmentPanel() {
        acknowledgmentPanel.show()
    }
}

private final class Panel<Content: View> {
    private var windowController: NSWindowController?

    init(title: String, content: Content) {
        if windowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .miniaturizable, /* .resizable,*/ .titled]
            let window = NSWindow()
            window.styleMask = styleMask
            window.title = title
            window.contentView = NSHostingView(rootView: content)
            window.center()
            windowController = NSWindowController(window: window)
        }
    }

    func show() {
        windowController?.showWindow(windowController?.window)
    }
}
#endif
