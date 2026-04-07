# macOS 番茄钟项目 Agent 执行指南

## 1. 目标与范围
- 目标：实现一个 macOS 自用番茄钟应用，首版聚焦「番茄钟 + 数据统计」。
- 发布约束：面向 App Store 上架标准设计与实现。
- 数据约束：仅本地存储，不引入账号体系与云同步。
- 交互形态：菜单栏（高频快操作）+ 独立窗口（完整信息与配置）。
- 视觉方向：系统原生、简洁、一致。

## 2. 固定技术决策（不可偏离）
- UI 技术：SwiftUI。
- 语言与平台：Swift + macOS（建议最低 macOS 14+）。
- 本地数据：SwiftData。
- 图表：Swift Charts（用于统计页）。
- 状态管理：Observation（或与现有代码一致的 ObservableObject）。
- 系统能力：Sandbox、用户通知、前后台状态与睡眠唤醒校准。

## 3. 架构原则
- 分层结构：`App / Features / Domain / Infrastructure / UI`。
- 单一事实源：番茄钟状态由统一引擎驱动，菜单栏与主窗口共享同一状态源。
- 业务与展示解耦：UI 只订阅状态和触发动作，不承载业务分支判断。
- 领域优先：计时状态机、聚合规则、仓储协议放在 Domain 层。
- 基础设施下沉：持久化、通知、系统事件监听封装在 Infrastructure。

## 4. 目录与模块职责
- `App/`
  - 应用入口、依赖注入、路由编排、全局生命周期协调。
- `Features/Pomodoro/`
  - 专注/短休/长休流程，暂停/继续/跳过，自动切换策略。
  - 依赖 `PomodoroEngine` 作为核心状态机。
- `Features/Statistics/`
  - 日/周专注时长、完成番茄数、连续达标天数。
  - 统计以 session 记录按需聚合为主。
- `Features/MenuBar/`
  - 菜单栏快速开始/暂停/停止与当前状态展示。
- `Features/Settings/`
  - 时长配置、自动切换策略、通知策略等用户偏好。
- `Domain/`
  - 实体、值对象、用例、仓储协议、状态机、扩展协议边界。
- `Infrastructure/`
  - `Persistence`：SwiftData 模型与仓储实现。
  - `System`：通知、前后台切换、睡眠唤醒与时间校准。
  - `Logging`：基础日志抽象（仅记录必要诊断信息）。
- `UI/`
  - Design Tokens（间距、圆角、字体层级、语义色）与通用组件。

## 5. 领域模型与核心规则
- `FocusSession`（核心实体）
  - 字段建议：`startAt`、`endAt`、`type(focus/shortBreak/longBreak)`、`isCompleted`、`taskId?`。
- `DailySummary`（可选派生）
  - 首版优先按需聚合，不强制维护冗余汇总表。
- 计时一致性规则
  - 以“绝对结束时间戳”作为真值，不依赖本地 ticker 累加得出最终状态。
  - 恢复/唤醒后按当前时间回算剩余秒数并自动修正。
  - 禁止出现负计时、重复完成、跨阶段重复记账。

## 6. 功能实现策略
- 番茄流程
  - 专注结束后根据策略进入短休或长休，支持自动流转与手动跳过。
- 统计策略
  - 未完成 session 默认不计入完成番茄数。
  - 日/周聚合统一通过 Domain 规则计算，避免 UI 层重复实现。
- 菜单栏与主窗口一致性
  - 两端动作都通过同一用例入口触发，避免并发分叉状态。
- 通知策略
  - 仅在授权后发送阶段结束提醒；未授权时走静默降级路径。

## 7. 工程与代码约束
- 所有新功能优先落在对应分层，不跨层直接依赖实现细节。
- 不在 Feature 直接访问 SwiftData 容器，必须通过仓储协议/用例访问。
- 保持 API 命名语义化，避免缩写与隐式状态。
- 组件复用优先使用 `UI/` 通用组件与 token，不做临时样式散落。
- 首版不引入多主题、多语言、云同步、账号体系。

## 8. 测试与验收基线
- 单元测试优先级
  - `PomodoroEngine`：状态切换、暂停恢复、自动流转、边界时序。
  - 统计聚合：跨天、跨周、未完成过滤、连续达标计算。
  - 时间修正：睡眠/唤醒、应用重启恢复剩余时间准确性。
- 验收场景
  - 完成一次完整流程（专注 -> 休息）并收到正确通知。
  - 菜单栏与窗口视图状态一致，操作互相可见。
  - 重启后可恢复进行中的计时状态。
  - 统计页日/周数据与 session 明细一致。

## 9. 演进边界（后续扩展）
- 通过协议化边界预留扩展：`TaskProvider` 等。
- 新能力（任务管理、习惯打卡、专注白名单）不得反向污染番茄钟核心状态机。
- 扩展优先复用既有 Domain 用例与 Infrastructure 能力，不重复造轮子。

## 10. Agent 执行清单（每次改动前自检）
- 本次改动是否符合首版范围与固定技术决策。
- 是否维持菜单栏与主窗口单一状态源。
- 是否继续采用绝对结束时间戳保证计时一致性。
- 是否避免跨层耦合与 Feature 直接依赖持久化实现。
- 是否补齐对应单测与关键验收路径。

## 11. 持久化设计基线（B 方案）
- 采用仓储适配方案：`Domain` 仅依赖 `SessionRepository`，不感知 SwiftData 类型。
- `Infrastructure/Persistence` 提供 `SwiftDataSessionRepository` 作为默认实现，`InMemorySessionRepository` 仅作为降级与测试实现。
- `TimerApp` 注入策略：优先初始化 `SwiftDataSessionRepository`，失败时回退到 `InMemorySessionRepository`，保证应用可启动。
- 存储模型映射规则：`FocusSession` <-> `SwiftDataFocusSessionRecord` 一一映射，`phase` 使用 rawValue 持久化。
- 统计策略保持不变：继续按 `allSessions()` 拉取后由 `StatisticsAggregator` 按需聚合，不引入冗余汇总表。
- 严禁在 `Feature/UI` 直接访问 `ModelContext`；所有读写必须经过仓储协议。
