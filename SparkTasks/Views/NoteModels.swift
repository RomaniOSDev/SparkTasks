//
//  NoteModels.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import Foundation
import SwiftUI
import Combine

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var category: NoteCategory
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, content: String = "", category: NoteCategory = .personal) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: updatedAt)
    }
}

enum NoteCategory: String, CaseIterable, Codable {
    case all = "all"
    case personal = "personal"
    case work = "work"
    case ideas = "ideas"
    case reminders = "reminders"
    case quotes = "quotes"
    
    var title: String {
        switch self {
        case .all: return "All"
        case .personal: return "Personal"
        case .work: return "Work"
        case .ideas: return "Ideas"
        case .reminders: return "Reminders"
        case .quotes: return "Quotes"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .gray
        case .personal: return .blue
        case .work: return .green
        case .ideas: return .purple
        case .reminders: return .orange
        case .quotes: return .pink
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "folder"
        case .personal: return "person.fill"
        case .work: return "briefcase.fill"
        case .ideas: return "lightbulb.fill"
        case .reminders: return "bell.fill"
        case .quotes: return "quote.bubble.fill"
        }
    }
}

class NotesManager: ObservableObject {
    @Published var notes: [Note] = []
    
    private let notesKey = "savedNotes"
    
    init() {
        loadNotes()
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
    }
    
    func updateNote(_ note: Note, title: String, content: String, category: NoteCategory) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].title = title
            notes[index].content = content
            notes[index].category = category
            notes[index].updatedAt = Date()
            saveNotes()
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
    }
    
    func resetData() {
        notes.removeAll()
        saveNotes()
    }
} 
