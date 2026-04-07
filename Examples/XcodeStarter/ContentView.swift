import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: TimerAppViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text(model.phaseText.capitalized)
                .font(.title2.weight(.semibold))

            Text(model.remainingText)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()

            HStack(spacing: 12) {
                Button("开始") {
                    Task { await model.start() }
                }
                .buttonStyle(.borderedProminent)

                Button("暂停") {
                    Task { await model.pause() }
                }
                .buttonStyle(.bordered)
                .disabled(!model.isRunning)

                Button("继续") {
                    Task { await model.resume() }
                }
                .buttonStyle(.bordered)
                .disabled(!model.isPaused)

                Button("跳过") {
                    Task { await model.skip() }
                }
                .buttonStyle(.bordered)
            }

            Divider()

            StatisticsView()
        }
        .padding(24)
        .frame(minWidth: 440, minHeight: 340)
    }
}
