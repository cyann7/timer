import Foundation

public protocol NotificationScheduling: Sendable {
    func requestAuthorizationIfNeeded() async
    func schedulePhaseFinishedNotification(phase: PomodoroPhase, fireAt: Date, settings: PomodoroSettings) async
    func cancelPendingNotifications() async
}

public actor NoopNotificationScheduler: NotificationScheduling {
    public init() {}

    public func requestAuthorizationIfNeeded() async {}

    public func schedulePhaseFinishedNotification(phase: PomodoroPhase, fireAt: Date, settings: PomodoroSettings) async {}

    public func cancelPendingNotifications() async {}
}
