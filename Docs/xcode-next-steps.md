# Xcode 下一步实操

## 目标
将 `timer` 包接入你的 macOS SwiftUI 工程，并跑起一个可用的首版界面（主窗口 + 菜单栏 + 统计概览）。

## 1. 把模板文件放进你的 App 工程
将以下文件从仓库复制到你自己的 Xcode App 工程目录：
- `Examples/XcodeStarter/TimerMacApp.swift`
- `Examples/XcodeStarter/TimerAppViewModel.swift`
- `Examples/XcodeStarter/ContentView.swift`
- `Examples/XcodeStarter/MenuBarView.swift`
- `Examples/XcodeStarter/StatisticsView.swift`

## 2. 在 Xcode 中添加文件
- 在项目导航中右键你的 App 分组，选择 Add Files to "你的工程名"。
- 选择上面的 5 个文件并添加。
- 勾选目标 Target Membership 为你的 macOS App target。

## 3. 设置入口文件
- 如果工程已有 `@main` App 文件，删除或替换为 `TimerMacApp.swift` 的内容。
- 确认工程中只有一个 `@main` 声明。

## 4. 导入依赖
- 你已在 Frameworks 中看到 `timer`，此时无需重复添加。
- 确保 `TimerAppViewModel.swift` 顶部有 `import timer`。

## 5. 运行验证
- 选择 macOS 本机运行目标，点击 Run。
- 验证主窗口能看到：阶段、倒计时、开始/暂停/继续/跳过按钮。
- 验证菜单栏出现计时入口并可操作。

## 6. 常见问题
- `No such module 'timer'`：检查该 Swift 文件是否属于 App target，执行 Resolve Package Versions 并 Clean Build Folder 后重试。
- `Multiple commands produce` 或入口冲突：确认仅保留一个 `@main` 文件。
- 菜单栏不显示：确认 `MenuBarExtra` 在 `App` 场景中声明，且应用已成功运行。
