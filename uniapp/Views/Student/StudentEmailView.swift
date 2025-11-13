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
                backgroundLayer
                content
            }
            .navigationTitle("邮件")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var backgroundLayer: some View {
        LinearGradient(
            colors: [Color(hex: "F8FAFC"), Color(hex: "F1F5F9")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            EmailStatsView(emails: mockEmails)
                .padding(.top, 16)
            
            AutoDeadlineBanner(emails: mockEmails)
                .padding(.horizontal, 20)
            
            filterBar
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredEmails) { email in
                        NavigationLink(destination: EmailDetailView(email: email)) {
                            EmailRow(email: email)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { cat in
                    Text(cat)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(selectedFilter == cat ? Color(hex:"6366F1") : Color.gray.opacity(0.15))
                        .foregroundColor(selectedFilter == cat ? .white : .black)
                        .cornerRadius(12)
                        .font(.system(size: 14, weight: .medium))
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedFilter = cat
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
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
            // 未读指示条
            RoundedRectangle(cornerRadius: 2)
                .fill(email.isRead ? Color.clear : Color(hex: "6366F1"))
                .frame(width: 4)
            
            // 邮件类型图标
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: categoryIcon)
                    .foregroundColor(categoryColor)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(email.title)
                            .font(.system(size: 16, weight: email.isRead ? .medium : .semibold))
                            .foregroundColor(email.isRead ? .primary : .black)
                            .lineLimit(2)
                        
                        // 发件人信息
                        HStack(spacing: 4) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(email.sender)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(email.excerpt)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        if let deadline = email.deadline, deadline.calendarAdded {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar.badge.checkmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(hex: "10B981"))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("已自动加入日程：\(deadline.title)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(hex: "10B981"))
                                    Text("\(deadline.date) · \(deadline.time)")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(hex: "059669"))
                                }
                                Spacer()
                            }
                            .padding(10)
                            .background(Color(hex: "D1FAE5").opacity(0.6))
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    // 相对时间
                    Text(email.date)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                
                // 分类标签
                HStack(spacing: 8) {
                    Text(email.category)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(categoryColor)
                        .cornerRadius(8)
                    
                    if !email.isRead {
                        Text("未读")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "6366F1"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "6366F1").opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
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
            LinearGradient(
                colors: [Color(hex: "F8FAFC"), Color(hex: "F1F5F9")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 邮件头部信息
                    VStack(alignment: .leading, spacing: 12) {
                        Text(email.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("发件人")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text(email.sender)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Text(email.date)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                    )
                    
                    if let deadline = email.deadline {
                        DeadlineSyncCard(deadline: deadline)
                    }
                    
                    // 原文
                    VStack(alignment: .leading, spacing: 12) {
                        Text("邮件内容")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        Text(detail.original)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.primary)
                            .lineSpacing(6)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                    )
                    
                    // AI 功能按钮区域
                    HStack(spacing: 12) {
                        // AI 翻译按钮
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showTranslation.toggle()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showTranslation ? "checkmark.circle.fill" : "character.bubble.fill")
                                    .foregroundColor(.white)
                                Text(showTranslation ? "已翻译" : "AI 翻译")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: showTranslation ? [Color(hex: "10B981"), Color(hex: "10B981")] : [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        
                        // AI 总结按钮
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showSummary.toggle()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showSummary ? "checkmark.circle.fill" : "list.bullet.rectangle.portrait.fill")
                                    .foregroundColor(.white)
                                Text(showSummary ? "已总结" : "AI 总结")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: showSummary ? [Color(hex: "10B981"), Color(hex: "10B981")] : [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // AI 翻译内容（点击后显示）
                    if showTranslation {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "10B981"))
                                Text("AI 翻译")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            Text(detail.aiTranslation)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.primary)
                                .lineSpacing(6)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "E8F5E9"))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // AI 总结内容（点击后显示）
                    if showSummary && !detail.aiSummary.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "list.bullet.rectangle.portrait.fill")
                                    .foregroundColor(Color(hex: "6366F1"))
                                Text("AI 总结要点")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(detail.aiSummary, id:\.self) { point in
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle()
                                            .fill(Color(hex: "8B5CF6"))
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text(point)
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // 添加到日历按钮
                    if let deadline = email.deadline, deadline.calendarAdded {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "10B981"))
                            Text("已同步到日历 · \(deadline.note)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "065F46"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color(hex: "ECFDF5"))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    } else {
                        Button(action: {}) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar.badge.plus")
                                Text("添加到日历")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(email.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DeadlineSyncCard: View {
    let deadline: EmailPreview.DeadlineMeta
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "10B981"))
                VStack(alignment: .leading, spacing: 2) {
                    Text("已自动添加到日历")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "065F46"))
                    Text(deadline.note)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "059669"))
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "10B981"))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(deadline.title)
                    .font(.system(size: 15, weight: .semibold))
                Text("截止：\(deadline.date) \(deadline.time)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "D1FAE5"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "34D399").opacity(0.4), lineWidth: 1)
                )
        )
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
    
    private var syncedCount: Int {
        emails.filter { $0.deadline?.calendarAdded == true }.count
    }

    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Text("\(emails.count)")
                    .font(.title)
                    .fontWeight(.bold)
                Text(loc.tr("email_stats_title"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack {
                Text("\(unreadCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "EF4444"))
                Text(loc.tr("email_stats_unread"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                Text("\(syncedCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "10B981"))
                Text("已同步日历")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

private struct AutoDeadlineBanner: View {
    let emails: [EmailPreview]
    
    private var nextDeadline: EmailPreview.DeadlineMeta? {
        let deadlines = emails.compactMap { $0.deadline }
        return deadlines.first
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "10B981").opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "sparkles")
                    .foregroundColor(Color(hex: "10B981"))
                    .font(.system(size: 20, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("AI 已将邮件截止日期同步到日程")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                if let nextDeadline {
                    Text("最近提醒：\(nextDeadline.title) · \(nextDeadline.date) \(nextDeadline.time)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                } else {
                    Text("当前暂无自动同步的任务")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "10B981"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "D1FAE5"))
        )
    }
}
