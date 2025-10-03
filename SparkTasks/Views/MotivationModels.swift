//
//  MotivationModels.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import Foundation
import SwiftUI
import Combine

struct MotivationalQuote: Identifiable, Codable {
    let id: UUID
    let text: String
    let author: String
    let category: QuoteCategory
    
    init(text: String, author: String, category: QuoteCategory) {
        self.id = UUID()
        self.text = text
        self.author = author
        self.category = category
    }
}

enum QuoteCategory: String, CaseIterable, Codable {
    case success = "success"
    case motivation = "motivation"
    case leadership = "leadership"
    case creativity = "creativity"
    case wisdom = "wisdom"
    
    var title: String {
        switch self {
        case .success: return "Success"
        case .motivation: return "Motivation"
        case .leadership: return "Leadership"
        case .creativity: return "Creativity"
        case .wisdom: return "Wisdom"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .motivation: return .orange
        case .leadership: return .blue
        case .creativity: return .purple
        case .wisdom: return .indigo
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "star.fill"
        case .motivation: return "flame.fill"
        case .leadership: return "crown.fill"
        case .creativity: return "paintbrush.fill"
        case .wisdom: return "lightbulb.fill"
        }
    }
}

class MotivationManager: ObservableObject {
    @Published var currentQuote: MotivationalQuote
    @Published var favoriteQuotes: [MotivationalQuote] = []
    
    private let quotes: [MotivationalQuote]
    private let favoritesKey = "favoriteQuotes"
    
    init() {
        self.quotes = MotivationManager.defaultQuotes
        self.currentQuote = quotes.randomElement() ?? quotes[0]
        loadFavorites()
    }
    
    func getRandomQuote() {
        var newQuote: MotivationalQuote
        repeat {
            newQuote = quotes.randomElement() ?? quotes[0]
        } while newQuote.id == currentQuote.id && quotes.count > 1
        
        currentQuote = newQuote
    }
    
    func toggleFavorite() {
        if isCurrentQuoteFavorite {
            favoriteQuotes.removeAll { $0.id == currentQuote.id }
        } else {
            favoriteQuotes.append(currentQuote)
        }
        saveFavorites()
    }
    
    var isCurrentQuoteFavorite: Bool {
        favoriteQuotes.contains { $0.id == currentQuote.id }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([MotivationalQuote].self, from: data) {
            favoriteQuotes = decoded
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteQuotes) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    static let defaultQuotes: [MotivationalQuote] = [
        MotivationalQuote(
            text: "Success is the ability to go from one failure to another with no loss of enthusiasm.",
            author: "Winston Churchill",
            category: .success
        ),
        MotivationalQuote(
            text: "The only way to do great work is to love what you do.",
            author: "Steve Jobs",
            category: .motivation
        ),
        MotivationalQuote(
            text: "Leadership is the art of getting someone else to do something you want done because he wants to do it.",
            author: "Dwight Eisenhower",
            category: .leadership
        ),
        MotivationalQuote(
            text: "Creativity is inventing new things. Innovation is creating new things.",
            author: "Theodore Levitt",
            category: .creativity
        ),
        MotivationalQuote(
            text: "Wisdom begins in wonder.",
            author: "Socrates",
            category: .wisdom
        ),
        MotivationalQuote(
            text: "The future belongs to those who believe in the beauty of their dreams.",
            author: "Eleanor Roosevelt",
            category: .motivation
        ),
        MotivationalQuote(
            text: "Don't be afraid to give up the good to go for the great.",
            author: "John Rockefeller",
            category: .success
        ),
        MotivationalQuote(
            text: "True leadership lies in guiding others to success.",
            author: "John Gardner",
            category: .leadership
        ),
        MotivationalQuote(
            text: "Creativity requires the courage to let go of certainties.",
            author: "Erich Fromm",
            category: .creativity
        ),
        MotivationalQuote(
            text: "Wisdom comes from experience, and experience comes from mistakes.",
            author: "Anonymous",
            category: .wisdom
        ),
        MotivationalQuote(
            text: "Your work is going to fill a large part of your life, and the only way to be truly satisfied is to do what you believe is great work.",
            author: "Steve Jobs",
            category: .motivation
        ),
        MotivationalQuote(
            text: "Success is not the key to happiness. Happiness is the key to success.",
            author: "Albert Schweitzer",
            category: .success
        ),
        MotivationalQuote(
            text: "A good leader takes a little more than his share of the blame, a little less than his share of the credit.",
            author: "Arnold Glasow",
            category: .leadership
        ),
        MotivationalQuote(
            text: "Creativity is just connecting things. When you ask creative people how they did something, they feel a little guilty because they didn't really do it, they just saw something.",
            author: "Steve Jobs",
            category: .creativity
        ),
        MotivationalQuote(
            text: "Wisdom is the daughter of experience.",
            author: "Leonardo da Vinci",
            category: .wisdom
        ),
        MotivationalQuote(
            text: "Motivation is what gets you started. Habit is what keeps you going.",
            author: "Jim Rohn",
            category: .motivation
        ),
        MotivationalQuote(
            text: "Success is a ladder that cannot be climbed with your hands in your pockets.",
            author: "Zig Ziglar",
            category: .success
        ),
        MotivationalQuote(
            text: "Leadership and learning are indispensable to each other.",
            author: "John Kennedy",
            category: .leadership
        ),
        MotivationalQuote(
            text: "Creativity is inventing, experimenting, growing, taking risks, breaking rules, making mistakes, and having fun.",
            author: "Mary Lou Cook",
            category: .creativity
        ),
        MotivationalQuote(
            text: "The only true wisdom is in knowing you know nothing.",
            author: "Socrates",
            category: .wisdom
        ),
        MotivationalQuote(
            text: "The only limit to our realization of tomorrow is our doubts of today.",
            author: "Franklin Roosevelt",
            category: .motivation
        ),
        MotivationalQuote(
            text: "Success is walking from failure to failure with no loss of enthusiasm.",
            author: "Winston Churchill",
            category: .success
        ),
        MotivationalQuote(
            text: "The supreme quality for leadership is unquestionably integrity.",
            author: "Dwight Eisenhower",
            category: .leadership
        ),
        MotivationalQuote(
            text: "Every artist was first an amateur.",
            author: "Ralph Emerson",
            category: .creativity
        ),
        MotivationalQuote(
            text: "The journey of a thousand miles begins with one step.",
            author: "Lao Tzu",
            category: .wisdom
        )
    ]
} 
