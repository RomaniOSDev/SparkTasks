//
//  MotivationView.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import SwiftUI

struct MotivationView: View {
    @StateObject private var motivationManager = MotivationManager()
    @State private var isAnimating = false
    @State private var showingShare = false
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 15) {
                Text("Motivation")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Tap or swipe for a new quote")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 20)
            
            Spacer()
            
            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isAnimating ? 5 : -5))
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                VStack(spacing: 20) {
                    Text(motivationManager.currentQuote.text)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .scaleEffect(isAnimating ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("— \(motivationManager.currentQuote.author)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .italic()
                }
                
                HStack {
                    Image(systemName: motivationManager.currentQuote.category.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(motivationManager.currentQuote.category.color)
                    
                    Text(motivationManager.currentQuote.category.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(motivationManager.currentQuote.category.color)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(motivationManager.currentQuote.category.color.opacity(0.2))
                )
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    motivationManager.getRandomQuote()
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if abs(value.translation.width) > 50 {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                motivationManager.getRandomQuote()
                            }
                        }
                    }
            )
            
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    motivationManager.getRandomQuote()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Next Quote")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .onAppear {
            isAnimating = true
        }
        .sheet(isPresented: $showingShare) {
            ShareSheet(activityItems: [
                "\(motivationManager.currentQuote.text)\n— \(motivationManager.currentQuote.author)\n\nShared from SparkTasks"
            ])
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    MotivationView()
} 
