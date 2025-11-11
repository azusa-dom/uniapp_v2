import Foundation

// MARK: - Academic Models

struct AcademicCourseModule: Identifiable {
    struct Assignment: Identifiable {
        let id = UUID()
        let name: String
        let grade: Int
        let submitted: Bool
        let dueDate: String
    }

    struct GradeComponent: Identifiable {
        let id = UUID()
        let component: String
        let weight: Int
        let grade: Int
    }

    let id = UUID()
    let name: String
    let code: String
    let grade: Int
    let moduleAverage: Int
    let assignments: [Assignment]
    let gradeBreakdown: [GradeComponent]
}

struct Deadline: Identifiable {
    let id = UUID()
    let title: String
    let dueDate: String
    let priority: String
    let details: String
}

struct CourseSummary: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
    let grade: Int
    let semester: String
    let assignments: Int
    let participation: Int
    let average: Int
}

struct CompletedCourse: Identifiable, Hashable {
    struct Component: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let percentage: Int
        let score: Int
    }

    let id = UUID()
    let name: String
    let code: String
    let finalGrade: Int
    let credit: Int
    let gradeLevel: String
    let semester: String
    let components: [Component]
}




