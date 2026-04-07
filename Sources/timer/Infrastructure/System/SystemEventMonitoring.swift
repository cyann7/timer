import Foundation

public protocol SystemEventMonitoring: Sendable {
    func startMonitoring() async
}

public actor NoopSystemEventMonitor: SystemEventMonitoring {
    public init() {}

    public func startMonitoring() async {}
}
