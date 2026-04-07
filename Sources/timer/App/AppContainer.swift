import Foundation

public struct AppContainer: Sendable {
    public let engine: PomodoroEngine
    public let sessionRepository: SessionRepository
    public let notificationScheduler: NotificationScheduling
    public let systemEventMonitor: SystemEventMonitoring
    public let logger: AppLogging
    public let statisticsAggregator: StatisticsAggregator

    public init(
        engine: PomodoroEngine = .init(),
        sessionRepository: SessionRepository = InMemorySessionRepository(),
        notificationScheduler: NotificationScheduling = NoopNotificationScheduler(),
        systemEventMonitor: SystemEventMonitoring = NoopSystemEventMonitor(),
        logger: AppLogging = ConsoleLogger(),
        statisticsAggregator: StatisticsAggregator = .init()
    ) {
        self.engine = engine
        self.sessionRepository = sessionRepository
        self.notificationScheduler = notificationScheduler
        self.systemEventMonitor = systemEventMonitor
        self.logger = logger
        self.statisticsAggregator = statisticsAggregator
    }
}
