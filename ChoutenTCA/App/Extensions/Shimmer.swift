//
//
// Copied from SwiftUI-Shimmer, to adjust colors
//
//

import SwiftUI

public struct Shimmer: ViewModifier {
    let animation: Animation
    @State private var phase: CGFloat = 0

    /// Initializes his modifier with a custom animation,
    /// - Parameter animation: A custom animation. The default animation is
    ///   `.linear(duration: 1.5).repeatForever(autoreverses: false)`.
    public init(animation: Animation = Self.defaultAnimation) {
        self.animation = animation
    }

    /// The default animation effect.
    public static let defaultAnimation = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)

    /// Convenience, backward-compatible initializer.
    /// - Parameters:
    ///   - duration: The duration of a shimmer cycle in seconds. Default: `1.5`.
    ///   - bounce: Whether to bounce (reverse) the animation back and forth. Defaults to `false`.
    ///   - delay:A delay in seconds. Defaults to `0`.
    public init(duration: Double = 1.5, bounce: Bool = false, delay: Double = 0) {
        self.animation = .linear(duration: duration)
            .repeatForever(autoreverses: bounce)
            .delay(delay)
    }

    public func body(content: Content) -> some View {
        content
            .modifier(
                AnimatedMask(phase: phase).animation(animation)
            )
            .onAppear { phase = 0.8 }
    }

    /// An animatable modifier to interpolate between `phase` values.
    struct AnimatedMask: AnimatableModifier {
        var phase: CGFloat = 0

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            content
                .mask(GradientMask(phase: phase).scaleEffect(3))
        }
    }

    /// A slanted, animatable gradient between transparent and opaque to use as mask.
    /// The `phase` parameter shifts the gradient, moving the opaque band.
    struct GradientMask: View {
        let phase: CGFloat
        let centerColor = Color(hex: "#8f8b8b")
        let edgeColor = Color.white.opacity(0)
        @Environment(\.layoutDirection) private var layoutDirection

        var body: some View {
            let isRightToLeft = layoutDirection == .rightToLeft
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: edgeColor, location: phase),
                    .init(color: centerColor, location: phase + 0.1),
                    .init(color: edgeColor, location: phase + 0.2)
                ]),
                startPoint: isRightToLeft ? .bottomTrailing : .topLeading,
                endPoint: isRightToLeft ? .topLeading : .bottomTrailing
            )
        }
    }
}

public extension View {
    /// Adds an animated shimmering effect to any view, typically to show that
    /// an operation is in progress.
    /// - Parameters:
    ///   - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
    ///   - duration: The duration of a shimmer cycle in seconds. Default: `1.5`.
    ///   - bounce: Whether to bounce (reverse) the animation back and forth. Defaults to `false`.
    ///   - delay:A delay in seconds. Defaults to `0`.
    @ViewBuilder func shimmer(
        active: Bool = true, duration: Double = 2, bounce: Bool = false, delay: Double = 0
    ) -> some View {
        if active {
            modifier(Shimmer(duration: duration, bounce: bounce, delay: delay))
        } else {
            self
        }
    }

    /// Adds an animated shimmering effect to any view, typically to show that
    /// an operation is in progress.
    /// - Parameters:
    ///   - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
    ///   - animation: A custom animation. The default animation is
    ///   `.linear(duration: 1.5).repeatForever(autoreverses: false)`.
    @ViewBuilder func shimmering(active: Bool = true, animation: Animation = Shimmer.defaultAnimation) -> some View {
        if active {
            modifier(Shimmer(animation: animation))
        } else {
            self
        }
    }
}
