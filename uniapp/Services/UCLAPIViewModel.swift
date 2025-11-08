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
        
        // 获取今天是星期几
        _ = calendar.component(.weekday, from: today)
        
        // 生成本周的课程表（周一到周五）
        var weekEvents: [UCLAPIEvent] = []
        
        // 周一课程
        if let monday = getWeekday(1, from: today) {
            weekEvents.append(UCLAPIEvent(
                title: "Research Methods Seminar",
                startTime: setTime(date: monday, hour: 10, minute: 0),
                endTime: setTime(date: monday, hour: 12, minute: 0),
                location: "Rockefeller Building, Room 342",
                type: .api,
                description: "Research methodology and study design"
            ))
            weekEvents.append(UCLAPIEvent(
                title: "Python Lab Session",
                startTime: setTime(date: monday, hour: 14, minute: 0),
                endTime: setTime(date: monday, hour: 17, minute: 0),
                location: "Computer Lab G03, Malet Place",
                type: .api,
                description: "Hands-on Python programming practice"
            ))
        }
        
        // 周二课程
        if let tuesday = getWeekday(2, from: today) {
            weekEvents.append(UCLAPIEvent(
                title: "Data Visualization Workshop",
                startTime: setTime(date: tuesday, hour: 9, minute: 30),
                endTime: setTime(date: tuesday, hour: 11, minute: 30),
                location: "Foster Court, Room 114",
                type: .api,
                description: "Creating interactive dashboards with Plotly"
            ))
            weekEvents.append(UCLAPIEvent(
                title: "Academic Writing Skills",
                startTime: setTime(date: tuesday, hour: 13, minute: 0),
                endTime: setTime(date: tuesday, hour: 15, minute: 0),
                location: "Main Library, Room 209",
                type: .api,
                description: "Academic paper structure and citation"
            ))
        }
        
        // 周三课程
        if let wednesday = getWeekday(3, from: today) {
            weekEvents.append(UCLAPIEvent(
                title: "Study Group Session",
                startTime: setTime(date: wednesday, hour: 10, minute: 0),
                endTime: setTime(date: wednesday, hour: 12, minute: 0),
                location: "Student Centre, Study Room 5",
                type: .api,
                description: "Weekly peer study group"
            ))
            weekEvents.append(UCLAPIEvent(
                title: "Machine Learning Tutorial",
                startTime: setTime(date: wednesday, hour: 15, minute: 0),
                endTime: setTime(date: wednesday, hour: 17, minute: 0),
                location: "Roberts Building, Room 110",
                type: .api,
                description: "Advanced ML algorithms and applications"
            ))
        }
        
        // 周四课程
        if let thursday = getWeekday(4, from: today) {
            weekEvents.append(UCLAPIEvent(
                title: "Healthcare Data Analysis",
                startTime: setTime(date: thursday, hour: 9, minute: 0),
                endTime: setTime(date: thursday, hour: 11, minute: 0),
                location: "Medical Sciences Building, LT1",
                type: .api,
                description: "Analyzing real-world healthcare datasets"
            ))
            weekEvents.append(UCLAPIEvent(
                title: "Database Systems Lab",
                startTime: setTime(date: thursday, hour: 14, minute: 0),
                endTime: setTime(date: thursday, hour: 16, minute: 0),
                location: "Computer Lab B07, Drayton House",
                type: .api,
                description: "SQL and NoSQL database practice"
            ))
        }
        
        // 周五课程
        if let friday = getWeekday(5, from: today) {
            weekEvents.append(UCLAPIEvent(
                title: "Project Supervision Meeting",
                startTime: setTime(date: friday, hour: 11, minute: 0),
                endTime: setTime(date: friday, hour: 12, minute: 0),
                location: "Office 4.12, Cruciform Building",
                type: .api,
                description: "One-on-one project guidance with supervisor"
            ))
            weekEvents.append(UCLAPIEvent(
                title: "Careers Workshop",
                startTime: setTime(date: friday, hour: 15, minute: 0),
                endTime: setTime(date: friday, hour: 17, minute: 0),
                location: "Wilkins Building, Carey Foster Room",
                type: .api,
                description: "CV writing and interview preparation"
            ))
        }
        
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
}
