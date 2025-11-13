//
//  UCLActivitiesService.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI
import Combine

// MARK: - UCL 活动服务
class UCLActivitiesService: ObservableObject {
    @Published var activities: [UCLActivity] = []
    @Published var isLoading = false
    
    // 模拟加载
    func loadActivities() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.activities = [
                .init(id: "1", title: "AI in Health 研讨会", startTime: "2024-11-15T14:00:00", endTime: "2024-11-15T16:00:00", date: "Nov 15, 2024", location: "Medawar Building G01", type: "seminar", description: "探讨人工智能在医疗诊断中的最新应用。"),
                .init(id: "2", title: "Python 数据分析工作坊", startTime: "2024-11-16T10:00:00", endTime: "2024-11-16T13:00:00", date: "Nov 16, 2024", location: "Roberts Building 101", type: "workshop", description: "学习使用 Pandas 和 Matplotlib 进行数据分析。"),
                .init(id: "3", title: "留学生社交之夜", startTime: "2024-11-16T18:00:00", endTime: "2024-11-16T21:00:00", date: "Nov 16, 2024", location: "Student Union", type: "social", description: "认识新朋友，享受免费披萨。")
            ]
            self.isLoading = false
        }
    }
    
    // 刷新活动
    func refreshActivities() {
        loadActivities()
    }
    
    // 辅助函数
    func formatTime(_ timeString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        
        if let date = isoFormatter.date(from: timeString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        }
        
        // 备用解析
        let altFormatter = DateFormatter()
        altFormatter.dateFormat = "h:mm a"
        if let date = altFormatter.date(from: timeString) {
             let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        }
        
        if timeString.contains(":") && timeString.count <= 5 {
            return timeString
        }
        
        return "N/A"
    }
    
    func getTypeLabel(_ type: String) -> String {
        switch type.lowercased() {
        case "workshop": return "工作坊"
        case "seminar": return "研讨会"
        case "lecture": return "讲座"
        case "social": return "社交活动"
        case "sports": return "体育活动"
        case "career": return "职业发展"
        case "cultural": return "文化活动"
        default: return "活动"
        }
    }
    
    func getTypeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "workshop": return Color(hex: "8B5CF6")
        case "seminar": return Color(hex: "6366F1")
        case "lecture": return Color(hex: "3B82F6")
        case "social": return Color(hex: "EC4899")
        case "sports": return Color(hex: "10B981")
        case "career": return Color(hex: "F59E0B")
        case "cultural": return Color(hex: "A855F7")
        default: return Color(hex: "6B7280")
        }
    }
}
