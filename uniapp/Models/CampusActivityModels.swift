//
//  CampusActivityModels.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI
import Foundation

// MARK: - 校园活动模型
struct CampusActivity: Identifiable {
    let id: String
    let title: String
    let type: ActivityType
    let location: String
    let date: String
    let startTime: String
    let endTime: String?
    let description: String
    let iconName: String
    
    enum ActivityType: String, CaseIterable {
        case academicCompetition = "学术竞赛"
        case academicLecture = "学术讲座"
        case clubActivity = "社团活动"
        case volunteer = "志愿服务"
        case cultural = "文化活动"
        case career = "职业发展"
        case sports = "体育赛事"
        case academicSeminar = "学术研讨"
        case health = "健康活动"
        case festival = "节日活动"
        
        var color: String {
            switch self {
            case .academicCompetition: return "F59E0B"
            case .academicLecture: return "3B82F6"
            case .clubActivity: return "8B5CF6"
            case .volunteer: return "10B981"
            case .cultural: return "A855F7"
            case .career: return "F59E0B"
            case .sports: return "10B981"
            case .academicSeminar: return "6366F1"
            case .health: return "EC4899"
            case .festival: return "F97316"
            }
        }
    }
    
    var typeColor: String {
        type.color
    }
}

// MARK: - 活动数据
class CampusActivityData {
    static let shared = CampusActivityData()
    
    let activities: [CampusActivity] = [
        CampusActivity(
            id: "A01",
            title: "校园科技展览会",
            type: .academicCompetition,
            location: "主方庭 (Main Quad)",
            date: "2025-11-05",
            startTime: "10:00",
            endTime: "16:00",
            description: "展示学期项目并与行业专家交流。Zoya的项目获得了\"最佳创意奖\"。",
            iconName: "trophy.fill"
        ),
        CampusActivity(
            id: "A02",
            title: "AI与医疗健康前沿讲座",
            type: .academicLecture,
            location: "Cruciform Lecture Theatre",
            date: "2025-11-14",
            startTime: "14:00",
            endTime: "16:00",
            description: "UCL健康数据科学研究院邀请业界专家分享AI在医疗领域的最新应用。",
            iconName: "sparkles"
        ),
        CampusActivity(
            id: "A03",
            title: "数学竞赛小组周会",
            type: .clubActivity,
            location: "数学系会议室",
            date: "2025-11-15",
            startTime: "18:00",
            endTime: "20:00",
            description: "每周一次的小组活动，解决具有挑战性的数学问题。",
            iconName: "person.3.fill"
        ),
        CampusActivity(
            id: "A04",
            title: "图书馆志愿者服务",
            type: .volunteer,
            location: "主图书馆 (Main Library)",
            date: "2025-11-16",
            startTime: "13:00",
            endTime: "17:00",
            description: "协助整理书籍和引导新生，服务社区。",
            iconName: "heart.fill"
        ),
        CampusActivity(
            id: "A05",
            title: "UCL国际文化节",
            type: .cultural,
            location: "学生会大楼 (Student Union)",
            date: "2025-11-20",
            startTime: "17:00",
            endTime: "21:00",
            description: "来自世界各地的学生展示自己国家的文化、美食和表演，庆祝多元文化。",
            iconName: "sparkles"
        ),
        CampusActivity(
            id: "A06",
            title: "职业发展工作坊：简历写作",
            type: .career,
            location: "IOE Building, Room 803",
            date: "2025-11-22",
            startTime: "15:00",
            endTime: "17:00",
            description: "UCL职业服务中心举办的简历优化工作坊，帮助学生准备求职材料。",
            iconName: "book.fill"
        ),
        CampusActivity(
            id: "A07",
            title: "秋季羽毛球友谊赛",
            type: .sports,
            location: "Bloomsbury Fitness",
            date: "2025-11-23",
            startTime: "16:00",
            endTime: "18:00",
            description: "UCL体育社团组织的羽毛球友谊赛，欢迎所有水平的学生参加。",
            iconName: "figure.run"
        ),
        CampusActivity(
            id: "A08",
            title: "机器学习研讨会",
            type: .academicSeminar,
            location: "Roberts Building 508",
            date: "2025-11-27",
            startTime: "10:00",
            endTime: "12:00",
            description: "计算机系组织的机器学习算法研讨会，由博士生分享最新研究成果。",
            iconName: "graduationcap.fill"
        ),
        CampusActivity(
            id: "A09",
            title: "心理健康意识周活动",
            type: .health,
            location: "学生健康中心",
            date: "2025-11-28",
            startTime: "12:00",
            endTime: "14:00",
            description: "UCL心理健康周活动，包括冥想工作坊、心理咨询和减压活动。",
            iconName: "heart.fill"
        ),
        CampusActivity(
            id: "A10",
            title: "UCL冬季音乐会",
            type: .cultural,
            location: "Bloomsbury Theatre",
            date: "2025-12-05",
            startTime: "19:00",
            endTime: "21:00",
            description: "UCL音乐社团年度冬季音乐会，包括古典音乐、爵士乐和流行音乐表演。",
            iconName: "sparkles"
        ),
        CampusActivity(
            id: "A11",
            title: "数据科学黑客松",
            type: .academicCompetition,
            location: "Computer Science Building",
            date: "2025-12-07",
            startTime: "09:00",
            endTime: "09:00",
            description: "24小时数据科学黑客松，挑战真实数据集，赢取丰厚奖品。",
            iconName: "trophy.fill"
        ),
        CampusActivity(
            id: "A12",
            title: "圣诞市集",
            type: .festival,
            location: "主方庭 (Main Quad)",
            date: "2025-12-10",
            startTime: "11:00",
            endTime: "18:00",
            description: "UCL传统圣诞市集，有手工艺品、热巧克力和节日音乐表演。",
            iconName: "sparkles"
        )
    ]
    
    let activityTypes: [String] = [
        "全部",
        "学术竞赛",
        "学术讲座",
        "社团活动",
        "志愿服务",
        "文化活动",
        "职业发展",
        "体育赛事",
        "学术研讨",
        "健康活动",
        "节日活动"
    ]
    
    func getTypeColor(for type: String) -> String {
        guard let activityType = CampusActivity.ActivityType.allCases.first(where: { $0.rawValue == type }) else {
            return "6B7280"
        }
        return activityType.color
    }
}
