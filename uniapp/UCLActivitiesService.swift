//
//  UCLActivitiesService.swift
//  uniapp
//
//  Created by 748 on 07/11/2025.
import SwiftUI
import EventKit
import Combine



class UCLActivitiesService: ObservableObject {
    @Published var activities: [UCLActivity] = []
    @Published var stats: ActivityStats = ActivityStats()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private var cancellables = Set<AnyCancellable>()
    
    // ✅ 虚拟活动数据
    private func getMockActivities() -> [UCLActivity] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return [
            UCLActivity(
                id: "1",
                title: "The Future of the ECHR – In Europe and UK",
                description: "探讨《欧洲人权公约》未来在英国和欧洲的地位",
                type: "academic",
                date: "2025-11-07",
                startTime: "2025-11-07T11:00:00",
                endTime: "2025-11-07T13:00:00",
                location: "UCL Faculty of Laws",
                rawData: nil
            ),
            UCLActivity(
                id: "2",
                title: "Assize Seminar – Cutting Edge Criminal Law",
                description: "聚焦刑法前沿问题，含多位知名学者发言",
                type: "academic",
                date: "2025-11-07",
                startTime: "2025-11-07T14:00:00",
                endTime: "2025-11-07T18:00:00",
                location: "UCL Centre for Criminal Law",
                rawData: nil
            ),
            UCLActivity(
                id: "3",
                title: "Repair Café",
                description: "免费修理日常用品，提倡可持续生活",
                type: "workshop",
                date: "2025-11-07",
                startTime: "2025-11-07T12:00:00",
                endTime: "2025-11-07T16:00:00",
                location: "UCL East Marshgate",
                rawData: nil
            ),
            UCLActivity(
                id: "4",
                title: "Workshop: Walking Elsewhere – Body and City in Exile",
                description: "结合身体与流亡城市的体验工作坊",
                type: "workshop",
                date: "2025-11-01",
                startTime: "2025-11-01T10:00:00",
                endTime: "2025-12-13T17:00:00",
                location: "UCL Institute of Advanced Studies",
                rawData: nil
            ),
            UCLActivity(
                id: "5",
                title: "Broken, Burnt, Buried: Ritual Lives of Objects in Ancient Egypt",
                description: "探索古埃及人如何通过「破坏」物品进行仪式",
                type: "academic",
                date: "2025-07-22",
                startTime: "2025-07-22T09:00:00",
                endTime: "2026-05-16T17:00:00",
                location: "Petrie Museum",
                rawData: nil
            ),
            UCLActivity(
                id: "6",
                title: "Prejudice in Power: Contesting the Pseudoscience of Superiority",
                description: "关于优生学和种族主义的历史批判与公共艺术展",
                type: "academic",
                date: "2025-02-27",
                startTime: "2025-02-27T10:00:00",
                endTime: "2025-12-12T17:00:00",
                location: "UCL Museums and Cultural Programmes",
                rawData: nil
            ),
            UCLActivity(
                id: "7",
                title: "Wednesdays Pop-Up Displays: Amongst Visions",
                description: "展出艺术家 Holly Davey 的原作及档案材料",
                type: "social",
                date: "2025-09-24",
                startTime: "2025-09-24T10:00:00",
                endTime: "2025-11-26T17:00:00",
                location: "UCL Art Museum",
                rawData: nil
            ),
            UCLActivity(
                id: "8",
                title: "World of Wasps",
                description: "通过影像与艺术探索「黄蜂的世界」，适合各年龄层",
                type: "academic",
                date: "2025-06-25",
                startTime: "2025-06-25T10:00:00",
                endTime: "2026-01-24T17:00:00",
                location: "Grant Museum",
                rawData: nil
            ),
            UCLActivity(
                id: "9",
                title: "Fair Food Futures UK Photo Exhibition",
                description: "揭示英国食品不安全现象的摄影展",
                type: "social",
                date: "2025-10-17",
                startTime: "2025-10-17T10:00:00",
                endTime: "2025-11-06T17:00:00",
                location: "Tower Hamlets",
                rawData: nil
            )
        ]
    }
    
    // ✅ 加载活动 - 使用虚拟数据
    func loadActivities() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.activities = self.getMockActivities()
            self.calculateStats()
            self.lastUpdated = Date()
            self.isLoading = false
            print("✅ 成功加载 \(self.activities.count) 个活动")
        }
    }
    
    // ✅ 刷新活动 - 重新加载虚拟数据
    func refreshActivities() {
        loadActivities()
    }
    
    // ✅ 降级方案: 从本地 JSON 加载
    private func loadLocalActivities() {
        guard let localURL = Bundle.main.url(forResource: "activities", withExtension: "json") else {
            DispatchQueue.main.async {
                self.errorMessage = "无法找到本地活动数据"
                self.isLoading = false
            }
            return
        }
        
        do {
            let data = try Data(contentsOf: localURL)
            let response = try JSONDecoder().decode(UCLActivitiesResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.activities = response.activities
                self.calculateStats()
                self.lastUpdated = Date()
                self.isLoading = false
                print("✅ 从本地加载了 \(response.activities.count) 个活动")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "加载本地数据失败: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // ✅ 计算统计数据
    private func calculateStats() {
        var stats = ActivityStats()
        stats.total = activities.count
        
        for activity in activities {
            // 按类型统计
            stats.byType[activity.type, default: 0] += 1
            
            // 按日期统计
            stats.byDate[activity.date, default: 0] += 1
        }
        
        self.stats = stats
    }
    
    // ✅ 格式化时间
    func formatTime(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let date = formatter.date(from: timeString) else {
            return timeString
        }
        
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // ✅ 格式化日期
    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "MMM d, EEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    // ✅ 获取活动类型颜色
    func getTypeColor(_ type: String) -> Color {
        let colorMap: [String: String] = [
            "room_booking": "3b82f6",
            "timetable": "8b5cf6",
            "club_activity": "ec4899",
            "career_event": "f59e0b",
            "workshop": "10b981",
            "social": "06b6d4",
            "academic": "6366f1"
        ]
        return Color(hex: colorMap[type] ?? "6b7280")
    }
    
    // ✅ 获取活动类型标签
    func getTypeLabel(_ type: String) -> String {
        let labelMap: [String: String] = [
            "room_booking": "房间预订",
            "timetable": "课程表",
            "club_activity": "社团活动",
            "career_event": "职业活动",
            "workshop": "工作坊",
            "social": "社交活动",
            "academic": "学术活动"
        ]
        return labelMap[type] ?? type
    }
    
    // ✅ 按日期筛选活动
    func activitiesForDate(_ date: Date) -> [UCLActivity] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        return activities.filter { $0.date == dateString }
    }
    
    // ✅ 按类型筛选活动
    func activitiesForType(_ type: String) -> [UCLActivity] {
        return activities.filter { $0.type == type }
    }
}
