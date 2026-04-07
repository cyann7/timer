import Foundation

public struct DesignSpacing: Sendable, Equatable {
    public let xs: Double
    public let sm: Double
    public let md: Double
    public let lg: Double

    public init(xs: Double = 4, sm: Double = 8, md: Double = 12, lg: Double = 16) {
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
    }
}

public struct DesignRadius: Sendable, Equatable {
    public let sm: Double
    public let md: Double
    public let lg: Double

    public init(sm: Double = 8, md: Double = 12, lg: Double = 16) {
        self.sm = sm
        self.md = md
        self.lg = lg
    }
}

public struct DesignTokens: Sendable, Equatable {
    public let spacing: DesignSpacing
    public let radius: DesignRadius

    public init(
        spacing: DesignSpacing = .init(),
        radius: DesignRadius = .init()
    ) {
        self.spacing = spacing
        self.radius = radius
    }
}
