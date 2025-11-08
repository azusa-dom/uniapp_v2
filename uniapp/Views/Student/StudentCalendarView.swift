//
//  StudentCalendarView.swift
//  uniapp
//
//  Created on 2024.
//  ✨ 重新设计 - 现代化日历视图，整合 UCL 活动
//

import SwiftUI
import EventKit

// MARK: - 枚举定义（在文件顶部）

/// 提醒时间枚举
enum ReminderTime: String, CaseIterable, Identifiable {
    case fiveMin = "5分钟前"
    case fifteenMin = "15分钟前"
    case thirtyMin = "30分钟前"
    case oneHour = "1小时前"
    case oneDay = "1天前"
    
    var id: String { rawValue }
    
    var minutes: Int {
        switch self {
        case .fiveMin: return 5
        case .fifteenMin: return 15
        case .thirtyMin: return 30
        case .oneHour: return 60
        case .oneDay: return 1440
        }
    }
}

/// 日历视图模式枚举
enum CalendarViewMode: String, CaseIterable, Identifiable {
    case month = "月视图"
    case week = "周视图"
    case day = "日视图"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        case .day: return "calendar.badge.clock"
        }
    }
}

// MARK: - 主视图
struct StudentCalendarView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = UCLAPIViewModel()
    @StateObject private var activitiesService = UCLActivitiesService()
    
    @State private var selectedDate = Date()
    @State private var viewMode: CalendarViewMode = .day
    @State private var showingAddEventSheet = false
    @State private var showingSettings = false  // ✅ 新增
    @State private var showingActivityDetail: UCLActivity?
    @State private var defaultReminderTime: ReminderTime = .fifteenMin  // ✅ 新增
    @State private var defaultViewMode: CalendarViewMode = .month  // ✅ 新增
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
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
                        // 顶部控制栏
                        topControlBar
                        
                        // 日历视图切换
                        calendarViewSection
                        
                        // 今日概览卡片
                        todayOverviewCard
                        
                        // 今日日程
                        todayScheduleSection
                        
                        // UCL 校园活动
                        uclActivitiesSection
                        
                        // 本周推荐
                        weeklyRecommendationsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .sheet(isPresented: $showingAddEventSheet) {
                AddEventSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSettings) {  // ✅ 新增
                CalendarSettingsView(
                    defaultReminderTime: $defaultReminderTime,
                    defaultViewMode: $defaultViewMode
                )
            }
            .sheet(item: $showingActivityDetail) { activity in
                ActivityDetailSheet(activity: activity, service: activitiesService)
            }
            .onAppear {
                loadData()
            }
        }
    }
    
    // MARK: - 顶部控制栏
    private var topControlBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("日历")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(formattedDateString(selectedDate))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // ✅ 设置按钮（新增）
            Button(action: { showingSettings = true }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "6366F1"))
                }
            }
            
            // 添加按钮
            Button(action: { showingAddEventSheet = true }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color(hex: "6366F1").opacity(0.4), radius: 12, x: 0, y: 4)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - 日历视图切换
    private var calendarViewSection: some View {
        VStack(spacing: 16) {
            // 视图模式选择器
            HStack(spacing: 12) {
                ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                    Button(action: { withAnimation(.spring(response: 0.3)) { viewMode = mode } }) {
                        HStack(spacing: 6) {
                            Image(systemName: mode.icon)
                                .font(.system(size: 14))
                            Text(mode.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(viewMode == mode ? .white : Color(hex: "6366F1"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Group {
                                if viewMode == mode {
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
                        .shadow(color: viewMode == mode ? Color(hex: "6366F1").opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                    }
                }
            }
            
            // 日历视图内容
            Group {
                switch viewMode {
                case .month:
                    ModernMonthView(selectedDate: $selectedDate)
                case .week:
                    ModernWeekView(selectedDate: $selectedDate)
                case .day:
                    ModernDayView(selectedDate: $selectedDate)
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
    
    // MARK: - 今日概览卡片
    private var todayOverviewCard: some View {
        let todayEvents = viewModel.events.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
        let todayActivities = activitiesService.activities.filter { activity in
            guard let activityDate = parseActivityDate(activity.date) else { return false }
            return Calendar.current.isDate(activityDate, inSameDayAs: selectedDate)
        }
        let todayTodos = appState.todoManager.todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return Calendar.current.isDate(dueDate, inSameDayAs: selectedDate)
        }
        
        return HStack(spacing: 16) {
            OverviewStatCard(
                title: "日程",
                count: todayEvents.count,
                icon: "calendar",
                color: "6366F1"
            )
            
            OverviewStatCard(
                title: "活动",
                count: todayActivities.count,
                icon: "sparkles",
                color: "8B5CF6"
            )
            
            OverviewStatCard(
                title: "待办",
                count: todayTodos.count,
                icon: "checkmark.circle",
                color: "10B981"
            )
        }
    }
    
    // MARK: - 今日日程
    private var todayScheduleSection: some View {
        let todayEvents = viewModel.events.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
        
        return VStack(alignment: .leading, spacing: 16) {
            if !todayEvents.isEmpty {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "6366F1"))
                    
                    Text("今日日程")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(todayEvents.count) 项")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    ForEach(todayEvents) { event in
                        ModernEventCard(event: event, viewModel: viewModel)
                    }
                }
            }
        }
    }
    
    // MARK: - UCL 校园活动
    private var uclActivitiesSection: some View {
        let todayActivities = activitiesService.activities.filter { activity in
            guard let activityDate = parseActivityDate(activity.date) else { return false }
            return Calendar.current.isDate(activityDate, inSameDayAs: selectedDate)
        }
        
        return VStack(alignment: .leading, spacing: 16) {
            if !todayActivities.isEmpty {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "8B5CF6"))
                    
                    Text("UCL 校园活动")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        // 跳转到活动页面
                    }) {
                        HStack(spacing: 4) {
                            Text("查看全部")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Color(hex: "8B5CF6"))
                    }
                }
                
                VStack(spacing: 12) {
                    ForEach(todayActivities) { activity in
                        ModernActivityCard(activity: activity, service: activitiesService) {
                            showingActivityDetail = activity
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 本周推荐
    private var weeklyRecommendationsSection: some View {
        let weeklyActivities = getWeeklyRecommendations()
        
        return VStack(alignment: .leading, spacing: 16) {
            if !weeklyActivities.isEmpty {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "8B5CF6"))
                    
                    Text("本周推荐")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(weeklyActivities) { activity in
                            WeeklyRecommendationCard(activity: activity, service: activitiesService) {
                                showingActivityDetail = activity
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 辅助方法
    private func loadData() {
        if viewModel.events.isEmpty {
            viewModel.fetchEvents()
        }
        if activitiesService.activities.isEmpty {
            activitiesService.loadActivities()
        }
    }
    
    private func formattedDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: loc.language == .chinese ? "zh_CN" : "en_US")
        formatter.dateFormat = loc.language == .chinese ? "M月d日 EEEE" : "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func parseActivityDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        if let date = formatter.date(from: dateString) {
            return date
        }

        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    private func getWeeklyRecommendations() -> [UCLActivity] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
        return activitiesService.activities.filter { activity in
            guard let activityDate = parseActivityDate(activity.date) else { return false }
            return activityDate >= startOfWeek && activityDate < endOfWeek
        }.prefix(5).map { $0 }
    }
}

// MARK: - ✅ 日历设置视图（新增）
struct CalendarSettingsView: View {
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    @Binding var defaultReminderTime: ReminderTime
    @Binding var defaultViewMode: CalendarViewMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(loc.tr("calendar_reminder_time"))) {
                    Picker("提醒时间", selection: $defaultReminderTime) {
                        ForEach(ReminderTime.allCases) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text(loc.tr("calendar_default_view"))) {
                    Picker("默认视图", selection: $defaultViewMode) {
                        ForEach(CalendarViewMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("通知设置")) {
                    HStack {
                        Text("事件提醒")
                        Spacer()
                        Text(defaultReminderTime.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("每日摘要", isOn: .constant(true))
                }
                
                Section(header: Text("显示设置")) {
                    Toggle("显示邮件日程", isOn: .constant(true))
                    Toggle("显示待办事项", isOn: .constant(true))
                    Toggle("显示UCL活动", isOn: .constant(true))
                }
            }
            .navigationTitle(loc.tr("calendar_settings"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(loc.tr("done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 概览统计卡片
struct OverviewStatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: color))
            }
            
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - 现代化事件卡片
struct ModernEventCard: View {
    let event: UCLAPIViewModel.UCLAPIEvent
    @ObservedObject var viewModel: UCLAPIViewModel
    @State private var showingAddSuccess = false
    
    var body: some View {
        HStack(spacing: 16) {
            // 时间指示器
            VStack(spacing: 4) {
                Text(event.startTime, style: .time)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Rectangle()
                    .fill(Color(hex: "6366F1").opacity(0.3))
                    .frame(width: 2, height: 30)
                
                Text(event.endTime, style: .time)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            // 内容区域
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6366F1"))
                    
                    Text(event.location)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                // 类型标签 - 课程和日程不显示"加入日历"按钮
                HStack(spacing: 8) {
                    Text(event.type == .api ? "课程" : "手动添加")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(event.type == .api ? Color(hex: "6366F1") : Color(hex: "8B5CF6"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill((event.type == .api ? Color(hex: "6366F1") : Color(hex: "8B5CF6")).opacity(0.15))
                        )
                    
                    // 课程不需要"加入日历"按钮，因为已经在日历中
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "6366F1").opacity(0.2), lineWidth: 1)
        )
        .alert("已添加", isPresented: $showingAddSuccess) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("活动已成功添加到您的日历")
        }
    }
}

// MARK: - 现代化活动卡片
struct ModernActivityCard: View {
    let activity: UCLActivity
    let service: UCLActivitiesService
    let onTap: () -> Void
    @State private var showingAddSuccess = false
    
    var body: some View {
        HStack(spacing: 16) {
            // 时间指示器
            VStack(spacing: 4) {
                Text(service.formatTime(activity.startTime))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "8B5CF6"))
                
                if !activity.endTime.isEmpty {
                    Rectangle()
                        .fill(Color(hex: "8B5CF6").opacity(0.3))
                        .frame(width: 2, height: 20)
                    
                    Text(service.formatTime(activity.endTime))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
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
                            .foregroundColor(Color(hex: "8B5CF6"))
                        
                        Text(location)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // 类型标签 + 加入日历按钮（校园活动可以选择是否加入）
                HStack(spacing: 8) {
                    Text(service.getTypeLabel(activity.type))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(service.getTypeColor(activity.type))
                        )
                    
                    Button(action: {
                        addActivityToCalendar()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 10))
                            Text("加入日历")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(hex: "10B981"))
                        )
                    }
                }
            }
            
            Spacer()
            
            Button(action: onTap) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(service.getTypeColor(activity.type).opacity(0.3), lineWidth: 1)
        )
        .alert("已添加", isPresented: $showingAddSuccess) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("活动已成功添加到您的日历")
        }
    }
    
    private func addActivityToCalendar() {
        // TODO: 实现添加到系统日历的逻辑
        showingAddSuccess = true
    }
}

// MARK: - 本周推荐卡片
struct WeeklyRecommendationCard: View {
    let activity: UCLActivity
    let service: UCLActivitiesService
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // 日期标签
                HStack {
                    Text(activity.date)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "8B5CF6"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(hex: "8B5CF6").opacity(0.15))
                        )
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "8B5CF6"))
                }
                
                // 标题
                Text(activity.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(height: 44, alignment: .topLeading)
                
                // 位置
                if let location = activity.location {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "8B5CF6"))
                        
                        Text(location)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // 类型标签
                Text(service.getTypeLabel(activity.type))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(service.getTypeColor(activity.type))
                    )
            }
            .frame(width: 220)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "8B5CF6").opacity(0.3), Color(hex: "8B5CF6").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 现代化月视图
struct ModernMonthView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(spacing: 0) {
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .tint(Color(hex: "6366F1"))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - 现代化周视图
struct ModernWeekView: View {
    @Binding var selectedDate: Date
    
    private var daysInWeek: [Date] {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        var dates: [Date] = []
        var currentDate = weekInterval.start
        while currentDate < weekInterval.end {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(daysInWeek, id: \.self) { date in
                    VStack(spacing: 8) {
                        Text(date.formatted(.dateTime.weekday(.short)))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(date.formatted(.dateTime.day()))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                            .frame(width: 44, height: 44)
                            .background(
                                Group {
                                    if Calendar.current.isDate(date, inSameDayAs: selectedDate) {
                                        LinearGradient(
                                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    } else if Calendar.current.isDateInToday(date) {
                                        Color(hex: "6366F1").opacity(0.15)
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .clipShape(Circle())
                            .shadow(
                                color: Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color(hex: "6366F1").opacity(0.4) : .clear,
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDate = date
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - 现代化日视图
struct ModernDayView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(hex: "6366F1").opacity(0.1))
                        )
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(selectedDate.formatted(.dateTime.month(.wide)))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(selectedDate.formatted(.dateTime.day()))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "6366F1"))
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(hex: "6366F1").opacity(0.1))
                        )
                }
            }
            
            // 今天按钮
            if !Calendar.current.isDateInToday(selectedDate) {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDate = Date()
                    }
                }) {
                    Text("返回今天")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color(hex: "6366F1").opacity(0.1))
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - 添加事件表单（新增）
struct AddEventSheet: View {
    @ObservedObject var viewModel: UCLAPIViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var eventTitle = ""
    @State private var eventLocation = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var reminderTime: ReminderTime = .fifteenMin
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("事件详情")) {
                    TextField("事件标题", text: $eventTitle)
                    TextField("地点", text: $eventLocation)
                }
                
                Section(header: Text("时间")) {
                    DatePicker("开始时间", selection: $startDate)
                    DatePicker("结束时间", selection: $endDate)
                }
                
                Section(header: Text("提醒")) {
                    Picker("提醒时间", selection: $reminderTime) {
                        ForEach(ReminderTime.allCases) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                }
            }
            .navigationTitle("添加事件")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button("保存") {
                        let newEvent = UCLAPIViewModel.UCLAPIEvent(
                            id: UUID(),
                            title: eventTitle,
                            startTime: startDate,
                            endTime: endDate,
                            location: eventLocation,
                            type: .manual
                        )
                        
                        viewModel.events.append(newEvent)
                        dismiss()
                    }
                    .disabled(eventTitle.isEmpty)
                }
            }
        }
    }
}

// MARK: - 信息行组件（新增）
struct InfoRow: View {
    let icon: String
    let title: String
    let content: String
    let color: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: color))
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: color).opacity(0.1))
        )
    }
}

// MARK: - 活动详情弹窗
struct ActivityDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let activity: UCLActivity
    let service: UCLActivitiesService
    
    @State private var eventStore = EKEventStore()
    @State private var showingAddSuccess = false
    @State private var showingAddError = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 头部图片区域
                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        service.getTypeColor(activity.type).opacity(0.6),
                                        service.getTypeColor(activity.type)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 200)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(service.getTypeLabel(activity.type))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.3))
                                )
                            
                            Text(activity.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(20)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // 时间信息
                        InfoRow(
                            icon: "clock.fill",
                            title: "时间",
                            content: "\(service.formatTime(activity.startTime))\(activity.endTime.isEmpty ? "" : " - \(service.formatTime(activity.endTime))")",
                            color: "6366F1"
                        )
                        
                        // 日期信息
                        InfoRow(
                            icon: "calendar",
                            title: "日期",
                            content: activity.date,
                            color: "8B5CF6"
                        )
                        
                        // 地点信息
                        if let location = activity.location {
                            InfoRow(
                                icon: "mappin.circle.fill",
                                title: "地点",
                                content: location,
                                color: "8B5CF6"
                            )
                        }
                        
                        // 描述
                        if let description = activity.description {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "text.alignleft")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "10B981"))
                                    
                                    Text("活动详情")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                
                                Text(description)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "10B981").opacity(0.1))
                            )
                        }
                        
                        // 加入日历按钮
                        Button(action: {
                            Task {
                                await addToCalendar()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 16))
                                Text("加入日历")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .navigationTitle("活动详情")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("关闭") {
                            dismiss()
                        }
                    }
                }
                .alert("添加成功", isPresented: $showingAddSuccess) {
                    Button("确定", role: .cancel) { }
                } message: {
                    Text("活动已成功添加到您的日历")
                }
                .alert("添加失败", isPresented: $showingAddError) {
                    Button("确定", role: .cancel) { }
                } message: {
                    Text("无法添加活动到日历，请检查权限设置")
                }
            }
        }
    }
    
    // 添加到日历方法
    func addToCalendar() async {
        // 请求日历访问权限
        if #available(macOS 14.0, iOS 17.0, *) {
            let status = EKEventStore.authorizationStatus(for: .event)
            
            if status == .notDetermined {
                let granted = try? await eventStore.requestFullAccessToEvents()
                if granted != true {
                    showingAddError = true
                    return
                }
            } else if status != .fullAccess {
                showingAddError = true
                return
            }
        } else {
            let status = EKEventStore.authorizationStatus(for: .event)
            
            if status == .notDetermined {
                let granted = try? await eventStore.requestAccess(to: .event)
                if granted != true {
                    showingAddError = true
                    return
                }
            } else if status != .authorized {
                showingAddError = true
                return
            }
        }
        
        // 创建事件
        let event = EKEvent(eventStore: eventStore)
        event.title = activity.title
        
        // 解析日期和时间
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        
        if var date = formatter.date(from: activity.date) {
            // 解析开始时间
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            
            if let startTime = timeFormatter.date(from: service.formatTime(activity.startTime)) {
                let calendar = Calendar.current
                let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
                date = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: date) ?? date
                event.startDate = date
                
                // 解析结束时间
                if !activity.endTime.isEmpty, let endTime = timeFormatter.date(from: service.formatTime(activity.endTime)) {
                    let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
                    let endDate = calendar.date(bySettingHour: endComponents.hour ?? 0, minute: endComponents.minute ?? 0, second: 0, of: date) ?? date
                    event.endDate = endDate
                } else {
                    // 默认持续1小时
                    event.endDate = date.addingTimeInterval(3600)
                }
            } else {
                event.startDate = date
                event.endDate = date.addingTimeInterval(3600)
            }
        } else {
            // 如果日期解析失败，使用当前日期
            event.startDate = Date()
            event.endDate = Date().addingTimeInterval(3600)
        }
        
        // 设置地点
        if let location = activity.location {
            event.location = location
        }
        
        // 设置描述
        if let description = activity.description {
            event.notes = description
        }
        
        // 添加到日历
        do {
            try eventStore.save(event, span: .thisEvent)
            showingAddSuccess = true
        } catch {
            showingAddError = true
        }
    }
}

