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

            Text("\(model.phaseText) · \(model.menuBarSubtitle())")
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
                if model.canTerminate {
                    Button("终止") {
                        Task { await model.terminate() }
                    }
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
