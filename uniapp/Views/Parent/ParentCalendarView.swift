
//
//  ParentCalendarView.swift
//  uniapp
//
//  Created on 2024.
//  ✨ 家长日历 - 查看孩子的日程安排
//

import SwiftUI
import EventKit

// MARK: - 主视图

struct ParentCalendarView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = UCLAPIViewModel()
    @StateObject private var activitiesService = UCLActivitiesService()
    
    @State private var selectedDate = Date()
    @State private var viewMode: CalendarViewMode = .day
    @State private var showingSettings = false
    @State private var showingEventDetail: UCLAPIViewModel.UCLAPIEvent?
    @State private var showingActivityDetail: UCLActivity?
    
    enum CalendarViewMode: String, CaseIterable {
        case month = "月"
        case week = "周"
        case day = "日"
        
        var icon: String {
            switch self {
            case .month: return "calendar"
            case .week: return "calendar.day.timeline.left"
            case .day: return "calendar.badge.clock"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [
                        Color(hex: "F8FAFC"),
                        Color(hex: "EEF2FF"),
                        Color(hex: "E0E7FF").opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if appState.shareCalendar {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // 顶部控制栏
                            topControlBar
                            
                            // 日历视图切换
                            calendarViewSection
                            
                            // 今日概览卡片
                            todayOverviewCard
                            
                            // 孩子的日程
                            studentScheduleSection
                            
                            // UCL 校园活动
                            uclActivitiesSection
                            
                            // 本周概览
                            weeklyOverviewSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                } else {
                    DataNotSharedView(dataType: loc.tr("data_sharing_calendar"))
                        .padding()
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .sheet(isPresented: $showingSettings) {
                ParentCalendarSettingsView()
            }
            .sheet(item: $showingEventDetail) { event in
                ParentEventDetailSheet(event: event)
            }
            .sheet(item: $showingActivityDetail) { activity in
                ActivityDetailSheet(activity: activity, service: activitiesService)
            }
            .onAppear {
                loadData()
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
    
    // MARK: - 顶部控制栏
    private var topControlBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("孩子的日历")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(formattedDateString(selectedDate))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 通知按钮
            Button(action: {
                // 查看通知
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "8B5CF6"))
                    
                    // 未读提示
                    Circle()
                        .fill(Color(hex: "7C3AED"))
                        .frame(width: 8, height: 8)
                        .offset(x: 12, y: -12)
                }
            }
            
            // 设置按钮
            Button(action: { showingSettings = true }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "8B5CF6"))
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
                        .foregroundColor(viewMode == mode ? .white : Color(hex: "8B5CF6"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Group {
                                if viewMode == mode {
                                    LinearGradient(
                                        colors: [Color(hex: "8B5CF6"), Color(hex: "7C3AED")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                } else {
                                    Color.white.opacity(0.8)
                                }
                            }
                        )
                        .clipShape(Capsule())
                        .shadow(color: viewMode == mode ? Color(hex: "8B5CF6").opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                    }
                }
            }
            
            // 日历视图内容
            Group {
                switch viewMode {
                case .month:
                    ParentMonthView(selectedDate: $selectedDate)
                case .week:
                    ParentWeekView(selectedDate: $selectedDate)
                case .day:
                    ParentDayView(selectedDate: $selectedDate)
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
            ParentOverviewStatCard(
                title: "课程",
                count: todayEvents.count,
                icon: "book.fill",
                color: "8B5CF6"
            )
            
            ParentOverviewStatCard(
                title: "活动",
                count: todayActivities.count,
                icon: "sparkles",
                color: "8B5CF6"
            )
            
            ParentOverviewStatCard(
                title: "作业",
                count: todayTodos.count,
                icon: "checkmark.circle",
                color: "10B981"
            )
        }
    }
    
    // MARK: - 孩子的日程
    private var studentScheduleSection: some View {
        let todayEvents = viewModel.events.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "8B5CF6"))
                
                Text("今日课程")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !todayEvents.isEmpty {
                    Text("\(todayEvents.count) 节")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            if todayEvents.isEmpty {
                EmptyStateCard(
                    icon: "calendar",
                    message: "今天没有安排课程",
                    color: "8B5CF6"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(todayEvents) { event in
                        ParentEventCard(event: event) {
                            showingEventDetail = event
                        }
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
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "8B5CF6"))
                
                Text("校园活动")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !todayActivities.isEmpty {
                    Text("\(todayActivities.count) 项")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            if todayActivities.isEmpty {
                EmptyStateCard(
                    icon: "sparkles",
                    message: "今天没有校园活动",
                    color: "8B5CF6"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(todayActivities) { activity in
                        ParentActivityCard(activity: activity, service: activitiesService) {
                            showingActivityDetail = activity
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 本周概览
    private var weeklyOverviewSection: some View {
        let weeklyStats = getWeeklyStats()
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "10B981"))
                
                Text("本周概览")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                WeeklyStatRow(
                    icon: "book.fill",
                    title: "本周课程",
                    count: weeklyStats.courses,
                    color: "8B5CF6"
                )
                
                WeeklyStatRow(
                    icon: "sparkles",
                    title: "本周活动",
                    count: weeklyStats.activities,
                    color: "8B5CF6"
                )
                
                WeeklyStatRow(
                    icon: "checkmark.circle",
                    title: "待完成作业",
                    count: weeklyStats.todos,
                    color: "10B981"
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
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
    
    private func getWeeklyStats() -> (courses: Int, activities: Int, todos: Int) {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)),
              let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else {
            return (0, 0, 0)
        }
        
        let courses = viewModel.events.filter { $0.startTime >= startOfWeek && $0.startTime < endOfWeek }.count
        let activities = activitiesService.activities.filter { activity in
            guard let activityDate = parseActivityDate(activity.date) else { return false }
            return activityDate >= startOfWeek && activityDate < endOfWeek
        }.count
        let todos = appState.todoManager.todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return dueDate >= startOfWeek && dueDate < endOfWeek && !todo.isCompleted
        }.count
        
        return (courses, activities, todos)
    }
}

// MARK: - 家长概览统计卡片

struct ParentOverviewStatCard: View {
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

// MARK: - 家长事件卡片

struct ParentEventCard: View {
    let event: UCLAPIViewModel.UCLAPIEvent
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 时间指示器
                VStack(spacing: 4) {
                    Text(event.startTime, style: .time)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "8B5CF6"))
                    
                    Rectangle()
                        .fill(Color(hex: "8B5CF6").opacity(0.3))
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
                            .foregroundColor(Color(hex: "8B5CF6"))
                        
                        Text(event.location)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    // 状态标签
                    HStack(spacing: 8) {
                        Text(event.type == .api ? "课程" : "活动")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "8B5CF6"))
                            )
                        
                        // 时间状态
                        if event.startTime > Date() {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10))
                                Text("即将开始")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(Color(hex: "10B981"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "10B981").opacity(0.15))
                            )
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "8B5CF6").opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 家长活动卡片

struct ParentActivityCard: View {
    let activity: UCLActivity
    let service: UCLActivitiesService
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(service.getTypeColor(activity.type).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(service.getTypeColor(activity.type))
                }
                
                // 内容区域
                VStack(alignment: .leading, spacing: 8) {
                    Text(activity.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                            Text(service.formatTime(activity.startTime))
                                .font(.system(size: 13))
                        }
                        .foregroundColor(.secondary)
                        
                        if let location = activity.location {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 11))
                                Text(location)
                                    .font(.system(size: 13))
                                    .lineLimit(1)
                            }
                            .foregroundColor(.secondary)
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
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 空状态卡片

struct EmptyStateCard: View {
    let icon: String
    let message: String
    let color: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(Color(hex: color).opacity(0.4))
            
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: color).opacity(0.2), lineWidth: 1.5)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                )
        )
    }
}

// MARK: - 本周统计行

struct WeeklyStatRow: View {
    let icon: String
    let title: String
    let count: Int
    let color: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: color))
            }
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: color))
        }
    }
}

// MARK: - 家长月视图

struct ParentMonthView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var viewModel: UCLAPIViewModel
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["日", "一", "二", "三", "四", "五", "六"]
    
    private var monthDates: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var dates: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while dates.count < 42 { // 6 周
            if calendar.isDate(currentDate, equalTo: selectedDate, toGranularity: .month) {
                dates.append(currentDate)
            } else {
                dates.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private func hasEvents(on date: Date) -> Bool {
        viewModel.events.contains { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 月份选择器
            HStack {
                Button(action: {
                    if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDate = newDate
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "8B5CF6"))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color(hex: "8B5CF6").opacity(0.1)))
                }
                
                Spacer()
                
                Text(selectedDate.formatted(.dateTime.year().month(.wide)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDate = newDate
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "8B5CF6"))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color(hex: "8B5CF6").opacity(0.1)))
                }
            }
            .padding(.horizontal, 8)
            
            // 星期标题
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            
            // 日期网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(0..<42, id: \.self) { index in
                    if let date = monthDates[index] {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                            }
                        }) {
                            VStack(spacing: 4) {
                                Text(calendar.component(.day, from: date).description)
                                    .font(.system(size: 16, weight: calendar.isDate(date, inSameDayAs: selectedDate) ? .bold : .medium))
                                    .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                                
                                // 事件指示器小点
                                if hasEvents(on: date) {
                                    Circle()
                                        .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.white : Color(hex: "8B5CF6"))
                                        .frame(width: 4, height: 4)
                                } else {
                                    Spacer().frame(height: 4)
                                }
                            }
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(
                                Group {
                                    if calendar.isDate(date, inSameDayAs: selectedDate) {
                                        LinearGradient(
                                            colors: [Color(hex: "8B5CF6"), Color(hex: "7C3AED")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    } else if calendar.isDateInToday(date) {
                                        Color(hex: "8B5CF6").opacity(0.1)
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Color.clear.frame(height: 44)
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
    }
}

// MARK: - 家长周视图

struct ParentWeekView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var viewModel: UCLAPIViewModel
    
    private var daysInWeek: [Date] {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        var dates: [Date] = []
        var currentDate = weekInterval.start
        while currentDate < weekInterval.end {
            dates.append(currentDate)
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        return dates
    }
    
    private func hasEvents(on date: Date) -> Bool {
        viewModel.events.contains { event in
            Calendar.current.isDate(event.startTime, inSameDayAs: date)
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(daysInWeek, id: \.self) { date in
                    VStack(spacing: 8) {
                        Text(date.formatted(.dateTime.weekday(.short)))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        ZStack(alignment: .bottom) {
                            Text(date.formatted(.dateTime.day()))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                                .frame(width: 44, height: 44)
                                .background(
                                    Group {
                                        if Calendar.current.isDate(date, inSameDayAs: selectedDate) {
                                            LinearGradient(
                                                colors: [Color(hex: "8B5CF6"), Color(hex: "7C3AED")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        } else if Calendar.current.isDateInToday(date) {
                                            Color(hex: "8B5CF6").opacity(0.15)
                                        } else {
                                            Color.clear
                                    }
                                        }
                                    }
                                )
                                .clipShape(Circle())
                                .shadow(
                                    color: Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color(hex: "8B5CF6").opacity(0.4) : .clear,
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            
                            // 事件指示器小点
                            if hasEvents(on: date) {
                                Circle()
                                    .fill(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.white : Color(hex: "8B5CF6"))
                                    .frame(width: 5, height: 5)
                                    .offset(y: 6)
                            }
                        }
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

// MARK: - 家长日视图

struct ParentDayView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDate = previousDay
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "8B5CF6"))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(hex: "8B5CF6").opacity(0.1))
                        )
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(selectedDate.formatted(.dateTime.day()))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(selectedDate.formatted(.dateTime.month(.wide)))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDate = nextDay
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "8B5CF6"))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(hex: "8B5CF6").opacity(0.1))
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

// MARK: - 家长事件详情

struct ParentEventDetailSheet: View {
    let event: UCLAPIViewModel.UCLAPIEvent
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 标题
                    Text(event.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // 时间信息
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(Color(hex: "8B5CF6"))
                            Text("开始时间")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(event.startTime, style: .time)
                                .fontWeight(.semibold)
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(Color(hex: "8B5CF6"))
                            Text("结束时间")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(event.endTime, style: .time)
                                .fontWeight(.semibold)
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(Color(hex: "8B5CF6"))
                            Text("地点")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(event.location)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "8B5CF6").opacity(0.1))
                    )
                    
                    // 描述
                    if let description = event.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("课程描述")
                                .font(.system(size: 18, weight: .semibold))
                            Text(description)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(24)
            }
            .background(Color(hex: "FFF8F0").ignoresSafeArea())
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
        }
    }
}

// MARK: - 家长日历设置

struct ParentCalendarSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var showWeekends = true
    @State private var syncWithDevice = true
    
    var body: some View {
        NavigationView {
            List {
                Section("通知设置") {
                    Toggle("启用通知", isOn: $notificationsEnabled)
                    Toggle("同步到设备日历", isOn: $syncWithDevice)
                }
                
                Section("显示设置") {
                    Toggle("显示周末", isOn: $showWeekends)
                }
            }
            .navigationTitle("日历设置")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct ParentCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ParentCalendarView()
            .environmentObject(LocalizationService())
            .environmentObject(AppState())
    }
}
