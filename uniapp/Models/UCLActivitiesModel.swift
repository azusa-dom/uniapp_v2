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
    var titleZH: String  // 中文标题
    var startTime: String
    var endTime: String
    var date: String
    var location: String?
    var locationZH: String?  // 中文地点
    var type: String
    var typeZH: String  // 中文类型
    var description: String?
    var descriptionZH: String?  // 中文描述
    
    // 根据当前语言返回内容
    func localizedTitle(isChinese: Bool) -> String {
        return isChinese ? titleZH : title
    }
    
    func localizedLocation(isChinese: Bool) -> String? {
        return isChinese ? locationZH : location
    }
    
    func localizedType(isChinese: Bool) -> String {
        return isChinese ? typeZH : type
    }
    
    func localizedDescription(isChinese: Bool) -> String? {
        return isChinese ? descriptionZH : description
    }
}
