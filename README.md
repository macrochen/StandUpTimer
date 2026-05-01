# StandUp Timer 🪑🧍🚶

macOS 菜单栏久坐提醒应用。通过三阶段循环计时（坐着→站立→活动），提醒你避免久坐，促进健康工作习惯。

时间到了会有一只可爱的橘猫出现在屏幕上提醒你站起来 🐱

![demo](docs/screenshots/demo.png)

## 功能

- **三阶段循环计时**：坐着 → 站立 → 活动 → 循环
- **菜单栏常驻**：显示当前阶段图标（🪑 坐 / 🧍 站 / 🚶 走）和倒计时
- **猫咪动画提醒**：时间到了，全屏显示橘猫动画，自动消失
- **可配置时长**：各阶段时长、猫咪显示时长均可自定义
- **纯菜单栏应用**：不显示 Dock 图标

## 系统要求

- macOS 14.0 Sonoma 或更高版本
- Apple Silicon (arm64)

## 安装

### 方式一：从源码构建

```bash
git clone https://github.com/macrochen/StandUpTimer.git
cd StandUpTimer
./build_app.sh --open
```

构建产物在 `dist/StandUp Timer.app`，拖到 `/Applications` 即可安装。

### 方式二：直接运行

```bash
swift run
```

## 使用

1. 启动后菜单栏出现 🪑 图标，自动开始计时
2. 点击图标查看当前状态、暂停/继续、跳过阶段
3. ⚙ 设置可调整：
   - 坐着办公时长（默认 20 分钟）
   - 站立时长（默认 8 分钟）
   - 活动时长（默认 2 分钟）
   - 猫咪显示时长（默认 10 秒）
4. 设置中按回车键快速保存

## 项目结构

```
StandUpTimer/
├── Package.swift                    # SPM 配置
├── build_app.sh                     # 打包脚本
├── Sources/
│   ├── StandUpTimerApp.swift        # App 入口 + AppKit 监听
│   ├── Models/
│   │   └── TimerPhase.swift         # 阶段枚举（sitting/standing/moving）
│   ├── ViewModels/
│   │   └── TimerManager.swift       # 核心计时逻辑
│   ├── Storage/
│   │   └── SettingsStore.swift      # UserDefaults 持久化
│   ├── Views/
│   │   ├── MenuBarView.swift        # 菜单栏下拉内容
│   │   ├── SettingsView.swift       # 设置界面
│   │   ├── SettingsWindowController.swift  # 独立设置窗口
│   │   ├── AlertView.swift          # 原始弹窗（已弃用）
│   │   ├── CatOverlayView.swift     # 猫咪全屏浮层
│   │   ├── CatVideoPlayerView.swift # APNG 动画播放器
│   │   └── CatView.swift            # SwiftUI 手绘猫咪（备用）
│   └── Resources/
│       ├── Info.plist               # LSUIElement=true
│       └── Videos/
│           ├── neko1.png            # 橘猫动画 1 (APNG)
│           └── neko2.png            # 橘猫动画 2 (APNG)
└── docs/
    └── plans/                       # 设计文档
```

## 技术栈

- **UI**: SwiftUI + MenuBarExtra
- **状态管理**: ObservableObject + Combine
- **动画**: NSImageView 播放 APNG
- **提醒窗口**: AppKit NSWindow (borderless, screenSaver level)
- **构建**: Swift Package Manager
- **最低支持**: macOS 14, Swift 5.9+

## 猫咪素材来源

动画素材来自 Chrome 扩展 [Cat Gatekeeper](https://chrome.google.com/webstore/detail/elbikiflgfhjdjmficnigpeegjbhdidh)，原始格式为 VP9+alpha webm，转换为 APNG 以支持 macOS 原生播放。

## 许可

MIT
