//
//  Animations.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//  Updated for iOS 26 design
//

import SwiftUI

// MARK: - iOS 26 Animation Presets
extension Animation {
    // iOS 26 новые spring animations
    static let smooth = Animation.spring(duration: 0.4, bounce: 0.25)
    static let bouncy = Animation.spring(duration: 0.5, bounce: 0.4)
    static let snappy = Animation.spring(duration: 0.3, bounce: 0.15)
    static let quick = Animation.easeInOut(duration: 0.2)
    static let card = Animation.spring(duration: 0.35, bounce: 0.2)
    
    // iOS 26 fluid animations
    static let fluid = Animation.interpolatingSpring(stiffness: 300, damping: 30)
    static let gentle = Animation.interpolatingSpring(stiffness: 200, damping: 25)
}

// MARK: - iOS 26 Transition Modifiers
extension AnyTransition {
    static var swipeUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
    
    static var swipeDown: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }
    
    static var swipeRight: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .scale(scale: 0.9))
        )
    }
    
    static var swipeLeft: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .scale(scale: 0.9))
        )
    }
    
    static var popup: AnyTransition {
        .scale(scale: 0.85).combined(with: .opacity)
    }
    
    // iOS 26 новые transitions
    static var zoom: AnyTransition {
        .scale(scale: 1.2).combined(with: .opacity)
    }
    
    static var blur: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.95))
    }
}

// MARK: - iOS 26 View Modifiers for Animations
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

// iOS 26 Bounce Effect
struct BounceEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = sin(animatableData * .pi) * 20
        return ProjectionTransform(CGAffineTransform(translationX: 0, y: -translation))
    }
}

// iOS 26 Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: isAnimating ? 300 : -300)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

extension View {
    func shake(with value: Int) -> some View {
        self.modifier(ShakeEffect(animatableData: CGFloat(value)))
    }
    
    func bounce(isActive: Bool) -> some View {
        self.modifier(BounceEffect(animatableData: isActive ? 1 : 0))
    }
    
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
    
    func cardFlip(isFlipped: Bool) -> some View {
        self.rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
    }
    
    func pulseEffect(isActive: Bool) -> some View {
        self.scaleEffect(isActive ? 1.08 : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isActive)
    }
    
    // iOS 26 новый breathe effect
    func breatheEffect(isActive: Bool) -> some View {
        self.scaleEffect(isActive ? 1.05 : 1.0)
            .opacity(isActive ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isActive)
    }
    
    // iOS 26 glow effect
    func glowEffect(color: Color = .brandPrimary, radius: CGFloat = 20) -> some View {
        self.shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
    }
}

