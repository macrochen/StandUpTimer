import SwiftUI
import AppKit

/// 独立设置窗口控制器 —— 不受 MenuBarExtra popover 影响
class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    func show(timer: TimerManager) {
        // 如果已经打开，前置即可
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView(timer: timer) { [weak self] in
            self?.close()
        }
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 360, height: 320)

        let win = NSWindow(
            contentRect: hostingView.frame,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "StandUp Timer 设置"
        win.contentView = hostingView
        win.isReleasedWhenClosed = false
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = win
    }

    func close() {
        window?.close()
        window = nil
    }
}
