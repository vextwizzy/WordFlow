//
//  WordCardStackView.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct WordCardStackView: View {
    @State private var viewModel: WordCardViewModel
    @State private var speechService = SpeechService()
    
    init(dataManager: DataManager, profile: UserProfile) {
        _viewModel = State(initialValue: WordCardViewModel(dataManager: dataManager, profile: profile))
    }
    
    var body: some View {
        ZStack {
            GlassBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Card stack
                GeometryReader { geometry in
                    ZStack {
                        if viewModel.words.isEmpty && !viewModel.isLoading {
                            emptyState
                        } else if viewModel.shouldShowQuiz {
                            // Quiz screen will be shown after 20 swipes
                            quizPrompt
                        } else {
                            // Cards
                            ForEach(Array(viewModel.words.enumerated()), id: \.element.id) { index, word in
                                if index < 3 { // Show only 3 cards in stack
                                    WordCardView(word: word) {
                                        speechService.speak(word.english)
                                    }
                                    .frame(width: geometry.size.width - 40, height: geometry.size.height - 40)
                                    .offset(x: index == 0 ? viewModel.dragOffset.width : 0,
                                           y: CGFloat(index) * 10)
                                    .scaleEffect(index == 0 ? 1.0 : 1.0 - (CGFloat(index) * 0.05))
                                    .rotationEffect(.degrees(index == 0 ? Double(viewModel.dragOffset.width / 20) : 0))
                                    .opacity(index < 2 ? 1.0 : 0.5)
                                    .gesture(
                                        index == 0 ? DragGesture()
                                            .onChanged { value in
                                                viewModel.dragOffset = value.translation
                                            }
                                            .onEnded { value in
                                                handleSwipe(value: value, word: word)
                                            } : nil
                                    )
                                    .zIndex(Double(viewModel.words.count - index))
                                }
                            }
                        }
                        
                        // Swipe indicators
                        if abs(viewModel.dragOffset.width) > 50 {
                            swipeIndicators
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 20)
                
                // Stats footer
                statsFooter
            }
            
            // Level up overlay
            if viewModel.showLevelUp {
                levelUpOverlay
            }
            
            // Achievement overlay
            if let achievement = viewModel.unlockedAchievement {
                achievementOverlay(achievement)
            }
        }
        .task {
            await viewModel.loadWords()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            // Streak
            StreakIndicator(streak: viewModel.profile.currentStreak, isCompact: true)
            
            Spacer()
            
            // XP and Level
            HStack(spacing: 12) {
                XPBadge(xp: viewModel.profile.xp, size: .small)
                LevelBadge(level: viewModel.profile.level, size: 40)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    // MARK: - Swipe Indicators
    
    private var swipeIndicators: some View {
        HStack {
            if viewModel.dragOffset.width < -50 {
                // Don't know indicator (left)
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.error)
                    .opacity(min(abs(viewModel.dragOffset.width) / 150, 1.0))
            }
            
            Spacer()
            
            if viewModel.dragOffset.width > 50 {
                // Know indicator (right)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.success)
                    .opacity(min(viewModel.dragOffset.width / 150, 1.0))
            }
        }
        .padding(.horizontal, 60)
    }
    
    // MARK: - Stats Footer
    
    private var statsFooter: some View {
        HStack(spacing: 30) {
            StatItem(
                icon: "book.fill",
                value: "\(viewModel.wordsStudiedToday)",
                label: "Today"
            )
            
            StatItem(
                icon: "checkmark.circle.fill",
                value: "\(viewModel.correctSwipes)",
                label: "Correct",
                color: .success
            )
            
            StatItem(
                icon: "xmark.circle.fill",
                value: "\(viewModel.wrongSwipes)",
                label: "Wrong",
                color: .error
            )
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.success)
            
            Text("Great job!")
                .font(.title1)
                .foregroundStyle(.white)
            
            Text("You've studied all available words for today.")
                .font(.bodyRegular)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            if !viewModel.profile.isPremium {
                Button(action: {}) {
                    Text("Upgrade to Premium")
                        .font(.bodyRegular)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(LinearGradient.goldGradient)
                        )
                }
                .padding(.top, 10)
            }
        }
        .padding()
    }
    
    // MARK: - Quiz Prompt
    
    private var quizPrompt: some View {
        VStack(spacing: 30) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(LinearGradient.brandGradient)
            
            Text("Time for a Quiz!")
                .font(.title1)
                .foregroundStyle(.white)
            
            Text("Test your knowledge with a quick quiz.")
                .font(.bodyRegular)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button(action: { viewModel.startQuiz() }) {
                Text("Start Quiz")
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
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    // MARK: - Level Up Overlay
    
    private var levelUpOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "star.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(LinearGradient.goldGradient)
                    .pulseEffect(isActive: true)
                
                Text("Level Up!")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                
                Text("You reached level \(viewModel.profile.level)")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
                
                Button(action: { viewModel.dismissLevelUp() }) {
                    Text("Continue")
                        .font(.bodyLarge)
                        .bold()
                        .foregroundStyle(.white)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(LinearGradient.goldGradient)
                        )
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .transition(.opacity)
    }
    
    // MARK: - Achievement Overlay
    
    private func achievementOverlay(_ achievement: Achievement) -> some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: achievement.iconName)
                    .font(.system(size: 80))
                    .foregroundStyle(LinearGradient.brandGradient)
                    .pulseEffect(isActive: true)
                
                Text("Achievement Unlocked!")
                    .font(.title1)
                    .foregroundStyle(.white)
                
                Text(achievement.title)
                    .font(.title2)
                    .foregroundStyle(.white)
                
                Text(achievement.descriptionText)
                    .font(.bodyRegular)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                XPBadge(xp: achievement.xpReward, size: .large)
                
                Button(action: { viewModel.dismissAchievement() }) {
                    Text("Awesome!")
                        .font(.bodyLarge)
                        .bold()
                        .foregroundStyle(.white)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(LinearGradient.brandGradient)
                        )
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .transition(.opacity)
    }
    
    // MARK: - Swipe Handler
    
    private func handleSwipe(value: DragGesture.Value, word: Word) {
        let swipeThreshold: CGFloat = 100
        
        withAnimation(.smooth) {
            if value.translation.width > swipeThreshold {
                // Swipe right - Know it
                viewModel.handleSwipe(word: word, knowIt: true)
                HapticService.shared.swipeRight()
            } else if value.translation.width < -swipeThreshold {
                // Swipe left - Don't know
                viewModel.handleSwipe(word: word, knowIt: false)
                HapticService.shared.swipeLeft()
            }
            
            viewModel.dragOffset = .zero
        }
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = .white
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(color.opacity(0.7))
        }
    }
}
