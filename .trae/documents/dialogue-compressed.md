# 对话压缩纪要（更新）

## 1. 项目目标
- 开发 macOS 自用番茄钟应用，首版范围为「番茄钟 + 数据统计」。
- 采用系统原生风格，菜单栏 + 主窗口双入口，面向 App Store 约束设计。

## 2. 已落地关键能力
- 完成分层骨架与核心领域能力：`PomodoroEngine`、`PomodoroCoordinator`、`StatisticsAggregator`。
- App 侧已接入主窗口 + 菜单栏共享状态源，支持开始/暂停/继续/停止/跳过。
- 交互规则已改为“仅显示可点击按钮”（不可点击按钮隐藏，不再灰态禁用）。
- 新增 stop/reset 语义：停止后重置当前阶段时长，不记完成 session。
- 主窗口尺寸策略已改为强制 `420x420`（窗口层面固定大小，覆盖系统历史窗口尺寸恢复）。

## 3. 工程问题与修复轨迹
- 处理过 `No such module 'timer'`、`has no member 'stop'`、package resolution 等问题。
- 根因包含：本地包路径引用错误、`project.pbxproj` 包引用结构不完整、窗口状态恢复机制误判为尺寸未生效。
- 现已修正本地包引用与窗口策略，工程可在本机 Xcode 继续构建与运行。

## 4. 存储方案决策（已执行 B 方案）
- 决策：采用“仓储适配”而非 UI 直接访问 SwiftData。
- 已新增：
  - `SwiftDataFocusSessionRecord`（持久化模型映射）
  - `SwiftDataSessionRepository`（`SessionRepository` 实现）
- App 注入策略：优先 `SwiftDataSessionRepository`，初始化失败回退 `InMemorySessionRepository`。
- 统计策略保持：`allSessions()` + `StatisticsAggregator` 按需聚合，不引入冗余汇总表。

## 5. 文档与规范更新
- 已将持久化 B 方案写入 `agent.md`（新增“持久化设计基线”章节）。
- 用户明确要求：后续每次对话先查看并遵循 `agent.md`。

## 6. 当前状态
- 代码层面：已具备本地持久化能力与回退兜底。
- 诊断层面：IDE 诊断无新增错误。
- 运行层面：当前执行环境的 CLI 构建受沙箱限制（`sandbox-exec`），最终以本机 Xcode 构建结果为准。

## 7. 待办方向
- 提醒能力增强：声音、通知、用户可设置（来自 `TODO`）。
- 统计展示升级：后续可接入 Charts。
- 通知权限与阶段提醒策略完善。
