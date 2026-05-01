import SwiftUI

/// 监听 showAlert 并自动打开弹窗窗口
struct AlertTriggerView: View {
    let timer: TimerManager
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onChange(of: timer.showAlert) { _, newValue in
                if newValue {
                    openWindow(id: "alert")
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
    }
}

@main
struct StandUpTimerApp: App {
    @State private var settings = SettingsStore()
    @State private var timerManager: TimerManager?
    
    var body: some Scene {
        MenuBarExtra {
            if let timer = timerManager {
                VStack {
                    MenuBarView(timer: timer)
                    AlertTriggerView(timer: timer)
                }
                .onAppear {
                    timer.start()
                }
            }
        } label: {
            if let timer = timerManager {
                Text("\(timer.currentPhase.icon)")
            } else {
                Text("🪑")
            }
        }
        .menuBarExtraStyle(.window)
        
        // 阶段切换弹窗
        Window("提醒", id: "alert") {
            if let timer = timerManager {
                AlertView(phase: timer.currentPhase.next) {
                    timer.nextPhase()
                    NSApp.keyWindow?.close()
                }
                .frame(width: 300, height: 200)
                .onAppear {
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
        .defaultSize(width: 300, height: 200)
        .windowResizability(.contentSize)
    }
    
    init() {
        let settings = SettingsStore()
        _settings = State(initialValue: settings)
        _timerManager = State(initialValue: TimerManager(settings: settings))
    }
}
