# TimerApp 开始动工实施计划

## Summary
- 目标：基于当前仓库现状，把 `timer` Swift Package 正式接入现有 `TimerApp` macOS App Target，完成可运行的首版界面（主窗口 + 菜单栏 + 本周统计），并消除当前入口与页面结构冲突。
- 范围：仅落地首版启动链路与 UI 绑定，不在本轮引入通知权限实装、SwiftData 持久化落地、Charts 统计可视化升级。
- 完成标准：工程仅保留一个 `@main` 入口；主窗口可执行开始/暂停/继续/跳过；菜单栏可见且状态同步；统计卡片可显示本周结果；现有包测试与 App 编译可通过。

## Current State Analysis
- 文档状态：
  - `/.trae/documents/agent.md` 已锁定固定技术决策（SwiftUI + macOS + 本地优先 + 菜单栏与主窗口单一状态源）。
  - `Docs/xcode-next-steps.md` 明确推荐接入 `Examples/XcodeStarter` 的 5 个文件并确保唯一 `@main`。
  - `/.trae/documents/dialogue-compressed.md` 记录了“同仓库持续开发”已确认，并给出下一步就是接入 Starter 模板。
- 代码状态：
  - 已存在 `TimerApp.xcodeproj` 与 `TimerApp/` App Target 目录。
  - 当前 App 仅有 `TimerApp/TimerAppApp.swift` + `TimerApp/ContentView.swift`，功能是极简“开始”按钮，尚未包含菜单栏与统计页。
  - `Examples/XcodeStarter/` 下已具备完整首版 5 文件模板，可直接承载主窗口、菜单栏与 ViewModel。
  - Package 核心能力（`PomodoroCoordinator`、`StatisticsService`、`MenuBarPresenter`）已在 `Sources/timer/` 中就绪，可供 App 直接复用。
- 主要缺口：
  - App 层未采用 Starter 的统一 `TimerAppViewModel`。
  - 缺少 `MenuBarExtra` 场景声明。
  - 入口命名与页面命名在接入 Starter 时会发生冲突（`@main` 与 `ContentView` 重名风险）。

## Proposed Changes
### 1) 统一 App 入口并接入菜单栏场景
- 文件：`/Users/czq/Code/TimerApp/TimerApp/TimerAppApp.swift`
  - What：替换为 Starter 入口结构（`@StateObject` 注入 `TimerAppViewModel`，同时声明 `WindowGroup` 与 `MenuBarExtra`）。
  - Why：建立单一应用状态源并实现文档要求的双交互形态。
  - How：保留当前文件路径以减少 Xcode target membership 变更成本，仅更新其实现内容；确保工程中唯一 `@main`。

### 2) 将主窗口页面升级为首版完整交互
- 文件：`/Users/czq/Code/TimerApp/TimerApp/ContentView.swift`
  - What：由当前极简页面升级为包含阶段、倒计时、四个主操作按钮与统计区块的视图。
  - Why：满足“可跑通完整番茄流程 + 统计概览”的首版体验。
  - How：改为依赖 `@EnvironmentObject` 注入的 `TimerAppViewModel`，所有操作通过异步 action 触发协调器。

### 3) 新增 App ViewModel 作为 UI 与 Domain 的桥接层
- 文件：`/Users/czq/Code/TimerApp/TimerApp/TimerAppViewModel.swift`（新建）
  - What：落地统一状态管理、启动引导、ticker 同步、统计刷新逻辑。
  - Why：避免页面直接持有协调器与仓储，实现菜单栏与窗口共享单一状态。
  - How：复用 `InMemorySessionRepository`、`PomodoroCoordinator`、`StatisticsService`、`MenuBarPresenter`；在主线程发布 UI 状态。

### 4) 新增菜单栏视图
- 文件：`/Users/czq/Code/TimerApp/TimerApp/MenuBarView.swift`（新建）
  - What：提供轻量快捷操作（开始/暂停/继续/跳过）与当前阶段摘要。
  - Why：落实 macOS 高频场景入口，且与主窗口保持同源状态。
  - How：使用同一 `TimerAppViewModel` 环境对象，不引入第二套状态容器。

### 5) 新增统计子视图
- 文件：`/Users/czq/Code/TimerApp/TimerApp/StatisticsView.swift`（新建）
  - What：展示本周完成番茄数与专注分钟。
  - Why：完成首版“番茄钟 + 数据统计”的闭环展示。
  - How：读取 ViewModel 中聚合后的展示字段；先用文本卡片样式，后续再升级 Charts。

### 6) 清理与一致性修正
- 文件：`/Users/czq/Code/TimerApp/Examples/XcodeStarter/*.swift`（保持示例用途，不并入 App target 业务逻辑）
  - What：不删除示例目录，但避免与 App Target 中同名类型重复编译。
  - Why：保留参考模板，同时确保目标编译输入唯一。
  - How：通过 Xcode target membership 控制仅 `TimerApp/` 下实现参与 App target 构建；必要时调整工程文件引用。

## Assumptions & Decisions
- 决策：本轮采用“在 `TimerApp/` 原路径就地升级”的方式，而不是直接把 `Examples/XcodeStarter` 文件整体拷贝进 target。
- 决策：统计仍基于 `InMemorySessionRepository`，先确保交互与状态链路正确；持久化切换到 SwiftData 放在后续迭代。
- 假设：`timer` 包已正确加入 `TimerApp` target（你已反馈包迁移完成），后续编译错误将按导入与 target membership 逐项修正。
- 假设：当前阶段以本地运行验证为主，不包含签名与上架元数据配置。

## Verification Steps
1. 包能力校验：运行 `swift test`，确认包内状态机与统计测试继续通过。
2. App 编译校验：在 `TimerApp.xcodeproj` 下构建 macOS App target，确认无重复 `@main`、无重复类型、无模块导入错误。
3. 主窗口交互校验：验证开始/暂停/继续/跳过可用，阶段与倒计时会刷新。
4. 菜单栏一致性校验：验证菜单栏显示，且与主窗口操作后的状态保持一致。
5. 统计展示校验：执行若干阶段切换后，确认“本周完成番茄数/专注分钟”可刷新并显示。
6. 基础回归：确认不会引入负计时显示、按钮启用态明显异常、启动后未初始化崩溃。
