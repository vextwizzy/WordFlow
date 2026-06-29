//
//  OnboardingView.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var name = ""
    @State private var showMainApp = false
    let dataManager: DataManager
    let onComplete: (UserProfile) -> Void
    
    var body: some View {
        ZStack {
            GlassBackground()
                .ignoresSafeArea()
            
            if showMainApp {
                // This will be handled by parent
                Color.clear
            } else {
                TabView(selection: $currentPage) {
                    // Page 1 - Welcome
                    welcomePage
                        .tag(0)
                    
                    // Page 2 - Features
                    featuresPage
                        .tag(1)
                    
                    // Page 3 - Get Started
                    getStartedPage
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }
    
    // MARK: - Welcome Page
    
    private var welcomePage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "book.pages.fill")
                .font(.system(size: 100))
                .foregroundStyle(LinearGradient.brandGradient)
            
            Text("Welcome to WordFlow")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            Text("Learn English words in a fun, TikTok-style way")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: { withAnimation { currentPage = 1 } }) {
                Text("Next")
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
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Features Page
    
    private var featuresPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("Why WordFlow?")
                .font(.largeTitle)
                .foregroundStyle(.white)
            
            VStack(spacing: 30) {
                OnboardingFeature(
                    icon: "hand.point.up.braille.fill",
                    title: "Swipe to Learn",
                    description: "Simple gestures to mark words as known or unknown"
                )
                
                OnboardingFeature(
                    icon: "flame.fill",
                    title: "Daily Streaks",
                    description: "Build consistency with daily learning goals"
                )
                
                OnboardingFeature(
                    icon: "trophy.fill",
                    title: "Gamification",
                    description: "Earn XP, level up, and unlock achievements"
                )
                
                OnboardingFeature(
                    icon: "brain.head.profile",
                    title: "AI Powered",
                    description: "Smart explanations and personalized learning"
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: { withAnimation { currentPage = 2 } }) {
                Text("Next")
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
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Get Started Page
    
    private var getStartedPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(LinearGradient.brandGradient)
            
            Text("What's your name?")
                .font(.largeTitle)
                .foregroundStyle(.white)
            
            TextField("Enter your name", text: $name)
                .font(.title3)
                .foregroundStyle(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 40)
                .autocorrectionDisabled()
            
            Spacer()
            
            Button(action: completeOnboarding) {
                Text("Get Started")
                    .font(.bodyLarge)
                    .bold()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(name.isEmpty ? LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing) : LinearGradient.brandGradient)
                    )
            }
            .disabled(name.isEmpty)
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Complete Onboarding
    
    private func completeOnboarding() {
        let profile = dataManager.createUserProfile(name: name)
        
        // Request notification permission
        Task {
            _ = await NotificationService.shared.requestAuthorization()
        }
        
        withAnimation {
            onComplete(profile)
        }
    }
}

// MARK: - Onboarding Feature

struct OnboardingFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(LinearGradient.goldGradient)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.bodySmall)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(dataManager: DataManager()) { _ in }
}
