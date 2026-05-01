import SwiftUI

struct SettingsView: View {
    @ObservedObject var timer: TimerManager
    let onClose: () -> Void
    
    @State private var sittingMinutes: String = ""
    @State private var standingMinutes: String = ""
    @State private var movingMinutes: String = ""
    @State private var catSeconds: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("StandUp Timer 设置")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("🪑 坐着办公时长：")
                        .frame(width: 140, alignment: .trailing)
                    TextField("", text: $sittingMinutes, onCommit: saveAndClose)
                        .frame(width: 60)
                    Text("分钟")
                }
                
                HStack {
                    Text("🧍 站立时长：")
                        .frame(width: 140, alignment: .trailing)
                    TextField("", text: $standingMinutes, onCommit: saveAndClose)
                        .frame(width: 60)
                    Text("分钟")
                }
                
                HStack {
                    Text("🚶 活动时长：")
                        .frame(width: 140, alignment: .trailing)
                    TextField("", text: $movingMinutes, onCommit: saveAndClose)
                        .frame(width: 60)
                    Text("分钟")
                }
                
                Divider()
                
                HStack {
                    Text("🐱 猫咪显示时长：")
                        .frame(width: 140, alignment: .trailing)
                    TextField("", text: $catSeconds, onCommit: saveAndClose)
                        .frame(width: 60)
                    Text("秒")
                }
            }
            
            HStack {
                Button("重置默认") {
                    sittingMinutes = "20"
                    standingMinutes = "8"
                    movingMinutes = "2"
                    catSeconds = "10"
                }
                
                Spacer()
                
                Button("取消") {
                    onClose()
                }
                
                Button("保存并重启计时") {
                    saveAndClose()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 360)
        .onAppear {
            loadSettings()
        }
    }
    
    private func loadSettings() {
        let s = SettingsStore()
        sittingMinutes = "\(s.sittingDuration)"
        standingMinutes = "\(s.standingDuration)"
        movingMinutes = "\(s.movingDuration)"
        catSeconds = "\(s.catDisplaySeconds)"
    }
    
    private func saveAndClose() {
        if let val = Int(sittingMinutes), val > 0 {
            timer.settings.sittingDuration = val
        }
        if let val = Int(standingMinutes), val > 0 {
            timer.settings.standingDuration = val
        }
        if let val = Int(movingMinutes), val > 0 {
            timer.settings.movingDuration = val
        }
        if let val = Int(catSeconds), val >= 3 {
            timer.settings.catDisplaySeconds = val
        }
        timer.reset()
        timer.start()
        onClose()
    }
}
