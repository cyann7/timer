import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var model: TimerAppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("番茄钟")
                .font(.headline)
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
        }
        .padding(12)
    }
}
