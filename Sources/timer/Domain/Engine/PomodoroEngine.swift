import Foundation

public struct PomodoroSnapshot: Sendable, Equatable {
    public let phase: PomodoroPhase
    public let remaining: TimeInterval
    public let isRunning: Bool
    public let isPaused: Bool
    public let completedFocusCycles: Int
    public let phaseStartedAt: Date?
    public let phaseEndsAt: Date?
    public let awaitingConfirmation: Bool
    public let completedPhase: PomodoroPhase?

    public init(
        phase: PomodoroPhase,
        remaining: TimeInterval,
        isRunning: Bool,
        isPaused: Bool,
        completedFocusCycles: Int,
        phaseStartedAt: Date?,
        phaseEndsAt: Date?,
        awaitingConfirmation: Bool = false,
        completedPhase: PomodoroPhase? = nil
    ) {
        self.phase = phase
        self.remaining = remaining
        self.isRunning = isRunning
        self.isPaused = isPaused
        self.completedFocusCycles = completedFocusCycles
        self.phaseStartedAt = phaseStartedAt
        self.phaseEndsAt = phaseEndsAt
        self.awaitingConfirmation = awaitingConfirmation
        self.completedPhase = completedPhase
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
    private var settings: PomodoroSettings
    private var phase: PomodoroPhase
    private var completedFocusCycles: Int
    private var phaseStartedAt: Date?
    private var phaseEndsAt: Date?
    private var pausedRemaining: TimeInterval?
    private var awaitingConfirmation: Bool = false
    private var completedPhase: PomodoroPhase?

    public init(settings: PomodoroSettings = .init()) {
        self.settings = settings
        self.phase = .focus
        self.completedFocusCycles = 0
    }

    public func updateSettings(_ newSettings: PomodoroSettings) -> PomodoroSnapshot {
        let wasIdle = phaseEndsAt == nil && pausedRemaining == nil
        settings = newSettings
        if wasIdle {
            // Update displayed remaining time when not running
        }
        return snapshot(now: Date())
    }

    public func currentSettings() -> PomodoroSettings {
        settings
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
        // Phase completed, wait for user confirmation
        let finished = makeFinishedSession(start: phaseStartedAt ?? now, end: end, completed: true)
        awaitingConfirmation = true
        completedPhase = phase
        phaseEndsAt = nil
        phaseStartedAt = nil
        return .init(snapshot: snapshot(now: now), finishedSession: finished)
    }

    public func confirmAndContinue(at now: Date = Date()) -> PomodoroEngineOutput {
        guard awaitingConfirmation else {
            return .init(snapshot: snapshot(now: now), finishedSession: nil)
        }
        awaitingConfirmation = false
        let previousPhase = completedPhase ?? phase
        completedPhase = nil
        transitionAfterCompletion(previousPhase: previousPhase, at: now)
        return .init(snapshot: snapshot(now: now), finishedSession: nil)
    }

    public func confirmAndStop(at now: Date = Date()) -> PomodoroEngineOutput {
        awaitingConfirmation = false
        completedPhase = nil
        phaseStartedAt = nil
        phaseEndsAt = nil
        pausedRemaining = nil
        phase = .focus
        return .init(snapshot: snapshot(now: now), finishedSession: nil)
    }

    public func skip(at now: Date = Date()) -> PomodoroEngineOutput {
        let finished: FocusSession?
        if let start = phaseStartedAt {
            finished = makeFinishedSession(start: start, end: now, completed: false)
        } else {
            finished = nil
        }
        let wasRunning = phaseEndsAt != nil || pausedRemaining != nil
        transitionAfterSkip(at: now, autoStart: wasRunning)
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

    private func transitionAfterCompletion(previousPhase: PomodoroPhase, at now: Date) {
        if previousPhase == .focus {
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

    private func transitionAfterSkip(at now: Date, autoStart: Bool) {
        if phase == .focus {
            if autoStart {
                beginPhase(.shortBreak, at: now)
            } else {
                phase = .shortBreak
            }
            return
        }
        if autoStart {
            beginPhase(.focus, at: now)
        } else {
            phase = .focus
        }
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
            phaseEndsAt: phaseEndsAt,
            awaitingConfirmation: awaitingConfirmation,
            completedPhase: completedPhase
        )
    }
}
