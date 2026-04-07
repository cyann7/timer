# TimerApp 方形布局与按钮状态机修正计划

## Summary
- 目标：将主窗口改为 `420×420` 正方形默认尺寸；修正“开始/暂停/继续/停止/跳过”交互约束，满足你定义的阶段点击规则。
- 成功标准：
  - 主窗口默认正方形尺寸为 `420×420`。
  - 初始仅“开始”可点。
  - 开始后仅“暂停”与“跳过”可点（“继续/停止”禁用）。
  - 暂停后“继续/停止/跳过”可点（“开始/暂停”禁用）。
  - “停止”行为为“停止并重置当前阶段初始时长”。

## Current State Analysis
- 已探索文件：
  - `TimerApp/ContentView.swift`：当前窗口尺寸为 `minWidth: 440, minHeight: 340`，按钮有开始/暂停/继续/跳过，尚无“停止”。
  - `TimerApp/TimerAppViewModel.swift`：已有 `isRunning`、`isPaused` 状态与 start/pause/resume/skip/syncTick；未提供 stop/reset 逻辑。
  - `Sources/timer/Domain/Engine/PomodoroEngine.swift`：无 stop API，仅 start/pause/resume/skip/sync。
  - `Sources/timer/Features/Pomodoro/PomodoroCoordinator.swift`：无 stop API。
  - `Tests/timerTests/timerTests.swift`：已有状态机与统计基础测试，可补 stop/reset 相关测试。
- 结论：
  - UI 层无法仅靠现有接口实现“停止并重置当前阶段”，需要在 Domain/Coordinator 暴露 reset 能力后上收至 ViewModel。

## Proposed Changes
### 1) 为计时引擎增加“停止并重置当前阶段”能力
- 文件：`/Users/czq/Code/TimerApp/Sources/timer/Domain/Engine/PomodoroEngine.swift`
  - What：新增 `stop(at:)`（或语义等价命名）接口。
  - Why：满足“暂停后可以停止，且停止要重置当前阶段时长”。
  - How：
    - 清空运行态字段（`phaseEndsAt`、`pausedRemaining`）。
    - 保留当前 `phase` 不变，仅把快照恢复到该阶段默认时长。
    - 不写入完成 session（停止不是完成，且非跳过逻辑）。

### 2) 在协调器层透传 stop/reset
- 文件：`/Users/czq/Code/TimerApp/Sources/timer/Features/Pomodoro/PomodoroCoordinator.swift`
  - What：新增 `stop(now:)` 方法并更新 `snapshot`。
  - Why：保持 Feature 层统一入口，UI 不直接依赖 Engine actor。
  - How：调用 engine 的 stop API；不触发 repository save。

### 3) ViewModel 新增 stop 行为与按钮可用态规则
- 文件：`/Users/czq/Code/TimerApp/TimerApp/TimerAppViewModel.swift`
  - What：
    - 新增 `stop()`。
    - 新增按钮状态派生属性（例如 `canStart/canPause/canResume/canStop/canSkip`）。
  - Why：把交互规则集中在状态层，避免 View 写分支逻辑。
  - How（按你的规则）：
    - 初始（未运行未暂停）：仅 `canStart = true`。
    - 运行中（isRunning）：`canPause = true`、`canSkip = true`。
    - 暂停中（isPaused）：`canResume = true`、`canStop = true`、`canSkip = true`。

### 4) 更新主窗口尺寸与按钮禁用逻辑
- 文件：`/Users/czq/Code/TimerApp/TimerApp/ContentView.swift`
  - What：
    - 尺寸改为正方形默认 `420×420`。
    - 新增“停止”按钮。
    - 5 个按钮改用 ViewModel 可用态属性控制。
  - Why：直接体现你要求的交互流转与尺寸规格。
  - How：
    - 统一 `.frame(minWidth: 420, idealWidth: 420, minHeight: 420, idealHeight: 420)`。
    - 按 `can*` 属性绑定 `.disabled(...)`。

### 5) 菜单栏同步同一交互规则
- 文件：`/Users/czq/Code/TimerApp/TimerApp/MenuBarView.swift`
  - What：菜单栏增加“停止”并与窗口共享一致启用态规则。
  - Why：避免双入口行为不一致。
  - How：同样使用 `can*` 属性控制按钮状态。

### 6) 补齐状态机测试（stop/reset）
- 文件：`/Users/czq/Code/TimerApp/Tests/timerTests/timerTests.swift`
  - What：新增 stop 场景测试。
  - Why：避免后续回归打破“停止重置当前阶段”语义。
  - How：
    - focus 运行后 stop：`phase` 仍是 focus，`isRunning/isPaused` 为 false，`remaining` 恢复 focus 默认时长。
    - pause 后 stop：同样重置为当前 phase 默认时长。

## Assumptions & Decisions
- 已确认决策：
  - 正方形尺寸采用 `420×420`。
  - “停止”语义采用“停止并重置当前阶段初始时长”。
- 约束：
  - 继续保持单一状态源（同一个 `TimerAppViewModel`）。
  - 不引入额外新功能（如通知实装、持久化改造、图表升级）以避免偏离本次目标。

## Verification Steps
1. 单测：执行 `swift test`，新增 stop/reset 测试通过且原测试不回归。
2. 编译：构建 `TimerApp` target，确保无新增编译错误。
3. 交互验收（主窗口）：
   - 启动后：仅“开始”可点；
   - 点击开始后：仅“暂停/跳过”可点；
   - 点击暂停后：仅“继续/停止/跳过”可点；
   - 点击停止后：回到当前阶段初始时长，且回到仅“开始”可点状态。
4. 一致性验收（菜单栏）：按钮可用态与主窗口完全一致。
