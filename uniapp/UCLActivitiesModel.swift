import Foundation

// ✅ 单个活动模型
struct UCLActivity: Identifiable, Codable {
    let id: String
    let title: String
    let description: String?
    let type: String
    let date: String
    let startTime: String
    let endTime: String
    let location: String?
    let rawData: RawData?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, type, date
        case startTime = "start_time"
        case endTime = "end_time"
        case location
        case rawData = "raw_data"
    }
    
    struct RawData: Codable {
        let contact: String?
        let phone: String?
    }
}

// ✅ API 响应模型
struct UCLActivitiesResponse: Codable {
    let activities: [UCLActivity]
    let total: Int
    let lastUpdated: String?
    
    enum CodingKeys: String, CodingKey {
        case activities, total
        case lastUpdated = "last_updated"
    }
}

// ✅ 活动统计模型
struct ActivityStats {
    var total: Int = 0
    var byType: [String: Int] = [:]
    var byDate: [String: Int] = [:]
}
