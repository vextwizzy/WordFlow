//
//  Word.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation
import SwiftData

@Model
final class Word {
    @Attribute(.unique) var id: UUID
    var english: String
    var transcription: String
    var translation: String
    var explanation: String
    var example: String
    var association: String
    var imageURL: String?
    var audioURL: String?
    var difficulty: DifficultyLevel
    var category: String
    var isLearned: Bool
    var swipeCount: Int
    var lastReviewed: Date?
    var nextReview: Date?
    var createdAt: Date
    
    // Swipe tracking
    var swipedRight: Int // Знаю
    var swipedLeft: Int  // Не знаю
    
    init(
        english: String,
        transcription: String,
        translation: String,
        explanation: String = "",
        example: String = "",
        association: String = "",
        imageURL: String? = nil,
        audioURL: String? = nil,
        difficulty: DifficultyLevel = .beginner,
        category: String = "General"
    ) {
        self.id = UUID()
        self.english = english
        self.transcription = transcription
        self.translation = translation
        self.explanation = explanation
        self.example = example
        self.association = association
        self.imageURL = imageURL
        self.audioURL = audioURL
        self.difficulty = difficulty
        self.category = category
        self.isLearned = false
        self.swipeCount = 0
        self.lastReviewed = nil
        self.nextReview = nil
        self.createdAt = Date()
        self.swipedRight = 0
        self.swipedLeft = 0
    }
    
    var masteryLevel: Double {
        guard swipeCount > 0 else { return 0.0 }
        return Double(swipedRight) / Double(swipeCount)
    }
    
    var shouldReview: Bool {
        guard let nextReview = nextReview else { return true }
        return Date() >= nextReview
    }
}

enum DifficultyLevel: String, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var xpMultiplier: Double {
        switch self {
        case .beginner: return 1.0
        case .intermediate: return 1.5
        case .advanced: return 2.0
        case .expert: return 2.5
        }
    }
}
