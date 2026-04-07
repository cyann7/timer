import Foundation

public struct PomodoroSettings: Sendable, Equatable, Codable {
    public var focusDuration: TimeInterval
    public var shortBreakDuration: TimeInterval
    public var longBreakDuration: TimeInterval
    public var cyclesBeforeLongBreak: Int
    public var soundEnabled: Bool
    public var notificationEnabled: Bool
    public var menuBarShowIcon: Bool
    public var menuBarShowTime: Bool
    public var menuBarShowSeconds: Bool

    public init(
        focusDuration: TimeInterval = 25 * 60,
        shortBreakDuration: TimeInterval = 5 * 60,
        longBreakDuration: TimeInterval = 15 * 60,
        cyclesBeforeLongBreak: Int = 4,
        soundEnabled: Bool = true,
        notificationEnabled: Bool = true,
        menuBarShowIcon: Bool = true,
        menuBarShowTime: Bool = true,
        menuBarShowSeconds: Bool = false
    ) {
        self.focusDuration = focusDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.cyclesBeforeLongBreak = max(cyclesBeforeLongBreak, 1)
        self.soundEnabled = soundEnabled
        self.notificationEnabled = notificationEnabled
        self.menuBarShowIcon = menuBarShowIcon
        self.menuBarShowTime = menuBarShowTime
        self.menuBarShowSeconds = menuBarShowSeconds
    }

    public func duration(for phase: PomodoroPhase) -> TimeInterval {
        switch phase {
        case .focus:
            return focusDuration
        case .shortBreak:
            return shortBreakDuration
        case .longBreak:
            return longBreakDuration
        }
    }
}
