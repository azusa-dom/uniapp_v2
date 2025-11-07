import SwiftUI

enum UserRole {
    case student
    case parent
}

class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userRole: UserRole = .student
    @Published var shareGrades = true
    @Published var shareCalendar = true
    @Published var avatarIcon = "person.fill"
    @Published var todoManager = TodoManager()
    @Published var calendarEvents: [CalendarEvent]? = []
}

enum CalendarEventType: String, Codable {
    case activity
    case todo
    case academic
}

struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var location: String
    var type: CalendarEventType
    var isAddedToCalendar: Bool
}
