import SwiftUI

struct TodoItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var dueDate: Date?
    var priority: TodoPriority
    var category: String
    var notes: String?
    var isCompleted: Bool
    var createdDate: Date
    var source: String

    init(id: UUID = UUID(),
         title: String,
         dueDate: Date? = nil,
         priority: TodoPriority = .medium,
         category: String = "作业",
         notes: String? = nil,
         isCompleted: Bool = false,
         createdDate: Date = Date(),
         source: String = "系统") {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
        self.notes = notes
        self.isCompleted = isCompleted
        self.createdDate = createdDate
        self.source = source
    }

    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && !isCompleted
    }

    var isUpcoming: Bool {
        guard let dueDate = dueDate else { return false }
        let interval = dueDate.timeIntervalSinceNow
        return interval > 0 && interval <= 24 * 60 * 60 && !isCompleted
    }
}

enum TodoPriority: String, Codable, CaseIterable {
    case low = "低"
    case medium = "中"
    case high = "高"
    case urgent = "紧急"

    var displayName: String { rawValue }

    var color: String {
        switch self {
        case .low: return "10B981"
        case .medium: return "F59E0B"
        case .high: return "EF4444"
        case .urgent: return "DC2626"
        }
    }
}

class TodoManager: ObservableObject {
    @Published var todos: [TodoItem] = [
        TodoItem(
            title: "CS Assignment",
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            priority: .high,
            category: "作业",
            notes: "完成第三章编程作业"
        ),
        TodoItem(
            title: "Math Problem Set",
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
            priority: .medium,
            category: "作业",
            notes: "解答1-20题"
        )
    ]

    var upcomingDeadlines: [TodoItem] {
        todos
            .filter { $0.isUpcoming }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
    }

    var overdueTodos: [TodoItem] {
        todos
            .filter { $0.isOverdue }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
    }

    func addTodo(_ todo: TodoItem) {
        todos.append(todo)
    }

    func toggleCompletion(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
        }
    }

    func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
    }
}
