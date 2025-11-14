//
//  EmailModels.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import Foundation

// MARK: - 完整邮件模型
struct Email: Identifiable, Codable {
    let id: String
    let sender: EmailContact
    let recipients: [EmailContact]
    let cc: [EmailContact]
    let subject: String
    let subjectZH: String
    let body: String
    let bodyZH: String
    let timestamp: Date
    let isRead: Bool
    let isStarred: Bool
    let hasAttachments: Bool
    let attachments: [EmailAttachment]
    let category: EmailCategory
    let priority: EmailPriority
    let labels: [String]
    
    enum EmailCategory: String, Codable {
        case inbox = "收件箱"
        case sent = "已发送"
        case draft = "草稿"
        case spam = "垃圾邮件"
        case trash = "已删除"
        case academic = "学术"
        case administrative = "行政"
        case social = "社交"
        case career = "职业"
        case newsletter = "简讯"
        
        var displayName: String {
            switch self {
            case .academic: return "学术"
            case .administrative: return "行政"
            case .social: return "社交"
            case .career: return "职业"
            case .newsletter: return "简讯"
            default: return rawValue
            }
        }
        
        var englishName: String {
            switch self {
            case .academic: return "Academic"
            case .administrative: return "Administrative"
            case .social: return "Events"
            case .career: return "Career"
            case .newsletter: return "Newsletter"
            default: return "General"
            }
        }
    }
    
    enum EmailPriority: String, Codable {
        case low = "低"
        case normal = "普通"
        case high = "高"
        case urgent = "紧急"
    }
}

// MARK: - 邮件联系人
struct EmailContact: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    let department: String?
    let title: String?
    
    var displayName: String {
        return "\(name) <\(email)>"
    }
}

// MARK: - 邮件附件
struct EmailAttachment: Identifiable, Codable {
    let id: String
    let fileName: String
    let fileType: String
    let fileSize: Int // bytes
    let downloadURL: String?
    
    var fileSizeFormatted: String {
        let kb = Double(fileSize) / 1024.0
        if kb < 1024 {
            return String(format: "%.1f KB", kb)
        } else {
            let mb = kb / 1024.0
            return String(format: "%.1f MB", mb)
        }
    }
    
    var fileIcon: String {
        switch fileType.lowercased() {
        case "pdf": return "doc.fill"
        case "doc", "docx": return "doc.text.fill"
        case "xls", "xlsx": return "tablecells.fill"
        case "ppt", "pptx": return "rectangle.stack.fill"
        case "jpg", "jpeg", "png": return "photo.fill"
        case "zip", "rar": return "doc.zipper"
        default: return "doc.fill"
        }
    }
}

// MARK: - 邮件草稿
struct EmailDraft: Identifiable, Codable {
    let id: String
    var recipients: [EmailContact]
    var cc: [EmailContact]
    var subject: String
    var body: String
    var attachments: [EmailAttachment]
    var lastModified: Date
}

// MARK: - 邮件过滤器
struct EmailFilter {
    var searchText: String = ""
    var category: Email.EmailCategory?
    var isUnreadOnly: Bool = false
    var isStarredOnly: Bool = false
    var hasAttachmentsOnly: Bool = false
    var dateRange: DateRange?
    
    enum DateRange {
        case today
        case thisWeek
        case thisMonth
        case custom(from: Date, to: Date)
    }
}

// MARK: - 兼容旧版本的 EmailPreview（用于现有视图）
struct EmailPreview: Identifiable {
    struct DeadlineMeta {
        var title: String
        var date: String
        var time: String
        var calendarAdded: Bool
        var note: String
    }
    
    let id: UUID
    var title: String
    var sender: String
    var excerpt: String
    var date: String
    var category: String // "Academic", "Events", "Urgent", "General"
    var isRead: Bool
    var deadline: DeadlineMeta? = nil
    
    // 从完整 Email 模型转换
    init(from email: Email) {
        self.id = UUID(uuidString: email.id) ?? UUID()
        self.title = email.subject
        self.sender = email.sender.name
        self.excerpt = String(email.body.prefix(100))
        self.date = formatRelativeDate(email.timestamp)
        self.category = email.category.englishName
        self.isRead = email.isRead
        self.deadline = nil
    }
    
    // 成员初始化器（用于旧数据兼容）
    init(
        id: UUID = UUID(),
        title: String,
        sender: String,
        excerpt: String,
        date: String,
        category: String,
        isRead: Bool,
        deadline: DeadlineMeta? = nil
    ) {
        self.id = id
        self.title = title
        self.sender = sender
        self.excerpt = excerpt
        self.date = date
        self.category = category
        self.isRead = isRead
        self.deadline = deadline
    }
}

struct EmailDetailContent {
    var original: String
    var aiTranslation: String
    var aiSummary: [String]
}

// MARK: - 辅助函数
private func formatRelativeDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    
    if calendar.isDateInToday(date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "今天 · \(formatter.string(from: date))"
    } else if calendar.isDateInYesterday(date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "昨天 · \(formatter.string(from: date))"
    } else {
        let daysAgo = calendar.dateComponents([.day], from: date, to: now).day ?? 0
        if daysAgo < 7 {
            return "\(daysAgo) 天前"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// 模拟邮件数据（从完整邮件数据转换，同时保留旧数据以保持兼容）
let mockEmails: [EmailPreview] = {
    // 从完整邮件数据转换
    let fromFullEmails = MockData.fullEmails.map { EmailPreview(from: $0) }
    // 保留旧的简化数据以保持向后兼容
    let oldEmails: [EmailPreview] = [
    .init(
        title: "机器学习课程作业提交提醒",
        sender: "Prof. Sarah Chen",
        excerpt: "机器学习期中作业将在 11 月 20 日 23:59 截止，系统已自动将 deadline 加入你的日程。",
        date: "今天 · 09:30",
        category: "Academic",
        isRead: false,
        deadline: .init(
            title: "机器学习作业截止",
            date: "2025-11-20",
            time: "23:59",
            calendarAdded: true,
            note: "已同步到「课程任务」日历"
        )
    ),
    .init(
        title: "图书归还提醒 - 《Deep Learning》",
        sender: "UCL Library Services",
        excerpt: "提醒：借阅的《Deep Learning》将于 11 月 18 日 23:59 到期，已放进图书事项日历。",
        date: "今天 · 14:20",
        category: "Urgent",
        isRead: false,
        deadline: .init(
            title: "归还《Deep Learning》",
            date: "2025-11-18",
            time: "23:59",
            calendarAdded: true,
            note: "Library Reminder 事件"
        )
    ),
    .init(
        title: "2025 春季学期学费缴纳通知",
        sender: "Student Finance Office",
        excerpt: "春季学费 £9,250 将在 12 月 15 日 截止，已自动排程提醒。",
        date: "昨天 · 11:00",
        category: "Urgent",
        isRead: true,
        deadline: .init(
            title: "春季学费缴纳",
            date: "2025-12-15",
            time: "23:59",
            calendarAdded: true,
            note: "Finance Tracker 事件"
        )
    ),
    .init(
        title: "数据结构小组项目分组通知",
        sender: "Dr. James Wilson",
        excerpt: "Group 3 需要在 11 月 17 日 前完成第一次会议，日历已预留时段。",
        date: "2 天前 · 16:45",
        category: "Academic",
        isRead: true,
        deadline: .init(
            title: "数据结构小组首次会议",
            date: "2025-11-17",
            time: "20:00",
            calendarAdded: true,
            note: "项目任务 - Group 3"
        )
    ),
    .init(
        title: "Google 校园招聘宣讲会报名",
        sender: "UCL Careers Service",
        excerpt: "宣讲会报名将于 11 月 22 日 12:00 截止，系统已创建提醒。",
        date: "3 天前 · 10:15",
        category: "Events",
        isRead: true,
        deadline: .init(
            title: "Google 宣讲会报名截止",
            date: "2025-11-22",
            time: "12:00",
            calendarAdded: true,
            note: "Career Hub 事件"
        )
    ),
    .init(
        title: "国际文化节志愿者招募",
        sender: "UCL Student Union",
        excerpt: "志愿者申请 11 月 19 日 截止，若想参加请在通知的日历时间前提交。",
        date: "4 天前 · 13:30",
        category: "Events",
        isRead: false,
        deadline: .init(
            title: "文化节志愿者申请截止",
            date: "2025-11-19",
            time: "23:59",
            calendarAdded: true,
            note: "Volunteer Reminder"
        )
    )
    ]
    // 合并新旧数据，优先使用完整邮件数据
    return fromFullEmails + oldEmails
}()

let mockEmailDetails: [String: EmailDetailContent] = {
    // 从完整邮件数据生成详情
    var details: [String: EmailDetailContent] = [:]
    for email in MockData.fullEmails {
        details[email.sender.name] = EmailDetailContent(
            original: email.body,
            aiTranslation: email.bodyZH,
            aiSummary: email.labels.map { "📧 \($0)" }
        )
    }
    // 保留旧的详情数据
    let oldDetails: [String: EmailDetailContent] = [
    "Prof. Sarah Chen": .init(
        original: """
Dear students,

This is a reminder for the COMP0078 machine learning assignment. Please implement at least three classifiers, provide a 10-15 page technical report, and submit code plus data via Moodle.

Deadline: 20 Nov 2025, 23:59.

Best,
Prof. Sarah Chen
""",
        aiTranslation: "亲爱的同学们：提醒大家 COMP0078 机器学习作业需完成三种分类算法、10-15 页报告以及提交代码与数据，截止 2025 年 11 月 20 日 23:59。",
        aiSummary: ["📚 COMP0078 作业提醒", "✍️ 需三种算法 + 技术报告", "⏰ 截止：11 月 20 日 23:59"]
    ),
    "UCL Library Services": .init(
        original: """
Dear reader,

The book \"Deep Learning\" (Goodfellow, 2016) is due on 18 Nov 2025. Please return or renew before the deadline to avoid £1/day fines.

Library Services
""",
        aiTranslation: "亲爱的读者，《Deep Learning》一书将于 2025 年 11 月 18 日到期，请提前归还或续借，逾期将按照每天 £1 收取罚金。",
        aiSummary: ["📘 图书到期提醒", "📍 Deep Learning", "⏰ 截止：11 月 18 日 23:59"]
    ),
    "Student Finance Office": .init(
        original: """
Hello,

Tuition for Spring 2025 (£9,250) is due on 15 Dec 2025. Please pay via MyUCL portal. Late payments may impact registration.

Finance Office
""",
        aiTranslation: "您好：2025 春季学期 £9,250 学费将于 2025 年 12 月 15 日到期，请通过 MyUCL 支付平台完成，逾期会影响注册。",
        aiSummary: ["💰 春季学费提醒", "金额：£9,250", "⏰ 截止：12 月 15 日"]
    ),
    "Dr. James Wilson": .init(
        original: """
Hi team,

COMP0005 project groups are finalised. Group 3 must arrange the first meeting before 17 Nov and submit the proposal by 25 Nov. Final deliverable is due 20 Dec.

Dr. Wilson
""",
        aiTranslation: "COMP0005 小组已经分配，Group 3 需在 11 月 17 日前完成第一次会议，25 日前提交提案，终版 12 月 20 日到期。",
        aiSummary: ["🧠 数据结构小组项目", "👥 Group 3", "⏰ 首次会议：11 月 17 日"]
    ),
    "UCL Careers Service": .init(
        original: """
Dear student,

Google will host a campus talk on 28 Nov (18:00-20:00). Registration deadline is 22 Nov 12:00 via Career Hub. Seats limited to 100.

Careers Service
""",
        aiTranslation: "Google 校园宣讲会 11 月 28 日 18:00-20:00 举行，请在 11 月 22 日 12:00 前在 Career Hub 报名，名额 100 人。",
        aiSummary: ["🚀 Google 宣讲会", "📍 Roberts G06", "⏰ 报名截止：11 月 22 日 12:00"]
    ),
    "UCL Student Union": .init(
        original: """
Hi!

We are recruiting volunteers for the International Culture Festival on 20 Nov. Volunteer applications close on 19 Nov. Duties include guiding guests and supporting booths.

SU Team
""",
        aiTranslation: "大家好！国际文化节志愿者现开放报名，11 月 19 日截止。活动在 11 月 20 日举行，职责包含引导来宾及展台支持。",
        aiSummary: ["🌍 文化节志愿者", "📅 活动：11 月 20 日", "⏰ 报名截止：11 月 19 日"]
    )
    ]
    // 合并新旧详情，优先使用完整邮件详情
    return details.merging(oldDetails) { new, _ in new }
}()
