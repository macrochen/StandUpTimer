# StandUp Timer 实现计划

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** 构建一款 macOS 菜单栏久坐提醒应用，通过三阶段循环计时促进健康工作习惯。

**Architecture:** SwiftUI + MenuBarExtra 实现菜单栏常驻，@Observable 管理状态，UserDefaults 持久化配置。

**Tech Stack:** SwiftUI, macOS 13+, Swift 5.9+

---

### Task 1: 创建 Xcode 项目结构

**Objective:** 初始化 SwiftUI macOS 项目，配置为菜单栏应用

**Step 1: 创建项目目录**
```bash
mkdir -p ~/workspace/StandUpTimer
cd ~/workspace/StandUpTimer
```

**Step 2: 创建 Package.swift（SPM 方式）**
```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "StandUpTimer",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "StandUpTimer",
            path: "Sources"
        )
    ]
)
```

**Step 3: 创建目录结构**
```bash
mkdir -p Sources/Models
mkdir -p Sources/ViewModels
mkdir -p Sources/Views
mkdir -p Sources/Storage
```

**Step 4: 验证**
```bash
swift build
# 预期: 编译成功（会报没有源文件，先忽略）
```

---

### Task 2: 创建 TimerPhase 模型

**Objective:** 定义三阶段枚举类型

**文件:** `Sources/Models/TimerPhase.swift`

**代码:**
```swift
import Foundation

enum TimerPhase: String, CaseIterable {
    case sitting   = "sitting"
    case standing  = "standing"
    case moving    = "moving"
    
    var icon: String {
        switch self {
        case .sitting:  return "🪑"
        case .standing: return "🧍"
        case .moving:   return "🚶"
        }
    }
    
    var label: String {
        switch self {
        case .sitting:  return "坐着"
        case .standing: return "站立"
        case .moving:   return "活动"
        }
    }
    
    var alertMessage: String {
        switch self {
        case .sitting:  return "可以坐下了，继续加油 🪑"
        case .standing: return "该站起来了！久坐伤身 🧍"
        case .moving:   return "活动一下，走两步 🚶"
        }
    }
    
    var next: TimerPhase {
        switch self {
        case .sitting:  return .standing
        case .standing: return .moving
        case .moving:   return .sitting
        }
    }
}
```

**验证:** `swift build` 编译通过

---

### Task 3: 创建 SettingsStore

**Objective:** 使用 UserDefaults 持久化用户配置

**文件:** `Sources/Storage/SettingsStore.swift`

**代码:**
```swift
import Foundation

class SettingsStore {
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let sittingDuration = "sittingDuration"
        static let standingDuration = "standingDuration"
        static let movingDuration = "movingDuration"
    }
    
    // 默认值：坐20分钟，站8分钟，活动2分钟
    var sittingDuration: Int {
        get { defaults.object(forKey: Keys.sittingDuration) as? Int ?? 20 }
        set { defaults.set(newValue, forKey: Keys.sittingDuration) }
    }
    
    var standingDuration: Int {
        get { defaults.object(forKey: Keys.standingDuration) as? Int ?? 8 }
        set { defaults.set(newValue, forKey: Keys.standingDuration) }
    }
    
    var movingDuration: Int {
        get { defaults.object(forKey: Keys.movingDuration) as? Int ?? 2 }
        set { defaults.set(newValue, forKey: Keys.movingDuration) }
    }
    
    func duration(for phase: TimerPhase) -> Int {
        switch phase {
        case .sitting:  return sittingDuration
        case .standing: return standingDuration
        case .moving:   return movingDuration
        }
    }
    
    func reset() {
        sittingDuration = 20
        standingDuration = 8
        movingDuration = 2
    }
}
```

**验证:** `swift build` 编译通过

---

### Task 4: 创建 TimerManager

**Objective:** 核心计时逻辑，管理倒计时和阶段切换

**文件:** `Sources/ViewModels/TimerManager.swift`

**代码:**
```swift
import Foundation
import SwiftUI

@Observable
class TimerManager {
    var currentPhase: TimerPhase = .sitting
    var timeRemaining: Int = 0
    var isRunning: Bool = false
    var showAlert: Bool = false
    
    private var timer: Timer?
    private let settings: SettingsStore
    
    init(settings: SettingsStore) {
        self.settings = settings
        self.timeRemaining = settings.duration(for: .sitting)
    }
    
    var timeDisplay: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.showAlert = true
            }
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
    }
    
    func resume() {
        start()
    }
    
    func nextPhase() {
        currentPhase = currentPhase.next
        timeRemaining = settings.duration(for: currentPhase)
        showAlert = false
        start()
    }
    
    func skipToNext() {
        timer?.invalidate()
        nextPhase()
    }
    
    func reset() {
        timer?.invalidate()
        isRunning = false
        currentPhase = .sitting
        timeRemaining = settings.duration(for: .sitting)
        showAlert = false
    }
}
```

**验证:** `swift build` 编译通过

---

### Task 5: 创建 MenuBarView

**Objective:** 菜单栏下拉内容视图

**文件:** `Sources/Views/MenuBarView.swift`

**代码:**
```swift
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
```

**验证:** `swift build` 编译通过

---

### Task 6: 创建 SettingsView

**Objective:** 设置窗口，调整各阶段时长

**文件:** `Sources/Views/SettingsView.swift`

**代码:**
```swift
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
```

**注意:** TimerManager 需要暴露 settings 属性，或者在 SettingsView 中使用独立的 SettingsStore。

**验证:** `swift build` 编译通过

---

### Task 7: 创建 AlertView

**Objective:** 阶段切换弹窗

**文件:** `Sources/Views/AlertView.swift`

**代码:**
```swift
import SwiftUI

struct AlertView: View {
    let phase: TimerPhase
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(phase.icon)
                .font(.system(size: 48))
            
            Text(phase.alertMessage)
                .font(.title2)
            
            Button("确认，开始\(phase.label)") {
                onConfirm()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(30)
    }
}
```

**验证:** `swift build` 编译通过

---

### Task 8: 创建 StandUpTimerApp 主入口

**Objective:** App 入口，配置 MenuBarExtra

**文件:** `Sources/StandUpTimerApp.swift`

**代码:**
```swift
import SwiftUI

@main
struct StandUpTimerApp: App {
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
        
        // 阶段切换弹窗
        WindowGroup("提醒") {
            if let timer = timerManager {
                AlertView(phase: timer.currentPhase.next) {
                    timer.nextPhase()
                }
                .frame(width: 300, height: 200)
            }
        }
        .defaultSize(width: 300, height: 200)
    }
    
    init() {
        let settings = SettingsStore()
        _settings = State(initialValue: settings)
        _timerManager = State(initialValue: TimerManager(settings: settings))
    }
}
```

**验证:** `swift build` 编译通过

---

### Task 9: 集成弹窗显示逻辑

**Objective:** 当 timer 到期时自动弹出提醒窗口

**修改:** `Sources/StandUpTimerApp.swift`

**关键逻辑:**
- 监听 `timerManager.showAlert`
- 当 `showAlert == true` 时显示弹窗
- 使用 `.alert()` modifier 或独立 WindowGroup

**验证:** 运行应用，等待倒计时结束，确认弹窗出现

---

### Task 10: 启动计时器并测试完整流程

**Objective:** 确保应用启动后自动开始计时

**修改:** `Sources/StandUpTimerApp.swift` 的 `onAppear`

**代码:**
```swift
.onAppear {
    timerManager?.start()
}
```

**验证:**
1. `swift run` 启动应用
2. 菜单栏出现 🪑 图标
3. 点击图标看到倒计时
4. 等待倒计时结束，弹窗出现
5. 点击确认，进入下一阶段
6. 循环正常

---

### Task 11: 打包为 .app 并配置 LSUIElement

**Objective:** 配置为纯菜单栏应用（不显示 Dock 图标）

**Step 1: 创建 Info.plist**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
```

**Step 2: 更新 Package.swift 加入资源**
```swift
.executableTarget(
    name: "StandUpTimer",
    path: "Sources",
    resources: [.process("Resources")]
)
```

**验证:** 运行后不显示 Dock 图标，只在菜单栏显示

---

### Task 12: 最终测试与清理

**Objective:** 完整功能验证

**测试清单:**
- [ ] 应用启动，菜单栏显示 🪑 图标
- [ ] 点击图标显示下拉菜单，有倒计时
- [ ] 暂停/继续功能正常
- [ ] 跳过功能正常
- [ ] 设置窗口可打开，能修改时长
- [ ] 设置保存后重启应用仍然生效
- [ ] 倒计时结束弹窗提醒
- [ ] 确认后进入下一阶段
- [ ] 三阶段循环正常
- [ ] 退出功能正常

**完成:**
```bash
cd ~/workspace/StandUpTimer
git init
git add .
git commit -m "feat: StandUp Timer v1.0 - macOS 久坐提醒应用"
```
