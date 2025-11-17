//
//  TodoManager.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI
import Combine

// MARK: - 待办事项管理器
class TodoManager: ObservableObject {
    @Published var todos: [TodoItem] = []
    
    private let userDefaultsKey = "saved_todos"
    
    init() {
        loadTodos()
        if todos.isEmpty {
            todos = TodoManager.mockTodos
            saveTodos()
        }
    }
    
    var upcomingDeadlines: [TodoItem] {
        todos.filter {
            $0.status != .completed && $0.dueDate != nil && $0.dueDate! > Date() && $0.dueDate! < Date().addingTimeInterval(86400 * 3)
        }
    }
    
    var activeTodos: [TodoItem] {
        todos.filter { $0.status != .completed }
    }
    
    var completedTodos: [TodoItem] {
        todos.filter { $0.status == .completed }
    }
    
    // MARK: - CRUD 操作
    
    func addTodo(_ todo: TodoItem) {
        todos.append(todo)
        saveTodos()
    }
    
    func updateTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            saveTodos()
        }
    }
    
    func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
        saveTodos()
    }
    
    func toggleTodoStatus(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            switch todos[index].status {
            case .notStarted:
                todos[index].status = .inProgress
            case .inProgress:
                todos[index].status = .completed
            case .completed:
                todos[index].status = .notStarted
            }
            saveTodos()
        }
    }
    
    // MARK: - 筛选
    
    func todosByCategory(_ category: String) -> [TodoItem] {
        if category == "全部" {
            return todos
        }
        return todos.filter { $0.category == category }
    }
    
    func todosByCourse(_ courseCode: String?) -> [TodoItem] {
        guard let courseCode = courseCode else {
            return todos.filter { $0.courseCode == nil }
        }
        return todos.filter { $0.courseCode == courseCode }
    }
    
    func todosByStatus(_ status: TodoStatus) -> [TodoItem] {
        todos.filter { $0.status == status }
    }
    
    // MARK: - 持久化
    
    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todos = decoded
        }
    }
    
    // MARK: - 模拟数据
    static var mockTodos: [TodoItem] = [
        .init(title: "完成数据科学报告", dueDate: Date().addingTimeInterval(86400 * 2), priority: .high, category: "作业", status: .inProgress, courseCode: "CHME0007"),
        .init(title: "准备统计学期中考试", dueDate: Date().addingTimeInterval(86400 * 5), priority: .medium, category: "考试", status: .notStarted, courseCode: "CHME0007"),
        .init(title: "阅读机器学习论文", dueDate: Date().addingTimeInterval(86400 * 1), priority: .low, category: "阅读", status: .completed),
        .init(title: "小组项目会议", dueDate: Date().addingTimeInterval(3600 * 4), priority: .urgent, category: "项目", status: .inProgress)
    ]
}

