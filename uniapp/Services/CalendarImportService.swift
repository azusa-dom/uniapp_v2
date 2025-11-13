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
        let predicate = eventStore.predicateForEvents(withStart: e.startTime.addingTimeInterval(-60),
                                                      end: e.endTime.addingTimeInterval(60),
                                                      calendars: nil)
        let existing = eventStore.events(matching: predicate).first { ev in
            ev.title == e.title && (ev.location ?? "") == e.location
        }
        if existing != nil { return false }

        let event = EKEvent(eventStore: eventStore)
        event.title = e.title
        event.location = e.location
        event.startDate = e.startTime
        event.endDate = e.endTime
        event.notes = "\(e.courseCode) \n\(e.type) \nInstructor: \(e.instructor)"
        if alarmMinutesBefore > 0 {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-alarmMinutesBefore * 60))
            event.addAlarm(alarm)
        }
        event.calendar = eventStore.defaultCalendarForNewEvents

        try eventStore.save(event, span: .thisEvent)
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

