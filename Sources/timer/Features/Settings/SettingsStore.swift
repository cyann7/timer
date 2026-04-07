import Foundation

public actor SettingsStore {
    private static let userDefaultsKey = "PomodoroSettings"
    private var settings: PomodoroSettings

    public init(settings: PomodoroSettings = .init()) {
        if let loaded = Self.loadFromDisk() {
            self.settings = loaded
        } else {
            self.settings = settings
        }
    }

    public func load() -> PomodoroSettings {
        settings
    }

    public func update(_ newValue: PomodoroSettings) {
        settings = newValue
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
    }

    private static func loadFromDisk() -> PomodoroSettings? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
        return try? JSONDecoder().decode(PomodoroSettings.self, from: data)
    }
}
