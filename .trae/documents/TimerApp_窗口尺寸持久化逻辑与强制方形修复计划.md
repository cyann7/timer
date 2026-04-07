# TimerApp 窗口尺寸持久化逻辑与强制方形修复计划

## Summary
- 目标：解释“为什么首次不是方形、为什么会记住手动改过的尺寸”，并把主窗口改成**每次打开都固定 420×420**。
- 成功标准：
  - 主窗口每次启动都按 420×420 显示。
  - 用户手动调整后，下次启动不再沿用历史尺寸。
  - 交互功能（按钮显隐、状态流转）不受影响。

## Current State Analysis
- 已确认代码现状：
  - `TimerApp/TimerAppApp.swift` 已配置：
    - `.defaultSize(width: 420, height: 420)`
    - `.windowResizability(.contentSize)`
  - `TimerApp/ContentView.swift` 也设置了 `420×420` 的内容尺寸约束。
- 现象根因（可从 macOS/SwiftUI 机制推断）：
  - `defaultSize` 只在“无历史窗口状态”时作为默认值；并不是每次启动强制覆盖。
  - macOS 会对窗口 frame 做状态恢复/持久化（窗口位置、尺寸），所以你手动改过后，重启会优先用持久化尺寸。
  - 因此“看起来没改”不是 frame 失效，而是被系统恢复逻辑覆盖。
- 结论：
  - 要实现“始终固定 420×420”，必须在 Scene 层明确关闭/绕开窗口尺寸恢复，并在窗口创建后主动设置固定尺寸策略。

## Proposed Changes
### 1) 将主窗口从 `WindowGroup` 切换为单窗口 `Window`
- 文件：`/Users/czq/Code/TimerApp/TimerApp/TimerAppApp.swift`
  - What：使用 `Window("Timer", id: "...")` 代替 `WindowGroup`（主窗口场景）。
  - Why：单窗口场景更容易精准控制窗口实例与尺寸行为，避免 group 场景默认恢复策略干扰。
  - How：保留现有 `ContentView` 和 `environmentObject` 注入，确保业务逻辑不变。

### 2) 在窗口生命周期中强制设置 420×420（覆盖历史 frame）
- 文件：`/Users/czq/Code/TimerApp/TimerApp/TimerAppApp.swift`
  - What：在窗口出现时抓取 `NSWindow`，执行固定尺寸写入（`setContentSize` + `min/max size` 同步限制）。
  - Why：从 AppKit 窗口层保证“每次都方形”，不依赖 `defaultSize` 的一次性默认行为。
  - How：增加轻量窗口访问桥接视图（SwiftUI 包装），在不改变业务 UI 的前提下设置窗口尺寸。

### 3) 保留当前按钮显隐逻辑，不变更状态机语义
- 文件：`/Users/czq/Code/TimerApp/TimerApp/ContentView.swift`（预期无需改）
  - What：不调整按钮规则与布局逻辑。
  - Why：本轮仅修窗口尺寸持久化问题，避免引入无关回归。
  - How：仅在需要时做最小兼容改动（例如避免窗口策略影响布局）。

### 4) 菜单栏场景保持原样
- 文件：`/Users/czq/Code/TimerApp/TimerApp/TimerAppApp.swift`（`MenuBarExtra` 部分）
  - What：不改菜单栏场景。
  - Why：问题仅发生在主窗口恢复/尺寸策略，与菜单栏无关。
  - How：仅确保主窗口改造后菜单栏继续共享同一 `model`。

## Assumptions & Decisions
- 已确认决策：
  - 窗口行为采用“**始终固定 420×420**”。
- 关键假设：
  - 当前问题主要由系统窗口状态恢复导致，而非现有布局约束失效。
  - 引入窗口层强制尺寸后，可稳定覆盖历史持久化 frame。

## Verification Steps
1. 首次启动验证：删除旧进程后启动，窗口为 420×420 方形。
2. 手动改尺寸验证：尝试拖拽改大小后关闭应用再打开，仍恢复为 420×420。
3. 回归验证：计时流程与按钮显隐规则与现状一致（不回退为 disabled 灰态）。
4. 构建验证：工程可正常 Build，且无新增诊断错误。
