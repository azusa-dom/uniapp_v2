//
//  ActivityViewModel.swift
//  uniapp
//

import Foundation
import SwiftUI

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var selectedCategory: String = "All"
    @Published var searchText: String = ""
    
    // 学业相关（用于首页/统计用）
    @Published var modules: [Module] = []
    @Published var assignments: [AcademicAssignment] = []
    @Published var currentGPA: Double = 0.0
    @Published var completedCourses: Int = 0
    @Published var totalCourses: Int = 0
    @Published var completedCredits: Int = 0
    @Published var highestGrade: Double = 0.0
    @Published var averageGrade: Double = 0.0
    @Published var pendingAssignments: Int = 0
    @Published var gradeLevel: String = "In Progress"
    
    let categories = ["All", "Academic", "Social", "Career", "Workshop", "Training", "Competition", "Wellbeing"]
    
    init() {
        loadMockData()
    }
    
    func loadMockData() {
        self.activities = MockData.activities
        self.modules = MockData.modules
        self.assignments = MockData.assignments
        
        // 计算 GPA
        calculateGPA()
        
        // 计算统计数据
        calculateStats()
    }
    
    private func calculateGPA() {
        // 使用已完成模块的最终分数进行 GPA 计算
        let completed = modules.filter { $0.isCompleted }
        guard !completed.isEmpty else {
            self.currentGPA = 0.0
            return 
        }
        let totalGrade = completed.reduce(0.0) { $0 + $1.finalMark }
        let average = totalGrade / Double(completed.count)
        
        // 英国分数转换为 4.0 制 GPA
        // 70+ = 4.0, 60-69 = 3.5, 50-59 = 3.0, 40-49 = 2.5, <40 = 0
        if average >= 70 {
            self.currentGPA = 4.0
        } else if average >= 60 {
            self.currentGPA = 3.5 + (average - 60) / 20.0  // 3.5-4.0
        } else if average >= 50 {
            self.currentGPA = 3.0 + (average - 50) / 20.0  // 3.0-3.5
        } else if average >= 40 {
            self.currentGPA = 2.5 + (average - 40) / 20.0  // 2.5-3.0
        } else {
            self.currentGPA = 0.0
        }
    }
    
    private func calculateStats() {
        let completed = modules.filter { $0.isCompleted }
        
        self.completedCourses = completed.count
        self.totalCourses = modules.count
        self.completedCredits = completed.reduce(0) { $0 + $1.credits }
        
        if let highest = completed.map({ $0.finalMark }).max() {
            self.highestGrade = highest
        }
        
        if !completed.isEmpty {
            let total = completed.reduce(0.0) { $0 + $1.finalMark }
            self.averageGrade = total / Double(completed.count)
        } else {
            self.averageGrade = 0
        }
        
        // MockData.assignments 表示未来任务，这里直接计数
        self.pendingAssignments = assignments.count
        
        // 计算学业等级（按平均分）
        if averageGrade >= 70 {
            self.gradeLevel = "Distinction"
        } else if averageGrade >= 60 {
            self.gradeLevel = "Merit"
        } else if averageGrade >= 50 {
            self.gradeLevel = "Pass"
        } else {
            self.gradeLevel = "In Progress"
        }
    }
    
    // 过滤后的活动
    var filteredActivities: [Activity] {
        var filtered = activities
        
        // 按分类过滤
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // 按搜索文本过滤
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered.sorted { $0.startDate < $1.startDate }
    }
    
    // 即将到来的活动（7天内）
    var upcomingActivities: [Activity] {
        let now = Date()
        let weekLater = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        
        return activities.filter { activity in
            activity.startDate >= now && activity.startDate <= weekLater
        }.sorted { $0.startDate < $1.startDate }
    }
    
    // 今天的活动
    var todayActivities: [Activity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return activities.filter { activity in
            calendar.isDate(activity.startDate, inSameDayAs: today)
        }.sorted { $0.startDate < $1.startDate }
    }
}
