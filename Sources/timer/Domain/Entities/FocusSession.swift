import Foundation

public struct FocusSession: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let startedAt: Date
    public let endedAt: Date
    public let phase: PomodoroPhase
    public let completed: Bool

    public init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date,
        phase: PomodoroPhase,
        completed: Bool
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.phase = phase
        self.completed = completed
    }

    public var duration: TimeInterval {
        endedAt.timeIntervalSince(startedAt)
    }
}
