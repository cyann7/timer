import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var model: TimerAppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("本周统计")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("完成番茄数")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(model.weekPomodoros)")
                        .font(.title3.weight(.semibold))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("专注分钟")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(model.weekFocusMinutes)")
                        .font(.title3.weight(.semibold))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
