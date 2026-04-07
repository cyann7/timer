import Foundation
import SwiftData

@Model
final class SwiftDataFocusSessionRecord {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date
    var phaseRawValue: String
    var completed: Bool

    init(
        id: UUID,
        startedAt: Date,
        endedAt: Date,
        phaseRawValue: String,
        completed: Bool
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.phaseRawValue = phaseRawValue
        self.completed = completed
    }

    convenience init(session: FocusSession) {
        self.init(
            id: session.id,
            startedAt: session.startedAt,
            endedAt: session.endedAt,
            phaseRawValue: session.phase.rawValue,
            completed: session.completed
        )
    }

    func update(from session: FocusSession) {
        startedAt = session.startedAt
        endedAt = session.endedAt
        phaseRawValue = session.phase.rawValue
        completed = session.completed
    }

    func toDomain() -> FocusSession {
        FocusSession(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            phase: PomodoroPhase(rawValue: phaseRawValue) ?? .focus,
            completed: completed
        )
    }
}
