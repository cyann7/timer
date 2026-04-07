import Foundation
import SwiftUI
import Combine
import timer

@MainActor
final class TimerAppViewModel: ObservableObject {
    @Published var phaseText = "focus"
    @Published var remainingText = "25:00"
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var weekPomodoros = 0
    @Published var weekFocusMinutes = 0

    private let repository: SessionRepository
    private let presenter = MenuBarPresenter()
    private var coordinator: PomodoroCoordinator?
    private var isBootstrapped = false
    private var ticker: Timer?

    init(repository: SessionRepository = Self.makeDefaultRepository()) {
        self.repository = repository
    }

    var menuBarTitle: String {
        remainingText
    }

    var canStart: Bool {
        !isRunning && !isPaused
    }

    var canPause: Bool {
        isRunning
    }

    var canResume: Bool {
        isPaused
    }

    var canStop: Bool {
        isPaused
    }

    var canSkip: Bool {
        isRunning || isPaused
    }

    func bootstrapIfNeeded() async {
        guard !isBootstrapped else { return }
        let engine = PomodoroEngine()
        let notification = NoopNotificationScheduler()
        coordinator = await PomodoroCoordinator(
            engine: engine,
            repository: repository,
            notificationScheduler: notification
        )
        isBootstrapped = true
        refreshFromSnapshot()
        startTicker()
        await refreshStatistics()
    }

    func start() async {
        guard let coordinator else { return }
        try? await coordinator.start()
        refreshFromSnapshot()
    }

    func pause() async {
        guard let coordinator else { return }
        await coordinator.pause()
        refreshFromSnapshot()
    }

    func resume() async {
        guard let coordinator else { return }
        await coordinator.resume()
        refreshFromSnapshot()
    }

    func skip() async {
        guard let coordinator else { return }
        try? await coordinator.skip()
        refreshFromSnapshot()
        await refreshStatistics()
    }

    func stop() async {
        guard let coordinator else { return }
        await coordinator.stop()
        refreshFromSnapshot()
    }

    func syncTick() async {
        guard let coordinator else { return }
        try? await coordinator.sync()
        refreshFromSnapshot()
        await refreshStatistics()
    }

    func refreshStatistics() async {
        let service = StatisticsService(repository: repository)
        guard let summary = try? await service.loadSummary() else { return }
        weekPomodoros = summary.weekCompletedPomodoros
        weekFocusMinutes = Int(summary.weekTotalFocusDuration / 60)
    }

    func menuBarSubtitle() -> String {
        guard let coordinator else { return remainingText }
        return presenter.present(snapshot: coordinator.snapshot).subtitle
    }

    private func startTicker() {
        ticker?.invalidate()
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.syncTick()
            }
        }
    }

    private func refreshFromSnapshot() {
        guard let coordinator else { return }
        let snapshot = coordinator.snapshot
        phaseText = snapshot.phase.rawValue
        remainingText = Self.format(seconds: Int(snapshot.remaining))
        isRunning = snapshot.isRunning
        isPaused = snapshot.isPaused
    }

    private static func format(seconds: Int) -> String {
        let min = max(seconds, 0) / 60
        let sec = max(seconds, 0) % 60
        return String(format: "%02d:%02d", min, sec)
    }

    private static func makeDefaultRepository() -> SessionRepository {
        if let repository = try? SwiftDataSessionRepository() {
            return repository
        }
        return InMemorySessionRepository()
    }
}
