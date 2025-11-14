import Foundation
import SwiftUI

// MARK: - Models
struct Assessment: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var weight: Double
    var score: Double?
}

struct Module: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var nameZH: String?  // 中文名称（可选）
    var code: String
    var credits: Int
    var isCompleted: Bool = false
    var assessments: [Assessment] = []
    
    // 根据语言返回显示名称
    func displayName(isChinese: Bool) -> String {
        if isChinese, let zhName = nameZH, !zhName.isEmpty {
            return "\(name) · \(zhName)"
        }
        return name
    }
    
    var finalMark: Double {
        guard !assessments.isEmpty else { return 0.0 }
        
        let weightedSum = assessments.reduce(0.0) { sum, assessment in
            let score = assessment.score ?? 0.0
            return sum + (score * (assessment.weight / 100.0))
        }
        
        return min(100, max(0, weightedSum))
    }
    
    var predictedMark: Double {
        let gradedAssessments = assessments.filter { $0.score != nil }
        guard !gradedAssessments.isEmpty else { return 0.0 }
        
        let totalWeightGraded = gradedAssessments.reduce(0.0) { $0 + $1.weight }
        guard totalWeightGraded > 0 else { return 0.0 }
        
        let achievedScore = gradedAssessments.reduce(0.0) { sum, assessment in
            sum + (assessment.score! * assessment.weight)
        }
        
        let predicted = achievedScore / totalWeightGraded
        return min(100, max(0, predicted))
    }
    
    var progressPercentage: Double {
        let gradedAssessments = assessments.filter { $0.score != nil }
        if assessments.isEmpty { return 0.0 }
        return Double(gradedAssessments.count) / Double(assessments.count)
    }
    
    var completedAssignments: Int {
        assessments.filter { $0.score != nil }.count
    }
    
    var totalAssignments: Int {
        assessments.count
    }
    
    var completedExams: Int = 0
    var totalExams: Int = 0
}

struct Assignment: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var course: String
    var dueDate: Date
}

// MARK: - ViewModel
@MainActor
class AcademicViewModel: ObservableObject {
    @Published var modules: [Module] = []
    @Published var upcomingAssignments: [Assignment] = [
        Assignment(title: "COMP0016 论文", course: "UCL CS", dueDate: Date().addingTimeInterval(86400 * 2)),
        Assignment(title: "FINA0010 报告", course: "UCL Finance", dueDate: Date().addingTimeInterval(86400 * 4))
    ]
    
    init() {
        loadMockData()
    }
    
    private func convertMarkToGPAPoint(_ mark: Double) -> Double {
        if mark >= 70 { return 4.0 }
        if mark >= 60 { return 3.0 }
        if mark >= 50 { return 2.0 }
        if mark >= 40 { return 1.0 }
        return 0.0
    }
    
    var currentGPA: Double {
        let completedModules = modules.filter { $0.isCompleted && $0.credits > 0 }
        guard !completedModules.isEmpty else { return 0.0 }
        
        let totalCredits = completedModules.reduce(0) { $0 + $1.credits }
        guard totalCredits > 0 else { return 0.0 }
        
        let totalWeightedPoints = completedModules.reduce(0.0) { sum, module in
            let gpaPoint = convertMarkToGPAPoint(module.finalMark)
            return sum + (gpaPoint * Double(module.credits))
        }
        
        return totalWeightedPoints / Double(totalCredits)
    }
    
    var inProgressModules: [Module] {
        modules.filter { !$0.isCompleted }.sorted { $0.name < $1.name }
    }
    
    var completedModules: [Module] {
        modules.filter { $0.isCompleted }.sorted { $0.finalMark > $1.finalMark }
    }
    
    var completedCredits: Int {
        completedModules.reduce(0) { $0 + $1.credits }
    }
    
    var completedCourses: Int {
        completedModules.count
    }
    
    var totalCourses: Int {
        modules.count
    }
    
    var gpaChange: Double = 0.15
    
    var gradeLevel: String {
        switch currentGPA {
        case 4.0: return "First (Avg)"
        case 3.0..<4.0: return "2:1 (Avg)"
        case 2.0..<3.0: return "2:2 (Avg)"
        case 1.0..<2.0: return "Third (Avg)"
        default: return "N/A"
        }
    }
    
    var highestGrade: Double {
        completedModules.map { $0.finalMark }.max() ?? 0
    }
    
    var averageGrade: Double {
        let sum = completedModules.reduce(0) { $0 + $1.finalMark }
        return completedModules.isEmpty ? 0 : sum / Double(completedModules.count)
    }
    
    var pendingAssignments: Int {
        upcomingAssignments.count
    }
    
    func addModule(name: String, nameZH: String? = nil, code: String, credits: Int, assessments: [Assessment], isCompleted: Bool) {
        var newModule = Module(
            name: name,
            nameZH: nameZH,
            code: code,
            credits: credits,
            isCompleted: isCompleted,
            assessments: assessments
        )
        
        if isCompleted {
            newModule.assessments = assessments.map {
                var assessment = $0
                if assessment.score == nil {
                    assessment.score = 70.0
                }
                return assessment
            }
        }
        
        modules.append(newModule)
    }
    
    func updateModule(_ module: Module) {
        if let index = modules.firstIndex(where: { $0.id == module.id }) {
            modules[index] = module
        }
    }
    
    func markModule(_ module: Module, completed: Bool) {
        if let index = modules.firstIndex(where: { $0.id == module.id }) {
            modules[index].isCompleted = completed
        }
    }
    
    func loadMockData() {
        // 使用 Student/MockData.swift 中的真实演示数据
        modules = MockData.modules
        upcomingAssignments = MockData.assignments
    }
}
