# Tomatime

一个面向 macOS 的番茄钟应用（SwiftUI + SwiftData + Swift Package）。

当前版本包含：
- 番茄钟完整流程：开始、暂停、继续、终止、跳过
- 阶段完成确认页（在主窗口内切换，不弹新窗口）
- 菜单栏状态与快捷操作
- 本地持久化统计（周统计 + 最近 7 天图表）
- 到点提醒（系统通知 + 声音 + Dock attention）
- 可配置设置（专注/休息时长、提醒开关、菜单栏显示）

## 技术栈
- Swift 6
- macOS 14+
- SwiftUI
- SwiftData
- Swift Concurrency
- Swift Testing

## 项目结构
- `TimerApp/`：macOS 应用壳（SwiftUI 页面与应用入口）
- `Sources/timer/`：可复用业务核心包
- `Tests/timerTests/`：核心状态机与统计测试
- `Docs/`：架构与接入文档
- `Examples/XcodeStarter/`：快速接入模板

## 快速开始
1. 克隆仓库
```bash
git clone https://github.com/cyann7/timer.git
cd TimerApp
```
2. 运行测试
```bash
swift test
```
3. 用 Xcode 打开工程
```bash
open TimerApp.xcodeproj
```
4. 选择 `TimerApp` scheme，运行 macOS target（产物名称为 `Tomatime`）。

## DMG 安装说明（重要）
### 1. 下载与安装
1. 在 GitHub Release 页面下载最新 `Tomatime-*.dmg`
2. 双击打开 `dmg`
3. 将 `Tomatime.app` 拖到 `Applications` 文件夹

### 2. 首次打开可能被系统拦截（请先看这里）
本应用由个人开发者发布，当前**未使用付费 Apple Developer 账号进行签名与公证**。  
因此 macOS 可能提示“无法打开 App”或“Apple 无法验证是否包含恶意软件”。

这不是应用损坏，属于系统 Gatekeeper 的默认安全拦截。

### 3. 解决流程（推荐）
1. 在 Finder 中找到 `Applications/Tomatime.app`
2. 右键（或 `Control` + 点击）`Tomatime.app`，选择“打开”
3. 在弹窗中再次点击“打开”

如果仍然被拦截：
1. 打开“系统设置” -> “隐私与安全性”
2. 在页面底部找到被拦截提示，点击“仍要打开”
3. 再次尝试启动 `Tomatime`

### 4. 终端方式（可选，仅高级用户）
如果你明确确认来源可信，也可以移除下载隔离标记：
```bash
xattr -dr com.apple.quarantine /Applications/Tomatime.app
```
执行后再打开应用即可。

## 主要功能说明
- 关闭主窗口不会退出应用，计时继续进行
- 点击状态栏图标或 Dock 图标可恢复主窗口
- 到点后会进入阶段完成页，可选择继续下一阶段或返回主页面
- 统计页展示本周完成番茄数、专注分钟数及每日番茄数量

## 开发文档
- 技术框架：[Docs/technical-framework.md](Docs/technical-framework.md)
- Xcode 接入步骤：[Docs/xcode-next-steps.md](Docs/xcode-next-steps.md)

## 许可证
本项目使用仓库根目录的 `LICENSE`。  
允许学习、修改与商用，但需保留原作者署名。
