//
//  TodoModels.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import Foundation
import SwiftUI

// MARK: - 待办事项
struct TodoItem: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var dueDate: Date?
    var priority: TodoPriority = .medium
    var category: String
    var notes: String?
    var status: TodoStatus = .notStarted
    var createdDate: Date = Date()
    var source: String = "学生" // "学生" 或 "学校"
    var courseCode: String? // 关联的课程代码
    
    // 兼容旧代码（计算属性，不参与编码）
    var isCompleted: Bool {
        get { status == .completed }
        set { status = newValue ? .completed : .notStarted }
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return status != .completed && dueDate < Date()
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case dueDate
        case priority
        case category
        case notes
        case status
        case createdDate
        case source
        case courseCode
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date? = nil,
        priority: TodoPriority = .medium,
        category: String,
        notes: String? = nil,
        status: TodoStatus = .notStarted,
        createdDate: Date = Date(),
        source: String = "学生",
        courseCode: String? = nil
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
        self.notes = notes
        self.status = status
        self.createdDate = createdDate
        self.source = source
        self.courseCode = courseCode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        priority = try container.decode(TodoPriority.self, forKey: .priority)
        category = try container.decode(String.self, forKey: .category)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        status = try container.decode(TodoStatus.self, forKey: .status)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        source = try container.decode(String.self, forKey: .source)
        courseCode = try container.decodeIfPresent(String.self, forKey: .courseCode)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encode(priority, forKey: .priority)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(status, forKey: .status)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(source, forKey: .source)
        try container.encodeIfPresent(courseCode, forKey: .courseCode)
    }
}

// MARK: - 待办状态
enum TodoStatus: String, Codable, CaseIterable, Identifiable {
    case notStarted = "未开始"
    case inProgress = "进行中"
    case completed = "已完成"
    
    var id: String { rawValue }
    
    var color: String {
        switch self {
        case .notStarted: return "6B7280"
        case .inProgress: return "6366F1"
        case .completed: return "10B981"
        }
    }
    
    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "clock.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

enum TodoPriority: String, Codable, CaseIterable, Identifiable {
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
