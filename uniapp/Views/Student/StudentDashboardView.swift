//
//  StudentDashboardView.swift (极致美观版)
//  uniapp
//

import SwiftUI

// MARK: - Consistent Purple Palette
enum DashboardPalette {
    static let deep = Color(hex: "5B21B6")
    static let medium = Color(hex: "7C3AED")
    static let bright = Color(hex: "9F7AEA")
    static let soft = Color(hex: "C4B5FD")
    static let pastel = Color(hex: "E9D5FF")
}

enum DashboardPaletteHex {
    static let deep = "5B21B6"
    static let medium = "7C3AED"
    static let bright = "9F7AEA"
    static let soft = "C4B5FD"
    static let pastel = "E9D5FF"
}

// MARK: - 学生首页主视图
struct StudentDashboardView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @StateObject private var activitiesService = UCLActivitiesService()
    @StateObject private var timetableVM = TimetableViewModel()
    
    @Binding var selectedTab: Int
    
    @State private var activeModal: DashboardModal?
    @State private var showingLogoutAlert = false
    @State private var selectedActivity: UCLActivity?
    @State private var showingActivityDetail = false
    @State private var showingCampusActivities = false
    
    private var pinnedActivities: [UCLActivity] {
        Array(activitiesService.activities.prefix(3))
    }
    
    private enum DashboardModal: Identifiable {
        case todo(TodoItem)
        case profile
        case avatar
        case settings
        case todoList
        case addTodo
        case courseDetail
        
        var id: String {
            switch self {
            case .todo(let todo): return "todo-\(todo.id.uuidString)"
            case .profile: return "profile"
            case .avatar: return "avatar"
            case .settings: return "settings"
            case .todoList: return "todoList"
            case .addTodo: return "addTodo"
            case .courseDetail: return "courseDetail"
            }
        }
    }
    
    private var todayClasses: [TodayClass] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let isChinese = loc.language == .chinese
        return timetableVM.todayEvents.map { e in
            TodayClass(
                name: e.localizedTitle(isChinese: isChinese),
                code: e.courseCode,
                time: "\(formatter.string(from: e.startTime)) - \(formatter.string(from: e.endTime))",
                location: e.localizedLocation(isChinese: isChinese),
                lecturer: e.localizedInstructor(isChinese: isChinese)
            )
        }
    }
    
    private var highlightedTodos: [TodoItem] {
        let active = appState.todoManager.todos.filter { !$0.isCompleted }
        let sorted = active.sorted { lhs, rhs in
            let lhsDate = lhs.dueDate ?? Date.distantFuture
            let rhsDate = rhs.dueDate ?? Date.distantFuture
            return lhsDate < rhsDate
        }
        var source = sorted
        if source.isEmpty {
            source = appState.todoManager.todos
        }
        return Array(source.prefix(3))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 更柔和的背景渐变
                LinearGradient(
                    colors: [
                        Color(hex: "F8F9FF"),
                        Color(hex: "EEF2FF")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 16) {
                        // 欢迎卡片
                        welcomeCard
                        
                        // 2x2 快速入口网格
                        quickActionsGrid
                        
                        // 今日课程
                        todayClassesSection
                        
                        // 即将截止
                        upcomingDeadlinesSection
                        
                        // 推荐活动
                        recommendationsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .sheet(item: $activeModal) { modal in
                    modalView(for: modal)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("首页")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // 设置按钮
                        Button {
                            activeModal = .settings
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 36, height: 36)
                                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                                
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "6366F1"))
                            }
                        }
                        
                        // 用户菜单（去掉“切换至家长端”）
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
                            Button(role: .destructive) {
                                showingLogoutAlert = true
                            } label: {
                                Label(loc.tr("profile_logout"), systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                    .shadow(color: Color(hex: "6366F1").opacity(0.25), radius: 8, x: 0, y: 2)
                                
                                Image(systemName: appState.avatarIcon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
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
    
    // MARK: - Modal View Builder
    @ViewBuilder
    private func modalView(for modal: DashboardModal) -> some View {
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
        case .todoList:
            StudentTodoListSheet()
                .environmentObject(appState)
        case .addTodo:
            AddTodoView()
                .environmentObject(appState)
                .environmentObject(loc)
        case .courseDetail:
            EmptyView()
        }
    }
    
    // MARK: - Welcome Card (精致版)
    private var welcomeCard: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: [
                    Color(hex: "6366F1"),
                    Color(hex: "8B5CF6")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            VStack(alignment: .leading, spacing: 14) {
                // 问候语
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("今天也是元气满满的一天呢, Zoya 👋")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("MSc Health Data Science")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    Spacer()
                }
            }
            .padding(20)
        }
        .frame(height: 100)
        .shadow(color: Color(hex: "6366F1").opacity(0.2), radius: 12, x: 0, y: 6)
    }
    
    private func miniStatChip(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            
            VStack(alignment: .leading, spacing: -2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.18))
        )
    }
    
    // MARK: - Quick Actions Grid (2x2精致网格)
    private var quickActionsGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                PremiumQuickActionCard(
                    icon: "sparkles",
                    title: "AI助手",
                    subtitle: "智能学习助理",
                    gradient: [DashboardPalette.deep, DashboardPalette.medium],
                    iconColor: .white
                ) {
                    selectedTab = 3  // AI 助手 tab
                }
                
                PremiumQuickActionCard(
                    icon: "envelope.fill",
                    title: "邮箱",
                    subtitle: "查看最新邮件",
                    gradient: [DashboardPalette.medium, DashboardPalette.bright],
                    iconColor: .white
                ) {
                    selectedTab = 5  // 邮箱 tab
                }
            }
            .frame(height: 100)
            
            HStack(spacing: 10) {
                PremiumQuickActionCard(
                    icon: "heart.text.square.fill",
                    title: "健康",
                    subtitle: "预约GP问诊",
                    gradient: [DashboardPalette.bright, DashboardPalette.soft],
                    iconColor: .white
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = 4  // 健康 tab
                    }
                }
                
                PremiumQuickActionCard(
                    icon: "calendar.badge.plus",
                    title: "活动",
                    subtitle: "发现精彩活动",
                    gradient: [DashboardPalette.soft, DashboardPalette.pastel],
                    iconColor: .white
                ) {
                    showingCampusActivities = true
                }
            }
            .frame(height: 100)
        }
    }
    
    // MARK: - Today's Classes Section
    private var todayClassesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                    
                    Text("今日课程")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { Task { _ = try? await CalendarImportService.shared.importTimetableEvents(MockData.timetableEvents, alarmMinutesBefore: 15) } }) {
                        HStack(spacing: 5) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("导入日历")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "6366F1"))
                    }
                    Button {
                        selectedTab = 1  // 切换到日历标签页
                    } label: {
                        Text("查看全部")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }
            
            if todayClasses.isEmpty {
                StudentEmptyStateCard(
                    icon: "checkmark.circle.fill",
                    message: "今天没有课程，好好利用这段时间！",
                    color: DashboardPaletteHex.soft
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(todayClasses) { classItem in
                        Button {
                            selectedTab = 1  // 切换到日历标签页
                        } label: {
                            PremiumClassCard(classItem: classItem)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Upcoming Deadlines Section
    private var upcomingDeadlinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DashboardPalette.bright)
                    
                    Text("即将截止")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button {
                    activeModal = .addTodo
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("添加")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "6366F1").opacity(0.25), radius: 6, x: 0, y: 3)
                }
            }
            
            if highlightedTodos.isEmpty {
                StudentEmptyStateCard(
                    icon: "checkmark.circle.fill",
                    message: "暂无待办事项，所有任务都已完成！",
                    color: DashboardPaletteHex.soft
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(highlightedTodos) { todo in
                        PremiumDeadlineCard(todo: todo)
                            .onTapGesture {
                                activeModal = .todo(todo)
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - Recommendations Section
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DashboardPalette.bright)
                    
                    Text("推荐活动")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if !pinnedActivities.isEmpty {
                    NavigationLink {
                        CampusActivitiesView()
                            .environmentObject(loc)
                    } label: {
                        Text("查看全部")
                            .font(.system(size: 13, weight: .semibold))
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
                    color: "9F7AEA"
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(pinnedActivities) { activity in
                        NavigationLink {
                            CampusActivitiesView()
                                .environmentObject(loc)
                        } label: {
                            PremiumActivityCard(activity: activity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Premium Quick Action Card (精致版)
private struct PremiumQuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // 渐变背景
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                // 内容
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Spacer()
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(iconColor.opacity(0.3))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity)
            .shadow(color: gradient[0].opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Premium Class Card
private struct PremiumClassCard: View {
    @EnvironmentObject var loc: LocalizationService
    let classItem: TodayClass
    
    var body: some View {
        HStack(spacing: 12) {
            // 时间指示器
            VStack(spacing: 4) {
                Text(classItem.time.split(separator: "-").first?.trimmingCharacters(in: .whitespaces) ?? "")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Circle()
                    .fill(Color(hex: "6366F1"))
                    .frame(width: 4, height: 4)
                
                Text(classItem.time.split(separator: "-").last?.trimmingCharacters(in: .whitespaces) ?? "")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            // 课程信息
            VStack(alignment: .leading, spacing: 6) {
                Text(classItem.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(classItem.code)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color(hex: "6366F1").opacity(0.1))
                        .clipShape(Capsule())
                    
                    Text("·")
                        .foregroundColor(.secondary)
                    
                    Text(classItem.lecturer)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 5) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(DashboardPalette.bright)
                    
                    Text(classItem.location)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Premium Deadline Card
private struct PremiumDeadlineCard: View {
    let todo: TodoItem
    
    private var timeRemaining: String {
        guard let dueDate = todo.dueDate else { return "无截止" }
        
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
        guard let dueDate = todo.dueDate else { return DashboardPalette.soft }
        
        let interval = dueDate.timeIntervalSince(Date())
        
        if interval < 0 {
            return DashboardPalette.deep
        } else if interval < 86400 {
            return DashboardPalette.bright
        } else if interval < 259200 {
            return DashboardPalette.medium
        } else {
            return DashboardPalette.soft
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 优先级指示
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(urgencyColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "clock.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(urgencyColor)
            }
            
            // 任务信息
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(todo.category)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text("·")
                        .foregroundColor(.secondary)
                    
                    Text(timeRemaining)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(urgencyColor)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Premium Activity Card
private struct PremiumActivityCard: View {
    @EnvironmentObject var loc: LocalizationService
    let activity: UCLActivity
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 活动图标
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(getTypeColor(activity.type).opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: getTypeIcon(activity.type))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(getTypeColor(activity.type))
            }
            
            // 活动信息
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(activity.localizedTitle(isChinese: isChinese))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(activity.localizedType(isChinese: isChinese))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(getTypeColor(activity.type))
                        .clipShape(Capsule())
                }
                
                if let location = activity.localizedLocation(isChinese: isChinese) {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(DashboardPalette.bright)
                        
                        Text(location)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                if !activity.startTime.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "6366F1"))
                        
                        Text(formatTime(activity.startTime))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
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
    
    private func getTypeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "workshop": return "hammer.fill"
        case "seminar": return "person.3.fill"
        case "lecture": return "book.fill"
        case "social": return "party.popper.fill"
        case "sports": return "figure.run"
        case "career": return "briefcase.fill"
        case "cultural": return "theatermasks.fill"
        default: return "star.fill"
        }
    }
    
    private func getTypeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "workshop": return DashboardPalette.deep
        case "seminar": return DashboardPalette.medium
        case "lecture": return DashboardPalette.bright
        case "social": return DashboardPalette.soft
        case "sports": return DashboardPalette.medium
        case "career": return DashboardPalette.bright
        case "cultural": return DashboardPalette.pastel
        default: return DashboardPalette.medium
        }
    }

    private func localizedTypeLabel(_ raw: String) -> String {
        let key = raw.lowercased()
        if loc.language == .chinese {
            switch key {
            case "workshop": return "工作坊"
            case "seminar": return "研讨会"
            case "lecture": return "讲座"
            case "social": return "社交活动"
            case "sports": return "体育活动"
            case "career": return "职业发展"
            case "cultural": return "文化活动"
            default: return "活动"
            }
        } else {
            switch key {
            case "workshop": return "Workshop"
            case "seminar": return "Seminar"
            case "lecture": return "Lecture"
            case "social": return "Social"
            case "sports": return "Sports"
            case "career": return "Career"
            case "cultural": return "Cultural"
            default: return "Activity"
            }
        }
    }
}

// MARK: - Supporting Models & Views
struct TodayClass: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let time: String
    let location: String
    let lecturer: String
}

struct StudentEmptyStateCard: View {
    let icon: String
    let message: String
    let color: String
    
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.12))
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color(hex: color))
            }
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Todo List Sheet
private struct StudentTodoListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    private var activeTodos: [TodoItem] {
        appState.todoManager.todos
            .filter { !$0.isCompleted }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }
    
    private var completedTodos: [TodoItem] {
        appState.todoManager.todos
            .filter { $0.isCompleted }
            .sorted { $0.createdDate > $1.createdDate }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("未完成") {
                    if activeTodos.isEmpty {
                        Text("暂无未完成任务")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(activeTodos) { todo in
                            TodoListRow(
                                todo: todo,
                                toggle: toggle,
                                delete: delete
                            )
                        }
                    }
                }
                
                if !completedTodos.isEmpty {
                    Section("已完成") {
                        ForEach(completedTodos) { todo in
                            TodoListRow(
                                todo: todo,
                                toggle: toggle,
                                delete: delete
                            )
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("待办事项")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
    
    private func toggle(_ todo: TodoItem) {
        if let idx = appState.todoManager.todos.firstIndex(where: { $0.id == todo.id }) {
            appState.todoManager.todos[idx].isCompleted.toggle()
        }
    }
    
    private func delete(_ todo: TodoItem) {
        appState.todoManager.todos.removeAll { $0.id == todo.id }
    }
}

private struct TodoListRow: View {
    let todo: TodoItem
    let toggle: (TodoItem) -> Void
    let delete: (TodoItem) -> Void
    
    var body: some View {
        HStack {
            Button(action: { toggle(todo) }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? DashboardPalette.medium : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.subheadline.weight(.semibold))
                    .strikethrough(todo.isCompleted)
                
                Text(todo.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let due = todo.dueDate {
                    Text(due.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let due = todo.dueDate {
                Text(due, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("无截止")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                delete(todo)
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
}

// MARK: - Preview
struct StudentDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        StudentDashboardView(selectedTab: .constant(0))
            .environmentObject(AppState())
            .environmentObject(LocalizationService())
    }
}
