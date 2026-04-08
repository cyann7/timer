import SwiftUI

struct PhaseCompletionView: View {
    @EnvironmentObject private var model: TimerAppViewModel

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: {
                    Task {
                        await model.confirmAndStop()
                    }
                }) {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Spacer()
            }

            Spacer()

            Text("🍅")
                .font(.system(size: 60))

            Text("\(model.completedPhaseName)完成!")
                .font(.title)
                .fontWeight(.bold)

            Text("请选择下一步操作")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: {
                Task {
                    await model.confirmAndContinue()
                }
            }) {
                Text(model.nextPhaseAction)
                    .frame(width: 120)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .padding(24)
        .frame(minWidth: 420, idealWidth: 420, minHeight: 420, idealHeight: 420)
    }
}
