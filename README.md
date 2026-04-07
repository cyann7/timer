# timer

这是一个面向 macOS 的番茄钟系统应用框架骨架，当前已落地：
- Domain 层状态机与统计聚合
- Feature 层协调器与菜单栏展示模型
- Infrastructure 层存储/通知/系统事件接口
- UI 设计令牌基础结构
- 可执行的单元测试（状态机与统计）

## 目录结构
- `Sources/timer/App`
- `Sources/timer/Features`
- `Sources/timer/Domain`
- `Sources/timer/Infrastructure`
- `Sources/timer/UI`
- `Docs/technical-framework.md`

## 本地验证
```bash
swift test
```

## 连接到 macOS App Target
- 在 Xcode 新建 macOS App 工程
- 将本包作为本地依赖引入
- 在 App Target 中接入 SwiftUI 页面、MenuBarExtra、SwiftData ModelContainer
- 复用 `PomodoroEngine`、`PomodoroCoordinator`、`StatisticsService` 作为业务核心
- 可直接使用 `Examples/XcodeStarter` 下的 5 个模板文件快速启动
- 详细步骤见 `Docs/xcode-next-steps.md`
