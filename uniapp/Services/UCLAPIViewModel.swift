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

        events = [
            UCLAPIEvent(
                title: "Data Science Lecture",
                startTime: calendar.date(byAdding: .hour, value: 2, to: today) ?? today,
                endTime: calendar.date(byAdding: .hour, value: 3, to: today) ?? today,
                location: "Roberts Building 110",
                type: .api,
                description: "Weekly lecture covering advanced analytics."
            ),
            UCLAPIEvent(
                title: "Group Project Standup",
                startTime: calendar.date(byAdding: .hour, value: 5, to: today) ?? today,
                endTime: calendar.date(byAdding: .hour, value: 6, to: today) ?? today,
                location: "Bloomsbury Cafe",
                type: .api,
                description: "Sprint sync with teammates."
            )
        ]
    }

    func addEventToCalendar(event: UCLAPIEvent) {
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
