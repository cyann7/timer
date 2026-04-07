# TimerApp 用户数据存储现状与持久化方案计划

## Summary
- 目标：明确回答“用户数据当前存在哪里（数据库还是文件）”，并给出后续若要持久化的实施方向。
- 结论：当前不是数据库也不是文件，使用的是进程内内存仓储；应用退出后数据丢失。

## Current State Analysis
- 仓储接口定义在 `SessionRepository`，只声明读写行为，不限定介质。
- 当前唯一实现是 `InMemorySessionRepository`，内部用数组保存会话数据。
- `PomodoroCoordinator` 在阶段完成/跳过时写入仓储，`StatisticsService` 从仓储读统计。
- App 层 `TimerAppViewModel` 与 `AppContainer` 都注入了 `InMemorySessionRepository`。
- 未发现 SwiftData/CoreData/SQLite/FileManager/UserDefaults 等落盘实现代码。
- 文档中有“SwiftData 本地存储”的技术规划，但当前代码尚未落地。

## Proposed Changes
### 1) 仅确认现状（本轮不改代码）
- 文件：无
  - What：对外明确“当前是内存存储，非数据库/文件”。
  - Why：先消除认知偏差，再决定是否推进持久化改造。
  - How：基于现有仓储实现与调用链给出可追溯结论。

### 2) 若要持久化，优先落地 SwiftData 仓储实现（下一阶段）
- 文件（建议）：
  - `Sources/timer/Infrastructure/Persistence/SwiftDataSessionRepository.swift`
  - `Sources/timer/Infrastructure/Persistence/Models/*`
  - `TimerApp/`（注入容器处切换到持久化仓储）
  - `Tests/timerTests/*`（新增持久化读写与恢复测试）
  - What：新增持久化仓储并替换内存仓储注入。
  - Why：满足“重启后数据仍在”的真实用户需求。
  - How：保持 `SessionRepository` 协议不变，仅替换实现，最小化上层改动。

## Assumptions & Decisions
- 已确认事实：当前用户数据仅在内存中，应用退出后会清空。
- 决策建议：若你要“可恢复历史数据”，优先做 SwiftData 本地持久化，而不是先上文件直写。

## Verification Steps
1. 现状验证：运行应用，产生若干 session，退出重开后统计归零（证明当前为内存态）。
2. 代码核验：确认仓储注入点仍为 `InMemorySessionRepository`。
3. 下一阶段验收（若启动持久化改造）：重启后 session 与统计仍可恢复。
