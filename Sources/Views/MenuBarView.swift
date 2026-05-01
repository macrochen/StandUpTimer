import SwiftUI

struct MenuBarView: View {
    @Bindable var timer: TimerManager
    @State private var showSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 当前状态
            HStack {
                Text(timer.currentPhase.icon)
                Text("当前：\(timer.currentPhase.label)")
                Spacer()
                Text(timer.timeDisplay)
                    .monospacedDigit()
            }
            .padding(.horizontal)
            
            Divider()
            
            // 控制按钮
            HStack {
                Button(timer.isRunning ? "⏸ 暂停" : "▶ 继续") {
                    if timer.isRunning {
                        timer.pause()
                    } else {
                        timer.resume()
                    }
                }
                
                Spacer()
                
                Button("⏭ 跳过") {
                    timer.skipToNext()
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // 设置按钮
            Button("⚙ 设置") {
                showSettings = true
            }
            .padding(.horizontal)
            
            Divider()
            
            // 退出
            Button("退出 StandUp Timer") {
                NSApplication.shared.terminate(nil)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showSettings) {
            SettingsView(timer: timer)
        }
    }
}
