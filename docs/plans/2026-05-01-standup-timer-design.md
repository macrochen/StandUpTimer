# StandUp Timer - macOS 久坐提醒应用设计文档

## 概述

一款 macOS 菜单栏应用，通过三阶段循环计时（坐着→站立→活动）提醒用户避免久坐，促进健康工作习惯。

## 核心功能

- **三阶段循环计时**：坐着(可配置) → 站立(可配置) → 活动(可配置) → 循环
- **菜单栏常驻**：显示当前阶段图标（🪑 坐 / 🧍 站 / 🚶 走）
- **阶段切换弹窗**：强制弹窗提醒，点击确认进入下一阶段
- **简易设置**：调整各阶段时长

## 用户流程

1. 启动后菜单栏出现图标，默认从"坐着"阶段开始倒计时
2. 倒计时结束 → 弹窗提醒"该站起来了！"
3. 用户点击确认 → 进入"站立"阶段倒计时
4. 站立结束 → 弹窗提醒"活动一下！"
5. 活动结束 → 弹窗提醒"可以坐下了" → 回到步骤 1 循环

## 技术栈

- **UI 框架**：SwiftUI + MenuBarExtra（macOS 13+）
- **状态管理**：@Observable (Swift 5.9+)
- **最低支持**：macOS 13 Ventura

## 文件结构

```
StandUpTimer/
├── StandUpTimerApp.swift      # App 入口，MenuBarExtra 配置
├── Models/
│   └── TimerPhase.swift       # 阶段枚举（sitting/standing/moving）
├── ViewModels/
│   └── TimerManager.swift     # 核心计时逻辑 + 状态管理
├── Views/
│   ├── MenuBarView.swift      # 菜单栏下拉内容
│   ├── SettingsView.swift     # 设置窗口
│   └── AlertView.swift        # 阶段切换弹窗
└── Storage/
    └── SettingsStore.swift    # UserDefaults 存储用户配置
```

## 核心组件

| 组件 | 职责 |
|------|------|
| TimerManager | 管理倒计时、阶段切换、触发通知 |
| SettingsStore | 读写用户配置（各阶段时长） |
| MenuBarView | 菜单栏图标 + 下拉菜单（设置/退出） |
| AlertView | 阶段结束时的模态弹窗 |

## 数据流

```
TimerManager (@Observable)
  ├── currentPhase: TimerPhase
  ├── timeRemaining: Int
  ├── isRunning: Bool
  └── 方法: start(), pause(), reset(), nextPhase()
        ↓
MenuBarExtra 监听 currentPhase → 切换图标
AlertView 监听 timeRemaining == 0 → 弹窗
```

## 阶段状态机

```
┌─────────┐   时间到    ┌──────────┐   时间到    ┌──────────┐
│ Sitting │ ─────────→ │ Standing │ ─────────→ │ Moving  │
│  🪑     │            │  🧍      │            │  🚶     │
└─────────┘            └──────────┘            └──────────┘
     ↑                                              │
     └──────────────── 弹窗确认 ←───────────────────┘
```

## 弹窗文字

- 坐→站："该站起来了！久坐伤身 🧍"
- 站→走："活动一下，走两步 🚶"
- 走→坐："可以坐下了，继续加油 🪑"

## 设置界面

```
┌────────────────────────────┐
│      StandUp Timer 设置      │
├────────────────────────────┤
│  坐着办公时长：  [ 20 ] 分钟  │
│  站立时长：      [  8 ] 分钟  │
│  活动时长：      [  2 ] 分钟  │
├────────────────────────────┤
│     [ 保存 ]    [ 重置 ]     │
└────────────────────────────┘
```

## 菜单栏下拉

```
┌─────────────────────┐
│  当前：🪑 坐着  18:32 │
│  ─────────────────  │
│  ⏸ 暂停 / ▶ 继续    │
│  ⏭ 跳过当前阶段     │
│  ⚙ 设置             │
│  ─────────────────  │
│  退出 StandUp Timer  │
└─────────────────────┘
```
