import Foundation

public protocol SessionRepository: Sendable {
    func save(_ session: FocusSession) async throws
    func allSessions() async throws -> [FocusSession]
}
