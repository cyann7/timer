import Foundation

public struct PomodoroSnapshot: Sendable, Equatable {
    public let phase: PomodoroPhase
    public let remaining: TimeInterval
    public let isRunning: Bool
    public let isPaused: Bool
    public let completedFocusCycles: Int
    public let phaseStartedAt: Date?
    public let phaseEndsAt: Date?

    public init(
        phase: PomodoroPhase,
        remaining: TimeInterval,
        isRunning: Bool,
        isPaused: Bool,
        completedFocusCycles: Int,
        phaseStartedAt: Date?,
        phaseEndsAt: Date?
    ) {
        self.phase = phase
        self.remaining = remaining
        self.isRunning = isRunning
        self.isPaused = isPaused
        self.completedFocusCycles = completedFocusCycles
        self.phaseStartedAt = phaseStartedAt
        self.phaseEndsAt = phaseEndsAt
    }
}

public struct PomodoroEngineOutput: Sendable, Equatable {
    public let snapshot: PomodoroSnapshot
    public let finishedSession: FocusSession?

    public init(snapshot: PomodoroSnapshot, finishedSession: FocusSession?) {
        self.snapshot = snapshot
        self.finishedSession = finishedSession
    }
}

public actor PomodoroEngine {
    private let settings: PomodoroSettings
    private var phase: PomodoroPhase
    private var completedFocusCycles: Int
    private var phaseStartedAt: Date?
    private var phaseEndsAt: Date?
    private var pausedRemaining: TimeInterval?

    public init(settings: PomodoroSettings = .init()) {
        self.settings = settings
        self.phase = .focus
        self.completedFocusCycles = 0
    }

    public func start(at now: Date = Date()) -> PomodoroEngineOutput {
        if phaseEndsAt != nil || pausedRemaining != nil {
            return .init(snapshot: snapshot(now: now), finishedSession: nil)
        }
        beginPhase(phase, at: now)
        return .init(snapshot: snapshot(now: now), finishedSession: nil)
    }

    public func pause(at now: Date = Date()) -> PomodoroEngineOutput {
        guard let end = phaseEndsAt else {
            return .init(snapshot: snapshot(now: now), finishedSession: nil)
        }
        pausedRemaining = max(0, end.timeIntervalSince(now))
        phaseEndsAt = nil
        return .init(snapshot: snapshot(now: now), finishedSession: nil)
    }

    public func resume(at now: Date = Date()) -> PomodoroEngineOutput {
        guard let remaining = pausedRemaining else {
            return .init(snapshot: snapshot(now: now), finishedSession: nil)
        }
        phaseStartedAt = now
        phaseEndsAt = now.addingTimeInterval(remaining)
        pausedRemaining = nil
        return .init(snapshot: snapshot(now: now), finishedSession: nil)
    }

    public func sync(at now: Date = Date()) -> PomodoroEngineOutput {
        guard let end = phaseEndsAt else {
            return .init(snapshot: snapshot(now: now), finishedSession: nil)
        }
        guard now >= end else {
            return .init(snapshot: snapshot(now: now), finishedSession: nil)
        }
        let finished = makeFinishedSession(start: phaseStartedAt ?? now, end: end, completed: true)
        transitionAfterCompletion(at: now)
        return .init(snapshot: snapshot(now: now), finishedSession: finished)
    }

    public func skip(at now: Date = Date()) -> PomodoroEngineOutput {
        let finished: FocusSession?
        if let start = phaseStartedAt {
            finished = makeFinishedSession(start: start, end: now, completed: false)
        } else {
            finished = nil
        }
        transitionAfterSkip(at: now)
        return .init(snapshot: snapshot(now: now), finishedSession: finished)
    }

    public func stop(at now: Date = Date()) -> PomodoroEngineOutput {
        phaseStartedAt = nil
        phaseEndsAt = nil
        pausedRemaining = nil
        return .init(snapshot: snapshot(now: now), finishedSession: nil)
    }

    public func currentSnapshot(at now: Date = Date()) -> PomodoroSnapshot {
        snapshot(now: now)
    }

    private func beginPhase(_ phase: PomodoroPhase, at now: Date) {
        self.phase = phase
        phaseStartedAt = now
        phaseEndsAt = now.addingTimeInterval(settings.duration(for: phase))
        pausedRemaining = nil
    }

    private func transitionAfterCompletion(at now: Date) {
        if phase == .focus {
            completedFocusCycles += 1
            if completedFocusCycles % settings.cyclesBeforeLongBreak == 0 {
                beginPhase(.longBreak, at: now)
            } else {
                beginPhase(.shortBreak, at: now)
            }
            return
        }
        beginPhase(.focus, at: now)
    }

    private func transitionAfterSkip(at now: Date) {
        if phase == .focus {
            beginPhase(.shortBreak, at: now)
            return
        }
        beginPhase(.focus, at: now)
    }

    private func makeFinishedSession(start: Date, end: Date, completed: Bool) -> FocusSession {
        FocusSession(
            startedAt: start,
            endedAt: end,
            phase: phase,
            completed: completed
        )
    }

    private func snapshot(now: Date) -> PomodoroSnapshot {
        let remaining: TimeInterval
        if let pausedRemaining {
            remaining = pausedRemaining
        } else if let phaseEndsAt {
            remaining = max(0, phaseEndsAt.timeIntervalSince(now))
        } else {
            remaining = settings.duration(for: phase)
        }

        return .init(
            phase: phase,
            remaining: remaining,
            isRunning: phaseEndsAt != nil,
            isPaused: pausedRemaining != nil,
            completedFocusCycles: completedFocusCycles,
            phaseStartedAt: phaseStartedAt,
            phaseEndsAt: phaseEndsAt
        )
    }
}
