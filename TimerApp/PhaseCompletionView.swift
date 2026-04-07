import SwiftUI

struct PhaseCompletionView: View {
    @EnvironmentObject private var model: TimerAppViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("🍅")
                .font(.system(size: 60))

            Text("\(model.completedPhaseName)完成!")
                .font(.title)
                .fontWeight(.bold)

            Text("请选择下一步操作")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                Button(action: {
                    Task {
                        await model.confirmAndStop()
                        dismiss()
                    }
                }) {
                    Text("结束")
                        .frame(width: 100)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(action: {
                    Task {
                        await model.confirmAndContinue()
                        dismiss()
                    }
                }) {
                    Text(model.nextPhaseAction)
                        .frame(width: 100)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(40)
        .frame(minWidth: 300, minHeight: 250)
    }
}
