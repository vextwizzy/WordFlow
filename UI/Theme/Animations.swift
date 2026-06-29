//
//  Animations.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

// MARK: - Animation Presets
extension Animation {
    static let smooth = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let bouncy = Animation.spring(response: 0.6, dampingFraction: 0.6)
    static let quick = Animation.easeInOut(duration: 0.2)
    static let card = Animation.spring(response: 0.4, dampingFraction: 0.8)
}

// MARK: - Transition Modifiers
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
            removal: .move(edge: .trailing).combined(with: .scale)
        )
    }
    
    static var swipeLeft: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .scale)
        )
    }
    
    static var popup: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }
}

// MARK: - View Modifiers for Animations
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

extension View {
    func shake(with value: Int) -> some View {
        self.modifier(ShakeEffect(animatableData: CGFloat(value)))
    }
    
    func cardFlip(isFlipped: Bool) -> some View {
        self.rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
    }
    
    func pulseEffect(isActive: Bool) -> some View {
        self.scaleEffect(isActive ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isActive)
    }
}
