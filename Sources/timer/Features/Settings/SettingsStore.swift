import Foundation

public actor SettingsStore {
    private var settings: PomodoroSettings

    public init(settings: PomodoroSettings = .init()) {
        self.settings = settings
    }

    public func load() -> PomodoroSettings {
        settings
    }

    public func update(_ newValue: PomodoroSettings) {
        settings = newValue
    }
}
