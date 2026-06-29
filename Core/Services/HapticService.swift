//
//  HapticService.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import UIKit

final class HapticService {
    static let shared = HapticService()
    
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // Specific haptics for app actions
    func swipeRight() {
        impact(.medium)
    }
    
    func swipeLeft() {
        impact(.light)
    }
    
    func levelUp() {
        notification(.success)
    }
    
    func achievementUnlocked() {
        notification(.success)
    }
    
    func correctAnswer() {
        notification(.success)
    }
    
    func wrongAnswer() {
        notification(.error)
    }
    
    func cardFlip() {
        impact(.light)
    }
}
