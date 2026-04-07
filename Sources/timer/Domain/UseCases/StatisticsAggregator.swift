import Foundation

public struct DailyFocusStat: Sendable, Equatable {
    public let dayStart: Date
    public let totalFocusDuration: TimeInterval
    public let completedPomodoros: Int

    public init(dayStart: Date, totalFocusDuration: TimeInterval, completedPomodoros: Int) {
        self.dayStart = dayStart
        self.totalFocusDuration = totalFocusDuration
        self.completedPomodoros = completedPomodoros
    }
}

public struct StatisticsSummary: Sendable, Equatable {
    public let daily: [DailyFocusStat]
    public let weekTotalFocusDuration: TimeInterval
    public let weekCompletedPomodoros: Int

    public init(daily: [DailyFocusStat], weekTotalFocusDuration: TimeInterval, weekCompletedPomodoros: Int) {
        self.daily = daily
        self.weekTotalFocusDuration = weekTotalFocusDuration
        self.weekCompletedPomodoros = weekCompletedPomodoros
    }
}

public struct StatisticsAggregator: Sendable {
    public init() {}

    public func summarize(
        sessions: [FocusSession],
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> StatisticsSummary {
        let focusSessions = sessions.filter { $0.phase == .focus && $0.completed }
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: referenceDate)
        let grouped = Dictionary(grouping: focusSessions) { session in
            calendar.startOfDay(for: session.endedAt)
        }

        let daily = grouped.keys.sorted().map { dayStart in
            let items = grouped[dayStart] ?? []
            return DailyFocusStat(
                dayStart: dayStart,
                totalFocusDuration: items.reduce(0) { $0 + $1.duration },
                completedPomodoros: items.count
            )
        }

        let weekItems: [FocusSession]
        if let weekInterval {
            weekItems = focusSessions.filter { weekInterval.contains($0.endedAt) }
        } else {
            weekItems = focusSessions
        }

        return StatisticsSummary(
            daily: daily,
            weekTotalFocusDuration: weekItems.reduce(0) { $0 + $1.duration },
            weekCompletedPomodoros: weekItems.count
        )
    }
}
