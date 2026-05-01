import SwiftUI

struct SettingsView: View {
    @Bindable var timer: TimerManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var sittingMinutes: String = ""
    @State private var standingMinutes: String = ""
    @State private var movingMinutes: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("StandUp Timer 设置")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("🪑 坐着办公时长：")
                        .frame(width: 140, alignment: .trailing)
                    TextField("", text: $sittingMinutes)
                        .frame(width: 60)
                    Text("分钟")
                }
                
                HStack {
                    Text("🧍 站立时长：")
                        .frame(width: 140, alignment: .trailing)
                    TextField("", text: $standingMinutes)
                        .frame(width: 60)
                    Text("分钟")
                }
                
                HStack {
                    Text("🚶 活动时长：")
                        .frame(width: 140, alignment: .trailing)
                    TextField("", text: $movingMinutes)
                        .frame(width: 60)
                    Text("分钟")
                }
            }
            
            HStack {
                Button("重置默认") {
                    sittingMinutes = "20"
                    standingMinutes = "8"
                    movingMinutes = "2"
                }
                
                Spacer()
                
                Button("取消") {
                    dismiss()
                }
                
                Button("保存") {
                    saveSettings()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 320)
        .onAppear {
            loadSettings()
        }
    }
    
    private func loadSettings() {
        sittingMinutes = "\(timer.settings.sittingDuration)"
        standingMinutes = "\(timer.settings.standingDuration)"
        movingMinutes = "\(timer.settings.movingDuration)"
    }
    
    private func saveSettings() {
        if let val = Int(sittingMinutes), val > 0 {
            timer.settings.sittingDuration = val
        }
        if let val = Int(standingMinutes), val > 0 {
            timer.settings.standingDuration = val
        }
        if let val = Int(movingMinutes), val > 0 {
            timer.settings.movingDuration = val
        }
    }
}
