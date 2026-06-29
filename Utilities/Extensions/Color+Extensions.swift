//
//  Color+Extensions.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

extension Color {
    // MARK: - Random Color
    
    static func random() -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
    
    // MARK: - Adaptive Colors
    
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
