import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userRole: UserRole = .student
    @Published var shareGrades = true
    @Published var shareCalendar = true
    @Published var avatarIcon = "person.fill"
    @Published var todoManager = TodoManager()
    @Published var calendarEvents: [CalendarEvent]? = []
    
    // 学生个人信息
    @Published var studentName = "Zoya Huo"
    @Published var studentEmail = "zoya@ucl.ac.uk"
    @Published var studentId = "3012345"
    @Published var studentProgram = "MSc Health Data Science"
    @Published var studentYear = "Year 1"
    @Published var studentPhone = ""
    @Published var studentBio = "这里可以自己自定义"
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
