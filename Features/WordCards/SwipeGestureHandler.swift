//
//  SwipeGestureHandler.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct SwipeGestureHandler: ViewModifier {
    let onSwipeUp: () -> Void
    let onSwipeDown: () -> Void
    let onSwipeRight: () -> Void
    let onSwipeLeft: () -> Void
    
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    private let swipeThreshold: CGFloat = 80
    
    func body(content: Content) -> some View {
        content
            .offset(dragOffset)
            .rotationEffect(.degrees(Double(dragOffset.width / 20)))
            .scaleEffect(isDragging ? 0.95 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation
                        
                        // Haptic feedback at threshold
                        if abs(value.translation.width) > swipeThreshold ||
                            abs(value.translation.height) > swipeThreshold {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.prepare()
                        }
                    }
                    .onEnded { value in
                        let horizontalTranslation = value.translation.width
                        let verticalTranslation = value.translation.height
                        let horizontalVelocity = value.predictedEndTranslation.width - value.translation.width
                        let verticalVelocity = value.predictedEndTranslation.height - value.translation.height
                        
                        // Determine dominant direction
                        if abs(horizontalTranslation) > abs(verticalTranslation) {
                            // Horizontal swipe
                            if abs(horizontalTranslation) > swipeThreshold &&
                                abs(horizontalVelocity) > 50 {
                                if horizontalTranslation > 0 {
                                    onSwipeRight()
                                } else {
                                    onSwipeLeft()
                                }
                            }
                        } else {
                            // Vertical swipe
                            if abs(verticalTranslation) > swipeThreshold &&
                                abs(verticalVelocity) > 50 {
                                if verticalTranslation > 0 {
                                    onSwipeDown()
                                } else {
                                    onSwipeUp()
                                }
                            }
                        }
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
    }
}

extension View {
    func onSwipe(
        up: @escaping () -> Void = {},
        down: @escaping () -> Void = {},
        right: @escaping () -> Void = {},
        left: @escaping () -> Void = {}
    ) -> some View {
        modifier(SwipeGestureHandler(
            onSwipeUp: up,
            onSwipeDown: down,
            onSwipeRight: right,
            onSwipeLeft: left
        ))
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 20)
        .fill(LinearGradient.brandGradient)
        .frame(width: 300, height: 400)
        .overlay(
            Text("Swipe me")
                .foregroundStyle(.white)
                .font(.largeTitle)
        )
        .onSwipe(
            up: { print("Up") },
            down: { print("Down") },
            right: { print("Right") },
            left: { print("Left") }
        )
}
