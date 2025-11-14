//
//  TimetableViewModel.swift
//  uniapp
//

import Foundation
import SwiftUI

@MainActor
class TimetableViewModel: ObservableObject {
    @Published var events: [TimetableEvent] = []
    @Published var isLoading = false
    @Published var selectedDate = Date()
    @Published var currentWeekStart = Date()
    
    init() {
        loadEvents()
        currentWeekStart = getWeekStart(for: Date())
    }
    
    // ✅ 加载所有课程事件并生成整个学期的重复课程
    func loadEvents() {
        // 从 MockData 加载基础课程
        let baseEvents = MockData.timetableEvents
        
        // 生成重复课程（整个学期）
        events = generateRecurringEvents(from: baseEvents)
    }
    
    // ✅ 生成重复课程（每周重复到学期结束）
    private func generateRecurringEvents(from baseEvents: [TimetableEvent]) -> [TimetableEvent] {
        var allEvents: [TimetableEvent] = []
        let calendar = Calendar.current
        
        // 学期时间范围（2024年9月-2025年12月，延长到当前日期之后以确保显示）
        let today = Date()
        guard let semesterStart = calendar.date(from: DateComponents(year: 2024, month: 9, day: 1)),
              let semesterEnd = calendar.date(byAdding: .year, value: 1, to: semesterStart) else {
            return baseEvents
        }
        
        // 获取学期开始那一周的第一天（周一）
        let semesterStartWeek = getWeekStart(for: semesterStart)
        
        for event in baseEvents {
            // 从基础事件中提取星期几和时间
            let weekday = calendar.component(.weekday, from: event.startTime)
            let hour = calendar.component(.hour, from: event.startTime)
            let minute = calendar.component(.minute, from: event.startTime)
            
            // 计算从学期开始第一周的那一天到目标星期几的天数差
            let semesterStartWeekday = calendar.component(.weekday, from: semesterStartWeek)
            var dayOffset = weekday - semesterStartWeekday
            if dayOffset < 0 {
                dayOffset += 7
            }
            
            // 从学期开始的第一周对应的星期几开始
            guard var currentDate = calendar.date(byAdding: .day, value: dayOffset, to: semesterStartWeek) else {
                continue
            }
            
            // 设置具体时间
            currentDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: currentDate) ?? currentDate
            
            // 生成每周重复的课程（包括今天和未来）
            let endDate = max(semesterEnd, calendar.date(byAdding: .month, value: 6, to: today) ?? semesterEnd)
            
            while currentDate <= endDate {
                // 计算结束时间
                let duration = event.endTime.timeIntervalSince(event.startTime)
                let endTime = currentDate.addingTimeInterval(duration)
                
                // 创建新的事件实例
                let newEvent = TimetableEvent(
                    id: "\(event.id)-\(Int(currentDate.timeIntervalSince1970))",
                    title: event.title,
                    titleZH: event.titleZH,
                    courseCode: event.courseCode,
                    type: event.type,
                    typeZH: event.typeZH,
                    location: event.location,
                    locationZH: event.locationZH,
                    startTime: currentDate,
                    endTime: endTime,
                    instructor: event.instructor,
                    instructorZH: event.instructorZH,
                    color: event.color
                )
                
                allEvents.append(newEvent)
                
                // 移动到下一周的同一时间
                if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) {
                    currentDate = nextWeek
                } else {
                    break
                }
            }
        }
        
        return allEvents.sorted { $0.startTime < $1.startTime }
    }
    
    // ✅ 获取指定日期的课程
    func events(for date: Date) -> [TimetableEvent] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    // ✅ 获取指定月份的所有课程
    func events(in month: Date) -> [TimetableEvent] {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return []
        }
        
        return events.filter { event in
            event.startTime >= monthStart && event.startTime <= monthEnd
        }.sorted { $0.startTime < $1.startTime }
    }
    
    // ✅ 获取一周的开始日期（周一）
    func getWeekStart(for date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = 2 // 周一
        return calendar.date(from: components) ?? date
    }
    
    // ✅ 检查某天是否有课程
    func hasEvents(on date: Date) -> Bool {
        !events(for: date).isEmpty
    }
    
    // ✅ 获取某天的课程数量
    func eventCount(on date: Date) -> Int {
        events(for: date).count
    }
    
    // ✅ 获取今天的课程
    var todayEvents: [TimetableEvent] {
        events(for: Date())
    }
    
    // ✅ 获取当前周的所有课程
    var weekEvents: [TimetableEvent] {
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: currentWeekStart) ?? currentWeekStart
        
        return events.filter { event in
            event.startTime >= currentWeekStart && event.startTime <= weekEnd
        }.sorted { $0.startTime < $1.startTime }
    }
    
    // 按日期分组
    func eventsByDay() -> [Date: [TimetableEvent]] {
        let calendar = Calendar.current
        var grouped: [Date: [TimetableEvent]] = [:]
        
        for event in weekEvents {
            let day = calendar.startOfDay(for: event.startTime)
            grouped[day, default: []].append(event)
        }
        
        return grouped
    }
}
