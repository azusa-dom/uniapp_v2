//
//  UCLAPIViewModel.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI
import Combine

// MARK: - UCL API 视图模型 (日历)
class UCLAPIViewModel: ObservableObject {
    @Published var events: [UCLAPIEvent] = []
    
    enum EventType { case api, manual }
    
    struct UCLAPIEvent: Identifiable, Equatable {
        let id: UUID
        let title: String
        let startTime: Date
        let endTime: Date
        let location: String
        let type: EventType
        var description: String? = nil
    }
    
    func fetchEvents() {
        // 模拟API调用
        let now = Date()
        let calendar = Calendar.current
        
        self.events = [
            .init(id: UUID(), title: "数据科学与统计", startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!, endTime: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: now)!, location: "Cruciform Building, 4.18", type: .api, description: "教授: Dr. Johnson"),
            .init(id: UUID(), title: "健康数据科学原理", startTime: calendar.date(bySettingHour: 16, minute: 30, second: 0, of: now)!, endTime: calendar.date(bySettingHour: 18, minute: 30, second: 0, of: now)!, location: "Foster Court, LT", type: .api, description: "教授: Prof. Smith")
        ]
    }
}
