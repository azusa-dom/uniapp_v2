//
//  LocalizationService.swift
//  uniapp
//
//  完整版本 - 包含所有翻译
//

import SwiftUI

class LocalizationService: ObservableObject {
    enum Language: String, CaseIterable, Identifiable {
        case chinese = "中文"
        case english = "English"
        
        var id: String { rawValue }
    }
    
    @Published var language: Language = .chinese
    
    func tr(_ key: String) -> String {
        let translations: [String: [Language: String]] = [
            // 通用
            "on": [.chinese: "开启", .english: "On"],
            "off": [.chinese: "关闭", .english: "Off"],
            "done": [.chinese: "完成", .english: "Done"],
            "cancel": [.chinese: "取消", .english: "Cancel"],
            "save": [.chinese: "保存", .english: "Save"],
            "delete": [.chinese: "删除", .english: "Delete"],
            "edit": [.chinese: "编辑", .english: "Edit"],
            "add": [.chinese: "添加", .english: "Add"],
            "confirm": [.chinese: "确认", .english: "Confirm"],
            "back": [.chinese: "返回", .english: "Back"],
            
            // 登录界面
            "login_title": [.chinese: "UCL 学生助手", .english: "UCL Student Portal"],
            "login_subtitle": [.chinese: "智能助手，连接你与 UCL", .english: "Your Smart UCL Companion"],
            "login_select_role": [.chinese: "选择身份", .english: "Select Role"],
            "login_student": [.chinese: "学生", .english: "Student"],
            "login_parent": [.chinese: "家长", .english: "Parent"],
            "login_button_student": [.chinese: "学生登录", .english: "Student Login"],
            "login_button_parent": [.chinese: "家长登录", .english: "Parent Login"],
            
            // Tab 标签
            "tab_home": [.chinese: "首页", .english: "Home"],
            "tab_calendar": [.chinese: "日历", .english: "Calendar"],
            "tab_academics": [.chinese: "学业", .english: "Academics"],
            "tab_ai": [.chinese: "AI", .english: "AI"],
            "tab_email": [.chinese: "邮件", .english: "Email"],
            "tab_activities": [.chinese: "活动", .english: "Activities"],
            "tab_todo": [.chinese: "待办", .english: "Todo"],
            "tab_parent_settings": [.chinese: "设置", .english: "Settings"],
            
            // 首页
            "home_welcome": [.chinese: "欢迎回来,", .english: "Welcome back,"],
            "home_quick_actions": [.chinese: "快捷操作", .english: "Quick Actions"],
            "home_qa_email": [.chinese: "邮件", .english: "Email"],
            "home_qa_calendar": [.chinese: "日历", .english: "Calendar"],
            "home_qa_chat": [.chinese: "AI", .english: "AI"],
            "home_qa_courses": [.chinese: "课程", .english: "Courses"],
            "home_qa_activities": [.chinese: "活动", .english: "Activities"],
            "home_deadlines": [.chinese: "即将截止", .english: "Deadlines"],
            "home_today_classes": [.chinese: "今日课程", .english: "Today's Classes"],
            "home_todo": [.chinese: "待办事项", .english: "To-Do"],
            "home_recommendations": [.chinese: "推荐活动", .english: "Recommendations"],
            
            // AI 助手
            "ai_title": [.chinese: "AI 助手", .english: "AI Assistant"],
            "ai_placeholder": [.chinese: "问我任何问题...", .english: "Ask me anything..."],
            "ai_thinking": [.chinese: "思考中...", .english: "Thinking..."],
            "ai_quick_questions": [.chinese: "快速问题", .english: "Quick Questions"],
            
            // 学业界面
            "academics_modules": [.chinese: "课程成绩", .english: "Modules"],
            "academics_assignments": [.chinese: "作业列表", .english: "Assignments"],
            "academics_overall_average": [.chinese: "总平均分", .english: "Overall Average"],
            "academics_module_name": [.chinese: "课程名称", .english: "Module Name"],
            "academics_module_code": [.chinese: "课程代码", .english: "Module Code"],
            "academics_mark": [.chinese: "成绩", .english: "Mark"],
            "academics_add_module": [.chinese: "添加课程", .english: "Add Module"],
            "academics_add_assignment": [.chinese: "添加作业", .english: "Add Assignment"],
            "academics_assignment_name": [.chinese: "作业名称", .english: "Assignment Name"],
            "academics_course_name": [.chinese: "课程名称", .english: "Course Name"],
            "academics_completed": [.chinese: "已完成", .english: "Completed"],
            "academics_score": [.chinese: "分数", .english: "Score"],
            "academics_total_points": [.chinese: "总分", .english: "Total"],
            "academics_view_details": [.chinese: "查看详情", .english: "View Details"],
            "academics_breakdown": [.chinese: "成绩构成", .english: "Grade Breakdown"],
            "academics_assignments_list": [.chinese: "作业列表", .english: "Assignments List"],
            "academics_weight": [.chinese: "权重", .english: "Weight"],
            "academics_grade": [.chinese: "成绩", .english: "Grade"],
            "academics_submitted": [.chinese: "已提交", .english: "Submitted"],
            "academics_not_submitted": [.chinese: "未提交", .english: "Not Submitted"],
            "academics_due_date": [.chinese: "截止日期", .english: "Due Date"],
            "academics_in_progress": [.chinese: "进行中", .english: "In Progress"],
            
            // 日历界面
            "calendar_title": [.chinese: "日历", .english: "Calendar"],
            "calendar_today": [.chinese: "今天", .english: "Today"],
            "calendar_schedule": [.chinese: "今日日程", .english: "Today's Schedule"],
            "calendar_no_events": [.chinese: "今天没有安排", .english: "No events today"],
            "calendar_add_event": [.chinese: "添加日程", .english: "Add Event"],
            "calendar_event_title": [.chinese: "日程标题", .english: "Event Title"],
            "calendar_location": [.chinese: "地点", .english: "Location"],
            "calendar_start_time": [.chinese: "开始时间", .english: "Start Time"],
            "calendar_end_time": [.chinese: "结束时间", .english: "End Time"],
            "calendar_reminder": [.chinese: "提醒", .english: "Reminder"],
            "calendar_notes": [.chinese: "备注", .english: "Notes"],
            "calendar_added_to_calendar": [.chinese: "已加入日历", .english: "Added"],
            "calendar_add_to_calendar": [.chinese: "加入日历", .english: "Add to Calendar"],
            "calendar_settings": [.chinese: "日历设置", .english: "Calendar Settings"],
            "calendar_reminder_time": [.chinese: "提醒时间", .english: "Reminder Time"],
            "calendar_5min_before": [.chinese: "提前5分钟", .english: "5 minutes before"],
            "calendar_15min_before": [.chinese: "提前15分钟", .english: "15 minutes before"],
            "calendar_30min_before": [.chinese: "提前30分钟", .english: "30 minutes before"],
            "calendar_1hour_before": [.chinese: "提前1小时", .english: "1 hour before"],
            "calendar_1day_before": [.chinese: "提前1天", .english: "1 day before"],
            "calendar_default_view": [.chinese: "默认视图", .english: "Default View"],
            "calendar_view_month": [.chinese: "月视图", .english: "Month"],
            "calendar_view_week": [.chinese: "周视图", .english: "Week"],
            "calendar_view_day": [.chinese: "日视图", .english: "Day"],
            
            // 邮件界面
            "email_title": [.chinese: "邮件", .english: "Email"],
            "email_inbox": [.chinese: "收件箱", .english: "Inbox"],
            "email_unread": [.chinese: "未读", .english: "Unread"],
            "email_all": [.chinese: "全部", .english: "All"],
            "email_urgent": [.chinese: "紧急", .english: "Urgent"],
            "email_academic": [.chinese: "学术", .english: "Academic"],
            "email_events": [.chinese: "活动", .english: "Events"],
            "email_detail": [.chinese: "邮件详情", .english: "Email Detail"],
            
            // 活动界面
            "activities_title": [.chinese: "UCL 活动", .english: "UCL Activities"],
            "activities_search": [.chinese: "搜索活动", .english: "Search Activities"],
            "activities_all": [.chinese: "全部", .english: "All"],
            "activities_academic": [.chinese: "学术", .english: "Academic"],
            "activities_cultural": [.chinese: "文化", .english: "Cultural"],
            "activities_sports": [.chinese: "体育", .english: "Sports"],
            "activities_clubs": [.chinese: "社团", .english: "Clubs"],
            "activities_lectures": [.chinese: "讲座", .english: "Lectures"],
            "activities_exhibitions": [.chinese: "展览", .english: "Exhibitions"],
            "activities_view_details": [.chinese: "查看详情", .english: "View Details"],
            "activities_add_to_calendar": [.chinese: "加入日历", .english: "Add to Calendar"],
            "activities_no_activities": [.chinese: "暂无活动", .english: "No activities"],
            "activities_loading": [.chinese: "加载中...", .english: "Loading..."],
            
            // 待办事项
            "todo_title": [.chinese: "待办事项", .english: "To-Do List"],
            "todo_add": [.chinese: "添加待办", .english: "Add Todo"],
            "todo_pending": [.chinese: "待完成", .english: "Pending"],
            "todo_completed": [.chinese: "已完成", .english: "Completed"],
            "todo_overdue": [.chinese: "已逾期", .english: "Overdue"],
            "todo_due_soon": [.chinese: "即将到期", .english: "Due Soon"],
            "todo_due_date": [.chinese: "截止时间", .english: "Due Date"],
            "todo_priority": [.chinese: "优先级", .english: "Priority"],
            "todo_category": [.chinese: "分类", .english: "Category"],
            "todo_notes": [.chinese: "备注", .english: "Notes"],
            "todo_save": [.chinese: "保存", .english: "Save"],
            "todo_delete": [.chinese: "删除", .english: "Delete"],
            "todo_mark_complete": [.chinese: "标记为完成", .english: "Mark as Complete"],
            "todo_mark_incomplete": [.chinese: "标记为未完成", .english: "Mark as Incomplete"],
            "todo_detail": [.chinese: "待办详情", .english: "Todo Detail"],
            "todo_created": [.chinese: "创建时间", .english: "Created"],
            "todo_source": [.chinese: "来源", .english: "Source"],
            
            // 个人资料
            "profile_title": [.chinese: "个人资料", .english: "Profile"],
            "profile_language": [.chinese: "语言", .english: "Language"],
            "profile_notifications": [.chinese: "通知", .english: "Notifications"],
            "profile_privacy": [.chinese: "隐私", .english: "Privacy"],
            "profile_switch_parent": [.chinese: "切换到家长视图", .english: "Switch to Parent"],
            "profile_switch_student": [.chinese: "切换到学生视图", .english: "Switch to Student"],
            "profile_select_avatar": [.chinese: "选择头像", .english: "Select Avatar"],
            "profile_logout": [.chinese: "退出登录", .english: "Logout"],
            "profile_logout_confirm": [.chinese: "确认退出", .english: "Confirm Logout"],
            "profile_logout_message": [.chinese: "确定要退出登录吗？", .english: "Are you sure you want to logout?"],
            
            // 数据共享
            "data_sharing_title": [.chinese: "数据共享", .english: "Data Sharing"],
            "data_sharing_grades": [.chinese: "成绩信息", .english: "Grades"],
            "data_sharing_calendar": [.chinese: "日历信息", .english: "Calendar"],
            "data_sharing_desc": [.chinese: "与家长共享", .english: "Share with parents"],
            
            // 家长端
            "parent_home_title": [.chinese: "家长中心", .english: "Parent Dashboard"],
            "parent_email_card_title": [.chinese: "邮件通知", .english: "Email Notifications"],
            "parent_email_card_unread": [.chinese: "封未读", .english: "unread"],
            "parent_academic_overview": [.chinese: "学业总览", .english: "Academic Overview"],
            "parent_academic_detail_title": [.chinese: "成绩详情", .english: "Grade Details"],
            "parent_attendance_detail_title": [.chinese: "出勤详情", .english: "Attendance Details"],
            "parent_email_notifications": [.chinese: "邮件通知", .english: "Email Notifications"],
            "parent_important_alerts": [.chinese: "重要提醒", .english: "Important Alerts"],
            "parent_daily_summary": [.chinese: "每日摘要", .english: "Daily Summary"],
            "parent_data_sharing_status": [.chinese: "数据共享状态", .english: "Data Sharing Status"],
            "parent_data_sharing_controlled": [.chinese: "由学生控制共享设置", .english: "Controlled by student"],
        ]
        
        return translations[key]?[language] ?? key
    }
}
