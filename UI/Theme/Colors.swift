//
//  Colors.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//  Updated for iOS 26 design
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors (iOS 26 Dynamic)
    static let brandPrimary = Color(hex: "6C5CE7")
    static let brandSecondary = Color(hex: "A29BFE")
    static let brandAccent = Color(hex: "FD79A8")
    
    // MARK: - iOS 26 Mesh Gradient Colors
    static let meshStart = Color(hex: "667EEA")
    static let meshMiddle = Color(hex: "764BA2")
    static let meshEnd = Color(hex: "F093FB")
    
    // MARK: - Glassmorphism (Enhanced for iOS 26)
    static let glassBackground = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.15)
    static let glassHighlight = Color.white.opacity(0.25)
    
    // MARK: - Gradients
    static let gradientStart = Color(hex: "6C5CE7")
    static let gradientEnd = Color(hex: "A29BFE")
    
    static let successGradientStart = Color(hex: "00B894")
    static let successGradientEnd = Color(hex: "55EFC4")
    
    static let errorGradientStart = Color(hex: "FF7675")
    static let errorGradientEnd = Color(hex: "FD79A8")
    
    // MARK: - Semantic Colors (iOS 26 Enhanced)
    static let success = Color(hex: "00B894")
    static let error = Color(hex: "FF7675")
    static let warning = Color(hex: "FDCB6E")
    static let info = Color(hex: "74B9FF")
    
    // MARK: - XP & Gamification
    static let xpGold = Color(hex: "F39C12")
    static let streakFire = Color(hex: "E74C3C")
    static let levelStar = Color(hex: "F1C40F")
    
    // MARK: - Card Colors (iOS 26 Depth)
    static let cardBackground = Color(hex: "1E1E1E")
    static let cardBackgroundLight = Color.white
    static let cardShadow = Color.black.opacity(0.12)
    
    // MARK: - Text Colors (iOS 26 Adaptive)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color.gray
    
    // MARK: - Helper
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - iOS 26 Mesh Gradients
extension LinearGradient {
    static let brandGradient = LinearGradient(
        colors: [.gradientStart, .gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [.successGradientStart, .successGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let errorGradient = LinearGradient(
        colors: [.errorGradientStart, .errorGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "F39C12"), Color(hex: "F1C40F")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // iOS 26 Mesh Gradient
    static let meshGradient = LinearGradient(
        colors: [.meshStart, .meshMiddle, .meshEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - iOS 26 Angular Gradients
extension AngularGradient {
    static let dynamicRing = AngularGradient(
        colors: [.brandPrimary, .brandAccent, .brandSecondary, .brandPrimary],
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(360)
    )
}

