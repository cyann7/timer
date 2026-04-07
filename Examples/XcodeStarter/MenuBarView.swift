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
                Button("开始") {
                    Task { await model.start() }
                }
                Button("暂停") {
                    Task { await model.pause() }
                }
                .disabled(!model.isRunning)
                Button("继续") {
                    Task { await model.resume() }
                }
                .disabled(!model.isPaused)
            }

            Divider()

            Button("跳过当前阶段") {
                Task { await model.skip() }
            }
        }
        .padding(12)
    }
}
