import Foundation
import SwiftUI

// 该文件用于扩展待办事项相关的工具方法

extension TodoItem {
    static var sampleData: [TodoItem] {
        [
            TodoItem(
                title: "完成数学作业",
                dueDate: Calendar.current.date(byAdding: .hour, value: 6, to: Date()),
                priority: .high,
                category: "作业"
            ),
            TodoItem(
                title: "复习数据科学笔记",
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                priority: .medium,
                category: "复习"
            ),
            TodoItem(
                title: "准备英语演讲",
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
                priority: .urgent,
                category: "演讲"
            )
        ]
    }
}
