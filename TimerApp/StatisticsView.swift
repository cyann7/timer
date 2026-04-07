import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject private var model: TimerAppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周统计")
                .font(.headline)

            HStack {
                StatCard(title: "完成番茄数", value: "\(model.weekPomodoros)")
                Spacer()
                StatCard(title: "专注分钟", value: "\(model.weekFocusMinutes)")
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
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .frame(height: 120)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .font(.title3.weight(.semibold))
        }
    }
}
