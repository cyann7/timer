import Foundation
import SwiftData

public actor SwiftDataSessionRepository: SessionRepository {
    private let container: ModelContainer

    public init(container: ModelContainer) {
        self.container = container
    }

    public init(inMemory: Bool = false) throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        let container = try ModelContainer(
            for: SwiftDataFocusSessionRecord.self,
            configurations: configuration
        )
        self.container = container
    }

    public func save(_ session: FocusSession) async throws {
        let context = ModelContext(container)
        let sessionId = session.id
        let descriptor = FetchDescriptor<SwiftDataFocusSessionRecord>(
            predicate: #Predicate { record in
                record.id == sessionId
            }
        )
        if let existing = try context.fetch(descriptor).first {
            existing.update(from: session)
        } else {
            context.insert(SwiftDataFocusSessionRecord(session: session))
        }
        try context.save()
    }

    public func allSessions() async throws -> [FocusSession] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<SwiftDataFocusSessionRecord>(
            sortBy: [SortDescriptor(\.startedAt, order: .forward)]
        )
        return try context.fetch(descriptor).map { $0.toDomain() }
    }
}
