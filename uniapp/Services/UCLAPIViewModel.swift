//
//  UCLAPIViewModel.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI
import Combine

// MARK: - 通用日历模型
enum ReminderTime: String, CaseIterable, Identifiable {
    case fiveMin = "5分钟前"
    case fifteenMin = "15分钟前"
    case thirtyMin = "30分钟前"
    case oneHour = "1小时前"
    case oneDay = "1天前"
    
    var id: String { rawValue }
    
    var minutes: Int {
        switch self {
        case .fiveMin: return 5
        case .fifteenMin: return 15
        case .thirtyMin: return 30
        case .oneHour: return 60
        case .oneDay: return 1440
        }
    }
}

enum RecurrenceFrequency: String, CaseIterable, Identifiable {
    case none = "不重复"
    case daily = "每天"
    case weekly = "每周"
    case biweekly = "每两周"
    case monthly = "每月"
    
    var id: String { rawValue }
}

struct RecurrenceRule: Equatable {
    var frequency: RecurrenceFrequency
    var interval: Int
    var endDate: Date?
    var weekdays: Set<Int>
    
    init(
        frequency: RecurrenceFrequency,
        interval: Int = 1,
        endDate: Date? = nil,
        weekdays: Set<Int> = []
    ) {
        self.frequency = frequency
        self.interval = max(1, interval)
        self.endDate = endDate
        self.weekdays = weekdays
    }
}

// MARK: - UCL API 视图模型 (日历)
class UCLAPIViewModel: ObservableObject {
    @Published var events: [UCLAPIEvent] = []
    
    enum EventType { case api, manual }
    
    struct UCLAPIEvent: Identifiable, Equatable {
        let id: UUID
        var title: String
        var startTime: Date
        var endTime: Date
        var location: String
        var type: EventType
        var description: String? = nil
        var recurrenceRule: RecurrenceRule? = nil
        var reminderTime: ReminderTime = .fifteenMin
    }
    
    func fetchEvents() {
        // 模拟API调用
        let now = Date()
        let calendar = Calendar.current
        
        self.events = [
            .init(
                id: UUID(),
                title: "数据科学与统计",
                startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!,
                endTime: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: now)!,
                location: "Cruciform Building, 4.18",
                type: .api,
                description: "教授: Dr. Johnson",
                recurrenceRule: RecurrenceRule(
                    frequency: .weekly,
                    interval: 1,
                    endDate: calendar.date(byAdding: .month, value: 2, to: now),
                    weekdays: [2, 4] // 周一、周三
                ),
                reminderTime: .fifteenMin
            ),
            .init(
                id: UUID(),
                title: "健康数据科学原理",
                startTime: calendar.date(bySettingHour: 16, minute: 30, second: 0, of: now)!,
                endTime: calendar.date(bySettingHour: 18, minute: 30, second: 0, of: now)!,
                location: "Foster Court, LT",
                type: .api,
                description: "教授: Prof. Smith",
                recurrenceRule: RecurrenceRule(
                    frequency: .weekly,
                    interval: 1,
                    endDate: calendar.date(byAdding: .month, value: 2, to: now),
                    weekdays: [3, 5] // 周二、周四
                ),
                reminderTime: .fifteenMin
            )
        ]
    }
}
