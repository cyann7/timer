import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var model: TimerAppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 24) {
                StatCard(title: "完成番茄数", value: "\(model.weekPomodoros)")
                StatCard(title: "专注分钟", value: "\(model.weekFocusMinutes)")
                Spacer()
            }

            if !model.dailyStats.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(model.dailyStats) { item in
                        DailyTomatoRow(item: item)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                Text("暂无数据")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct DailyTomatoRow: View {
    let item: TimerAppViewModel.DailyStatItem
    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "E"
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(Self.weekdayFormatter.string(from: item.date))
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(width: 42, alignment: .leading)

            if item.pomodoros > 0 {
                HStack(spacing: 4) {
                    ForEach(0..<item.pomodoros, id: \.self) { _ in
                        Text("🍅")
                            .font(.title3)
                    }
                }
            }

            Spacer(minLength: 0)
            Text("\(item.pomodoros)")
                .font(.body.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
        }
    }
}
