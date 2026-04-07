import Foundation

public struct MenuBarPresentation: Sendable, Equatable {
    public let title: String
    public let subtitle: String

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}

public struct MenuBarPresenter: Sendable {
    public init() {}

    public func present(snapshot: PomodoroSnapshot) -> MenuBarPresentation {
        let minutes = Int(snapshot.remaining) / 60
        let seconds = Int(snapshot.remaining) % 60
        let time = String(format: "%02d:%02d", minutes, seconds)
        return .init(title: snapshot.phase.rawValue, subtitle: time)
    }
}
