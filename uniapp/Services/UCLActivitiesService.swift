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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // 使用 MockData.activities 进行演示
            let dfDate = DateFormatter()
            dfDate.locale = Locale(identifier: "en_US")
            dfDate.dateFormat = "MMM d, yyyy"

            let dfTime = DateFormatter()
            dfTime.locale = Locale(identifier: "en_US")
            dfTime.dateFormat = "HH:mm"

            self.activities = MockData.activities.map { a in
                UCLActivity(
                    id: a.id,
                    title: a.title,
                    titleZH: a.titleZH,
                    startTime: dfTime.string(from: a.startDate),
                    endTime: dfTime.string(from: a.endDate),
                    date: dfDate.string(from: a.startDate),
                    location: a.location,
                    locationZH: a.locationZH,
                    type: a.category.lowercased(),
                    typeZH: a.categoryZH.lowercased(),
                    description: a.description,
                    descriptionZH: a.descriptionZH
                )
            }
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
