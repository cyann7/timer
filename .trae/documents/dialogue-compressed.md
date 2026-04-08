# 对话压缩纪要（更新至 2026-04-08）

## 1. 项目目标
- 开发 macOS 自用番茄钟应用，首版范围为「番茄钟 + 数据统计」。
- 采用系统原生风格，菜单栏 + 主窗口双入口，面向 App Store 约束设计。

## 2. 已落地关键能力

### 核心引擎
- `PomodoroEngine`：核心状态机，支持开始/暂停/继续/停止/跳过
- `PomodoroCoordinator`：协调层，连接引擎、仓储、通知
- `StatisticsAggregator`：统计聚合，按需计算日/周数据

### 设置与通知
- `SettingsStore`：UserDefaults 持久化设置
- `UserNotificationScheduler`：真实通知实现，支持声音和系统通知
- `PomodoroSettings`：可配置项包括：
  - 专注时长、短休息、长休息、长休息周期
  - 声音开关、通知开关
  - 菜单栏显示：图标、时间、秒数

### 菜单栏功能
- 使用 `NSStatusItem` 实现自定义行为
- 单击：打开主窗口并获取焦点
- 右键：精简菜单（开始/暂停/继续 + 退出）
- 显示：番茄图标 🍅 + 剩余时间

### 阶段完成提醒（已重构）
- `PomodoroSnapshot.awaitingConfirmation`：等待用户确认状态
- `PhaseCompletionView`：原窗口内显示（不再弹出新窗口），左上角有返回按钮
- 引擎不自动转换阶段，需调用 `confirmAndContinue()` 或 `confirmAndStop()`

### 统计图表（已重构）
- 使用 Swift Charts 显示过去 7 天番茄数柱状图
- `StatisticsView` 移至独立页面，通过顶部分段控制器切换
- `ContentView` 使用 `Picker(.segmented)` 实现计时/统计页面切换

### 窗口行为（已更新）
- 主窗口固定 420x420
- 关闭窗口不退出应用，计时继续（`applicationShouldTerminateAfterLastWindowClosed` 返回 `false`）
- 点击 Dock 图标或菜单栏图标可重新打开窗口
- 使用 `Notification.Name.openMainWindow` 通知机制重新打开 SwiftUI Window

### 跳过功能（已增强）
- 在 idle 状态下（未运行、未暂停），如果当前阶段不是专注，可以跳过进入下一阶段
- `canSkipBeforeStart` 属性控制开始按钮旁的跳过按钮显示
- 引擎 `skip()` 方法支持 `autoStart` 参数，idle 状态跳过后不自动开始计时

## 3. 关键文件清单

### Swift Package (Sources/timer/)
```
Domain/Engine/PomodoroEngine.swift          # 核心状态机
Domain/Entities/PomodoroSettings.swift      # 设置模型
Domain/Entities/PomodoroPhase.swift         # 阶段枚举
Domain/Entities/FocusSession.swift          # 会话实体
Domain/UseCases/StatisticsAggregator.swift  # 统计聚合
Features/Pomodoro/PomodoroCoordinator.swift # 协调层
Features/Settings/SettingsStore.swift       # 设置存储
Features/Statistics/StatisticsService.swift # 统计服务
Infrastructure/System/UserNotificationScheduler.swift # 通知实现
Infrastructure/Persistence/SwiftDataSessionRepository.swift # 持久化
```

### App Target (TimerApp/)
```
TimerAppApp.swift          # 应用入口，AppDelegate，NSStatusItem
TimerAppViewModel.swift    # 视图模型，状态管理
ContentView.swift          # 主界面（带分段控制器切换计时/统计）
SettingsView.swift         # 设置界面
StatisticsView.swift       # 统计图表（Swift Charts）
PhaseCompletionView.swift  # 阶段完成视图（内嵌于主窗口）
MenuBarView.swift          # 菜单栏视图（精简版）
```

## 4. 技术实现要点

### 状态机逻辑（PomodoroEngine）
- `sync()` 检测时间到后设置 `awaitingConfirmation = true`，不自动转换
- `confirmAndContinue()` 确认并进入下一阶段
- `confirmAndStop()` 确认并重置到专注阶段
- `skip(autoStart:)` 跳过当前阶段，支持是否自动开始下一阶段
- 使用绝对结束时间戳，不依赖 ticker 累加

### 菜单栏实现（AppDelegate）
```swift
// 单击打开窗口，右键显示菜单
button.sendAction(on: [.leftMouseUp, .rightMouseUp])

@objc func statusBarClicked(_ sender: NSStatusBarButton) {
    if event.type == .rightMouseUp {
        showContextMenu(sender)  // 右键菜单
    } else {
        openMainWindow()          // 单击打开窗口
    }
}
```

### 窗口重新打开机制
```swift
// 通知定义
extension Notification.Name {
    static let openMainWindow = Notification.Name("openMainWindow")
}

// AppDelegate 中发送通知
NotificationCenter.default.post(name: .openMainWindow, object: nil)

// SwiftUI Window 中监听并打开
.onReceive(NotificationCenter.default.publisher(for: .openMainWindow)) { _ in
    openWindow(id: "main-window")
}
```

### 设置持久化
- 使用 UserDefaults + JSON 编码
- `PomodoroSettings` 实现 Codable
- ViewModel 的 @Published 属性通过 didSet 触发保存

## 5. 待办事项（TODO 文件）

### 已完成 ✅
- [x] 提醒：声音，通知，用户可设置
- [x] 番茄时间和休息时间用户可设置
- [x] 点击关闭窗口，结束整个软件
- [x] 点击标题小番茄，跳转到软件窗口
- [x] 再开始时，也可以点击跳过（开始按钮旁边加一个跳过按钮）
- [x] 结束提示不要弹出新窗口，而是在原来的窗口上变动。左上角加返回按钮
- [x] 关闭窗口不退出软件，只是关闭窗口，计时继续。点击标题栏或 Dock 图标窗口回来
- [x] 统计图表不放在计时页面，专门放在一个统计页面

### 待实现
- [ ] 设计一个 app logo

## 6. 构建与打包

### 构建命令
```bash
xcodebuild -scheme TimerApp -configuration Debug build
swift test  # 运行测试
```

### 打包为 App
```bash
xcodebuild -scheme TimerApp -configuration Release archive -archivePath /tmp/TimerApp.xcarchive
cp -R /tmp/TimerApp.xcarchive/Products/Applications/TimerApp.app ~/Desktop/
```

## 7. Git 提交历史
```
fdc8dcb Add menu bar enhancements, phase completion alerts, and statistics charts
df53ace Add settings and notification functionality
0be22de before claude code
c2a53cf Initial Commit
```

## 8. 注意事项
- 遵循 Agent.md 中的架构原则和技术决策
- 不在 Feature/UI 直接访问 SwiftData，必须通过仓储协议
- 菜单栏与主窗口共享 TimerAppViewModel 作为单一状态源
- 测试使用 `swift test`，共 4 个测试用例
