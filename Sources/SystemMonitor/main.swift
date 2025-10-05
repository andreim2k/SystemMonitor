import SwiftUI
import AppKit
import Foundation

// Main entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Hide the app from the dock since we're a menu bar app
        NSApp.setActivationPolicy(.accessory)

        menuBarController = MenuBarController()
    }
}
