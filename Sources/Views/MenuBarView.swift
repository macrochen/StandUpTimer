import SwiftUI

struct MenuBarView: View {
    @ObservedObject var timer: TimerManager
    
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
            
            // 设置按钮 — 用独立窗口打开
            Button("⚙ 设置") {
                SettingsWindowController.shared.show(timer: timer)
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
    }
}
