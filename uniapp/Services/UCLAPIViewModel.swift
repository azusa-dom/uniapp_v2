import SwiftUI
import EventKit

final class UCLAPIViewModel: ObservableObject {
    enum EventType: String {
        case api
        case manual
    }

    struct UCLAPIEvent: Identifiable, Equatable {
        let id: UUID
        var title: String
        var startTime: Date
        var endTime: Date
        var location: String
        var type: EventType
        var description: String?

        init(id: UUID = UUID(),
             title: String,
             startTime: Date,
             endTime: Date,
             location: String,
             type: EventType,
             description: String? = nil) {
            self.id = id
            self.title = title
            self.startTime = startTime
            self.endTime = endTime
            self.location = location
            self.type = type
            self.description = description
        }
    }

    @Published var events: [UCLAPIEvent] = []
    private let eventStore = EKEventStore()

    func fetchEvents() {
        guard events.isEmpty else { return }
        let calendar = Calendar.current
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
        
        if let dec10b = calendar.date(byAdding: .day, value: 30, to: today) {
            events.append(UCLAPIEvent(
                title: "📝 Markov 模型小组项目截止 (CHME0030)",
                startTime: setTime(date: dec10b, hour: 23, minute: 59),
                endTime: setTime(date: dec10b, hour: 23, minute: 59),
                location: "课堂展示",
                type: .api,
                description: "健康经济学与决策建模 - Markov 模型小组项目"
            ))
        }
    }
}
