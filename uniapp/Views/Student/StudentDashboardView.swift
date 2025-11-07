//
//  StudentDashboardView.swift (完整修复版)
//  uniapp
//
//  修复版本：EmptyStateCard统一，移除重复定义
//

import SwiftUI

// MARK: - 学生首页主视图
struct StudentDashboardView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @StateObject private var activitiesService = UCLActivitiesService()
    @Binding var selectedTab: Int
    @State private var activeModal: DashboardModal?
    @State private var showingLogoutAlert = false

    private var pinnedActivities: [UCLActivity] {
        activitiesService.activities.prefix(3).map { $0 }
    }

    private enum DashboardModal: Identifiable {
        case todo(TodoItem)
        case profile
        case avatar
        case settings
        case addTodo

        var id: String {
            switch self {
            case .todo(let todo):
                return "todo-\(todo.id.uuidString)"
            case .profile:
                return "profile"
            case .avatar:
                return "avatar"
            case .settings:
                return "settings"
            case .addTodo:
                return "addTodo"
            }
        }
    }
    
    // 今日课程数据
    private var todayClasses: [TodayClass] {
        return [
            TodayClass(
                name: "数据科学与统计",
                code: "CHME0007",
                time: "14:00 - 16:00",
                location: "Cruciform Building, Room 4.18",
                lecturer: "Dr. Johnson"
            ),
            TodayClass(
                name: "健康数据科学原理",
                code: "CHME0006",
                time: "16:30 - 18:30",
                location: "Foster Court, Lecture Theatre",
                lecturer: "Prof. Smith"
            )
        ]
    }

    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        header
                        statsRow
                        todayClassesSection
                        upcomingDeadlinesSection
                        recommendationsSection
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 30)
                }
                .sheet(item: $activeModal) { modal in
                    switch modal {
                    case .todo(let todo):
                        TodoDetailView(
                            todo: todo,
                            isPresented: Binding(
                                get: {
                                    if case .todo(let currentTodo) = activeModal {
                                        return currentTodo.id == todo.id
                                    }
                                    return false
                                },
                                set: { newValue in
                                    if !newValue {
                                        activeModal = nil
                                    }
                                }
                            )
                        )
                        .environmentObject(loc)
                        .environmentObject(appState)
                    case .profile:
                        StudentProfileView()
                            .environmentObject(appState)
                            .environmentObject(loc)
                    case .avatar:
                        AvatarPickerView(selectedIcon: $appState.avatarIcon)
                            .environmentObject(loc)
                    case .settings:
                        StudentSettingsView()
                            .environmentObject(appState)
                            .environmentObject(loc)
                    case .addTodo:
                        AddTodoView()
                            .environmentObject(appState)
                            .environmentObject(loc)
                    }
                }
            }
            .navigationTitle(loc.tr("tab_home"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            activeModal = .settings
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "6366F1"))
                        }
                        
                        Menu {
                            Button {
                                activeModal = .profile
                            } label: {
                                Label(loc.tr("profile_title"), systemImage: "person.crop.circle")
                            }

                            Button {
                                activeModal = .avatar
                            } label: {
                                Label(loc.tr("profile_select_avatar"), systemImage: "paintbrush.pointed")
                            }

                            Divider()

                            if appState.userRole == .student {
                                Button {
                                    withAnimation(.spring(response: 0.4)) {
                                        appState.userRole = .parent
                                    }
                                } label: {
                                    Label(loc.tr("profile_switch_parent"), systemImage: "arrow.left.arrow.right.circle")
                                }
                            }

                            Button(role: .destructive) {
                                showingLogoutAlert = true
                            } label: {
                                Label(loc.tr("profile_logout"), systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 38, height: 38)
                                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)

                                Circle()
                                    .stroke(Color(hex: "6366F1").opacity(0.3), lineWidth: 1)
                                    .frame(width: 38, height: 38)

                                Image(systemName: appState.avatarIcon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "6366F1"))
                            }
                        }
                    }
                }
            }
            .alert(loc.tr("profile_logout_confirm"), isPresented: $showingLogoutAlert) {
                Button(loc.tr("cancel"), role: .cancel) {}
                Button(loc.tr("profile_logout"), role: .destructive) {
                    withAnimation(.spring(response: 0.4)) {
                        appState.isLoggedIn = false
                    }
                }
            } message: {
                Text(loc.tr("profile_logout_message"))
            }
            .onAppear {
                if activitiesService.activities.isEmpty {
                    activitiesService.loadActivities()
                }
            }
        }
    }

    // MARK: - 头部区域（只保留邮件和活动）
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.tr("home_welcome") + " Zoya")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            Text("MSc Health Data Science · Year 1")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            // 只保留邮件和活动两个快捷按钮
            HStack(spacing: 16) {
                quickActionButton(icon: "envelope.fill", title: loc.tr("home_qa_email")) {
                    selectedTab = 4
                }

                quickActionButton(icon: "sparkles", title: loc.tr("home_qa_activities")) {
                    selectedTab = 5
                }
            }
        }
    }

    // MARK: - 统计卡片行
    private var statsRow: some View {
        HStack(spacing: 12) {
            DashboardStatCard(
                title: loc.tr("home_deadlines"),
                value: "\(appState.todoManager.upcomingDeadlines.count)",
                icon: "clock.fill",
                color: Color(hex: "F59E0B")
            )
            
            DashboardStatCard(
                title: loc.tr("home_today_classes"),
                value: "\(todayClasses.count)",
                icon: "book.fill",
                color: Color(hex: "6366F1")
            )
            
            DashboardStatCard(
                title: loc.tr("home_todo"),
                value: "\(appState.todoManager.todos.filter { !$0.isCompleted }.count)",
                icon: "checkmark.circle.fill",
                color: Color(hex: "10B981")
            )
        }
    }

    // MARK: - 今日课程区域
    private var todayClassesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📚 " + loc.tr("home_today_classes"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    selectedTab = 1
                }) {
                    Text("查看全部")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6366F1"))
                }
            }

            if todayClasses.isEmpty {
                StudentEmptyStateCard(
                    icon: "checkmark.circle.fill",
                    message: "今天没有课程，好好利用这段时间！",
                    color: "10B981"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(todayClasses) { classItem in
                        TodayClassCard(classItem: classItem)
                            .onTapGesture {
                                selectedTab = 1
                            }
                    }
                }
            }
        }
    }

    // MARK: - 即将截止区域
    private var upcomingDeadlinesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("⏰ " + loc.tr("home_deadlines"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    activeModal = .addTodo
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                        Text("添加")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "6366F1"))
                }
                
                if !appState.todoManager.upcomingDeadlines.isEmpty {
                    Button(action: {
                        // 跳转到学业界面的作业tab
                        selectedTab = 2
                    }) {
                        Text("查看全部")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }

            if appState.todoManager.upcomingDeadlines.isEmpty {
                VStack(spacing: 16) {
                    StudentEmptyStateCard(
                        icon: "checkmark.circle.fill",
                        message: "暂无待办事项，所有任务都已完成！",
                        color: "10B981"
                    )
                    
                    Button {
                        activeModal = .addTodo
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                            
                            Text("快速添加待办")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(appState.todoManager.upcomingDeadlines.prefix(3)) { todo in
                        DeadlineCard(todo: todo)
                            .onTapGesture {
                                activeModal = .todo(todo)
                            }
                    }
                }
            }
        }
    }

    // MARK: - 推荐活动区域
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🎯 " + loc.tr("home_recommendations"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !pinnedActivities.isEmpty {
                    Button(action: {
                        selectedTab = 5 // 跳转到活动
                    }) {
                        Text("查看全部")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }

            if activitiesService.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if pinnedActivities.isEmpty {
                StudentEmptyStateCard(
                    icon: "sparkles",
                    message: "暂无活动，稍后再来看看吧",
                    color: "F59E0B"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(pinnedActivities) { activity in
                        RecommendationActivityCard(activity: activity)
                            .onTapGesture {
                                selectedTab = 5
                            }
                    }
                }
            }
        }
    }

    // MARK: - 快捷操作按钮
    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 今日课程数据模型
struct TodayClass: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let time: String
    let location: String
    let lecturer: String
}

// MARK: - 今日课程卡片
struct TodayClassCard: View {
    let classItem: TodayClass
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧时间指示器
            VStack(spacing: 4) {
                Text(classItem.time.split(separator: "-").first?.trimmingCharacters(in: .whitespaces) ?? "")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Rectangle()
                    .fill(Color(hex: "6366F1").opacity(0.3))
                    .frame(width: 2, height: 20)
                
                Text(classItem.time.split(separator: "-").last?.trimmingCharacters(in: .whitespaces) ?? "")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)
            
            // 课程信息
            VStack(alignment: .leading, spacing: 6) {
                Text(classItem.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(classItem.code)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "6366F1"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(hex: "6366F1").opacity(0.1))
                    .clipShape(Capsule())
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Text(classItem.location)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "10B981"))
                    
                    Text(classItem.lecturer)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 截止日期卡片
struct DeadlineCard: View {
    let todo: TodoItem
    
    private var timeRemaining: String {
        guard let dueDate = todo.dueDate else { return "无截止时间" }
        
        let now = Date()
        let interval = dueDate.timeIntervalSince(now)
        
        if interval < 0 {
            return "已逾期"
        } else if interval < 3600 {
            return "\(Int(interval / 60))分钟后"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))小时后"
        } else {
            return "\(Int(interval / 86400))天后"
        }
    }
    
    private var urgencyColor: Color {
        guard let dueDate = todo.dueDate else { return Color(hex: "6B7280") }
        
        let interval = dueDate.timeIntervalSince(Date())
        
        if interval < 0 {
            return Color(hex: "EF4444") // 已逾期 - 红色
        } else if interval < 86400 {
            return Color(hex: "F59E0B") // 24小时内 - 橙色
        } else if interval < 259200 {
            return Color(hex: "8B5CF6") // 3天内 - 紫色
        } else {
            return Color(hex: "10B981") // 3天以上 - 绿色
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 优先级指示器
            ZStack {
                Circle()
                    .fill(urgencyColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(urgencyColor)
            }
            
            // 任务信息
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(todo.category)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(timeRemaining)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(urgencyColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(urgencyColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 空状态卡片（统一版本）
struct StudentEmptyStateCard: View {
    let icon: String
    let message: String
    let color: String
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: color))
            }
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 统计卡片
struct DashboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - 推荐活动卡片
struct RecommendationActivityCard: View {
    let activity: UCLActivity
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧时间指示器
            VStack(spacing: 4) {
                if !activity.startTime.isEmpty {
                    Text(formatTime(activity.startTime))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    if !activity.endTime.isEmpty {
                        Rectangle()
                            .fill(Color(hex: "F59E0B").opacity(0.3))
                            .frame(width: 2, height: 20)
                        
                        Text(formatTime(activity.endTime))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
            }
            .frame(width: 60)
            
            // 内容区域
            VStack(alignment: .leading, spacing: 8) {
                Text(activity.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let location = activity.location {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "F59E0B"))
                        
                        Text(location)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // 类型标签
                Text(getTypeLabel(activity.type))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(getTypeColor(activity.type))
                    )
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formatTime(_ timeString: String) -> String {
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = isoFormatter.date(from: timeString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        }
        
        if timeString.contains(":") && timeString.count <= 5 {
            return timeString
        }
        
        return "时间待定"
    }
    
    private func getTypeLabel(_ type: String) -> String {
        switch type.lowercased() {
        case "workshop": return "工作坊"
        case "seminar": return "研讨会"
        case "lecture": return "讲座"
        case "social": return "社交活动"
        case "sports": return "体育活动"
        case "career": return "职业发展"
        case "cultural": return "文化活动"
        default: return "活动"
        }
    }
    
    private func getTypeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "workshop": return Color(hex: "8B5CF6")
        case "seminar": return Color(hex: "6366F1")
        case "lecture": return Color(hex: "3B82F6")
        case "social": return Color(hex: "EC4899")
        case "sports": return Color(hex: "10B981")
        case "career": return Color(hex: "F59E0B")
        case "cultural": return Color(hex: "A855F7")
        default: return Color(hex: "6B7280")
        }
    }
}
