# macOS 番茄钟系统应用技术框架设计方案

## 1. Summary
- 目标：设计一个用于 macOS 的自用番茄钟应用技术框架，首版覆盖「番茄钟 + 数据统计」，后续可平滑扩展更多效率功能。
- 关键决策：采用 SwiftUI 原生技术栈，双模式交互（菜单栏 + 独立窗口），本地存储优先，发布标准按 App Store 约束设计。
- 成功标准：形成可直接实施的工程结构、模块边界、数据模型、系统能力接入方案、验证标准与演进路径。

## 2. Current State Analysis
- 仓库现状：`/Users/czq/Code/timer` 当前为空仓库（仅 `.git` 元数据），暂无现成代码或依赖约束。
- 技术约束：由于目标包含 macOS 系统能力（通知、菜单栏、后台计时状态一致性）与 App Store 规范，优先原生方案可降低后续合规和集成复杂度。
- 需求边界（已确认）：
  - 技术路线：SwiftUI 原生。
  - 发布目标：上架 App Store。
  - 数据策略：仅本地存储。
  - 首版范围：番茄钟 + 数据统计。
  - 交互形态：双模式（菜单栏 + 独立窗口）。
  - 视觉方向：系统原生简洁风格。

## 3. Proposed Changes

### 3.1 工程与分层设计
- 文件：`timer.xcodeproj`（新建）
  - What：建立 macOS App 工程，Target 为 macOS 14+（建议），启用 Sandbox 与 Notifications 能力。
  - Why：满足 App Store 基础合规，明确系统 API 可用范围。
  - How：使用 Swift + SwiftUI + Observation（或 ObservableObject）作为 UI 状态基础。
- 文件：`TimerApp/`（新建主工程目录）
  - What：采用「App 层 / Feature 层 / Domain 层 / Infrastructure 层」分层。
  - Why：控制后续功能扩展复杂度，避免番茄钟逻辑与 UI 强耦合。
  - How：
    - `App/`：应用入口、依赖注入、路由。
    - `Features/`：`Pomodoro`、`Statistics`、`Settings`、`MenuBar`。
    - `Domain/`：实体、用例、仓储协议、计时状态机。
    - `Infrastructure/`：持久化、通知、系统事件监听、日志。

### 3.2 核心功能模块定义
- 文件：`TimerApp/Features/Pomodoro/*`
  - What：实现专注/短休/长休流程、暂停/继续/跳过、自动切换策略。
  - Why：番茄钟是主价值路径，需优先稳定。
  - How：由 `PomodoroEngine`（状态机）驱动，UI 仅订阅状态，不直接处理业务分支。
- 文件：`TimerApp/Features/Statistics/*`
  - What：提供日/周专注时长、完成番茄数、连续达标天数。
  - Why：满足首版“番茄钟 + 数据统计”目标。
  - How：基于本地 session 记录做聚合，图表先用 Swift Charts。
- 文件：`TimerApp/Features/MenuBar/*`
  - What：菜单栏快速开始/暂停/停止 + 当前状态展示。
  - Why：符合 macOS 高频轻操作习惯。
  - How：用 `MenuBarExtra` 承载快捷操作，与主窗口共享同一状态源。

### 3.3 数据与存储方案
- 文件：`TimerApp/Infrastructure/Persistence/*`
  - What：首选 SwiftData（仅本地），核心模型含 `FocusSession`、`DailySummary`（可选派生）。
  - Why：原生集成与 SwiftUI 绑定成本低，满足本地存储诉求。
  - How：
    - `FocusSession`：开始时间、结束时间、类型（focus/shortBreak/longBreak）、是否完成、关联任务标识（预留）。
    - 统计数据优先“按需聚合”，避免首版维护冗余汇总表。

### 3.4 系统能力与可靠性
- 文件：`TimerApp/Infrastructure/System/*`
  - What：封装通知、前后台切换、系统睡眠/唤醒时间校准。
  - Why：计时应用的可信度取决于时间一致性与提醒可达性。
  - How：
    - 统一使用“绝对结束时间戳”而非仅靠本地 ticker 累加。
    - 应用恢复时按当前时间回算剩余秒数并自动修正。
    - 通知中心发送阶段结束提醒，遵循用户授权状态。

### 3.5 UI 与设计系统
- 文件：`TimerApp/UI/*`
  - What：建立基础 Design Tokens（间距、圆角、字体层级、语义色）与通用组件。
  - Why：在“系统原生简洁”前提下保证视觉一致性与可扩展性。
  - How：
    - 使用系统材质、动态字体、深浅色适配。
    - 首版不做多主题，仅保留 token 可拓展能力。

### 3.6 测试与质量保障
- 文件：`TimerAppTests/*`
  - What：覆盖状态机单测、统计聚合单测、持久化读写基本测试。
  - Why：计时和统计最容易出现边界错误，需先自动化兜底。
  - How：
    - 状态机：切换、暂停恢复、跨阶段自动流转。
    - 统计：跨天、跨周、未完成 session 过滤。
    - 时间修正：睡眠唤醒后剩余时间一致性。

### 3.7 版本演进与扩展位
- 文件：`TimerApp/Domain/Extensibility/*`（可后建）
  - What：预留任务管理、习惯打卡、专注白名单等扩展接口。
  - Why：避免未来新增功能重写核心计时逻辑。
  - How：通过协议化边界（如 `TaskProvider`）接入，不反向污染 Pomodoro 核心模块。

## 4. Assumptions & Decisions
- 已锁定决策：
  - 使用 SwiftUI 原生技术栈。
  - 发布按 App Store 要求设计（沙盒、权限与通知合规）。
  - 数据仅本地，不引入云同步。
  - 首版功能为番茄钟 + 数据统计。
  - 交互采用菜单栏 + 独立窗口双模式。
  - UI 采用系统原生简洁风格。
- 关键假设：
  - 最低系统版本设为 macOS 14+，以获得更稳定的 SwiftUI/SwiftData/Charts 体验。
  - 首版暂不引入多语言、账号体系、跨设备同步。

## 5. Verification Steps
- 架构验证：
  - 确认工程可构建、可运行、菜单栏与主窗口共享同一计时状态。
- 功能验证：
  - 完成一次完整番茄流程（专注 -> 休息）并收到阶段通知。
  - 重启应用后可恢复进行中的计时状态（基于结束时间戳回算）。
  - 统计页正确展示日/周专注时长与完成番茄数量。
- 质量验证：
  - 状态机与统计聚合单元测试通过。
  - 睡眠/唤醒场景下时间误差在可接受范围内（不出现负计时或重复完成）。
- 合规验证：
  - 权限请求路径清晰，不在未授权情况下触发无效提醒。
  - 工程配置满足 App Store 基础提交前置要求（签名、沙盒能力、隐私说明预留）。
