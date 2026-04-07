import Foundation

public protocol AppLogging: Sendable {
    func info(_ message: String)
    func error(_ message: String)
}

public struct ConsoleLogger: AppLogging {
    public init() {}

    public func info(_ message: String) {
        print("INFO: \(message)")
    }

    public func error(_ message: String) {
        print("ERROR: \(message)")
    }
}
