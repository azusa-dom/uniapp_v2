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
    var todoManager: TodoManager
    
    // 用于订阅 TodoManager 的变化
    private var cancellables = Set<AnyCancellable>()
    
    // 初始化器
    init() {
        self.todoManager = TodoManager()
        
        // 订阅 TodoManager 的变化，当 todos 变化时触发 AppState 的更新
        todoManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // -- 日历事件 --
    @Published var calendarEvents: [UCLAPIViewModel.UCLAPIEvent]? = nil
    
    // 兼容性：todos 作为 todoManager.todos 的代理
    var todos: [TodoItem] {
        get { todoManager.todos }
        set { todoManager.todos = newValue }
    }
    
    // ✅ 待办事项管理方法（代理到 TodoManager）
    func addTodo(_ todo: TodoItem) {
        todoManager.addTodo(todo)
    }
    
    func updateTodo(_ todo: TodoItem) {
        todoManager.updateTodo(todo)
    }
    
    func toggleTodo(_ todo: TodoItem) {
        todoManager.toggleTodoStatus(todo)
    }
    
    func deleteTodo(_ todo: TodoItem) {
        todoManager.deleteTodo(todo)
    }
}
