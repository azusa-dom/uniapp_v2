//
//  UCLActivitiesModel.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import Foundation

// MARK: - UCL 活动
struct UCLActivity: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var startTime: String
    var endTime: String
    var date: String
    var location: String?
    var type: String
    var description: String?
}
