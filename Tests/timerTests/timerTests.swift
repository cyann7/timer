import Testing
@testable import timer
import Foundation

@Test func pomodoroEngineCompletesAndTransitions() async throws {
    let settings = PomodoroSettings(
        focusDuration: 60,
        shortBreakDuration: 30,
        longBreakDuration: 90,
        cyclesBeforeLongBreak: 2
    )
    let engine = PomodoroEngine(settings: settings)
    let start = Date(timeIntervalSince1970: 10_000)

    let started = await engine.start(at: start).snapshot
    #expect(started.phase == .focus)
    #expect(started.isRunning)

    let done = await engine.sync(at: start.addingTimeInterval(61))
    #expect(done.finishedSession != nil)
    #expect(done.finishedSession?.phase == .focus)
    #expect(done.finishedSession?.completed == true)
    #expect(done.snapshot.awaitingConfirmation == true)
    #expect(done.snapshot.completedPhase == .focus)

    // User confirms to continue
    let confirmed = await engine.confirmAndContinue(at: start.addingTimeInterval(62))
    #expect(confirmed.snapshot.phase == .shortBreak)
    #expect(confirmed.snapshot.completedFocusCycles == 1)
    #expect(confirmed.snapshot.awaitingConfirmation == false)
}

@Test func statisticsAggregatorSummarizesFocusSessions() {
    let calendar = Calendar(identifier: .gregorian)
    let day1Start = Date(timeIntervalSince1970: 100_000)
    let day2Start = day1Start.addingTimeInterval(24 * 60 * 60)
    let sessions = [
        FocusSession(
            startedAt: day1Start,
            endedAt: day1Start.addingTimeInterval(25 * 60),
            phase: .focus,
            completed: true
        ),
        FocusSession(
            startedAt: day1Start.addingTimeInterval(26 * 60),
            endedAt: day1Start.addingTimeInterval(51 * 60),
            phase: .focus,
            completed: true
        ),
        FocusSession(
            startedAt: day2Start,
            endedAt: day2Start.addingTimeInterval(5 * 60),
            phase: .shortBreak,
            completed: true
        )
    ]
    let summary = StatisticsAggregator().summarize(
        sessions: sessions,
        referenceDate: day2Start,
        calendar: calendar
    )

    #expect(summary.daily.count == 1)
    #expect(summary.daily[0].completedPomodoros == 2)
    #expect(summary.weekCompletedPomodoros == 2)
    #expect(summary.weekTotalFocusDuration == 50 * 60)
}

@Test func pomodoroEngineStopResetsCurrentPhaseDurationWhenRunning() async {
    let settings = PomodoroSettings(
        focusDuration: 120,
        shortBreakDuration: 30,
        longBreakDuration: 90,
        cyclesBeforeLongBreak: 2
    )
    let engine = PomodoroEngine(settings: settings)
    let start = Date(timeIntervalSince1970: 20_000)

    _ = await engine.start(at: start)
    let stopped = await engine.stop(at: start.addingTimeInterval(40)).snapshot

    #expect(stopped.phase == .focus)
    #expect(stopped.isRunning == false)
    #expect(stopped.isPaused == false)
    #expect(stopped.remaining == 120)
}

@Test func pomodoroEngineStopResetsCurrentPhaseDurationWhenPaused() async {
    let settings = PomodoroSettings(
        focusDuration: 120,
        shortBreakDuration: 30,
        longBreakDuration: 90,
        cyclesBeforeLongBreak: 2
    )
    let engine = PomodoroEngine(settings: settings)
    let start = Date(timeIntervalSince1970: 30_000)

    _ = await engine.start(at: start)
    _ = await engine.pause(at: start.addingTimeInterval(25))
    let stopped = await engine.stop(at: start.addingTimeInterval(30)).snapshot

    #expect(stopped.phase == .focus)
    #expect(stopped.isRunning == false)
    #expect(stopped.isPaused == false)
    #expect(stopped.remaining == 120)
}

@Test func pomodoroEngineTerminateDoesNotAutoStartNextPhase() async {
    let settings = PomodoroSettings(
        focusDuration: 120,
        shortBreakDuration: 30,
        longBreakDuration: 90,
        cyclesBeforeLongBreak: 2
    )
    let engine = PomodoroEngine(settings: settings)
    let start = Date(timeIntervalSince1970: 40_000)

    _ = await engine.start(at: start)
    let terminated = await engine.terminate(at: start.addingTimeInterval(20)).snapshot

    #expect(terminated.phase == .shortBreak)
    #expect(terminated.isRunning == false)
    #expect(terminated.isPaused == false)
    #expect(terminated.remaining == 30)
}

@Test func pomodoroEngineCanStartAnotherPomodoroAfterFocusCompletion() async {
    let settings = PomodoroSettings(
        focusDuration: 60,
        shortBreakDuration: 30,
        longBreakDuration: 90,
        cyclesBeforeLongBreak: 2
    )
    let engine = PomodoroEngine(settings: settings)
    let start = Date(timeIntervalSince1970: 50_000)

    _ = await engine.start(at: start)
    _ = await engine.sync(at: start.addingTimeInterval(61))
    let continued = await engine.confirmAndStartAnotherPomodoro(at: start.addingTimeInterval(62)).snapshot

    #expect(continued.phase == .focus)
    #expect(continued.isRunning == true)
    #expect(continued.completedFocusCycles == 1)
}
