import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject private var model: TimerAppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("本周统计")
                .font(.title2.weight(.semibold))

            HStack(spacing: 24) {
                StatCard(title: "完成番茄数", value: "\(model.weekPomodoros)")
                StatCard(title: "专注分钟", value: "\(model.weekFocusMinutes)")
                Spacer()
            }

            if !model.dailyStats.isEmpty {
                Chart(model.dailyStats) { item in
                    BarMark(
                        x: .value("日期", item.date, unit: .day),
                        y: .value("番茄数", item.pomodoros)
                    )
                    .foregroundStyle(Color.red.gradient)
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .frame(maxHeight: .infinity)
            } else {
                Text("暂无数据")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title.weight(.semibold))
        }
    }
}
