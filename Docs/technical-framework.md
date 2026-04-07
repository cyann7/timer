# macOS 番茄钟技术框架

## 技术栈
- 语言与平台：Swift 6、macOS 14+
- UI：SwiftUI + MenuBarExtra（在 App Target 中接入）
- 数据：SwiftData（首版本地存储）
- 图表：Swift Charts（统计页）
- 并发：Swift Concurrency（actor 隔离计时与存储）

## 架构分层
- App：应用入口、依赖注入、路由编排
- Features：Pomodoro、Statistics、MenuBar、Settings
- Domain：实体、状态机、统计用例、仓储协议
- Infrastructure：持久化、通知、系统事件、日志
- UI：设计令牌与通用视觉参数

## 核心流
- PomodoroEngine 维护 phase、remaining、completed cycles
- PomodoroCoordinator 负责调用引擎并落库 session
- StatisticsService 聚合 session 产生日/周统计结果
- MenuBarPresenter 将运行态转换为菜单栏文本展示

## App Store 约束
- 启用 Sandbox
- 仅请求必要通知权限
- 不依赖私有 API
- 隐私说明与权限用途在应用层补齐

## 后续扩展
- 增加任务管理：在 FocusSession 引入任务关联标识
- 增加习惯追踪：新增 Habit 实体与聚合器
- 增加云同步：在仓储层替换为 SwiftData + CloudKit 组合
