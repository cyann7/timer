import Foundation

@MainActor
public final class PomodoroCoordinator {
    private let engine: PomodoroEngine
    private let repository: SessionRepository
    private let notificationScheduler: NotificationScheduling
    private(set) public var snapshot: PomodoroSnapshot

    public init(
        engine: PomodoroEngine,
        repository: SessionRepository,
        notificationScheduler: NotificationScheduling
    ) async {
        self.engine = engine
        self.repository = repository
        self.notificationScheduler = notificationScheduler
        self.snapshot = await engine.currentSnapshot()
    }

    public func start(now: Date = Date()) async throws {
        let output = await engine.start(at: now)
        snapshot = output.snapshot
        if let end = snapshot.phaseEndsAt {
            await notificationScheduler.schedulePhaseFinishedNotification(phase: snapshot.phase, fireAt: end)
        }
    }

    public func pause(now: Date = Date()) async {
        snapshot = await engine.pause(at: now).snapshot
    }

    public func resume(now: Date = Date()) async {
        let output = await engine.resume(at: now)
        snapshot = output.snapshot
        if let end = snapshot.phaseEndsAt {
            await notificationScheduler.schedulePhaseFinishedNotification(phase: snapshot.phase, fireAt: end)
        }
    }

    public func skip(now: Date = Date()) async throws {
        let output = await engine.skip(at: now)
        snapshot = output.snapshot
        if let session = output.finishedSession {
            try await repository.save(session)
        }
    }

    public func stop(now: Date = Date()) async {
        snapshot = await engine.stop(at: now).snapshot
    }

    public func sync(now: Date = Date()) async throws {
        let output = await engine.sync(at: now)
        snapshot = output.snapshot
        if let session = output.finishedSession {
            try await repository.save(session)
        }
    }
}
