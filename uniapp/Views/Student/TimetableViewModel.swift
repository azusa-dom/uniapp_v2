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
    
    init() {
        loadMockData()
    }
    
    func loadMockData() {
        events = MockData.timetableEvents
    }
    
    // 获取今天的课程（将 Mock 数据映射到当前周）
    var todayEvents: [TimetableEvent] {
        let calendar = Calendar.current
        return projectedEventsForSelectedWeek().filter { event in
            calendar.isDate(event.startTime, inSameDayAs: selectedDate)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    // 获取本周的课程（将 Mock 数据映射到当前周）
    var weekEvents: [TimetableEvent] {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)),
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
            return []
        }
        return projectedEventsForSelectedWeek().filter { event in
            event.startTime >= weekStart && event.startTime < weekEnd
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

    // 将 MockData 中的事件按原始 weekday 映射到 selectedDate 所在周
    private func projectedEventsForSelectedWeek() -> [TimetableEvent] {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) else {
            return events
        }
        // weekStart 是本周第一天（周日或周一取决于当前地区）。
        return events.map { e in
            let originalWeekday = calendar.component(.weekday, from: e.startTime)
            // 计算本周对应 weekday 的日期
            var targetDay = calendar.date(byAdding: .day, value: originalWeekday - calendar.component(.weekday, from: weekStart), to: weekStart) ?? weekStart
            // 设置具体的开始/结束时刻
            let startComp = calendar.dateComponents([.hour, .minute, .second], from: e.startTime)
            let endComp = calendar.dateComponents([.hour, .minute, .second], from: e.endTime)
            let start = calendar.date(bySettingHour: startComp.hour ?? 0, minute: startComp.minute ?? 0, second: startComp.second ?? 0, of: targetDay) ?? targetDay
            let end = calendar.date(bySettingHour: endComp.hour ?? 0, minute: endComp.minute ?? 0, second: endComp.second ?? 0, of: targetDay) ?? start.addingTimeInterval(3600)
            return TimetableEvent(
                id: e.id,
                title: e.title,
                titleZH: e.titleZH,
                courseCode: e.courseCode,
                type: e.type,
                typeZH: e.typeZH,
                location: e.location,
                locationZH: e.locationZH,
                startTime: start,
                endTime: end,
                instructor: e.instructor,
                instructorZH: e.instructorZH,
                color: e.color
            )
        }
    }
}
