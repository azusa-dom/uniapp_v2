//
//  LocalizationHelper.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import Foundation

// MARK: - 双语显示辅助工具
struct LocalizationHelper {
    // 课程名称双语映射
    static let courseNameMapping: [String: String] = [
        "Statistical Methods in Health Data Science": "统计方法",
        "Python Programming Workshop": "Python编程",
        "Epidemiology for Health Data Science": "流行病学",
        "Machine Learning for Health": "机器学习",
        "Health Data Management": "健康数据管理",
        "Clinical Informatics and EHR Systems": "临床信息学",
        "Health Databases and Data Management": "健康数据库",
        "Research Methods": "研究方法",
        "Dissertation": "毕业论文"
    ]
    
    // 活动类型双语映射
    static let activityTypeMapping: [String: String] = [
        "workshop": "工作坊",
        "seminar": "研讨会",
        "lecture": "讲座",
        "social": "社交活动",
        "sports": "体育活动",
        "career": "职业发展",
        "cultural": "文化活动",
        "academic": "学术活动"
    ]
    
    // 课程类型双语映射
    static let courseTypeMapping: [String: String] = [
        "Lecture": "讲座",
        "Practical": "实践课",
        "Seminar": "研讨会",
        "Lab": "实验课",
        "Supervision": "指导课",
        "Tutorial": "辅导课"
    ]
    
    /// 获取课程双语标题（格式：中文 / English）
    static func localizedCourseTitle(_ englishTitle: String) -> String {
        if let chinese = courseNameMapping[englishTitle] {
            return "\(chinese) / \(englishTitle)"
        }
        return englishTitle
    }
    
    /// 获取活动类型双语标签
    static func localizedActivityType(_ type: String) -> String {
        let key = type.lowercased()
        if let chinese = activityTypeMapping[key] {
            return "\(chinese) / \(type)"
        }
        return type
    }
    
    /// 获取课程类型双语标签
    static func localizedCourseType(_ type: String) -> String {
        if let chinese = courseTypeMapping[type] {
            return "\(chinese) / \(type)"
        }
        return type
    }
}

