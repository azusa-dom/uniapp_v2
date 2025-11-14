//
//  StudentEmailView.swift
//  uniapp
//
//  Created on 2024.
//

import SwiftUI

// ✅ 第四部分：邮箱首页 UI
struct StudentEmailView: View {
    @EnvironmentObject var loc: LocalizationService
    @State var selectedFilter = "全部"
    
    let categories = ["全部", "紧急", "学术", "活动"]
    
    var filteredEmails: [EmailPreview] {
        let categoryMap: [String: String] = ["全部": "All", "紧急": "Urgent", "学术": "Academic", "活动": "Events"]
        let englishFilter = categoryMap[selectedFilter] ?? "All"
        if englishFilter == "All" { return mockEmails }
        return mockEmails.filter { $0.category == englishFilter }
    }
    
    var readRate: Double {
        let read = mockEmails.filter { $0.isRead }.count
        return Double(read) / Double(mockEmails.count)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变（与其他页面一致）
                LinearGradient(
                    colors: [
                        Color(hex: "F8F9FF"),
                        Color(hex: "EEF2FF"),
                        Color(hex: "E0E7FF")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 统计卡片
                        EmailStatsView(emails: mockEmails)
                            .padding(.top, 8)
                        
                        // 分类标签（现代化设计）
                        VStack(alignment: .leading, spacing: 12) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(categories, id:\.self) { cat in
                                        Button {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedFilter = cat
                                            }
                                        } label: {
                                            Text(cat)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(selectedFilter == cat ? .white : Color(hex: "6366F1"))
                                                .padding(.horizontal, 18)
                                                .padding(.vertical, 10)
                                                .background(
                                                    Group {
                                                        if selectedFilter == cat {
                                                            LinearGradient(
                                                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        } else {
                                                            Color.white.opacity(0.8)
                                                        }
                                                    }
                                                )
                                                .clipShape(Capsule())
                                                .shadow(
                                                    color: selectedFilter == cat ? Color(hex: "6366F1").opacity(0.3) : .clear,
                                                    radius: 8,
                                                    x: 0,
                                                    y: 4
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // 邮件列表
                        VStack(spacing: 12) {
                            ForEach(filteredEmails) { email in
                                NavigationLink(destination: EmailDetailView(email: email)) {
                                    EmailRow(email: email)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("邮件")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// ✅ 第五部分：邮件列表的卡片 UI（Apple 风格）
struct EmailRow: View {
    let email: EmailPreview
    
    // 获取邮件类型图标
    var categoryIcon: String {
        switch email.category {
        case "Academic": return "book.fill"
        case "Events": return "party.popper.fill"
        case "Urgent": return "exclamationmark.triangle.fill"
        default: return "envelope.fill"
        }
    }
    
    // 获取邮件类型颜色
    var categoryColor: Color {
        switch email.category {
        case "Academic": return Color(hex: "6366F1")
        case "Events": return Color(hex: "EC4899")
        case "Urgent": return Color(hex: "F59E0B")
        default: return Color(hex: "8B5CF6")
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 未读指示条（更明显）
            RoundedRectangle(cornerRadius: 3)
                .fill(email.isRead ? Color.clear : Color(hex: "6366F1"))
                .frame(width: 4)
            
            // 邮件类型图标（更精致）
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                categoryColor.opacity(0.2),
                                categoryColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: categoryIcon)
                    .foregroundColor(categoryColor)
                    .font(.system(size: 20, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        // 标题（字体大小与其他页面一致）
                        Text(email.title)
                            .font(.system(size: 16, weight: email.isRead ? .medium : .semibold))
                            .foregroundColor(email.isRead ? .primary : .black)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // 发件人信息（更清晰）
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Text(email.sender)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        // 摘要（字体大小统一）
                        Text(email.excerpt)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    // 相对时间（更精致）
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(email.date)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if !email.isRead {
                            Circle()
                                .fill(Color(hex: "6366F1"))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 2)
                }
                
                // 分类标签（现代化设计）
                HStack(spacing: 8) {
                    Text(email.category)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(categoryColor)
                        )
                    
                    if !email.isRead {
                        Text("未读")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "6366F1"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "6366F1").opacity(0.12))
                            )
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    email.isRead ? Color.clear : Color(hex: "6366F1").opacity(0.2),
                    lineWidth: 1
                )
        )
    }
}

// 兼容旧版本的 EmailCard（供 ParentEmailView 使用）
struct EmailCard: View {
    let title: String
    let sender: String
    let preview: String
    let category: String
    let time: String
    
    var body: some View {
            HStack(alignment: .top, spacing: 12) {
                    Circle()
                .fill(Color(hex:"8B5CF6").opacity(0.5))
                .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                    Text(sender)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(preview)
                        .font(.caption)
                    .foregroundColor(.gray)
                        .lineLimit(2)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(radius: 3, y: 1)
    }
}

// ✅ 第六部分：邮件详情页（翻译 + 总结 + 添加到日历）
struct EmailDetailView: View {
    let email: EmailPreview
    
    @State private var showTranslation = false
    @State private var showSummary = false
    
    var detail: EmailDetailContent {
        if let existingDetail = mockEmailDetails[email.sender] {
            return existingDetail
        }
        // 默认内容（没有AI翻译和总结的邮件）
        return EmailDetailContent(
            original: """
Dear Student,

\(email.excerpt)

Please check your student portal for more details.

Best regards,
\(email.sender)
""",
            aiTranslation: """
亲爱的同学，

\(email.excerpt)

请登录学生门户查看详细信息。
""",
            aiSummary: [
                "📧 请查看完整邮件内容",
                "🔍 登录学生门户获取更多信息"
            ]
        )
    }
    
    var body: some View {
        ZStack {
            // 背景渐变（与其他页面一致）
            LinearGradient(
                colors: [
                    Color(hex: "F8F9FF"),
                    Color(hex: "EEF2FF"),
                    Color(hex: "E0E7FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // 邮件头部信息（现代化设计）
                    VStack(alignment: .leading, spacing: 16) {
                        Text(email.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("发件人")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text(email.sender)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(email.date)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    )
                    
                    // 原文（字体大小统一）
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "6366F1"))
                            Text("邮件内容")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        Text(detail.original)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.primary)
                            .lineSpacing(8)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    )
                    
                    // AI 功能按钮区域（现代化设计）
                    HStack(spacing: 12) {
                        // AI 翻译按钮
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showTranslation.toggle()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showTranslation ? "checkmark.circle.fill" : "character.bubble.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(showTranslation ? "已翻译" : "AI 翻译")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Group {
                                    if showTranslation {
                                        LinearGradient(
                                            colors: [Color(hex: "10B981"), Color(hex: "059669")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(
                                color: showTranslation ? Color(hex: "10B981").opacity(0.3) : Color(hex: "6366F1").opacity(0.3),
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                        }
                        
                        // AI 总结按钮
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showSummary.toggle()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showSummary ? "checkmark.circle.fill" : "list.bullet.rectangle.portrait.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(showSummary ? "已总结" : "AI 总结")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Group {
                                    if showSummary {
                                        LinearGradient(
                                            colors: [Color(hex: "10B981"), Color(hex: "059669")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(
                                color: showSummary ? Color(hex: "10B981").opacity(0.3) : Color(hex: "6366F1").opacity(0.3),
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // AI 翻译内容（点击后显示）
                    if showTranslation {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "10B981"))
                                Text("AI 翻译")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            Text(detail.aiTranslation)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.primary)
                                .lineSpacing(8)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "E8F5E9"))
                                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // AI 总结内容（点击后显示）
                    if showSummary && !detail.aiSummary.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "list.bullet.rectangle.portrait.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "6366F1"))
                                Text("AI 总结要点")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(detail.aiSummary, id:\.self) { point in
                                    HStack(alignment: .top, spacing: 10) {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 8, height: 8)
                                            .padding(.top, 6)
                                        Text(point)
                                            .font(.system(size: 15, weight: .regular))
                                            .foregroundColor(.primary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // 添加到日历按钮（现代化设计）
                    Button(action: {}) {
                        HStack(spacing: 10) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("添加到日历")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(
                            color: Color(hex: "6366F1").opacity(0.3),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle(email.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct AddEmailToCalendarView: View {

    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    
    @State var eventName: String
    @State private var eventDate = Date()
    
    init(emailTitle: String) {
        _eventName = State(initialValue: emailTitle)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(loc.tr("email_event_name"))) {
                    TextField(loc.tr("email_event_name"), text: $eventName)
                }
                
                Section(header: Text(loc.tr("calendar_event_start"))) {
                    DatePicker("Date", selection: $eventDate)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text(loc.tr("todo_save"))
                }
                .disabled(eventName.isEmpty)
            }
            .navigationTitle(loc.tr("email_add_to_calendar"))
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
}
struct ActionButton: View {

    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(DesignSystem.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct EmailStatsView: View {
    @EnvironmentObject var loc: LocalizationService
    let emails: [EmailPreview]

    private var unreadCount: Int {
        emails.filter { !$0.isRead }.count
    }

    var body: some View {
        HStack(spacing: 24) {
            // 总邮件数
            VStack(spacing: 8) {
                Text("\(emails.count)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                Text(loc.tr("email_stats_title"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // 分隔线
            Rectangle()
                .fill(Color(hex: "E0E7FF"))
                .frame(width: 1)
                .frame(height: 50)
            
            // 未读邮件数
            VStack(spacing: 8) {
                Text("\(unreadCount)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "EF4444"))
                Text(loc.tr("email_stats_unread"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
}
