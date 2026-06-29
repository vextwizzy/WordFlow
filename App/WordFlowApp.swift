//
//  WordFlowApp.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI
import SwiftData

@main
struct WordFlowApp: App {
    @State private var dataManager = DataManager()
    @State private var showOnboarding = true
    @State private var currentProfile: UserProfile?
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showOnboarding && currentProfile == nil {
                    OnboardingView(dataManager: dataManager) { profile in
                        currentProfile = profile
                        showOnboarding = false
                    }
                } else if let profile = currentProfile {
                    TabBarView(dataManager: dataManager, profile: profile)
                } else {
                    // Loading state
                    ZStack {
                        GlassBackground()
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            .task {
                // Check if user already exists
                if let existingProfile = dataManager.getUserProfile() {
                    currentProfile = existingProfile
                    showOnboarding = false
                }
            }
        }
        .modelContainer(dataManager.modelContainer)
    }
}
