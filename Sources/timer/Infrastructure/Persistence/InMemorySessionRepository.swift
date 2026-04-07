import Foundation

public actor InMemorySessionRepository: SessionRepository {
    private var sessions: [FocusSession] = []

    public init() {}

    public func save(_ session: FocusSession) async throws {
        sessions.append(session)
    }

    public func allSessions() async throws -> [FocusSession] {
        sessions
    }
}
