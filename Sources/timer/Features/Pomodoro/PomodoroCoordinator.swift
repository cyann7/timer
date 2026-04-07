import Foundation

@MainActor
public final class PomodoroCoordinator {
    private let engine: PomodoroEngine
    private let repository: SessionRepository
    private let notificationScheduler: NotificationScheduling
    private let settingsStore: SettingsStore
    private(set) public var snapshot: PomodoroSnapshot

    public init(
        engine: PomodoroEngine,
        repository: SessionRepository,
        notificationScheduler: NotificationScheduling,
        settingsStore: SettingsStore
    ) async {
        self.engine = engine
        self.repository = repository
        self.notificationScheduler = notificationScheduler
        self.settingsStore = settingsStore
        self.snapshot = await engine.currentSnapshot()
    }

    public func start(now: Date = Date()) async throws {
        let output = await engine.start(at: now)
        snapshot = output.snapshot
        if let end = snapshot.phaseEndsAt {
            let settings = await settingsStore.load()
            await notificationScheduler.schedulePhaseFinishedNotification(phase: snapshot.phase, fireAt: end, settings: settings)
        }
    }

    public func pause(now: Date = Date()) async {
        snapshot = await engine.pause(at: now).snapshot
        await notificationScheduler.cancelPendingNotifications()
    }

    public func resume(now: Date = Date()) async {
        let output = await engine.resume(at: now)
        snapshot = output.snapshot
        if let end = snapshot.phaseEndsAt {
            let settings = await settingsStore.load()
            await notificationScheduler.schedulePhaseFinishedNotification(phase: snapshot.phase, fireAt: end, settings: settings)
        }
    }

    public func skip(now: Date = Date()) async throws {
        let output = await engine.skip(at: now)
        snapshot = output.snapshot
        await notificationScheduler.cancelPendingNotifications()
        if let session = output.finishedSession {
            try await repository.save(session)
        }
    }

    public func stop(now: Date = Date()) async {
        snapshot = await engine.stop(at: now).snapshot
        await notificationScheduler.cancelPendingNotifications()
    }

    public func sync(now: Date = Date()) async throws {
        let output = await engine.sync(at: now)
        snapshot = output.snapshot
        if let session = output.finishedSession {
            try await repository.save(session)
        }
    }

    public func confirmAndContinue(now: Date = Date()) async {
        let output = await engine.confirmAndContinue(at: now)
        snapshot = output.snapshot
        if let end = snapshot.phaseEndsAt {
            let settings = await settingsStore.load()
            await notificationScheduler.schedulePhaseFinishedNotification(phase: snapshot.phase, fireAt: end, settings: settings)
        }
    }

    public func confirmAndStop(now: Date = Date()) async {
        snapshot = await engine.confirmAndStop(at: now).snapshot
    }

    public func updateSettings(_ newSettings: PomodoroSettings) async {
        await settingsStore.update(newSettings)
        snapshot = await engine.updateSettings(newSettings)
    }

    public func loadSettings() async -> PomodoroSettings {
        await settingsStore.load()
    }
}
