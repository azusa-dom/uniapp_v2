//
//  全局状态.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI
import Combine

// MARK: - 用户角色
enum UserRole: String, CaseIterable, Identifiable {
    case student = "学生"
    case parent = "家长"
    
    var id: String { rawValue }
}

// MARK: - 全局 App 状态
class AppState: ObservableObject {
    
    // -- 认证和角色 --
    @Published var isLoggedIn: Bool = true // 演示方便，设为 true
    @Published var userRole: UserRole = .student // 默认角色
    
    // -- 学生数据 --
    @Published var avatarIcon: String = "person.fill" // 学生头像
    @Published var studentName: String = "Zoya Huo"
    @Published var studentEmail: String = "zoya.huo@ucl.ac.uk"
    @Published var studentId: String = "UCL123456"
    @Published var studentProgram: String = "MSc Health Data Science"
    @Published var studentYear: String = "2024-25"
    @Published var studentPhone: String = "+44 20 1234 5678"
    @Published var studentBio: String = "健康数据科学专业学生，专注于数据分析和健康研究。"
    
    // -- 共享设置 --
    @Published var shareGrades: Bool = true
    @Published var shareCalendar: Bool = true
    
    // -- 管理器 --
    // 直接在 AppState 中管理待办事项
    @Published var todos: [TodoItem] = TodoManager.mockTodos
    
    // -- 日历事件 --
    @Published var calendarEvents: [UCLAPIViewModel.UCLAPIEvent]? = nil
    
    // TodoManager 计算属性（只读，用于访问计算属性）
    var todoManager: TodoManager {
        let manager = TodoManager()
        manager.todos = self.todos
        return manager
    }
    
    // ✅ 待办事项管理方法
    func addTodo(_ todo: TodoItem) {
        todos.append(todo)
    }
    
    func toggleTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
        }
    }
    
    func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
    }
}
