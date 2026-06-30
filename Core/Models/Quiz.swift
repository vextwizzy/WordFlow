//
//  Quiz.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation
import SwiftData

@Model
final class Quiz {
    @Attribute(.unique) var id: UUID
    var wordId: UUID
    var wordEnglish: String
    var questionType: QuizType
    var question: String
    var options: [String]
    var correctAnswer: String
    var userAnswer: String?
    var isCorrect: Bool?
    var answeredAt: Date?
    var createdAt: Date
    
    init(
        wordId: UUID,
        wordEnglish: String,
        questionType: QuizType,
        question: String,
        options: [String],
        correctAnswer: String
    ) {
        self.id = UUID()
        self.wordId = wordId
        self.wordEnglish = wordEnglish
        self.questionType = questionType
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        self.userAnswer = nil
        self.isCorrect = nil
        self.answeredAt = nil
        self.createdAt = Date()
    }
    
    func submitAnswer(_ answer: String) {
        userAnswer = answer
        isCorrect = (answer == correctAnswer)
        answeredAt = Date()
    }
}

enum QuizType: String, Codable, CaseIterable {
    case translation = "Translation"
    case fillInBlank = "Fill in the Blank"
    case multipleChoice = "Multiple Choice"
    case listening = "Listening"
}

// Quiz session to group multiple quizzes together
@Model
final class QuizSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var totalQuestions: Int
    var correctAnswers: Int
    var wrongAnswers: Int
    var xpEarned: Int
    var quizIds: [UUID]
    
    init() {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = nil
        self.totalQuestions = 0
        self.correctAnswers = 0
        self.wrongAnswers = 0
        self.xpEarned = 0
        self.quizIds = []
    }
    
    var score: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    var isPerfect: Bool {
        return totalQuestions > 0 && correctAnswers == totalQuestions
    }
    
    func completeSession() {
        endTime = Date()
    }
}
