//
//  TimetableModels.swift
//  uniapp
//

import Foundation

// MARK: - Timetable Event Model
struct TimetableEvent: Identifiable, Codable {
    let id: String
    let title: String
    let titleZH: String  // 中文标题
    let courseCode: String
    let type: String // Lecture, Practical, Seminar, Lab, Supervision
    let typeZH: String  // 中文类型
    let location: String
    let locationZH: String  // 中文地点
    let startTime: Date
    let endTime: Date
    let instructor: String
    let instructorZH: String  // 中文讲师
    let color: String
    
    // 根据当前语言返回标题
    func localizedTitle(isChinese: Bool) -> String {
        return isChinese ? titleZH : title
    }
    
    func localizedType(isChinese: Bool) -> String {
        return isChinese ? typeZH : type
    }
    
    func localizedLocation(isChinese: Bool) -> String {
        return isChinese ? locationZH : location
    }
    
    func localizedInstructor(isChinese: Bool) -> String {
        return isChinese ? instructorZH : instructor
    }
}

// MARK: - Activity Model
struct Activity: Identifiable, Codable {
    let id: String
    let title: String
    let titleZH: String  // 中文标题
    let description: String
    let descriptionZH: String  // 中文描述
    let category: String // Academic, Social, Career, Workshop, Training, etc.
    let categoryZH: String  // 中文分类
    let location: String
    let locationZH: String  // 中文地点
    let startDate: Date
    let endDate: Date
    let organizerName: String
    let organizerNameZH: String  // 中文组织者
    let maxParticipants: Int
    let currentParticipants: Int
    let imageURL: String
    let tags: [String]
    let tagsZH: [String]  // 中文标签
    let color: String
    
    // 计算属性
    var isFullyBooked: Bool {
        currentParticipants >= maxParticipants
    }
    
    var availableSpots: Int {
        max(0, maxParticipants - currentParticipants)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, HH:mm"
        return formatter.string(from: startDate)
    }
    
    // 根据当前语言返回内容
    func localizedTitle(isChinese: Bool) -> String {
        return isChinese ? titleZH : title
    }
    
    func localizedDescription(isChinese: Bool) -> String {
        return isChinese ? descriptionZH : description
    }
    
    func localizedCategory(isChinese: Bool) -> String {
        return isChinese ? categoryZH : category
    }
    
    func localizedLocation(isChinese: Bool) -> String {
        return isChinese ? locationZH : location
    }
    
    func localizedOrganizer(isChinese: Bool) -> String {
        return isChinese ? organizerNameZH : organizerName
    }
    
    func localizedTags(isChinese: Bool) -> [String] {
        return isChinese ? tagsZH : tags
    }
}