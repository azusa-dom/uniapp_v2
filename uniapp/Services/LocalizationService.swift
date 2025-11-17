//
//  LocalizationService.swift
//  uniapp
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
        "tab_activity_calendar": [.chinese: "活动日历", .english: "Activity Calendar"],
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
        "home_greeting": [.chinese: "今天也是元气满满的一天呢,", .english: "Have a productive day,"],
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
        "save": [.chinese: "保存", .english: "Save"],
        "todo_save": [.chinese: "保存", .english: "Save"],
        "email_event_name": [.chinese: "事件名称", .english: "Event Name"],
        "calendar_event_start": [.chinese: "开始时间", .english: "Start Time"],
        "email_add_to_calendar": [.chinese: "添加到日历", .english: "Add to Calendar"],
        "calendar_add_to_calendar": [.chinese: "添加到日历", .english: "Add to Calendar"],
        "calendar_import": [.chinese: "导入日历", .english: "Import Calendar"],
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
        "academics_add_assignment": [.chinese: "添加作业", .english: "Add Assignment"],

        // Dashboard 新增翻译
        "dashboard_quick_actions": [.chinese: "快捷操作", .english: "Quick Actions"],
        "dashboard_ai_assistant": [.chinese: "AI助手", .english: "AI Assistant"],
        "dashboard_ai_subtitle": [.chinese: "智能学习助理", .english: "Smart Learning Assistant"],
        "dashboard_mailbox": [.chinese: "邮箱", .english: "Mailbox"],
        "dashboard_email_subtitle": [.chinese: "查看最新邮件", .english: "Check Latest Emails"],
        "dashboard_health": [.chinese: "健康", .english: "Health"],
        "dashboard_health_subtitle": [.chinese: "预约GP问诊", .english: "Book GP Appointment"],
        "dashboard_activities": [.chinese: "活动", .english: "Activities"],
        "dashboard_activities_subtitle": [.chinese: "发现精彩活动", .english: "Discover Events"],
        "dashboard_view_all": [.chinese: "查看全部", .english: "View All"],
        "dashboard_add": [.chinese: "添加", .english: "Add"],
        "dashboard_no_classes": [.chinese: "今天没有课程，好好利用这段时间！", .english: "No classes today, make the most of it!"],
        "dashboard_no_todos": [.chinese: "暂无待办事项，所有任务都已完成！", .english: "No pending todos, all tasks completed!"],
        "dashboard_no_activities": [.chinese: "暂无活动，稍后再来看看吧", .english: "No activities yet, check back later"],
        "dashboard_overdue": [.chinese: "已逾期", .english: "Overdue"],
        "dashboard_no_deadline": [.chinese: "无截止", .english: "No deadline"],
        "dashboard_minutes_left": [.chinese: "分钟后", .english: " minutes left"],
        "dashboard_hours_left": [.chinese: "小时后", .english: " hours left"],
        "dashboard_days_left": [.chinese: "天后", .english: " days left"],
        "dashboard_time_tbd": [.chinese: "时间待定", .english: "Time TBD"],

        // Settings 新增翻译
        "settings_title": [.chinese: "设置", .english: "Settings"],
        "settings_avatar": [.chinese: "头像设置", .english: "Avatar Settings"],
        "settings_personal_info": [.chinese: "个人信息", .english: "Personal Information"],
        "settings_academic_info": [.chinese: "学业信息", .english: "Academic Information"],
        "settings_contact": [.chinese: "联系方式", .english: "Contact Information"],
        "settings_about": [.chinese: "个人简介", .english: "About"],
        "settings_name": [.chinese: "姓名", .english: "Name"],
        "settings_email": [.chinese: "邮箱", .english: "Email"],
        "settings_student_id": [.chinese: "学号", .english: "Student ID"],
        "settings_program": [.chinese: "专业", .english: "Program"],
        "settings_year": [.chinese: "年级", .english: "Year"],
        "settings_phone": [.chinese: "手机号", .english: "Phone"],
        "settings_bio": [.chinese: "简介", .english: "Bio"],
        "settings_select_icon": [.chinese: "选择图标", .english: "Select Icon"],
        "settings_upload_photo": [.chinese: "相册上传", .english: "Upload Photo"],
        "settings_camera": [.chinese: "相册上传", .english: "Upload from Album"],
        "settings_unsaved_title": [.chinese: "未保存的更改", .english: "Unsaved Changes"],
        "settings_unsaved_message": [.chinese: "您有未保存的更改，是否要保存？", .english: "You have unsaved changes. Do you want to save them?"],
        "settings_discard": [.chinese: "放弃更改", .english: "Discard Changes"],
        "settings_continue_editing": [.chinese: "继续编辑", .english: "Continue Editing"],
        "settings_placeholder_name": [.chinese: "请输入姓名", .english: "Enter your name"],
        "settings_placeholder_email": [.chinese: "请输入邮箱", .english: "Enter your email"],
        "settings_placeholder_student_id": [.chinese: "请输入学号", .english: "Enter student ID"],
        "settings_placeholder_program": [.chinese: "请输入专业", .english: "Enter your program"],
        "settings_placeholder_year": [.chinese: "例如：Year 1", .english: "e.g., Year 1"],
        "settings_placeholder_phone": [.chinese: "请输入手机号", .english: "Enter phone number"],
        "settings_language_section": [.chinese: "应用设置", .english: "App Settings"],
        "settings_language_title": [.chinese: "语言 / Language", .english: "Language / 语言"],
        "settings_language_subtitle": [.chinese: "选择应用显示语言", .english: "Choose app display language"],

        // Todo 翻译
        "todo_list_title": [.chinese: "待办事项", .english: "Todos"],
        "todo_incomplete": [.chinese: "未完成", .english: "Incomplete"],
        "todo_completed": [.chinese: "已完成", .english: "Completed"],
        "todo_no_incomplete": [.chinese: "暂无未完成任务", .english: "No incomplete tasks"],
        "todo_delete": [.chinese: "删除", .english: "Delete"],

        // 活动类型翻译
        "activity_workshop": [.chinese: "工作坊", .english: "Workshop"],
        "activity_seminar": [.chinese: "研讨会", .english: "Seminar"],
        "activity_lecture": [.chinese: "讲座", .english: "Lecture"],
        "activity_social": [.chinese: "社交活动", .english: "Social"],
        "activity_sports": [.chinese: "体育活动", .english: "Sports"],
        "activity_career": [.chinese: "职业发展", .english: "Career"],
        "activity_cultural": [.chinese: "文化活动", .english: "Cultural"],
        "activity_academic": [.chinese: "学术活动", .english: "Academic"],
        "activity_default": [.chinese: "活动", .english: "Activity"],

        // Profile 新增翻译
        "profile_student_id": [.chinese: "学号:", .english: "Student ID:"],
        "profile_notifications": [.chinese: "通知", .english: "Notifications"],
        "profile_privacy": [.chinese: "隐私设置", .english: "Privacy"],
        "profile_switch_student": [.chinese: "切换到学生端", .english: "Switch to Student"],
        "data_sharing_title": [.chinese: "数据共享设置", .english: "Data Sharing"],
        "data_sharing_grades_desc": [.chinese: "与家长共享成绩信息", .english: "Share grades with parents"],
        "data_sharing_calendar_desc": [.chinese: "与家长共享日程安排", .english: "Share calendar with parents"],
        "data_sharing_desc": [.chinese: "家长只能查看您允许共享的信息", .english: "Parents can only view information you allow"],
        "language_selection_title": [.chinese: "选择语言", .english: "Select Language"]
    ]
    
    // 翻译函数
    func tr(_ key: String) -> String {
        return translations[key]?[language] ?? key
    }
}
