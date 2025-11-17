//
//  AcademicModels.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import Foundation
import SwiftUI

// MARK: - 家长学业
struct CourseSummary: Identifiable {
    let id = UUID()
    var name: String
    var code: String? = nil
    var grade: Int
    var semester: String? = nil
    var assignments: Int? = nil
    var participation: Int? = nil
    var average: Int? = nil
    var trend: String? = nil // "up", "down", "stable"
    
    var gradeColor: Color {
        grade >= 70 ? Color(hex: "10B981") : (grade >= 60 ? Color(hex: "F59E0B") : Color(hex: "EF4444"))
    }
    
    var trendIcon: String {
        switch trend {
        case "up": return "arrow.up.right"
        case "down": return "arrow.down.right"
        default: return "arrow.right"
        }
    }
    
    var trendColor: Color {
        switch trend {
        case "up": return Color(hex: "10B981")
        case "down": return Color(hex: "EF4444")
        default: return Color(hex: "6B7280")
        }
    }
}

func degreeClassification(for score: Double) -> String {
    switch score {
    case 70...: return "一等学位 (First Class)"
    case 60..<70: return "二等一 (Upper Second)"
    case 50..<60: return "二等二 (Lower Second)"
    case 40..<50: return "三等 (Third Class)"
    default: return "不及格 (Fail)"
    }
}

// MARK: - 出勤
struct ATTStats {
    struct Course: Identifiable { let id = UUID(); let name: String; let present: Int; let late: Int; let absent: Int }
    let present: Int; let late: Int; let absent: Int; let courses: [Course]
    static let sample = ATTStats(
        present: 92, late: 5, absent: 3,
        courses: [
            .init(name: "健康数据科学", present: 95, late: 3, absent: 2),
            .init(name: "机器学习导论", present: 90, late: 7, absent: 3),
            .init(name: "统计学",     present: 92, late: 4, absent: 4)
        ]
    )
}

// MARK: - 家长健康
struct ParentHealthOverview: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let unit: String
    let icon: String
    let status: String
    let color: String
    let progress: Double
    let note: String
}
