//
//  DailyStreak.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation
import SwiftData

@Model
final class DailyStreak {
    @Attribute(.unique) var id: UUID
    var date: Date
    var wordsStudied: Int
    var xpEarned: Int
    var quizzesCompleted: Int
    var studyTime: TimeInterval
    var goalAchieved: Bool
    
    init(date: Date) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.wordsStudied = 0
        self.xpEarned = 0
        self.quizzesCompleted = 0
        self.studyTime = 0
        self.goalAchieved = false
    }
    
    func addWord() {
        wordsStudied += 1
    }
    
    func addXP(_ amount: Int) {
        xpEarned += amount
    }
    
    func addQuiz() {
        quizzesCompleted += 1
    }
    
    func addStudyTime(_ duration: TimeInterval) {
        studyTime += duration
    }
}
