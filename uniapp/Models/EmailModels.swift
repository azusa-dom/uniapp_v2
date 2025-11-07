import Foundation

// MARK: - Email Models

struct EmailPreview: Identifiable {
    let id = UUID()
    let title: String
    let sender: String
    let excerpt: String
    let date: String
    let category: String
    let isRead: Bool
}

struct EmailDetailContent {
    let original: String
    let aiTranslation: String
    let aiSummary: [String]
}

// Mock data
let mockEmails = [
    EmailPreview(
        title: "2024–25 Semester Registration",
        sender: "registry@ucl.ac.uk",
        excerpt: "Your course registration for the 2024–25 academic year has been successfully confirmed. Please review your enrolled courses in the student portal.",
        date: "Today 10:30",
        category: "Urgent",
        isRead: false
    ),
    EmailPreview(
        title: "Assignment Feedback – Module 3",
        sender: "s.johnson@ucl.ac.uk",
        excerpt: "Great work on your recent assignment. Here are some detailed comments on your submission. Your analysis was thorough and well-structured.",
        date: "Today 09:15",
        category: "Academic",
        isRead: true
    ),
    EmailPreview(
        title: "This Week's Campus Events",
        sender: "union@ucl.ac.uk",
        excerpt: "Don't miss out on exciting events happening around campus this week, including workshops, social activities, and career seminars.",
        date: "Yesterday",
        category: "Events",
        isRead: false
    ),
    EmailPreview(
        title: "Library Book Return Reminder",
        sender: "library@ucl.ac.uk",
        excerpt: "This is a friendly reminder that your borrowed books are due for return by the end of this week. Please return them to avoid late fees.",
        date: "2 days ago",
        category: "Urgent",
        isRead: false
    ),
    EmailPreview(
        title: "Research Opportunity Available",
        sender: "research@ucl.ac.uk",
        excerpt: "We have an exciting research position available in the Computer Science department. Applications are now open for qualified students.",
        date: "3 days ago",
        category: "Academic",
        isRead: true
    ),
    EmailPreview(
        title: "2024-25 Scholarship Applications Open",
        sender: "financialaid@ucl.ac.uk",
        excerpt: "The scholarship application portal for the 2024-25 academic year is now open. Don't miss this opportunity to apply for financial support.",
        date: "4 days ago",
        category: "Urgent",
        isRead: false
    ),
    EmailPreview(
        title: "Career Development Workshop",
        sender: "careers@ucl.ac.uk",
        excerpt: "Join us next week for an exclusive career development workshop focused on the technology industry. Register now to secure your spot.",
        date: "5 days ago",
        category: "Events",
        isRead: true
    ),
    EmailPreview(
        title: "Final Exam Timetable Released",
        sender: "exams@ucl.ac.uk",
        excerpt: "Your final examination timetable for this semester has been published. Please check the student portal for your exam schedule.",
        date: "1 week ago",
        category: "Urgent",
        isRead: true
    ),
    EmailPreview(
        title: "Lab Booking Confirmation",
        sender: "lab.coordinator@ucl.ac.uk",
        excerpt: "Your laboratory session booking has been confirmed for Wednesday at 2:00 PM. Please arrive on time with all required materials.",
        date: "1 week ago",
        category: "Academic",
        isRead: false
    ),
    EmailPreview(
        title: "Health Centre Appointment",
        sender: "health@ucl.ac.uk",
        excerpt: "Your health check appointment at UCL Health Centre has been confirmed for next Tuesday at 10:00 AM.",
        date: "1 week ago",
        category: "Events",
        isRead: true
    )
]

let mockEmailDetails: [String: EmailDetailContent] = [
    "registry@ucl.ac.uk": EmailDetailContent(
        original: """
Dear Student,

Your course registration for the 2024–25 academic year has been successfully confirmed. Please review your enrolled courses in the student portal.

Please make sure to complete all required tasks before the deadline.

Best regards,
registry@ucl.ac.uk
""",
        aiTranslation: """
亲爱的同学，

您的 2024–25 学年课程注册已成功确认。请登录系统查看已选课程。

请确保在截止日期前完成所有必要的注册步骤。
""",
        aiSummary: [
            "✅ 课程注册已确认成功",
            "📌 检查课程列表是否正确",
            "⏰ 截止日前完成所有 mandatory tasks"
        ]
    ),
    "s.johnson@ucl.ac.uk": EmailDetailContent(
        original: """
Great work on your recent assignment. Here are some detailed comments on your submission...
""",
        aiTranslation: """
同学你好，

你最近的作业完成得很好！以下是导师对你提交内容的详细点评，请根据反馈进行修改。
""",
        aiSummary: [
            "✅ 作业整体表现不错",
            "📝 根据导师意见修改第二部分内容",
            "📚 为下次 seminar 准备反思内容"
        ]
    ),
    "union@ucl.ac.uk": EmailDetailContent(
        original: """
Don't miss out on exciting events happening around campus this week...
""",
        aiTranslation: """
同学，

本周校园有多场精彩活动，欢迎参加！涵盖工作坊、讲座和社交活动。
""",
        aiSummary: [
            "🎉 查看所有本周校园活动",
            "⭐ 标记感兴趣的 workshop / social events",
            "📅 推荐加入日历设置提醒"
        ]
    )
]
