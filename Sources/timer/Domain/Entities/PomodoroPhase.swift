import Foundation

public enum PomodoroPhase: String, Codable, Sendable, CaseIterable {
    case focus
    case shortBreak
    case longBreak
}
