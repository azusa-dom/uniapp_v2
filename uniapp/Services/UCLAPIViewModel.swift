import SwiftUI
import EventKit

final class UCLAPIViewModel: ObservableObject {
    enum EventType: String {
        case api
        case manual
        case activity  // UCL 活动
        case recommended  // 推荐活动
    }

    struct UCLAPIEvent: Identifiable, Equatable {
        let id: UUID
        var title: String
        var startTime: Date
        var endTime: Date
        var location: String
        var type: EventType
        var description: String?
        var activityType: String?  // 活动类型 (academic, cultural, sport等)
        var isRecommended: Bool  // 是否为推荐活动

        init(id: UUID = UUID(),
             title: String,
             startTime: Date,
             endTime: Date,
             location: String,
             type: EventType,
             description: String? = nil,
             activityType: String? = nil,
             isRecommended: Bool = false) {
            self.id = id
            self.title = title
            self.startTime = startTime
            self.endTime = endTime
            self.location = location
            self.type = type
            self.description = description
            self.activityType = activityType
            self.isRecommended = isRecommended
        }
    }

    @Published var events: [UCLAPIEvent] = []
    @Published var activities: [UCLActivity] = []  // UCL 活动数据
    private let eventStore = EKEventStore()
    private let activitiesService = UCLActivitiesService()
    
    init() {
        // 在初始化时加载活动数据
        activitiesService.loadActivities()
        
        // 监听活动加载完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.activities = self.activitiesService.activities
            print("📱 活动数据已加载: \(self.activities.count) 个")
        }
    }

    func fetchEvents() {
        guard events.isEmpty else { return }
        
        let today = Date()

        // 生成本周的课程表（周一到周五）- 真实 HDS 课程
        var weekEvents: [UCLAPIEvent] = []
        
        // 周一 - 数据方法与健康研究（CHME0013）
        if let monday = getWeekday(1, from: today) {
            weekEvents.append(UCLAPIEvent(
                title: "数据方法与健康研究 (CHME0013)",
                startTime: setTime(date: monday, hour: 10, minute: 0),
                endTime: setTime(date: monday, hour: 12, minute: 0),
                location: "Rockefeller Building, Room 342",
                type: .api,
                description: "研究方法论与数据分析设计"
            ))
        }
        
        // 周二 - 数据科学与统计（CHME0007）
        if let tuesday = getWeekday(2, from: today) {
            weekEvents.append(UCLAPIEvent(
                title: "数据科学与统计 (CHME0007)",
                startTime: setTime(date: tuesday, hour: 9, minute: 30),
                endTime: setTime(date: tuesday, hour: 11, minute: 30),
                location: "Foster Court, Room 114",
                type: .api,
                description: "回归分析与统计建模"
            ))
        }
        
        // 周三 - Python 健康研究编程（CHME0011）
        if let wednesday = getWeekday(3, from: today) {
            weekEvents.append(UCLAPIEvent(
                title: "Python 健康研究编程 (CHME0011)",
                startTime: setTime(date: wednesday, hour: 14, minute: 0),
                endTime: setTime(date: wednesday, hour: 17, minute: 0),
                location: "Computer Lab G03, Malet Place",
                type: .api,
                description: "数据清洗、可视化与脚本优化"
            ))
        }
        
        // 周四 - 医疗人工智能（CHME0016）
        if let thursday = getWeekday(4, from: today) {
            weekEvents.append(UCLAPIEvent(
                title: "医疗人工智能 (CHME0016)",
                startTime: setTime(date: thursday, hour: 10, minute: 0),
                endTime: setTime(date: thursday, hour: 12, minute: 0),
                location: "Roberts Building, Room 110",
                type: .api,
                description: "CNN、NLP 与 Transformer 应用"
            ))
        }
        
        // 周五 - 健康数据科学原理（CHME0006）
        if let friday = getWeekday(5, from: today) {
            weekEvents.append(UCLAPIEvent(
                title: "健康数据科学原理 (CHME0006)",
                startTime: setTime(date: friday, hour: 11, minute: 0),
                endTime: setTime(date: friday, hour: 13, minute: 0),
                location: "Medical Sciences Building, LT1",
                type: .api,
                description: "文献综述与数据系统案例分析"
            ))
        }
        
        // 添加作业截止日期事件
        addAssignmentDeadlines(&weekEvents, relativeTo: today)
        
        events = weekEvents
        
        // 如果活动已经加载，立即集成；否则稍后集成
        if !activities.isEmpty {
            integrateActivitiesToEvents()
            generateRecommendations()
            print("📅 活动已集成到日历: \(activities.count) 个")
        } else {
            // 等待活动加载完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if !self.activities.isEmpty {
                    self.integrateActivitiesToEvents()
                    self.generateRecommendations()
                    print("📅 延迟集成活动到日历: \(self.activities.count) 个")
                }
            }
        }
    }
    
    // 辅助函数：获取本周特定星期几的日期
    private func getWeekday(_ targetWeekday: Int, from date: Date) -> Date? {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: date)
        
        // 周日=1, 周一=2, ..., 周六=7
        // 转换为周一=1, ..., 周日=7
        let adjustedCurrent = currentWeekday == 1 ? 7 : currentWeekday - 1
        let dayDifference = targetWeekday - adjustedCurrent
        
        return calendar.date(byAdding: .day, value: dayDifference, to: date)
    }
    
    // 辅助函数：设置具体时间
    private func setTime(date: Date, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? date
    }

    func addEventToCalendar(event: UCLAPIEvent) {
        if #available(macOS 14.0, iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, _ in
                guard granted else { return }
                let ekEvent = EKEvent(eventStore: self.eventStore)
                ekEvent.title = event.title
                ekEvent.startDate = event.startTime
                ekEvent.endDate = event.endTime
                ekEvent.location = event.location
                ekEvent.calendar = self.eventStore.defaultCalendarForNewEvents
                try? self.eventStore.save(ekEvent, span: .thisEvent)
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, _ in
                guard granted else { return }
                let ekEvent = EKEvent(eventStore: self.eventStore)
                ekEvent.title = event.title
                ekEvent.startDate = event.startTime
                ekEvent.endDate = event.endTime
                ekEvent.location = event.location
                ekEvent.calendar = self.eventStore.defaultCalendarForNewEvents
                try? self.eventStore.save(ekEvent, span: .thisEvent)
            }
        }
    }

    func addManualEvent(title: String, startTime: Date, endTime: Date, location: String) {
        let newEvent = UCLAPIEvent(
            title: title,
            startTime: startTime,
            endTime: endTime,
            location: location,
            type: .manual
        )
        events.append(newEvent)
    }
    
    // 添加作业截止日期事件
    private func addAssignmentDeadlines(_ events: inout [UCLAPIEvent], relativeTo today: Date) {
        let calendar = Calendar.current
        
        // CHME0013 - 数据方法与健康研究
        if let nov20 = calendar.date(byAdding: .day, value: 10, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 研究设计报告截止 (CHME0013)",
                startTime: setTime(date: nov20, hour: 23, minute: 59),
                endTime: setTime(date: nov20, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "数据方法与健康研究 - 研究设计报告"
            ))
        }
        
        if let dec1 = calendar.date(byAdding: .day, value: 21, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 模拟试卷截止 (CHME0013)",
                startTime: setTime(date: dec1, hour: 23, minute: 59),
                endTime: setTime(date: dec1, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "数据方法与健康研究 - 模拟试卷"
            ))
        }
        
        // CHME0007 - 数据科学与统计
        if let nov25 = calendar.date(byAdding: .day, value: 15, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 多元分析练习截止 (CHME0007)",
                startTime: setTime(date: nov25, hour: 23, minute: 59),
                endTime: setTime(date: nov25, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "数据科学与统计 - 多元分析练习"
            ))
        }
        
        if let dec3 = calendar.date(byAdding: .day, value: 23, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 概率论小测截止 (CHME0007)",
                startTime: setTime(date: dec3, hour: 23, minute: 59),
                endTime: setTime(date: dec3, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "数据科学与统计 - 概率论小测"
            ))
        }
        
        // CHME0006 - 健康数据科学原理
        if let nov18 = calendar.date(byAdding: .day, value: 8, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 数据系统案例分析截止 (CHME0006)",
                startTime: setTime(date: nov18, hour: 23, minute: 59),
                endTime: setTime(date: nov18, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "健康数据科学原理 - 数据系统案例分析"
            ))
        }
        
        if let nov28 = calendar.date(byAdding: .day, value: 18, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 小组讨论演示截止 (CHME0006)",
                startTime: setTime(date: nov28, hour: 23, minute: 59),
                endTime: setTime(date: nov28, hour: 23, minute: 59),
                location: "课堂展示",
                type: .api,
                description: "健康数据科学原理 - 小组讨论演示"
            ))
        }
        
        if let dec5 = calendar.date(byAdding: .day, value: 25, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 模块测验截止 (CHME0006)",
                startTime: setTime(date: dec5, hour: 23, minute: 59),
                endTime: setTime(date: dec5, hour: 23, minute: 59),
                location: "在线考试",
                type: .api,
                description: "健康数据科学原理 - 模块测验"
            ))
        }
        
        // CHME0011 - Python 健康研究编程
        if let nov15 = calendar.date(byAdding: .day, value: 5, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 脚本优化练习截止 (CHME0011)",
                startTime: setTime(date: nov15, hour: 23, minute: 59),
                endTime: setTime(date: nov15, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "Python 健康研究编程 - 脚本优化练习"
            ))
        }
        
        if let nov30 = calendar.date(byAdding: .day, value: 20, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 Pandas 期末练习截止 (CHME0011)",
                startTime: setTime(date: nov30, hour: 23, minute: 59),
                endTime: setTime(date: nov30, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "Python 健康研究编程 - Pandas 期末练习"
            ))
        }
        
        if let dec6 = calendar.date(byAdding: .day, value: 26, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 代码规范检查截止 (CHME0011)",
                startTime: setTime(date: dec6, hour: 23, minute: 59),
                endTime: setTime(date: dec6, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "Python 健康研究编程 - 代码规范检查"
            ))
        }
        
        // CHME0008 - 数据科学流行病学
        if let dec5b = calendar.date(byAdding: .day, value: 25, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 流行病模型推导截止 (CHME0008)",
                startTime: setTime(date: dec5b, hour: 23, minute: 59),
                endTime: setTime(date: dec5b, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "数据科学流行病学 - 流行病模型推导"
            ))
        }
        
        if let dec8 = calendar.date(byAdding: .day, value: 28, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 R 代码应用测试截止 (CHME0008)",
                startTime: setTime(date: dec8, hour: 23, minute: 59),
                endTime: setTime(date: dec8, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "数据科学流行病学 - R 代码应用测试"
            ))
        }
        
        // CHME0016 - 医疗人工智能
        if let nov25b = calendar.date(byAdding: .day, value: 15, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 Transformer 文献讨论截止 (CHME0016)",
                startTime: setTime(date: nov25b, hour: 23, minute: 59),
                endTime: setTime(date: nov25b, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "医疗人工智能 - Transformer 文献讨论"
            ))
        }
        
        if let dec10 = calendar.date(byAdding: .day, value: 30, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 期末模型复现截止 (CHME0016)",
                startTime: setTime(date: dec10, hour: 23, minute: 59),
                endTime: setTime(date: dec10, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "医疗人工智能 - 期末模型复现"
            ))
        }
        
        // CHME0021 - 医疗信息系统基础
        if let nov22 = calendar.date(byAdding: .day, value: 12, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 HL7/FHIR 解析作业截止 (CHME0021)",
                startTime: setTime(date: nov22, hour: 23, minute: 59),
                endTime: setTime(date: nov22, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "医疗信息系统基础 - HL7/FHIR 解析作业"
            ))
        }
        
        if let dec1b = calendar.date(byAdding: .day, value: 21, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 医院 IT 基础设施分析截止 (CHME0021)",
                startTime: setTime(date: dec1b, hour: 23, minute: 59),
                endTime: setTime(date: dec1b, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "医疗信息系统基础 - 医院 IT 基础设施分析"
            ))
        }
        
        // CHME0012 - 应用计算基因组学
        if let nov30b = calendar.date(byAdding: .day, value: 20, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 SNP 变异分析截止 (CHME0012)",
                startTime: setTime(date: nov30b, hour: 23, minute: 59),
                endTime: setTime(date: nov30b, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "应用计算基因组学 - SNP 变异分析"
            ))
        }
        
        if let dec12 = calendar.date(byAdding: .day, value: 32, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 基因组可视化报告截止 (CHME0012)",
                startTime: setTime(date: dec12, hour: 23, minute: 59),
                endTime: setTime(date: dec12, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "应用计算基因组学 - 基因组可视化报告"
            ))
        }
        
        // CHME0030 - 健康经济学与决策建模
        if let nov27 = calendar.date(byAdding: .day, value: 17, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 决策树模型构建截止 (CHME0030)",
                startTime: setTime(date: nov27, hour: 23, minute: 59),
                endTime: setTime(date: nov27, hour: 23, minute: 59),
                location: "在线提交",
                type: .api,
                description: "健康经济学与决策建模 - 决策树模型构建"
            ))
        }
        
    }
    
    // MARK: - UCL 活动集成
    
    /// 加载 UCL 活动数据
    func loadUCLActivities() {
        activitiesService.loadActivities()
        
        // 监听活动加载完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.activities = self.activitiesService.activities
            self.integrateActivitiesToEvents()
            self.generateRecommendations()
        }
    }
    
    /// 将 UCL 活动集成到日历事件中
    private func integrateActivitiesToEvents() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for activity in activities {
            // 解析日期时间
            let startDate = parseActivityDateTime(activity.date, activity.startTime)
            let endDate = parseActivityDateTime(activity.date, activity.endTime)
            
            // 创建事件
            let event = UCLAPIEvent(
                title: activity.title,
                startTime: startDate,
                endTime: endDate,
                location: activity.location ?? "UCL Campus",
                type: .activity,
                description: activity.description,
                activityType: activity.type,
                isRecommended: false
            )
            
            // 避免重复添加
            if !events.contains(where: { $0.id == event.id }) {
                events.append(event)
            }
        }
        
        // 按时间排序
        events.sort { $0.startTime < $1.startTime }
    }
    
    /// 生成个性化推荐活动
    private func generateRecommendations() {
        // 根据学生的专业（健康数据科学）推荐相关活动
        let recommendedTypes = ["academic", "lecture", "seminar"]
        let healthKeywords = ["health", "data", "ai", "medical", "population", "informatics"]
        
        var recommendCount = 0
        
        for activity in activities {
            // 判断是否推荐
            let typeMatch = recommendedTypes.contains { activity.type.lowercased().contains($0) }
            let keywordMatch = healthKeywords.contains { keyword in
                activity.title.lowercased().contains(keyword) ||
                (activity.description?.lowercased().contains(keyword) ?? false)
            }
            
            if typeMatch || keywordMatch {
                print("✨ 匹配推荐: \(activity.title)")
                
                // 检查活动是否已经在事件中
                if let index = events.firstIndex(where: { event in
                    event.title == activity.title &&
                    Calendar.current.isDate(event.startTime, inSameDayAs: parseActivityDateTime(activity.date, activity.startTime))
                }) {
                    // 标记为推荐
                    events[index] = UCLAPIEvent(
                        id: events[index].id,
                        title: events[index].title,
                        startTime: events[index].startTime,
                        endTime: events[index].endTime,
                        location: events[index].location,
                        type: .recommended,
                        description: events[index].description,
                        activityType: events[index].activityType,
                        isRecommended: true
                    )
                    recommendCount += 1
                    print("✅ 已标记为推荐")
                }
            }
        }
        
        print("🎯 总共标记了 \(recommendCount) 个推荐活动")
    }
    
    /// 解析活动日期时间
    private func parseActivityDateTime(_ dateStr: String, _ timeStr: String) -> Date {
        let locale = Locale(identifier: "en_US_POSIX")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        
        // 尝试 ISO 8601 格式
        if timeStr.contains("T") {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let isoDate = isoFormatter.date(from: timeStr) {
                return isoDate
            }
            
            // 尝试不带毫秒的 ISO 格式
            let fallbackFormats = ["yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd'T'HH:mm"]
            for format in fallbackFormats {
                dateFormatter.dateFormat = format
                if let isoDate = dateFormatter.date(from: timeStr) {
                    return isoDate
                }
            }
        }
        
        // 尝试组合日期和时间
        let combined = "\(dateStr) \(timeStr)"
        let combinedFormats = [
            "MMM d, yyyy HH:mm",
            "MMM d, yyyy HH:mm:ss",
            "yyyy-MM-dd HH:mm",
            "yyyy-MM-dd HH:mm:ss"
        ]
        
        for format in combinedFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: combined) {
                return date
            }
        }
        
        // 仅解析日期
        let dateOnlyFormats = ["MMM d, yyyy", "yyyy-MM-dd"]
        for format in dateOnlyFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateStr) {
                return date
            }
        }
        
        return Date()
    }
    
    /// 获取推荐活动列表
    func getRecommendedActivities() -> [UCLAPIEvent] {
        let recommended = events.filter { $0.isRecommended && $0.startTime > Date() }
            .sorted { $0.startTime < $1.startTime }
            .prefix(5)
            .map { $0 }
        
        print("🎯 推荐活动数量: \(recommended.count) / 总事件: \(events.count)")
        print("🎯 已标记推荐的事件: \(events.filter { $0.isRecommended }.count)")
        
        return Array(recommended)
    }
    
    /// 添加活动到日历
    func addActivityToCalendar(_ activity: UCLActivity) {
        let startDate = parseActivityDateTime(activity.date, activity.startTime)
        let endDate = parseActivityDateTime(activity.date, activity.endTime)
        
        let event = UCLAPIEvent(
            title: activity.title,
            startTime: startDate,
            endTime: endDate,
            location: activity.location ?? "UCL Campus",
            type: .activity,
            description: activity.description,
            activityType: activity.type
        )
        
        // 添加到事件列表
        if !events.contains(where: { $0.title == event.title && Calendar.current.isDate($0.startTime, inSameDayAs: event.startTime) }) {
            events.append(event)
            events.sort { $0.startTime < $1.startTime }
        }
        
        // 添加到系统日历
        addEventToCalendar(event: event)
    }
}
