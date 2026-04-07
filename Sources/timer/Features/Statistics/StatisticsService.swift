import Foundation

public struct StatisticsService: Sendable {
    private let repository: SessionRepository
    private let aggregator: StatisticsAggregator

    public init(repository: SessionRepository, aggregator: StatisticsAggregator = .init()) {
        self.repository = repository
        self.aggregator = aggregator
    }

    public func loadSummary(referenceDate: Date = Date()) async throws -> StatisticsSummary {
        let sessions = try await repository.allSessions()
        return aggregator.summarize(sessions: sessions, referenceDate: referenceDate)
    }
}
