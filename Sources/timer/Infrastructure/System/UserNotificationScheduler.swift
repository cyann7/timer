import Foundation
import UserNotifications

public actor UserNotificationScheduler: NotificationScheduling {
    private let notificationCenter: UNUserNotificationCenter

    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    public func requestAuthorizationIfNeeded() async {
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
    }

    public func schedulePhaseFinishedNotification(phase: PomodoroPhase, fireAt: Date, settings: PomodoroSettings) async {
        guard settings.notificationEnabled else { return }

        await cancelPendingNotifications()

        let content = UNMutableNotificationContent()
        content.title = notificationTitle(for: phase)
        content.body = notificationBody(for: phase)

        if settings.soundEnabled {
            content.sound = .default
        }
        if #available(macOS 12.0, *) {
            content.interruptionLevel = .timeSensitive
        }

        let interval = max(fireAt.timeIntervalSinceNow, 0.1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: "phase-finished", content: content, trigger: trigger)

        try? await notificationCenter.add(request)
    }

    public func cancelPendingNotifications() async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["phase-finished"])
    }

    private func notificationTitle(for phase: PomodoroPhase) -> String {
        switch phase {
        case .focus:
            return "专注时间结束"
        case .shortBreak:
            return "短休息结束"
        case .longBreak:
            return "长休息结束"
        }
    }

    private func notificationBody(for phase: PomodoroPhase) -> String {
        switch phase {
        case .focus:
            return "休息一下吧！"
        case .shortBreak, .longBreak:
            return "准备好开始专注了吗？"
        }
    }
}
