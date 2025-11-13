//
//  TodoModels.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import Foundation
import SwiftUI

// MARK: - 待办事项
struct TodoItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var dueDate: Date?
    var priority: TodoPriority = .medium
    var category: String
    var notes: String?
    var isCompleted: Bool = false
    var createdDate: Date = Date()
    var source: String = "学生" // "学生" 或 "学校"
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
}

enum TodoPriority: String, CaseIterable, Identifiable {
    case low, medium, high, urgent
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        case .urgent: return "紧急"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "10B981"
        case .medium: return "F59E0B"
        case .high: return "EF4444"
        case .urgent: return "DC2626"
        }
    }
}
