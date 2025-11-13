//
//  Untitled.swift
//  uniappv3
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI

class LocalizationService: ObservableObject {
    enum Language: String, CaseIterable, Identifiable {
        case chinese = "中文"
        case english = "English"
        
        var id: String { rawValue }
    }
    
    @Published var language: Language = .chinese
    
    // 简易的翻译字典
    private let translations: [String: [Language: String]] = [
        // 登录与通用
        "app.tagline": [.chinese: "让学习更简单", .english: "Make learning easier"],
        "language.select": [.chinese: "语言", .english: "Language"],
        "role.student": [.chinese: "学生", .english: "Student"],
        "role.parent": [.chinese: "家长", .english: "Parent"],
        "login.title": [.chinese: "登录", .english: "Sign In"],
        "login.subtitle": [.chinese: "使用学号或邮箱登录", .english: "Use your email to sign in"],
        "input.student.email": [.chinese: "学生邮箱", .english: "Student Email"],
        "input.parent.account": [.chinese: "家长账号", .english: "Parent Account"],
        "placeholder.student.email": [.chinese: "student@demo.edu", .english: "student@demo.edu"],
        "placeholder.parent.email": [.chinese: "parent@demo.edu", .english: "parent@demo.edu"],
        "input.password": [.chinese: "密码", .english: "Password"],
        "placeholder.password": [.chinese: "请输入密码", .english: "Enter password"],
        "a11y.hidePassword": [.chinese: "隐藏密码", .english: "Hide password"],
        "a11y.showPassword": [.chinese: "显示密码", .english: "Show password"],
        "login.rememberMe": [.chinese: "记住我", .english: "Remember me"],
        "login.forgotPassword": [.chinese: "忘记密码？", .english: "Forgot password?"],
        "login.button.signIn": [.chinese: "登录", .english: "Sign In"],
        "login.divider.orContinue": [.chinese: "或继续", .english: "or continue"],
        "login.button.apple": [.chinese: "使用 Apple 登录", .english: "Sign in with Apple"],
        "login.button.google": [.chinese: "使用 Google 登录", .english: "Sign in with Google"],
        "login.demo.student": [.chinese: "学生示例", .english: "Demo Student"],
        "login.demo.parent": [.chinese: "家长示例", .english: "Demo Parent"],
        "home.student.title": [.chinese: "学生首页", .english: "Student Home"],
        "home.parent.title": [.chinese: "家长首页", .english: "Parent Home"],
        "home.success": [.chinese: "登录成功", .english: "Signed in successfully"],
        "home.logout": [.chinese: "退出登录", .english: "Log out"],
        "tab_home": [.chinese: "首页", .english: "Home"],
        "tab_calendar": [.chinese: "日历", .english: "Calendar"],
        "tab_academics": [.chinese: "学业", .english: "Academics"],
        "tab_ai": [.chinese: "AI助手", .english: "AI Assistant"],
        "tab_health": [.chinese: "健康", .english: "Health"],
        "tab_email": [.chinese: "邮件", .english: "Email"],
        "ai_title": [.chinese: "AI 助手", .english: "AI Assistant"],
        "tab_parent_dashboard": [.chinese: "家长中心", .english: "Dashboard"],
        "profile_language": [.chinese: "语言设置", .english: "Language"],
        "data_sharing_grades": [.chinese: "成绩数据", .english: "Grades Data"],
        "data_sharing_calendar": [.chinese: "日历数据", .english: "Calendar Data"],
        "parent_data_sharing_status": [.chinese: "数据共享状态", .english: "Data Sharing Status"],
        "parent_data_sharing_controlled": [.chinese: "数据共享由学生在应用内控制", .english: "Data sharing is controlled by the student in their app."],
        "parent_email_notifications": [.chinese: "邮件通知", .english: "Email Notifications"],
        "parent_important_alerts": [.chinese: "重要提醒", .english: "Important Alerts"],
        "parent_daily_summary": [.chinese: "每日总结", .english: "Daily Summary"],
        "on": [.chinese: "开启", .english: "On"],
        "done": [.chinese: "完成", .english: "Done"],
        "tab_parent_settings": [.chinese: "家长设置", .english: "Settings"],
        "parent_academic_detail_title": [.chinese: "学业详情", .english: "Academic Details"],
        "home_welcome": [.chinese: "欢迎回来,", .english: "Welcome back,"],
        "home_qa_email": [.chinese: "邮件", .english: "Email"],
        "home_qa_activities": [.chinese: "活动", .english: "Activities"],
        "home_deadlines": [.chinese: "即将截止", .english: "Deadlines"],
        "home_today_classes": [.chinese: "今日课程", .english: "Today's Classes"],
        "home_todo": [.chinese: "待办", .english: "Todos"],
        "home_recommendations": [.chinese: "推荐活动", .english: "Recommendations"],
        "profile_title": [.chinese: "个人资料", .english: "Profile"],
        "profile_select_avatar": [.chinese: "选择头像", .english: "Select Avatar"],
        "profile_switch_parent": [.chinese: "切换到家长端", .english: "Switch to Parent"],
        "profile_logout": [.chinese: "登出", .english: "Logout"],
        "profile_logout_confirm": [.chinese: "确认登出", .english: "Confirm Logout"],
        "profile_logout_message": [.chinese: "您确定要登出吗？", .english: "Are you sure you want to log out?"],
        "cancel": [.chinese: "取消", .english: "Cancel"],
        "todo_save": [.chinese: "保存", .english: "Save"],
        "email_event_name": [.chinese: "事件名称", .english: "Event Name"],
        "calendar_event_start": [.chinese: "开始时间", .english: "Start Time"],
        "email_add_to_calendar": [.chinese: "添加到日历", .english: "Add to Calendar"],
        "calendar_add_to_calendar": [.chinese: "添加到日历", .english: "Add to Calendar"],
        "login.terms": [.chinese: "登录即表示同意相关条款与隐私政策", .english: "By signing in you agree to the terms and privacy policy"],
        "email_stats_title": [.chinese: "总邮件", .english: "Total Emails"],
        "email_stats_unread": [.chinese: "未读", .english: "Unread"],
        "calendar_reminder_time": [.chinese: "默认提醒时间", .english: "Default Reminder Time"],
        "calendar_default_view": [.chinese: "默认视图", .english: "Default View"],
        "calendar_settings": [.chinese: "日历设置", .english: "Calendar Settings"],
        "login.loading": [.chinese: "正在登录…", .english: "Signing in…"],
        "academics_modules": [.chinese: "课程成绩", .english: "Modules"],
        "academics_assignments": [.chinese: "作业", .english: "Assignments"],
        "academics_module_name": [.chinese: "课程名称", .english: "Module Name"],
        "academics_module_code": [.chinese: "课程代码", .english: "Module Code"],
        "academics_mark": [.chinese: "分数", .english: "Mark"],
        "academics_add_module": [.chinese: "添加课程", .english: "Add Module"],
        "academics_assignment_name": [.chinese: "作业名称", .english: "Assignment Name"],
        "academics_course_name": [.chinese: "课程", .english: "Course"],
        "academics_completed": [.chinese: "已完成", .english: "Completed"],
        "academics_score": [.chinese: "得分", .english: "Score"],
        "academics_total_points": [.chinese: "总分", .english: "Total Points"],
        "academics_add_assignment": [.chinese: "添加作业", .english: "Add Assignment"]
    ]
    
    // 翻译函数
    func tr(_ key: String) -> String {
        return translations[key]?[language] ?? key
    }
}
