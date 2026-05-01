import SwiftUI
import AppKit
import Combine

/// 透明浮动窗口管理器 —— 猫咪提醒用
class FloatingAlertWindowController {
    private var window: NSWindow?
    private var isShowing = false

    func show(displaySeconds: Int, onDismiss: @escaping () -> Void) {
        guard !isShowing else { return }
        isShowing = true

        if let existing = window {
            existing.orderOut(nil)
            existing.close()
            window = nil
        }

        guard let screen = NSScreen.main else {
            isShowing = false
            return
        }

        let catView = CatOverlayView(displaySeconds: displaySeconds) { [weak self] in
            guard let self = self, self.isShowing else { return }
            self.isShowing = false
            self.closeWindow()
            onDismiss()
        }

        let hostingView = NSHostingView(rootView: catView)

        let win = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        win.contentView = hostingView
        win.isOpaque = false
        win.backgroundColor = .clear
        win.hasShadow = false
        win.level = .screenSaver
        win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        win.isReleasedWhenClosed = false
        win.setFrame(screen.frame, display: true)
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = win
    }

    private func closeWindow() {
        window?.orderOut(nil)
        window?.close()
        window = nil
    }

    func close() {
        isShowing = false
        closeWindow()
    }
}

/// AppKit 级别监听器 —— 不依赖 SwiftUI 视图渲染
class AlertObserver {
    private let timer: TimerManager
    private let settings: SettingsStore
    private let alertController: FloatingAlertWindowController
    private var cancellables = Set<AnyCancellable>()

    init(timer: TimerManager, settings: SettingsStore, alertController: FloatingAlertWindowController) {
        self.timer = timer
        self.settings = settings
        self.alertController = alertController

        timer.$showAlert
            .removeDuplicates()
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                // 如果正在重置，跳过
                guard !self.timer.isResetting else { return }
                let seconds = self.settings.catDisplaySeconds
                self.alertController.show(displaySeconds: seconds) {
                    self.timer.nextPhase()
                }
            }
            .store(in: &cancellables)
    }
}

@main
struct StandUpTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var settings = SettingsStore()
    @State private var timerManager: TimerManager?

    var body: some Scene {
        MenuBarExtra {
            if let timer = timerManager {
                MenuBarView(timer: timer)
            }
        } label: {
            if let timer = timerManager {
                Text("\(timer.currentPhase.icon)")
            } else {
                Text("🪑")
            }
        }
        .menuBarExtraStyle(.window)
    }

    init() {
        let settings = SettingsStore()
        _settings = State(initialValue: settings)
        let timer = TimerManager(settings: settings)
        _timerManager = State(initialValue: timer)
        appDelegate.setup(timer: timer, settings: settings)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var observer: AlertObserver?
    private let alertController = FloatingAlertWindowController()

    func setup(timer: TimerManager, settings: SettingsStore) {
        observer = AlertObserver(timer: timer, settings: settings, alertController: alertController)
        timer.start()
    }
}
