//
//  TaskModels.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import Foundation
import SwiftUI
import Combine

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var dueDate: Date
    var createdAt: Date
    
    init(title: String, description: String = "", priority: TaskPriority = .medium, dueDate: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.isCompleted = false
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = Date()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var title: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .medium: return "minus.circle"
        case .high: return "exclamationmark.triangle"
        }
    }
}

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    
    private let tasksKey = "savedTasks"
    
    init() {
        loadTasks()
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
        updateAppStorage()
    }
    
    func updateTask(_ task: Task, title: String, description: String, priority: TaskPriority, dueDate: Date) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = title
            tasks[index].description = description
            tasks[index].priority = priority
            tasks[index].dueDate = dueDate
            saveTasks()
        }
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
            updateAppStorage()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        updateAppStorage()
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    private func updateAppStorage() {
        UserDefaults.standard.set(completedTasksCount, forKey: "completedTasksCount")
        UserDefaults.standard.set(tasks.count, forKey: "totalTasksCount")
    }
    
    func resetData() {
        tasks.removeAll()
        saveTasks()
        updateAppStorage()
    }
} 
