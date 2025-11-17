//
//  CalendarImportService.swift
//  uniapp
//

import Foundation
import EventKit

final class CalendarImportService {
    static let shared = CalendarImportService()
    private let eventStore = EKEventStore()

    private init() {}

    // Import timetable events into the system calendar; skips likely duplicates
    func importTimetableEvents(_ events: [TimetableEvent], alarmMinutesBefore: Int = 15) async throws -> Int {
        guard await ensureCalendarPermission() else {
            throw NSError(domain: "CalendarImport", code: 1, userInfo: [NSLocalizedDescriptionKey: "没有日历权限"])
        }

        var importedCount = 0
        for e in events {
            if try await saveIfNotDuplicate(e, alarmMinutesBefore: alarmMinutesBefore) {
                importedCount += 1
            }
        }
        return importedCount
    }

    private func saveIfNotDuplicate(_ e: TimetableEvent, alarmMinutesBefore: Int) async throws -> Bool {
        // 检查是否已存在相同的事件（通过标题和位置匹配）
        let calendar = Calendar.current
        // 扩大搜索范围：从当前日期往前3个月，往后6个月
        let searchStart = calendar.date(byAdding: .month, value: -3, to: e.startTime) ?? e.startTime
        let searchEnd = calendar.date(byAdding: .month, value: 6, to: e.startTime) ?? e.startTime
        
        let predicate = eventStore.predicateForEvents(withStart: searchStart,
                                                      end: searchEnd,
                                                      calendars: nil)
        let existing = eventStore.events(matching: predicate).first { ev in
            // 检查标题是否匹配（可能包含课程代码）
            let eventTitle = ev.title ?? ""
            let expectedTitle = "\(e.courseCode) · \(e.title)"
            let matchesTitle = eventTitle == expectedTitle || 
                              eventTitle.contains(e.courseCode) || 
                              eventTitle.contains(e.title)
            
            // 检查位置是否匹配（支持中英文）
            let matchesLocation = (ev.location ?? "") == e.location || 
                                 (ev.location ?? "") == e.locationZH ||
                                 e.location.contains(ev.location ?? "") ||
                                 e.locationZH.contains(ev.location ?? "")
            
            // 检查时间是否匹配（允许1小时的误差）
            let timeDiff = abs(ev.startDate.timeIntervalSince(e.startTime))
            let matchesTime = timeDiff < 3600 // 1小时内
            
            return matchesTitle && matchesLocation && matchesTime
        }
        if existing != nil { return false }

        let event = EKEvent(eventStore: eventStore)
        // 使用课程代码和标题作为事件标题
        event.title = "\(e.courseCode) · \(e.title)"
        event.location = e.location
        event.startDate = e.startTime
        event.endDate = e.endTime
        event.notes = "课程代码: \(e.courseCode)\n类型: \(e.type)\n讲师: \(e.instructor)"
        
        // 添加提醒
        if alarmMinutesBefore > 0 {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-alarmMinutesBefore * 60))
            event.addAlarm(alarm)
        }
        
        // 设置每周重复规则（学期通常持续12-14周）
        let recurrenceRule = EKRecurrenceRule(
            recurrenceWith: .weekly,
            interval: 1,
            end: EKRecurrenceEnd(end: calendar.date(byAdding: .weekOfYear, value: 14, to: e.startTime) ?? e.startTime)
        )
        event.recurrenceRules = [recurrenceRule]
        
        event.calendar = eventStore.defaultCalendarForNewEvents

        try eventStore.save(event, span: .futureEvents)
        return true
    }

    private func ensureCalendarPermission() async -> Bool {
        if #available(iOS 17, *) {
            let status = EKEventStore.authorizationStatus(for: .event)
            switch status {
            case .notDetermined:
                return await requestWriteAccess()
            case .writeOnly, .fullAccess:
                return true
            default:
                return false
            }
        } else {
            let status = EKEventStore.authorizationStatus(for: .event)
            switch status {
            case .notDetermined:
                return (try? await eventStore.requestAccess(to: .event)) ?? false
            case .authorized:
                return true
            default:
                return false
            }
        }
    }

    @available(iOS 17, *)
    private func requestWriteAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            eventStore.requestWriteOnlyAccessToEvents { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }
}

