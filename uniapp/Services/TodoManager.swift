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
            title: "完成 Python 数据分析作业",
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            priority: .high,
            category: "作业",
            notes: "使用 pandas 完成数据清洗和可视化，提交 Jupyter Notebook",
            source: "CHME0007"
        ),
        TodoItem(
            title: "准备 Research Methods 演讲",
            dueDate: Calendar.current.date(byAdding: .day, value: 4, to: Date()),
            priority: .medium,
            category: "作业",
            notes: "10分钟演讲，需要准备 PPT 和演讲稿",
            source: "CHME0008"
        ),
        TodoItem(
            title: "提交文献综述初稿",
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            priority: .medium,
            category: "论文",
            notes: "至少15篇文献，3000字，APA格式",
            source: "毕业项目"
        ),
        TodoItem(
            title: "完成 Machine Learning 练习题",
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            priority: .high,
            category: "作业",
            notes: "第5章习题 1-20 题，需要提交代码和结果截图",
            source: "CHME0009"
        ),
        TodoItem(
            title: "阅读指定论文并写摘要",
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
            priority: .low,
            category: "阅读",
            notes: "阅读 'Deep Learning in Healthcare' 并写500字摘要",
            source: "CHME0007"
        ),
        TodoItem(
            title: "小组项目进度汇报",
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            priority: .urgent,
            category: "项目",
            notes: "准备本周进度PPT，展示数据收集成果",
            source: "小组项目"
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
