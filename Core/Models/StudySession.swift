//
//  StudySession.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation
import SwiftData

@Model
final class StudySession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var wordsStudiedIds: [UUID]
    var correctSwipes: Int  // Swipe right
    var wrongSwipes: Int    // Swipe left
    var totalSwipes: Int
    var xpEarned: Int
    var wasQuizCompleted: Bool
    
    init() {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = nil
        self.wordsStudiedIds = []
        self.correctSwipes = 0
        self.wrongSwipes = 0
        self.totalSwipes = 0
        self.xpEarned = 0
        self.wasQuizCompleted = false
    }
    
    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    var durationInMinutes: Int {
        return Int(duration / 60)
    }
    
    var accuracy: Double {
        guard totalSwipes > 0 else { return 0.0 }
        return Double(correctSwipes) / Double(totalSwipes)
    }
    
    func addWord(_ wordId: UUID) {
        if !wordsStudiedIds.contains(wordId) {
            wordsStudiedIds.append(wordId)
        }
    }
    
    func recordSwipe(isCorrect: Bool) {
        totalSwipes += 1
        if isCorrect {
            correctSwipes += 1
        } else {
            wrongSwipes += 1
        }
    }
    
    func endSession() {
        endTime = Date()
    }
}
