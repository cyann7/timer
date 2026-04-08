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
    @Published var dailyStats: [DailyStatItem] = []
    @Published var showPhaseCompletionAlert = false
    @Published var completedPhaseName: String = ""
    @Published var nextPhaseAction: String = ""

    struct DailyStatItem: Identifiable {
        let id = UUID()
        let date: Date
        let pomodoros: Int
        let focusMinutes: Int
    }

    @Published var focusDuration: TimeInterval = 25 * 60 {
        didSet { Task { await saveSettings() } }
    }
    @Published var shortBreakDuration: TimeInterval = 5 * 60 {
        didSet { Task { await saveSettings() } }
    }
    @Published var longBreakDuration: TimeInterval = 15 * 60 {
        didSet { Task { await saveSettings() } }
    }
    @Published var cyclesBeforeLongBreak: Int = 4 {
        didSet { Task { await saveSettings() } }
    }
    @Published var soundEnabled: Bool = true {
        didSet { Task { await saveSettings() } }
    }
    @Published var notificationEnabled: Bool = true {
        didSet { Task { await saveSettings() } }
    }
    @Published var menuBarShowIcon: Bool = true {
        didSet { Task { await saveSettings() } }
    }
    @Published var menuBarShowTime: Bool = true {
        didSet { Task { await saveSettings() } }
    }
    @Published var menuBarShowSeconds: Bool = false {
        didSet { Task { await saveSettings() } }
    }
    @Published var remainingSeconds: Int = 25 * 60

    private let repository: SessionRepository
    private let settingsStore: SettingsStore
    private let presenter = MenuBarPresenter()
    private var coordinator: PomodoroCoordinator?
    private var isBootstrapped = false
    private var ticker: Timer?

    init(repository: SessionRepository? = nil, settingsStore: SettingsStore? = nil) {
        self.repository = repository ?? TimerAppViewModel.makeDefaultRepository()
        self.settingsStore = settingsStore ?? SettingsStore()
    }

    var menuBarTitle: String {
        var parts: [String] = []
        if menuBarShowIcon {
            parts.append("🍅")
        }
        if menuBarShowTime {
            if menuBarShowSeconds {
                parts.append(remainingText)
            } else {
                let minutes = (remainingSeconds + 59) / 60
                parts.append("\(minutes)m")
            }
        }
        return parts.isEmpty ? "🍅" : parts.joined(separator: " ")
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

    var canSkipBeforeStart: Bool {
        !isRunning && !isPaused && phaseText != "focus"
    }

    func bootstrapIfNeeded() async {
        guard !isBootstrapped else { return }

        let loadedSettings = await settingsStore.load()
        focusDuration = loadedSettings.focusDuration
        shortBreakDuration = loadedSettings.shortBreakDuration
        longBreakDuration = loadedSettings.longBreakDuration
        cyclesBeforeLongBreak = loadedSettings.cyclesBeforeLongBreak
        soundEnabled = loadedSettings.soundEnabled
        notificationEnabled = loadedSettings.notificationEnabled
        menuBarShowIcon = loadedSettings.menuBarShowIcon
        menuBarShowTime = loadedSettings.menuBarShowTime
        menuBarShowSeconds = loadedSettings.menuBarShowSeconds

        let engine = PomodoroEngine(settings: loadedSettings)
        let notification = UserNotificationScheduler()
        await notification.requestAuthorizationIfNeeded()

        coordinator = await PomodoroCoordinator(
            engine: engine,
            repository: repository,
            notificationScheduler: notification,
            settingsStore: settingsStore
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

    func confirmAndContinue() async {
        guard let coordinator else { return }
        await coordinator.confirmAndContinue()
        showPhaseCompletionAlert = false
        refreshFromSnapshot()
        await refreshStatistics()
    }

    func confirmAndStop() async {
        guard let coordinator else { return }
        await coordinator.confirmAndStop()
        showPhaseCompletionAlert = false
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

        // Build daily stats for the past 7 days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var stats: [DailyStatItem] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            if let dailyStat = summary.daily.first(where: { calendar.isDate($0.dayStart, inSameDayAs: date) }) {
                stats.append(DailyStatItem(
                    date: date,
                    pomodoros: dailyStat.completedPomodoros,
                    focusMinutes: Int(dailyStat.totalFocusDuration / 60)
                ))
            } else {
                stats.append(DailyStatItem(date: date, pomodoros: 0, focusMinutes: 0))
            }
        }
        dailyStats = stats
    }

    func menuBarSubtitle() -> String {
        guard let coordinator else { return remainingText }
        return presenter.present(snapshot: coordinator.snapshot).subtitle
    }

    private func saveSettings() async {
        guard let coordinator else { return }
        let newSettings = PomodoroSettings(
            focusDuration: focusDuration,
            shortBreakDuration: shortBreakDuration,
            longBreakDuration: longBreakDuration,
            cyclesBeforeLongBreak: cyclesBeforeLongBreak,
            soundEnabled: soundEnabled,
            notificationEnabled: notificationEnabled,
            menuBarShowIcon: menuBarShowIcon,
            menuBarShowTime: menuBarShowTime,
            menuBarShowSeconds: menuBarShowSeconds
        )
        await coordinator.updateSettings(newSettings)
        refreshFromSnapshot()
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
        remainingSeconds = Int(snapshot.remaining)
        remainingText = Self.format(seconds: remainingSeconds)
        isRunning = snapshot.isRunning
        isPaused = snapshot.isPaused

        if snapshot.awaitingConfirmation && !showPhaseCompletionAlert {
            if let completed = snapshot.completedPhase {
                completedPhaseName = Self.phaseDisplayName(completed)
                nextPhaseAction = Self.nextPhaseActionName(completed)
            }
            showPhaseCompletionAlert = true
        }
    }

    private static func phaseDisplayName(_ phase: PomodoroPhase) -> String {
        switch phase {
        case .focus: return "专注"
        case .shortBreak: return "短休息"
        case .longBreak: return "长休息"
        }
    }

    private static func nextPhaseActionName(_ completedPhase: PomodoroPhase) -> String {
        switch completedPhase {
        case .focus: return "开始休息"
        case .shortBreak, .longBreak: return "开始专注"
        }
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
