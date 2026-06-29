//
//  QuizView.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: QuizViewModel
    
    init(dataManager: DataManager, profile: UserProfile, words: [Word]) {
        _viewModel = State(initialValue: QuizViewModel(dataManager: dataManager, profile: profile, words: words))
    }
    
    var body: some View {
        ZStack {
            GlassBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with progress
                header
                
                if viewModel.isCompleted {
                    // Results
                    resultsView
                } else {
                    // Quiz question
                    Spacer()
                    
                    if viewModel.currentQuizIndex < viewModel.quizzes.count {
                        quizQuestionView
                    }
                    
                    Spacer()
                }
            }
        }
        .task {
            await viewModel.generateQuizzes()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                
                Spacer()
                
                Text("Quiz")
                    .font(.title2)
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Placeholder for symmetry
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Progress bar
            ProgressBar(
                progress: viewModel.progress,
                height: 6,
                backgroundColor: Color.white.opacity(0.2),
                foregroundGradient: .goldGradient
            )
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Quiz Question
    
    private var quizQuestionView: some View {
        let quiz = viewModel.quizzes[viewModel.currentQuizIndex]
        
        return VStack(spacing: 30) {
            // Question number
            Text("Question \(viewModel.currentQuizIndex + 1) of \(viewModel.quizzes.count)")
                .font(.bodySmall)
                .foregroundStyle(.white.opacity(0.7))
            
            // Question
            GlassCard {
                Text(quiz.question)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(24)
            }
            .padding(.horizontal, 20)
            
            // Options
            VStack(spacing: 16) {
                ForEach(quiz.options, id: \.self) { option in
                    QuizOptionButton(
                        option: option,
                        isSelected: viewModel.selectedAnswer == option,
                        isCorrect: viewModel.showResult ? option == quiz.correctAnswer : nil,
                        isWrong: viewModel.showResult && viewModel.selectedAnswer == option && option != quiz.correctAnswer
                    ) {
                        viewModel.selectAnswer(option)
                    }
                }
            }
            .padding(.horizontal, 20)
            .disabled(viewModel.showResult)
            
            // Next button
            if viewModel.selectedAnswer != nil {
                Button(action: { viewModel.nextQuestion() }) {
                    Text(viewModel.showResult ? "Next" : "Check")
                        .font(.bodyLarge)
                        .bold()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(LinearGradient.brandGradient)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
    }
    
    // MARK: - Results View
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Score circle
            CircularProgressBar(
                progress: viewModel.scorePercentage / 100,
                size: 160,
                lineWidth: 12,
                gradient: viewModel.isPerfect ? .goldGradient : .brandGradient
            )
            
            // Title
            Text(viewModel.isPerfect ? "Perfect!" : viewModel.scorePercentage >= 70 ? "Great Job!" : "Keep Practicing!")
                .font(.largeTitle)
                .foregroundStyle(.white)
            
            // Stats
            GlassCard {
                VStack(spacing: 16) {
                    HStack {
                        Label("Correct", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.success)
                        Spacer()
                        Text("\(viewModel.correctAnswers)")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    
                    Divider()
                        .background(.white.opacity(0.3))
                    
                    HStack {
                        Label("Wrong", systemImage: "xmark.circle.fill")
                            .foregroundStyle(.error)
                        Spacer()
                        Text("\(viewModel.wrongAnswers)")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    
                    Divider()
                        .background(.white.opacity(0.3))
                    
                    HStack {
                        Label("XP Earned", systemImage: "star.fill")
                            .foregroundStyle(.xpGold)
                        Spacer()
                        Text("+\(viewModel.xpEarned)")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
                .padding(20)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Done button
            Button(action: { dismiss() }) {
                Text("Continue Learning")
                    .font(.bodyLarge)
                    .bold()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(LinearGradient.brandGradient)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

// MARK: - Quiz Option Button

struct QuizOptionButton: View {
    let option: String
    let isSelected: Bool
    let isCorrect: Bool?
    let isWrong: Bool
    let action: () -> Void
    
    var backgroundColor: LinearGradient {
        if isCorrect == true {
            return .successGradient
        } else if isWrong {
            return .errorGradient
        } else if isSelected {
            return .brandGradient
        } else {
            return LinearGradient(colors: [.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var borderColor: Color {
        if isCorrect == true {
            return .success
        } else if isWrong {
            return .error
        } else if isSelected {
            return .brandPrimary
        } else {
            return .white.opacity(0.3)
        }
    }
    
    var icon: String? {
        if isCorrect == true {
            return "checkmark.circle.fill"
        } else if isWrong {
            return "xmark.circle.fill"
        }
        return nil
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option)
                    .font(.bodyLarge)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColor, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuizView(
        dataManager: DataManager(),
        profile: UserProfile(name: "Test User"),
        words: []
    )
}
