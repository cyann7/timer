# TimerApp 正方形窗口与按钮显隐交互优化计划

## Summary
- 目标：把主窗口尺寸改成真正生效的正方形，并把当前“禁用灰态按钮”改为“仅显示可点击按钮”，提升界面简洁度与美观度。
- 成功标准：
  - 主窗口首次打开即为正方形尺寸，且不再出现“看起来没改”的情况。
  - 主窗口与菜单栏中，只渲染当前状态可执行的按钮；不可执行按钮完全隐藏。
  - 交互规则仍保持你已确认的状态机约束：初始仅开始；运行时暂停/跳过；暂停时继续/停止/跳过。

## Current State Analysis
- 已探索文件与现状：
  - `TimerApp/ContentView.swift`
    - 当前仅设置了 `.frame(minWidth: 420, idealWidth: 420, minHeight: 420, idealHeight: 420)`。
    - 按钮仍是全部显示 + `.disabled(...)` 的灰态方案，不符合“失效按钮隐藏”要求。
  - `TimerApp/TimerAppApp.swift`
    - `WindowGroup` 未配置窗口默认尺寸与可调整策略，导致仅靠 `ContentView` frame 不足以稳定控制 macOS 窗口外框尺寸。
  - `TimerApp/MenuBarView.swift`
    - 与主窗口同样是“全显示 + disabled”，未做显隐控制。
- 根因判断：
  - “尺寸没改”的核心原因是 Scene 层没有锁定窗口尺寸策略；仅 View 层 frame 在 macOS 上不等价于固定窗口尺寸。
  - “UI 不好看”的核心原因是按钮策略仍为禁用态展示，而不是状态化显隐。

## Proposed Changes
### 1) 在 Scene 层锁定主窗口为正方形显示策略
- 文件：`/Users/czq/Code/TimerApp/TimerApp/TimerAppApp.swift`
  - What：在 `WindowGroup` 上增加窗口尺寸与可调整策略配置。
  - Why：保证正方形尺寸在 macOS 窗口层真实生效。
  - How：
    - 设置默认窗口大小为 `420 × 420`。
    - 视情况设置内容尺寸限制/窗口不可自由拉伸（采用 SwiftUI 原生窗口修饰符）。

### 2) 主窗口改为“可点击按钮才显示”
- 文件：`/Users/czq/Code/TimerApp/TimerApp/ContentView.swift`
  - What：移除 `.disabled(...)` 方案，改为按状态条件渲染按钮。
  - Why：减少视觉噪音，符合你的“UI 要好看”目标。
  - How：
    - 基于 `model.canStart/canPause/canResume/canStop/canSkip` 使用条件渲染。
    - 仅展示当前合法动作集合，保留统一按钮样式，优化按钮区布局间距避免跳动感。

### 3) 菜单栏同步显隐逻辑，保持双入口一致
- 文件：`/Users/czq/Code/TimerApp/TimerApp/MenuBarView.swift`
  - What：与主窗口一致，隐藏不可执行动作按钮。
  - Why：避免“窗口和菜单栏规则不一致”的认知负担。
  - How：按同一 `can*` 状态条件渲染按钮；保留“跳过当前阶段”仅在可执行时显示。

### 4) 状态逻辑保持不变，仅做展示层优化
- 文件：`/Users/czq/Code/TimerApp/TimerApp/TimerAppViewModel.swift`
  - What：复用现有 `can*` 规则，不新增状态分支。
  - Why：降低回归风险，确保行为语义不变只改 UI 呈现。
  - How：如有必要仅补充展示层辅助属性，不改 start/pause/resume/stop/skip 语义。

## Assumptions & Decisions
- 已锁定决策：
  - 正方形目标尺寸继续采用 `420 × 420`。
  - 不再展示禁用按钮，只展示可执行按钮。
- 假设：
  - 本轮不改动 Domain 层状态机规则，仅优化窗口与 UI 表现层。

## Verification Steps
1. 窗口尺寸验证：
   - 启动应用后主窗口默认尺寸为 `420 × 420`，并验证尺寸策略符合预期（固定或受限可调整）。
2. 主窗口按钮显隐验证：
   - 初始仅显示“开始”。
   - 开始后仅显示“暂停、跳过”。
   - 暂停后仅显示“继续、停止、跳过”。
3. 菜单栏一致性验证：
   - 菜单栏按钮显隐与主窗口同状态同步。
4. 编译与诊断验证：
   - 工程可正常 Build，且 `GetDiagnostics` 无新增错误。
