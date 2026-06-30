//
//  Typography.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

extension Font {
    // MARK: - Headings
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // MARK: - Body
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .rounded)
    static let bodyRegular = Font.system(size: 16, weight: .regular, design: .rounded)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .rounded)
    
    // MARK: - Special
    static let wordCard = Font.system(size: 48, weight: .bold, design: .rounded)
    static let transcription = Font.system(size: 20, weight: .regular, design: .monospaced)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    static let xpBadge = Font.system(size: 14, weight: .bold, design: .rounded)
}

// MARK: - Text Modifiers
extension View {
    func headingStyle() -> some View {
        self.font(.title1)
            .foregroundStyle(Color.textPrimary)
    }
    
    func subheadingStyle() -> some View {
        self.font(.title3)
            .foregroundStyle(Color.textSecondary)
    }
    
    func bodyStyle() -> some View {
        self.font(.bodyRegular)
            .foregroundStyle(Color.textPrimary)
    }
    
    func captionStyle() -> some View {
        self.font(.caption)
            .foregroundStyle(Color.textTertiary)
    }
}
