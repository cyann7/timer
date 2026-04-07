import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var model: TimerAppViewModel
    var onOpenMainWindow: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("番茄钟")
                    .font(.headline)
                Spacer()
                Button(action: {
                    onOpenMainWindow?()
                    NSApp.activate(ignoringOtherApps: true)
                }) {
                    Image(systemName: "macwindow")
                }
                .buttonStyle(.borderless)
                .help("打开主窗口")
            }

            Text("\(model.phaseText.capitalized) · \(model.menuBarSubtitle())")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                if model.canStart {
                    Button("开始") {
                        Task { await model.start() }
                    }
                }
                if model.canPause {
                    Button("暂停") {
                        Task { await model.pause() }
                    }
                }
                if model.canResume {
                    Button("继续") {
                        Task { await model.resume() }
                    }
                }
                if model.canStop {
                    Button("停止") {
                        Task { await model.stop() }
                    }
                }
            }

            Divider()

            if model.canSkip {
                Button("跳过当前阶段") {
                    Task { await model.skip() }
                }
            }

            Divider()

            Button("退出") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(12)
    }
}
