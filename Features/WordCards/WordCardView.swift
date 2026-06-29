//
//  WordCardView.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct WordCardView: View {
    let word: Word
    let onSpeak: () -> Void
    @State private var isFlipped = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Card background with gradient
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                // Card content
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Difficulty badge
                    HStack {
                        Spacer()
                        Text(word.difficulty.rawValue)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(difficultyColor(word.difficulty))
                            )
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                    
                    if !isFlipped {
                        // Front side - Word
                        frontSide
                    } else {
                        // Back side - Translation & Details
                        backSide
                    }
                    
                    Spacer()
                    
                    // Bottom actions
                    bottomActions
                }
                .padding(24)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .onTapGesture {
                withAnimation(.card) {
                    isFlipped.toggle()
                    HapticService.shared.cardFlip()
                }
            }
        }
    }
    
    // MARK: - Front Side
    
    private var frontSide: some View {
        VStack(spacing: 16) {
            // English word
            Text(word.english)
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.brandPrimary, .brandSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            // Transcription
            Text(word.transcription)
                .font(.transcription)
                .foregroundStyle(.textSecondary)
            
            // Speak button
            Button(action: onSpeak) {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Listen")
                        .font(.bodyRegular)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(LinearGradient.brandGradient)
                )
            }
            
            // Hint to flip
            Text("Tap to see translation")
                .font(.caption)
                .foregroundStyle(.textTertiary)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Back Side
    
    private var backSide: some View {
        VStack(spacing: 20) {
            // Translation
            Text(word.translation)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.brandPrimary)
                .multilineTextAlignment(.center)
            
            Divider()
                .padding(.horizontal, 40)
            
            // Explanation
            if !word.explanation.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Explanation", systemImage: "lightbulb.fill")
                        .font(.bodySmall)
                        .foregroundStyle(.textSecondary)
                    
                    Text(word.explanation)
                        .font(.bodyRegular)
                        .foregroundStyle(.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Example
            if !word.example.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Example", systemImage: "text.quote")
                        .font(.bodySmall)
                        .foregroundStyle(.textSecondary)
                    
                    Text(word.example)
                        .font(.bodyRegular)
                        .italic()
                        .foregroundStyle(.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActions: some View {
        HStack(spacing: 20) {
            // Swipe hint left
            VStack(spacing: 4) {
                Image(systemName: "arrow.left")
                    .font(.title3)
                Text("Don't know")
                    .font(.caption)
            }
            .foregroundStyle(.error.opacity(0.6))
            
            Spacer()
            
            // Category
            Text(word.category)
                .font(.caption)
                .foregroundStyle(.textTertiary)
            
            Spacer()
            
            // Swipe hint right
            VStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(.title3)
                Text("Know it")
                    .font(.caption)
            }
            .foregroundStyle(.success.opacity(0.6))
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Helpers
    
    private func difficultyColor(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .beginner: return .success
        case .intermediate: return .warning
        case .advanced: return .error
        case .expert: return .brandPrimary
        }
    }
}

#Preview {
    ZStack {
        GlassBackground()
        
        WordCardView(
            word: Word(
                english: "Journey",
                transcription: "/ˈdʒɜːrni/",
                translation: "Путешествие",
                explanation: "A journey is when you travel from one place to another.",
                example: "I went on a long journey across Europe.",
                difficulty: .beginner,
                category: "Travel"
            ),
            onSpeak: {}
        )
        .frame(width: 350, height: 600)
        .padding()
    }
}
