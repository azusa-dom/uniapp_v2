//
//  TodoManager.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI
import Combine

// MARK: - 待办事项管理器
// (为了简单起见，我们把它和 AppState 放在一起)
class TodoManager: ObservableObject {
    @Published var todos: [TodoItem] = mockTodos
    
    var upcomingDeadlines: [TodoItem] {
        todos.filter {
            !$0.isCompleted && $0.dueDate != nil && $0.dueDate! > Date() && $0.dueDate! < Date().addingTimeInterval(86400 * 3)
        }
    }
    
    func addTodo(_ todo: TodoItem) {
        todos.append(todo)
    }
    
    // 模拟数据
    static var mockTodos: [TodoItem] = [
        .init(title: "完成数据科学报告", dueDate: Date().addingTimeInterval(86400 * 2), priority: .high, category: "作业"),
        .init(title: "准备统计学期中考试", dueDate: Date().addingTimeInterval(86400 * 5), priority: .medium, category: "考试"),
        .init(title: "阅读机器学习论文", dueDate: Date().addingTimeInterval(86400 * 1), priority: .low, category: "阅读", isCompleted: true),
        .init(title: "小组项目会议", dueDate: Date().addingTimeInterval(3600 * 4), priority: .urgent, category: "项目")
    ]
}
