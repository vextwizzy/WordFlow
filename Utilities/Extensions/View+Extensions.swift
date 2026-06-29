//
//  View+Extensions.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

extension View {
    // MARK: - Glassmorphism
    
    func glassBackground() -> some View {
        self.background(.ultraThinMaterial)
    }
    
    // MARK: - Card Style
    
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
    
    // MARK: - Conditional Modifier
    
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    // MARK: - Hide Keyboard
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
