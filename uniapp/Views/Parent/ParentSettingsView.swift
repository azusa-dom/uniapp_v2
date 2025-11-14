// MARK: - ParentSettingsView.swift
// 文件位置: uniapp/Views/Parent/ParentSettingsView.swift

import SwiftUI

struct ParentSettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        ZStack {
            DesignSystem.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 学生信息卡
                    StudentInfoCard()
                    
                    // 隐私权限状态
                    PrivacyPermissionsCard()
                    
                    // 家长端设置
                    ParentPreferencesCard()
                    
                    // 关于信息
                    AboutCard()
                    
                    // 退出登录
                    LogoutButton()
                }
                .padding()
            }
        }
        .navigationTitle(loc.language == .chinese ? "设置与隐私" : "Settings & Privacy")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - 学生信息卡
struct StudentInfoCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc.language == .chinese ? "学生信息" : "Student Information")
                .font(.headline)
            
            HStack(spacing: 16) {
                // 头像
                ZStack {
                    Circle()
                        .fill(DesignSystem.primaryGradient)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: appState.avatarIcon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.studentName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(appState.studentEmail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text(appState.studentProgram)
                            .font(.caption)
                        Text("•")
                            .font(.caption)
                        Text(appState.studentYear)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 隐私权限状态卡
struct PrivacyPermissionsCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "hand.raised.fill")
                    .foregroundColor(DesignSystem.primaryColor)
                Text(loc.language == .chinese ? "数据共享权限" : "Data Sharing Permissions")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // 说明文字
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(loc.language == .chinese
                         ? "以下权限由学生控制，家长端只读"
                         : "These permissions are controlled by the student")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Divider()
                
                // 成绩权限
                PermissionRow(
                    icon: "graduationcap.fill",
                    title: loc.language == .chinese ? "成绩信息" : "Academic Grades",
                    description: loc.language == .chinese ? "包含课程成绩、平均分、学分等" : "Includes course grades, average, credits",
                    isEnabled: appState.shareGrades
                )
                
                Divider()
                
                // 课表权限
                PermissionRow(
                    icon: "calendar.badge.clock",
                    title: loc.language == .chinese ? "课程表" : "Class Schedule",
                    description: loc.language == .chinese ? "包含每日课程安排、教室地点等" : "Includes daily schedule, classroom locations",
                    isEnabled: appState.shareCalendar
                )
                
                Divider()
                
                // 健康信息权限（示例 - 需要在 AppState 中添加）
                PermissionRow(
                    icon: "heart.text.square.fill",
                    title: loc.language == .chinese ? "健康档案" : "Health Records",
                    description: loc.language == .chinese ? "包含过敏史、用药记录、就诊预约" : "Includes allergies, medications, appointments",
                    isEnabled: true  // 默认共享，可以扩展为 appState.shareHealthInfo
                )
                
                Divider()
                
                // 校园活动权限
                PermissionRow(
                    icon: "star.fill",
                    title: loc.language == .chinese ? "校园活动" : "Campus Activities",
                    description: loc.language == .chinese ? "包含参与的活动、社团等" : "Includes activities, clubs participation",
                    isEnabled: true  // 可扩展为 appState.shareCampusActivities
                )
            }
            
            // 底部提示
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .font(.caption2)
                Text(loc.language == .chinese
                     ? "如需更改权限，请联系学生在学生端进行调整"
                     : "To change permissions, please ask the student to adjust in their settings")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 权限行组件
struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isEnabled ? DesignSystem.successColor : .gray)
                .frame(width: 40, height: 40)
                .background(isEnabled ? DesignSystem.successColor.opacity(0.1) : Color.gray.opacity(0.1))
                .clipShape(Circle())
            
            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // 状态标签
            HStack(spacing: 4) {
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.caption)
                Text(isEnabled ? "已共享" : "未共享")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isEnabled ? DesignSystem.successColor : .gray)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isEnabled ? DesignSystem.successColor.opacity(0.1) : Color.gray.opacity(0.1))
            .clipShape(Capsule())
        }
    }
}

// MARK: - 家长端偏好设置卡
struct ParentPreferencesCard: View {
    @EnvironmentObject var loc: LocalizationService
    
    @AppStorage("parentTimeZone") private var timeZonePreference = "London"
    @AppStorage("parentNotifications") private var notificationsEnabled = true
    @AppStorage("parentDigestFrequency") private var digestFrequency = "Daily"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(DesignSystem.primaryColor)
                Text(loc.language == .chinese ? "家长端设置" : "Parent Preferences")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // 语言设置
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(loc.language == .chinese ? "界面语言" : "Interface Language",
                              systemImage: "globe")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(loc.language == .chinese ? "切换显示语言" : "Switch display language")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Picker("", selection: Binding(
                        get: { loc.language },
                        set: { loc.language = $0 }
                    )) {
                        ForEach(LocalizationService.Language.allCases, id: \.self) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Divider()
                
                // 时区显示
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(loc.language == .chinese ? "时区显示" : "Time Zone",
                              systemImage: "clock.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(loc.language == .chinese ? "选择时间显示时区" : "Choose time display zone")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Picker("", selection: $timeZonePreference) {
                        Text(loc.language == .chinese ? "本地时间" : "Local Time").tag("Local")
                        Text(loc.language == .chinese ? "伦敦时间" : "London Time").tag("London")
                        Text(loc.language == .chinese ? "双时区显示" : "Both").tag("Both")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Divider()
                
                // 通知设置
                Toggle(isOn: $notificationsEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(loc.language == .chinese ? "推送通知" : "Push Notifications",
                              systemImage: "bell.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(loc.language == .chinese ? "接收重要事项提醒" : "Receive important updates")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .tint(DesignSystem.primaryColor)
                
                Divider()
                
                // 摘要频率
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(loc.language == .chinese ? "摘要频率" : "Digest Frequency",
                              systemImage: "newspaper.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(loc.language == .chinese ? "接收学生状态摘要" : "Receive student status digest")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Picker("", selection: $digestFrequency) {
                        Text(loc.language == .chinese ? "每日" : "Daily").tag("Daily")
                        Text(loc.language == .chinese ? "每周" : "Weekly").tag("Weekly")
                        Text(loc.language == .chinese ? "关闭" : "Off").tag("Off")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 关于信息卡
struct AboutCard: View {
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc.language == .chinese ? "关于" : "About")
                .font(.headline)
            
            VStack(spacing: 12) {
                AboutRow(
                    icon: "info.circle.fill",
                    title: loc.language == .chinese ? "应用版本" : "App Version",
                    value: "1.0.0"
                )
                
                Divider()
                
                AboutRow(
                    icon: "lock.shield.fill",
                    title: loc.language == .chinese ? "隐私政策" : "Privacy Policy",
                    value: "",
                    isLink: true
                )
                
                Divider()
                
                AboutRow(
                    icon: "doc.text.fill",
                    title: loc.language == .chinese ? "使用条款" : "Terms of Service",
                    value: "",
                    isLink: true
                )
                
                Divider()
                
                AboutRow(
                    icon: "questionmark.circle.fill",
                    title: loc.language == .chinese ? "帮助与支持" : "Help & Support",
                    value: "",
                    isLink: true
                )
            }
            
            // 底部说明
            VStack(spacing: 8) {
                Divider()
                
                Text(loc.language == .chinese
                     ? "UniApp - 面向国际学生和家长的智能校园助手"
                     : "UniApp - Smart Campus Assistant for International Students & Parents")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                
                Text("© 2024 UniApp. " + (loc.language == .chinese ? "保留所有权利" : "All rights reserved"))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 退出登录按钮
struct LogoutButton: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @State private var showingAlert = false
    
    var body: some View {
        Button {
            showingAlert = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(Color(hex: "EF4444"))
                    .font(.system(size: 18, weight: .semibold))
                
                Text(loc.language == .chinese ? "退出登录" : "Log Out")
                    .foregroundColor(Color(hex: "EF4444"))
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "EF4444").opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "EF4444").opacity(0.3), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .alert(
            loc.language == .chinese ? "确认退出" : "Confirm Logout",
            isPresented: $showingAlert
        ) {
            Button(loc.language == .chinese ? "取消" : "Cancel", role: .cancel) {}
            Button(loc.language == .chinese ? "退出登录" : "Log Out", role: .destructive) {
                withAnimation(.spring(response: 0.4)) {
                    appState.isLoggedIn = false
                }
            }
        } message: {
            Text(loc.language == .chinese 
                 ? "确定要退出登录吗？您将需要重新登录才能访问家长面板。" 
                 : "Are you sure you want to log out? You will need to log in again to access the parent panel.")
        }
    }
}

// MARK: - 关于行组件
struct AboutRow: View {
    let icon: String
    let title: String
    let value: String
    var isLink: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(DesignSystem.primaryColor)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if isLink {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

