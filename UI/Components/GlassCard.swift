//
//  GlassCard.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//  Updated for iOS 26 design
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.1
    var blur: CGFloat = 20
    
    init(cornerRadius: CGFloat = 20, opacity: Double = 0.1, blur: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.opacity = opacity
        self.blur = blur
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                ZStack {
                    // iOS 26 enhanced glass effect
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                }
            )
    }
}

// iOS 26 Dynamic Island style background
struct GlassBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Mesh gradient base (iOS 26 style)
            LinearGradient(
                colors: [
                    Color(hex: "667EEA"),
                    Color(hex: "764BA2"),
                    Color(hex: "F093FB")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                // Animated blobs with iOS 26 mesh effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.brandAccent.opacity(0.4),
                                Color.brandAccent.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 220, height: 220)
                    .blur(radius: 60)
                    .offset(
                        x: animate ? -30 : -50,
                        y: animate ? -80 : -100
                    )
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animate)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.brandSecondary.opacity(0.4),
                                Color.brandSecondary.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 125
                        )
                    )
                    .frame(width: 280, height: 280)
                    .blur(radius: 80)
                    .offset(
                        x: geometry.size.width - (animate ? 120 : 100),
                        y: geometry.size.height - (animate ? 130 : 150)
                    )
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animate)
                
                // Third blob for depth
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "764BA2").opacity(0.3),
                                Color(hex: "764BA2").opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 70)
                    .offset(
                        x: geometry.size.width / 2 + (animate ? 20 : -20),
                        y: geometry.size.height / 2 + (animate ? -30 : 30)
                    )
                    .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    ZStack {
        GlassBackground()
        
        GlassCard {
            VStack(spacing: 16) {
                Text("Glass Card")
                    .font(.title1)
                    .foregroundStyle(.white)
                
                Text("Beautiful iOS 26 glassmorphism")
                    .font(.bodyRegular)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(24)
        }
        .padding()
    }
}

