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
    @EnvironmentObject var viewModel: UCLAPIViewModel
    @StateObject private var activitiesService = UCLActivitiesService()
    @Binding var selectedTab: Int
    @State private var activeModal: DashboardModal?
    @State private var showingLogoutAlert = false
    @State private var recommendedEvents: [UCLAPIViewModel.UCLAPIEvent] = []

    private var pinnedActivities: [UCLActivity] {
        activitiesService.activities.prefix(3).map { $0 }
    }

    private enum DashboardModal: Identifiable {
        case todo(TodoItem)
        case profile
        case avatar
        case settings
        case addTodo
        case allTodos

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
            case .allTodos:
                return "allTodos"
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
                    VStack(spacing: 20) {
                        header
                        statsRow
                        todayClassesSection
                        upcomingDeadlinesSection
                        recommendationsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
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
                    case .allTodos:
                        StudentAllTodosView()
                            .environmentObject(appState)
                            .environmentObject(loc)
                    }
                }
            }
            .navigationTitle(loc.tr("tab_home"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
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
                        
                        Button {
                            activeModal = .settings
                        } label: {
                            Label(loc.tr("tab_settings"), systemImage: "gearshape.fill")
                        }

                        Divider()

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
                
                // 触发事件加载
                if viewModel.events.isEmpty {
                    viewModel.fetchEvents()
                }
                
                // 初始加载推荐事件
                updateRecommendedEvents()
                
                // 延迟更新以捕获异步加载的事件
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    updateRecommendedEvents()
                }
            }
            .onChange(of: viewModel.events.count) { _, _ in
                // 当事件数量改变时更新推荐
                updateRecommendedEvents()
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
    
    // MARK: - 辅助方法
    private func updateRecommendedEvents() {
        recommendedEvents = viewModel.getRecommendedActivities()
        print("🔄 更新推荐事件: \(recommendedEvents.count) 个")
    }

    // MARK: - 头部区域（简洁版本）
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.tr("home_welcome") + " Zoya")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            Text(loc.tr("student_program"))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
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
                
                if !todayClasses.isEmpty {
                    Button(action: {
                        selectedTab = 1
                    }) {
                        Text(loc.tr("view_all"))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }

            if todayClasses.isEmpty {
                StudentEmptyStateCard(
                    icon: "checkmark.circle.fill",
                    message: loc.tr("no_classes_today"),
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
                        Text(loc.tr("add"))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "6366F1"))
                }

                if !appState.todoManager.upcomingDeadlines.isEmpty {
                    Button(action: {
                        // 打开所有待办事项视图
                        activeModal = .allTodos
                    }) {
                        Text(loc.tr("view_all"))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }

            if appState.todoManager.upcomingDeadlines.isEmpty {
                VStack(spacing: 16) {
                    StudentEmptyStateCard(
                        icon: "checkmark.circle.fill",
                        message: loc.tr("no_tasks"),
                        color: "10B981"
                    )

                    Button {
                        activeModal = .addTodo
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))

                            Text(loc.tr("quick_add_todo"))
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
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "F59E0B"))

                    Text(loc.tr("recommended_for_you"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }

                Spacer()

                if !recommendedEvents.isEmpty {
                    Button(action: {
                        selectedTab = 5 // 跳转到活动
                    }) {
                        Text(loc.tr("view_all"))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }

            if recommendedEvents.isEmpty {
                StudentEmptyStateCard(
                    icon: "star.fill",
                    message: loc.tr("finding_activities"),
                    color: "F59E0B"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(recommendedEvents) { event in
                        RecommendedEventCard(event: event)
                            .onTapGesture {
                                selectedTab = 5
                            }
                    }
                }
            }
            
            // 说明文字
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Text(loc.tr("recommendation_hint"))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
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

// MARK: - 学生全部待办事项视图

struct StudentAllTodosView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showingAddTodo = false
    @State private var selectedFilter: TodoFilter = .all
    @State private var selectedTodo: TodoItem?
    
    enum TodoFilter: String, CaseIterable {
        case all
        case upcoming
        case today
        case week
        case completed

        func localizedTitle(_ loc: LocalizationService) -> String {
            switch self {
            case .all: return loc.language == .chinese ? "全部" : "All"
            case .upcoming: return loc.tr("upcoming_deadlines")
            case .today: return loc.language == .chinese ? "今天" : "Today"
            case .week: return loc.language == .chinese ? "本周" : "This Week"
            case .completed: return loc.tr("completed")
            }
        }

        var systemImage: String {
            switch self {
            case .all: return "list.bullet"
            case .upcoming: return "clock.fill"
            case .today: return "calendar"
            case .week: return "calendar.badge.clock"
            case .completed: return "checkmark.circle.fill"
            }
        }
    }
    
    private var filteredTodos: [TodoItem] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .all:
            return appState.todoManager.todos
        case .upcoming:
            return appState.todoManager.upcomingDeadlines
        case .today:
            return appState.todoManager.todos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return calendar.isDateInToday(dueDate)
            }
        case .week:
            return appState.todoManager.todos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now)!
                return dueDate >= now && dueDate <= weekFromNow
            }
        case .completed:
            return appState.todoManager.todos.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 筛选器
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TodoFilter.allCases, id: \.self) { filter in
                                makeFilterChip(for: filter)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(.ultraThinMaterial)
                    
                    // 待办列表
                    if filteredTodos.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()

                            Image(systemName: selectedFilter == .completed ? "checkmark.circle.fill" : "tray")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "6366F1").opacity(0.3))

                            Text(selectedFilter == .completed ?
                                (loc.language == .chinese ? "暂无已完成的任务" : "No completed tasks") :
                                (loc.language == .chinese ? "暂无待办事项" : "No pending tasks")
                            )
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.secondary)

                            Button {
                                showingAddTodo = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                    Text(loc.language == .chinese ? "添加新待办" : "Add New Todo")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color(hex: "6366F1"))
                                .cornerRadius(12)
                            }

                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filteredTodos) { todo in
                                    TodoRowCard(todo: todo) {
                                        selectedTodo = todo
                                    } onToggle: {
                                        appState.todoManager.toggleCompletion(todo)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle(loc.tr("todo_title"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.tr("close")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTodo = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView()
                    .environmentObject(appState)
                    .environmentObject(loc)
            }
            .sheet(item: $selectedTodo) { todo in
                TodoDetailView(
                    todo: todo,
                    isPresented: Binding(
                        get: { selectedTodo != nil },
                        set: { if !$0 { selectedTodo = nil } }
                    )
                )
                .environmentObject(loc)
                .environmentObject(appState)
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
    
    private func makeFilterChip(for filter: TodoFilter) -> some View {
        FilterChip(
            title: filter.localizedTitle(loc),
            icon: filter.systemImage,
            isSelected: selectedFilter == filter,
            count: countForFilter(filter)
        ) {
            selectedFilter = filter
        }
    }
    
    private func countForFilter(_ filter: TodoFilter) -> Int {
        switch filter {
        case .all:
            return appState.todoManager.todos.count
        case .upcoming:
            return appState.todoManager.upcomingDeadlines.count
        case .today:
            return todayTodosCount
        case .week:
            return weekTodosCount
        case .completed:
            return completedTodosCount
        }
    }
    
    private var todayTodosCount: Int {
        let calendar = Calendar.current
        return appState.todoManager.todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDateInToday(dueDate)
        }.count
    }
    
    private var weekTodosCount: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now) else { return 0 }
        
        return appState.todoManager.todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return dueDate >= now && dueDate <= weekFromNow
        }.count
    }
    
    private var completedTodosCount: Int {
        return appState.todoManager.todos.filter { $0.isCompleted }.count
    }
}

// MARK: - 筛选器芯片

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    private var badgeBackgroundColor: Color {
        isSelected ? Color.white.opacity(0.3) : Color(hex: "6366F1").opacity(0.1)
    }
    
    private var badgeForegroundColor: Color {
        isSelected ? .white : Color(hex: "6366F1")
    }
    
    private var chipBackgroundColor: Color {
        isSelected ? Color(hex: "6366F1") : Color.white.opacity(0.8)
    }
    
    private var shadowColor: Color {
        isSelected ? Color(hex: "6366F1").opacity(0.3) : .clear
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                
                if count > 0 {
                    countBadge
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(chipBackgroundColor)
            )
            .shadow(color: shadowColor, radius: 8, y: 2)
        }
    }
    
    private var countBadge: some View {
        Text("\(count)")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(badgeForegroundColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(badgeBackgroundColor)
            .cornerRadius(8)
    }
}

// MARK: - 待办行卡片

struct TodoRowCard: View {
    let todo: TodoItem
    let onTap: () -> Void
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 完成按钮
                Button(action: onToggle) {
                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(todo.isCompleted ? Color(hex: "10B981") : Color.gray.opacity(0.3))
                }
                .buttonStyle(.plain)
                
                // 内容
                VStack(alignment: .leading, spacing: 6) {
                    Text(todo.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                        .strikethrough(todo.isCompleted)
                    
                    HStack(spacing: 12) {
                        if let dueDate = todo.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 11))
                                Text(dueDate, style: .relative)
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(isOverdue(dueDate) && !todo.isCompleted ? Color(hex: "EF4444") : .secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: todo.priority.color))
                                .frame(width: 6, height: 6)
                            Text(todo.priority.displayName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: todo.priority.color))
                        }
                        
                        if !todo.category.isEmpty {
                            Text(todo.category)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        return date < Date()
    }
}

// MARK: - 推荐活动卡片
struct RecommendedEventCard: View {
    @EnvironmentObject var loc: LocalizationService
    let event: UCLAPIViewModel.UCLAPIEvent

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = "M月d日"
        return dateFormatter.string(from: event.startTime)
    }
    
    var formattedTime: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let start = timeFormatter.string(from: event.startTime)
        let end = timeFormatter.string(from: event.endTime)
        return "\(start) - \(end)"
    }
    
    var activityTypeIcon: String {
        guard let type = event.activityType else { return "star.fill" }
        switch type.lowercased() {
        case "academic", "lecture", "seminar":
            return "graduationcap.fill"
        case "cultural", "art", "exhibition":
            return "paintpalette.fill"
        case "sport", "fitness":
            return "figure.run"
        case "club", "society":
            return "person.3.fill"
        case "workshop":
            return "hammer.fill"
        default:
            return "star.fill"
        }
    }
    
    var activityTypeColor: Color {
        guard let type = event.activityType else { return Color(hex: "F59E0B") }
        switch type.lowercased() {
        case "academic", "lecture", "seminar":
            return Color(hex: "6366F1")
        case "cultural", "art", "exhibition":
            return Color(hex: "EC4899")
        case "sport", "fitness":
            return Color(hex: "10B981")
        case "club", "society":
            return Color(hex: "8B5CF6")
        case "workshop":
            return Color(hex: "F59E0B")
        default:
            return Color(hex: "F59E0B")
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // 左侧图标
            ZStack {
                Circle()
                    .fill(activityTypeColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: activityTypeIcon)
                    .font(.system(size: 20))
                    .foregroundColor(activityTypeColor)
            }
            
            // 中间内容
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    // 日期
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(formattedDate)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    // 时间
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(formattedTime)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                // 地点
                if !event.location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(event.location)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // 右侧推荐标签
            VStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "F59E0B"))


                Text(loc.language == .chinese ? "推荐" : "Rec.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "F59E0B"))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            activityTypeColor.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(activityTypeColor.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}
