
//
//  学生日历.swift
//  uniappv3
//
//  Created by 748 on 12/11/2025.
//

//
//  StudentCalendarView.swift
//  uniapp

//

import SwiftUI
import EventKit

// MARK: - 枚举定义（在文件顶部）

/// 日历视图模式枚举
enum CalendarViewMode: String, CaseIterable, Identifiable {
    case month
    case week
    case day
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        case .day: return "calendar.badge.clock"
        }
    }
    
    func displayName(isChinese: Bool) -> String {
        switch self {
        case .month: return isChinese ? "月视图" : "Month"
        case .week: return isChinese ? "周视图" : "Week"
        case .day: return isChinese ? "日视图" : "Day"
        }
    }
}

enum DurationOption: String, CaseIterable, Identifiable {
    case halfHour = "30 分钟"
    case oneHour = "1 小时"
    case oneAndHalf = "90 分钟"
    case twoHours = "2 小时"
    case custom = "自定义"
    
    var id: String { rawValue }
    
    var minutes: Int? {
        switch self {
        case .halfHour: return 30
        case .oneHour: return 60
        case .oneAndHalf: return 90
        case .twoHours: return 120
        case .custom: return nil
        }
    }
}

// MARK: - 主视图
struct StudentCalendarView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = UCLAPIViewModel()
    @StateObject private var activitiesService = UCLActivitiesService()
    @StateObject private var timetableViewModel = TimetableViewModel()
    
    @State private var selectedDate = Date()
    @State private var viewMode: CalendarViewMode = .day
    @State private var showingAddEventSheet = false
    @State private var showingSettings = false  // ✅ 新增
    @State private var showingActivityDetail: UCLActivity?
    @State private var showingEventDetail: UCLAPIViewModel.UCLAPIEvent?
    @State private var selectedTodo: TodoItem?
    @State private var defaultReminderTime: ReminderTime = .fifteenMin  // ✅ 新增
    @State private var defaultViewMode: CalendarViewMode = .month  // ✅ 新增
    
    private var eventsForSelectedDate: [UCLAPIViewModel.UCLAPIEvent] {
        events(on: selectedDate)
    }
    
    var body: some View {
        NavigationStack {
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
                        
                        // 今日日程（所有视图模式都显示）
                        todayScheduleSection
                        
                        // 今日待办（所有视图模式都显示）
                        todayTodosSection
                        
                        // UCL 校园活动（所有视图模式都显示）
                        uclActivitiesSection
                        
                        // 本周推荐（所有视图模式都显示）
                        weeklyRecommendationsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .id(appState.todoManager.todos.count) // 强制刷新当 todos 变化时
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddEventSheet) {
                AddEventSheet(
                    viewModel: viewModel,
                    selectedDate: selectedDate,
                    defaultReminderTime: defaultReminderTime
                )
            }
            .sheet(isPresented: $showingSettings) {  // ✅ 新增
                CalendarSettingsView(
                    defaultReminderTime: $defaultReminderTime,
                    defaultViewMode: $defaultViewMode
                )
            }
            .sheet(item: $showingActivityDetail) { activity in
                ActivityDetailSheet(activity: activity, service: activitiesService)
                    .environmentObject(loc)
            }
            .sheet(item: $showingEventDetail) { event in
                EventDetailSheet(event: event)
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
            .onAppear {
                viewMode = defaultViewMode
                loadData()
            }
            .onChange(of: defaultViewMode) { oldValue, newMode in
                viewMode = newMode
            }
            .alert("导入成功", isPresented: $showingImportSuccess) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("已成功导入 \(importedCount) 门课程到系统日历，课程将每周重复。")
            }
            .alert("导入失败", isPresented: $showingImportError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(importErrorMessage.isEmpty ? "无法导入课程到日历，请检查权限设置" : importErrorMessage)
            }
        }
    }
    
    // MARK: - 顶部控制栏
    private var topControlBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(loc.language == .chinese ? "日历" : "Calendar")
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

            // 导入课表到系统日历
            Button(action: { Task { await importMockTimetableToSystemCalendar() } }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)

                    if isImporting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "6366F1")))
                    } else {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }
            .disabled(isImporting)

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
                            Text(mode.displayName(isChinese: loc.language == .chinese))
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
                    ModernMonthView(
                        selectedDate: $selectedDate,
                        eventsProvider: { date in events(on: date) }
                    )
                    .environmentObject(loc)
                case .week:
                    WeekTimetableView()
                        .environmentObject(loc)
                        .environmentObject(timetableViewModel)
                case .day:
                    ModernDayView(
                        selectedDate: $selectedDate,
                        eventsProvider: { date in events(on: date) }
                    )
                    .environmentObject(loc)
                    .environmentObject(timetableViewModel)
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
    
    
    // MARK: - 今日日程
    private var todayScheduleSection: some View {
        let todayEvents = eventsForSelectedDate
        
        return VStack(alignment: .leading, spacing: 16) {
            if !todayEvents.isEmpty {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "6366F1"))
                    
                    Text(loc.language == .chinese ? "今日日程" : "Today's Schedule")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(loc.language == .chinese ? "\(todayEvents.count) 项" : "\(todayEvents.count) items")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    ForEach(todayEvents) { event in
                        ModernEventCard(event: event) {
                            showingEventDetail = event
                        }
                        .environmentObject(loc)
                        .environmentObject(timetableViewModel)
                    }
                }
            } else {
                StudentEmptyStateCard(
                    icon: "calendar.badge.exclamationmark",
                    message: loc.language == .chinese ? "今天还没有安排，来添加一个吧。" : "No schedule for today. Add one!",
                    color: "6366F1"
                )
            }
        }
    }
    
    // MARK: - 今日待办
    private var todayTodosSection: some View {
        let todayTodos = appState.todoManager.todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return Calendar.current.isDate(dueDate, inSameDayAs: selectedDate) && !todo.isCompleted
        }
        .sorted { lhs, rhs in
            let lhsDate = lhs.dueDate ?? Date.distantFuture
            let rhsDate = rhs.dueDate ?? Date.distantFuture
            return lhsDate < rhsDate
        }
        
        return VStack(alignment: .leading, spacing: 16) {
            if !todayTodos.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "10B981"))
                    
                    Text(loc.language == .chinese ? "今日待办" : "Today's Todos")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(loc.language == .chinese ? "\(todayTodos.count) 项" : "\(todayTodos.count) items")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    ForEach(todayTodos) { todo in
                        CalendarTodoCard(todo: todo) {
                            selectedTodo = todo
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
            if !todayActivities.isEmpty {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "8B5CF6"))
                    
                    Text(loc.language == .chinese ? "UCL 校园活动" : "UCL Campus Activities")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        // 跳转到活动页面
                    }) {
                        HStack(spacing: 4) {
                            Text(loc.language == .chinese ? "查看全部" : "View All")
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
                    
                    Text(loc.language == .chinese ? "本周推荐" : "Weekly Recommendations")
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
            // 使用 MockData 中的课程表填充日历事件
            let mapped = MockData.timetableEvents.map { e in
                UCLAPIViewModel.UCLAPIEvent(
                    id: UUID(),
                    title: "\(e.courseCode) · \(e.title)",
                    startTime: e.startTime,
                    endTime: e.endTime,
                    location: e.location,
                    type: .manual,
                    description: "\(e.type) | Instructor: \(e.instructor)",
                    recurrenceRule: nil,
                    reminderTime: .fifteenMin
                )
            }
            viewModel.events = mapped
        }
        if activitiesService.activities.isEmpty {
            activitiesService.loadActivities()
        }
    }

    @State private var showingImportSuccess = false
    @State private var showingImportError = false
    @State private var importErrorMessage = ""
    @State private var importedCount = 0
    @State private var isImporting = false
    
    // 导入 Mock 课程表到系统日历
    private func importMockTimetableToSystemCalendar() async {
        isImporting = true
        do {
            let count = try await CalendarImportService.shared.importTimetableEvents(MockData.timetableEvents, alarmMinutesBefore: 15)
            importedCount = count
            isImporting = false
            showingImportSuccess = true
        } catch {
            isImporting = false
            importErrorMessage = error.localizedDescription
            showingImportError = true
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
    
    private func events(on date: Date) -> [UCLAPIViewModel.UCLAPIEvent] {
        var allEvents: [UCLAPIViewModel.UCLAPIEvent] = []
        
        // 添加 UCLAPI 事件（手动添加的日程）
        let apiEvents = viewModel.events
            .compactMap { occurrence(for: $0, on: date) }
        allEvents.append(contentsOf: apiEvents)
        
        // 添加 TimetableViewModel 的课程事件（使用中英文标题）
        let isChinese = loc.language == .chinese
        let timetableEvents = timetableViewModel.events(for: date).map { timetableEvent in
            UCLAPIViewModel.UCLAPIEvent(
                id: UUID(uuidString: timetableEvent.id) ?? UUID(),
                title: timetableEvent.localizedTitle(isChinese: isChinese),
                startTime: timetableEvent.startTime,
                endTime: timetableEvent.endTime,
                location: timetableEvent.localizedLocation(isChinese: isChinese),
                type: .api,
                description: timetableEvent.localizedTitle(isChinese: isChinese)
            )
        }
        allEvents.append(contentsOf: timetableEvents)
        
        return allEvents.sorted { $0.startTime < $1.startTime }
    }
    
    private func occurrence(for event: UCLAPIViewModel.UCLAPIEvent, on date: Date) -> UCLAPIViewModel.UCLAPIEvent? {
        let calendar = Calendar.current
        if calendar.isDate(event.startTime, inSameDayAs: date) {
            return event
        }
        
        guard let rule = event.recurrenceRule else { return nil }
        let targetDay = calendar.startOfDay(for: date)
        let originDay = calendar.startOfDay(for: event.startTime)
        guard targetDay >= originDay else { return nil }
        if let endDate = rule.endDate, targetDay > calendar.startOfDay(for: endDate) {
            return nil
        }
        
        switch rule.frequency {
        case .none:
            return nil
        case .daily:
            let diff = calendar.dateComponents([.day], from: originDay, to: targetDay).day ?? 0
            guard diff >= 0, diff % rule.interval == 0 else { return nil }
            return shiftedEvent(event, to: targetDay)
        case .weekly, .biweekly:
            let allowedWeekdays = rule.weekdays.isEmpty
                ? [calendar.component(.weekday, from: event.startTime)]
                : Array(rule.weekdays)
            guard allowedWeekdays.contains(calendar.component(.weekday, from: date)) else { return nil }
            let diff = calendar.dateComponents([.weekOfYear], from: originDay, to: targetDay).weekOfYear ?? 0
            guard diff >= 0, diff % rule.interval == 0 else { return nil }
            return shiftedEvent(event, to: targetDay)
        case .monthly:
            guard calendar.component(.day, from: event.startTime) == calendar.component(.day, from: date) else { return nil }
            let diff = calendar.dateComponents([.month], from: originDay, to: targetDay).month ?? 0
            guard diff >= 0, diff % rule.interval == 0 else { return nil }
            return shiftedEvent(event, to: targetDay)
        }
    }
    
    private func shiftedEvent(_ event: UCLAPIViewModel.UCLAPIEvent, to date: Date) -> UCLAPIViewModel.UCLAPIEvent {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: event.startTime)
        let duration = event.endTime.timeIntervalSince(event.startTime)
        let newStart = calendar.date(
            bySettingHour: startComponents.hour ?? 0,
            minute: startComponents.minute ?? 0,
            second: startComponents.second ?? 0,
            of: date
        ) ?? date
        let newEnd = newStart.addingTimeInterval(duration)
        
        return UCLAPIViewModel.UCLAPIEvent(
            id: event.id,
            title: event.title,
            startTime: newStart,
            endTime: newEnd,
            location: event.location,
            type: event.type,
            description: event.description,
            recurrenceRule: event.recurrenceRule,
            reminderTime: event.reminderTime
        )
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var timetableViewModel: TimetableViewModel
    let event: UCLAPIViewModel.UCLAPIEvent
    let onTap: () -> Void
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
    // 获取课程的中英文标题（如果是课程类型）
    private var eventTitle: String {
        // event.title 已经在 events(on:) 方法中使用了 localizedTitle，所以直接使用
        return event.title
    }
    
    // 获取课程的中英文地点（如果是课程类型）
    private var eventLocation: String {
        // event.location 已经在 events(on:) 方法中使用了 localizedLocation，所以直接使用
        return event.location
    }
    
    var body: some View {
        Button(action: onTap) {
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
                    Text(eventTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6366F1"))
                        
                        Text(eventLocation)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    // 类型标签 - 课程和日程不显示"加入日历"按钮
                    HStack(spacing: 8) {
                        Text(event.type == .api ? (isChinese ? "课程" : "Course") : (isChinese ? "手动添加" : "Manual"))
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
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 现代化活动卡片
struct ModernActivityCard: View {
    @EnvironmentObject var loc: LocalizationService
    let activity: UCLActivity
    let service: UCLActivitiesService
    let onTap: () -> Void
    @State private var showingAddSuccess = false
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
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
                Text(activity.localizedTitle(isChinese: isChinese))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let location = activity.localizedLocation(isChinese: isChinese) {
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
                    Text(activity.localizedType(isChinese: isChinese))
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
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            onTap()
        }
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

// MARK: - 日历待办卡片
struct CalendarTodoCard: View {
    let todo: TodoItem
    let onTap: () -> Void
    
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
        guard let dueDate = todo.dueDate else { return Color(hex: "6366F1") }
        
        let interval = dueDate.timeIntervalSince(Date())
        
        if interval < 0 {
            return Color(hex: "EF4444")
        } else if interval < 86400 {
            return Color(hex: "F59E0B")
        } else if interval < 259200 {
            return Color(hex: "F97316")
        } else {
            return Color(hex: "6366F1")
        }
    }
    
    var body: some View {
        Button(action: onTap) {
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct WeeklyRecommendationCard: View {
    @EnvironmentObject var loc: LocalizationService
    let activity: UCLActivity
    let service: UCLActivitiesService
    let onTap: () -> Void
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
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
                Text(activity.localizedTitle(isChinese: isChinese))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(height: 44, alignment: .topLeading)
                
                // 位置
                if let location = activity.localizedLocation(isChinese: isChinese) {
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
                Text(activity.localizedType(isChinese: isChinese))
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

// MARK: - 日程详情 Sheet
struct EventDetailSheet: View {
    let event: UCLAPIViewModel.UCLAPIEvent
    @Environment(\.dismiss) private var dismiss
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    detailHeader
                    infoCard
                    if let description = event.description {
                        descriptionCard(description)
                    }
                }
                .padding(20)
            }
            .navigationTitle("日程详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
    
    private var detailHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.system(size: 24, weight: .bold))
            
            Text(dateFormatter.string(from: event.startTime))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
    
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                iconCircle("clock")
                VStack(alignment: .leading, spacing: 4) {
                    Text("时间")
                        .font(.system(size: 14, weight: .semibold))
                    Text("\(timeFormatter.string(from: event.startTime)) - \(timeFormatter.string(from: event.endTime))")
                        .font(.system(size: 15))
                }
            }
            
            Divider()
            
            HStack(alignment: .top, spacing: 12) {
                iconCircle("mappin.circle.fill", color: "F97316")
                VStack(alignment: .leading, spacing: 4) {
                    Text("地点")
                        .font(.system(size: 14, weight: .semibold))
                    Text(event.location)
                        .font(.system(size: 15))
                }
            }
            
            Divider()
            
            HStack(alignment: .top, spacing: 12) {
                iconCircle("book.fill", color: "8B5CF6")
                VStack(alignment: .leading, spacing: 4) {
                    Text("类型")
                        .font(.system(size: 14, weight: .semibold))
                    Text(event.type == .api ? "课程" : "个人安排")
                        .font(.system(size: 15))
                }
            }
            
            if let recurrence = event.recurrenceRule {
                Divider()
                
                HStack(alignment: .top, spacing: 12) {
                    iconCircle("repeat", color: "0EA5E9")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("重复")
                            .font(.system(size: 14, weight: .semibold))
                        Text(recurrenceDescription(recurrence))
                            .font(.system(size: 15))
                    }
                }
            }
            
            Divider()
            
            HStack(alignment: .top, spacing: 12) {
                iconCircle("bell.badge.fill", color: "F97316")
                VStack(alignment: .leading, spacing: 4) {
                    Text("提醒")
                        .font(.system(size: 14, weight: .semibold))
                    Text(event.reminderTime.rawValue)
                        .font(.system(size: 15))
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private func descriptionCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("备注")
                .font(.system(size: 16, weight: .semibold))
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private func iconCircle(_ name: String, color: String = "6366F1") -> some View {
        Circle()
            .fill(Color(hex: color).opacity(0.15))
            .frame(width: 40, height: 40)
            .overlay(
                Image(systemName: name)
                    .foregroundColor(Color(hex: color))
            )
    }
    
    private func recurrenceDescription(_ rule: RecurrenceRule) -> String {
        var base = rule.frequency.rawValue
        if let endDate = rule.endDate {
            base += " · 至 " + endDate.formatted(date: .abbreviated, time: .omitted)
        } else {
            base += " · 持续进行"
        }
        return base
    }
}

// MARK: - 现代化月视图
struct ModernMonthView: View {
    @Binding var selectedDate: Date
    let eventsProvider: (Date) -> [UCLAPIViewModel.UCLAPIEvent]
    @EnvironmentObject var loc: LocalizationService
    
    @State private var visibleMonth: Date
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
    init(
        selectedDate: Binding<Date>,
        eventsProvider: @escaping (Date) -> [UCLAPIViewModel.UCLAPIEvent]
    ) {
        self._selectedDate = selectedDate
        self.eventsProvider = eventsProvider
        _visibleMonth = State(initialValue: Calendar.current.startOfMonth(for: selectedDate.wrappedValue))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            monthHeader
            weekdayHeader
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInVisibleMonth) { day in
                    dayCell(for: day)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .onChange(of: selectedDate) { oldValue, newValue in
            let targetMonth = calendar.startOfMonth(for: newValue)
            if !calendar.isDate(targetMonth, inSameDayAs: visibleMonth) {
                visibleMonth = targetMonth
            }
        }
    }
    
    private var monthHeader: some View {
        HStack(spacing: 12) {
            Button(action: { shiftMonth(-1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "6366F1"))
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color(hex: "6366F1").opacity(0.1))
                    )
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(visibleMonth, format: .dateTime.year().month())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(isChinese ? "共 \(monthlyEventCount) 个安排" : "\(monthlyEventCount) events")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { shiftMonth(1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "6366F1"))
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color(hex: "6366F1").opacity(0.1))
                    )
            }
        }
    }
    
    private var weekdayHeader: some View {
        let symbols = orderedWeekdaySymbols
        return HStack(spacing: 0) {
            ForEach(symbols, id: \.value) { weekday in
                Text(weekday.symbol.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: "F8F9FF"))
        )
    }
    
    private func dayCell(for day: MonthDayItem) -> some View {
        let isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(day.date)
        let events = eventsProvider(day.date)
        
        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedDate = day.date
                visibleMonth = calendar.startOfMonth(for: day.date)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                // 日期数字
                HStack {
                    Text("\(calendar.component(.day, from: day.date))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(textColor(isSelected: isSelected, isWithinMonth: day.isWithinDisplayedMonth, isToday: isToday))
                    
                    Spacer()
                    
                    if isToday && !isSelected {
                        Circle()
                            .fill(Color(hex: "6366F1"))
                            .frame(width: 4, height: 4)
                    }
                }
                
                // 事件指示器（使用小圆点，避免重叠）
                eventIndicators(events: events, isSelected: isSelected)
            }
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .topLeading)
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .background(backgroundColor(isSelected: isSelected, isWithinMonth: day.isWithinDisplayedMonth, isToday: isToday))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color(hex: "6366F1") : (isToday ? Color(hex: "6366F1").opacity(0.3) : Color.clear),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func eventIndicators(events: [UCLAPIViewModel.UCLAPIEvent], isSelected: Bool) -> some View {
        if events.isEmpty {
            Spacer()
                .frame(height: 4)
        } else {
            // 只显示一个红点，表示有事件
            Circle()
                .fill(Color(hex: "EF4444"))
                .frame(width: 4, height: 4)
        }
    }
    
    private func textColor(isSelected: Bool, isWithinMonth: Bool, isToday: Bool) -> Color {
        if isSelected {
            return .white
        }
        if isToday {
            return Color(hex: "6366F1")
        }
        return isWithinMonth ? .primary : .secondary.opacity(0.5)
    }
    
    private func backgroundColor(isSelected: Bool, isWithinMonth: Bool, isToday: Bool) -> some View {
        Group {
            if isSelected {
                LinearGradient(
                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else if isToday {
                Color(hex: "6366F1").opacity(0.08)
            } else if isWithinMonth {
                Color.white
            } else {
                Color(hex: "F8F9FF").opacity(0.5)
            }
        }
    }
    
    private var orderedWeekdaySymbols: [(value: Int, symbol: String)] {
        // 使用正确的 locale 来获取星期符号
        let locale = Locale(identifier: isChinese ? "zh_CN" : "en_US")
        var localizedCalendar = Calendar.current
        localizedCalendar.locale = locale
        let symbols = localizedCalendar.shortStandaloneWeekdaySymbols
        let firstWeekday = localizedCalendar.firstWeekday - 1
        return (0..<symbols.count).map { offset in
            let index = (offset + firstWeekday) % symbols.count
            return (value: index + 1, symbol: symbols[index])
        }
    }
    
    private var daysInVisibleMonth: [MonthDayItem] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: visibleMonth) else { return [] }
        var days: [MonthDayItem] = []
        
        let firstWeekdayOfMonth = calendar.component(.weekday, from: monthInterval.start)
        let leadingPadding = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7
        
        if leadingPadding > 0 {
            for offset in stride(from: leadingPadding, to: 0, by: -1) {
                let date = calendar.date(byAdding: .day, value: -offset, to: monthInterval.start)!
                days.append(MonthDayItem(date: date, isWithinDisplayedMonth: false))
            }
        }
        
        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(MonthDayItem(date: currentDate, isWithinDisplayedMonth: true))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        while days.count % 7 != 0 {
            let nextDate = calendar.date(byAdding: .day, value: 1, to: days.last!.date)!
            days.append(MonthDayItem(date: nextDate, isWithinDisplayedMonth: false))
        }
        
        return days
    }
    
    private var monthlyEventCount: Int {
        daysInVisibleMonth
            .filter { $0.isWithinDisplayedMonth }
            .reduce(0) { $0 + eventsProvider($1.date).count }
    }
    
    private func shiftMonth(_ value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: visibleMonth) {
            withAnimation(.spring(response: 0.3)) {
                visibleMonth = newMonth
                selectedDate = alignSelectedDate(to: newMonth)
            }
        }
    }
    
    private func alignSelectedDate(to month: Date) -> Date {
        let targetComponents = calendar.dateComponents([.year, .month], from: month)
        let currentDay = calendar.component(.day, from: selectedDate)
        var components = targetComponents
        components.day = min(
            currentDay,
            calendar.range(of: .day, in: .month, for: month)?.count ?? currentDay
        )
        return calendar.date(from: components) ?? month
    }
    
    private func eventColor(for event: UCLAPIViewModel.UCLAPIEvent) -> Color {
        switch event.type {
        case .api:
            return Color(hex: "6366F1")
        case .manual:
            return Color(hex: "10B981")
        }
    }
    
    private func eventTimeLabel(for event: UCLAPIViewModel.UCLAPIEvent) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: event.startTime)
    }
}

private struct MonthDayItem: Identifiable {
    let date: Date
    let isWithinDisplayedMonth: Bool
    
    var id: Date { date }
}

private extension Calendar {
    func startOfMonth(for targetDate: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: targetDate)) ?? targetDate
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
    let eventsProvider: (Date) -> [UCLAPIViewModel.UCLAPIEvent]
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var timetableViewModel: TimetableViewModel
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
    private var todayEvents: [UCLAPIViewModel.UCLAPIEvent] {
        eventsProvider(selectedDate)
    }
    
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
                    Text(isChinese ? "返回今天" : "Back to Today")
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
            
            // 今日日程
            dayScheduleSection
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
    
    // MARK: - 日视图日程部分
    private var dayScheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !todayEvents.isEmpty {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "6366F1"))
                    
                    Text(isChinese ? "今日日程" : "Today's Schedule")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(isChinese ? "\(todayEvents.count) 项" : "\(todayEvents.count) items")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    ForEach(todayEvents) { event in
                        ModernEventCard(event: event) {
                            // 点击事件处理
                        }
                    }
                }
            } else {
                StudentEmptyStateCard(
                    icon: "calendar.badge.exclamationmark",
                    message: isChinese ? "今天还没有安排，来添加一个吧。" : "No schedule for today. Add one!",
                    color: "6366F1"
                )
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - 添加事件表单（新增）
struct AddEventSheet: View {
    @ObservedObject var viewModel: UCLAPIViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var eventTitle = ""
    @State private var eventLocation = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var reminderTime: ReminderTime
    @State private var durationOption: DurationOption = .oneHour
    @State private var customDuration: Double = 60
    @State private var recurrenceEnabled = false
    @State private var recurrenceFrequency: RecurrenceFrequency = .weekly
    @State private var recurrenceEndDate: Date
    @State private var hasRecurrenceEndDate = true
    @State private var selectedWeekdays: Set<Int>
    
    init(viewModel: UCLAPIViewModel, selectedDate: Date, defaultReminderTime: ReminderTime) {
        self.viewModel = viewModel
        let initialEnd = selectedDate.addingTimeInterval(3600)
        _startDate = State(initialValue: selectedDate)
        _endDate = State(initialValue: initialEnd)
        _reminderTime = State(initialValue: defaultReminderTime)
        _recurrenceEndDate = State(initialValue: Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? initialEnd)
        let defaultWeekday = Calendar.current.component(.weekday, from: selectedDate)
        _selectedWeekdays = State(initialValue: [defaultWeekday])
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("事件详情")) {
                    TextField("事件标题", text: $eventTitle)
                    TextField("地点", text: $eventLocation)
                }
                
                Section(header: Text("时间")) {
                    DatePicker("开始时间", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    
                    if durationOption == .custom {
                        DatePicker("结束时间", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                    } else {
                        HStack {
                            Text("结束时间")
                            Spacer()
                            Text(endDate.formatted(date: .omitted, time: .shortened))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("持续时间")) {
                    Picker("持续时间", selection: $durationOption) {
                        ForEach(DurationOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if durationOption == .custom {
                        Stepper(value: $customDuration, in: 15...240, step: 15) {
                            Text("自定义：\(Int(customDuration)) 分钟")
                        }
                    }
                }
                
                Section(header: Text("提醒")) {
                    Picker("提醒时间", selection: $reminderTime) {
                        ForEach(ReminderTime.allCases) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                }
                
                Section(header: Text("重复")) {
                    Toggle("开启重复", isOn: $recurrenceEnabled.animation())
                    
                    if recurrenceEnabled {
                        Picker("频率", selection: $recurrenceFrequency) {
                            ForEach(RecurrenceFrequency.allCases.filter { $0 != .none }) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        if requiresWeekdaySelection {
                            WeekdaySelector(selection: $selectedWeekdays)
                            
                            if selectedWeekdays.isEmpty {
                                Text("请选择至少一个上课日")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Toggle("设置结束日期", isOn: $hasRecurrenceEndDate.animation())
                        
                        if hasRecurrenceEndDate {
                            DatePicker("结束日期", selection: $recurrenceEndDate, in: startDate..., displayedComponents: .date)
                        }
                    }
                }
            }
            .navigationTitle("添加事件")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: startDate) { oldValue, newValue in
                syncEndDateWithDuration()
                if !recurrenceEnabled {
                    selectedWeekdays = [Calendar.current.component(.weekday, from: newValue)]
                }
            }
            .onChange(of: durationOption) { oldValue, newValue in
                syncEndDateWithDuration()
            }
            .onChange(of: customDuration) { oldValue, newValue in
                syncEndDateWithDuration()
            }
            .onChange(of: recurrenceEnabled) { oldValue, enabled in
                if enabled && requiresWeekdaySelection {
                    ensureWeekdaySeed()
                }
            }
            .onChange(of: recurrenceFrequency) { oldValue, newValue in
                if (newValue == .weekly || newValue == .biweekly) && recurrenceEnabled {
                    ensureWeekdaySeed()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let rule = buildRecurrenceRule()
                        let newEvent = UCLAPIViewModel.UCLAPIEvent(
                            id: UUID(),
                            title: eventTitle,
                            startTime: startDate,
                            endTime: endDate,
                            location: eventLocation,
                            type: .manual,
                            description: nil,
                            recurrenceRule: rule,
                            reminderTime: reminderTime
                        )
                        
                        viewModel.events.append(newEvent)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func syncEndDateWithDuration() {
        guard durationOption != .custom else {
            endDate = startDate.addingTimeInterval(customDuration * 60)
            return
        }
        if let minutes = durationOption.minutes {
            endDate = startDate.addingTimeInterval(Double(minutes) * 60)
        }
    }
    
    private func buildRecurrenceRule() -> RecurrenceRule? {
        guard recurrenceEnabled else { return nil }
        let interval: Int
        switch recurrenceFrequency {
        case .biweekly:
            interval = 2
        case .none:
            return nil
        default:
            interval = 1
        }
        
        let endDate = hasRecurrenceEndDate ? recurrenceEndDate : nil
        let weekdays = requiresWeekdaySelection ? selectedWeekdays : []
        
        return RecurrenceRule(
            frequency: recurrenceFrequency,
            interval: interval,
            endDate: endDate,
            weekdays: weekdays
        )
    }
    
    private var requiresWeekdaySelection: Bool {
        recurrenceFrequency == .weekly || recurrenceFrequency == .biweekly
    }
    
    private var canSave: Bool {
        let hasTitle = !eventTitle.trimmingCharacters(in: .whitespaces).isEmpty
        let hasWeekday = !recurrenceEnabled || !requiresWeekdaySelection || !selectedWeekdays.isEmpty
        return hasTitle && hasWeekday
    }
    
    private func ensureWeekdaySeed() {
        if selectedWeekdays.isEmpty {
            let weekday = Calendar.current.component(.weekday, from: startDate)
            selectedWeekdays.insert(weekday)
        }
    }
}

private struct WeekdaySelector: View {
    @Binding var selection: Set<Int>
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(orderedWeekdays, id: \.value) { weekday in
                let isSelected = selection.contains(weekday.value)
                Button {
                    toggle(weekday.value)
                } label: {
                    Text(label(for: weekday.symbol))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? Color(hex: "6366F1") : Color.gray.opacity(0.15))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 4)
    }
    
    private var orderedWeekdays: [(value: Int, symbol: String)] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let firstWeekday = calendar.firstWeekday - 1
        return (0..<symbols.count).map { offset in
            let index = (offset + firstWeekday) % symbols.count
            return (value: index + 1, symbol: symbols[index])
        }
    }
    
    private func label(for symbol: String) -> String {
        let localeCode = Locale.preferredLanguages.first ?? ""
        if localeCode.contains("zh") {
            return symbol
        }
        return symbol.prefix(3).uppercased()
    }
    
    private func toggle(_ day: Int) {
        if selection.contains(day) {
            selection.remove(day)
        } else {
            selection.insert(day)
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
    @EnvironmentObject var loc: LocalizationService
    let activity: UCLActivity
    let service: UCLActivitiesService
    
    @State private var eventStore = EKEventStore()
    @State private var showingAddSuccess = false
    @State private var showingAddError = false
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
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
                            Text(activity.localizedType(isChinese: isChinese))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.3))
                                )
                            
                            Text(activity.localizedTitle(isChinese: isChinese))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(20)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // 时间信息
                        InfoRow(
                            icon: "clock.fill",
                            title: isChinese ? "时间" : "Time",
                            content: "\(service.formatTime(activity.startTime))\(activity.endTime.isEmpty ? "" : " - \(service.formatTime(activity.endTime))")",
                            color: "6366F1"
                        )
                        
                        // 日期信息
                        InfoRow(
                            icon: "calendar",
                            title: isChinese ? "日期" : "Date",
                            content: activity.date,
                            color: "8B5CF6"
                        )
                        
                        // 地点信息
                        if let location = activity.localizedLocation(isChinese: isChinese) {
                            InfoRow(
                                icon: "mappin.circle.fill",
                                title: isChinese ? "地点" : "Location",
                                content: location,
                                color: "8B5CF6"
                            )
                        }
                        
                        // 描述
                        if let description = activity.localizedDescription(isChinese: isChinese) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "text.alignleft")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "10B981"))
                                    
                                    Text(isChinese ? "活动详情" : "Activity Details")
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
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
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
        guard await ensureCalendarPermission() else {
            showingAddError = true
            return
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

    private func ensureCalendarPermission() async -> Bool {
        if #available(iOS 17, *) {
            let status = EKEventStore.authorizationStatus(for: .event)
            switch status {
            case .notDetermined:
                return await requestWriteAccess()
            case .writeOnly, .fullAccess:
                return true
            default:
                return false
            }
        } else {
            let status = EKEventStore.authorizationStatus(for: .event)
            switch status {
            case .notDetermined:
                return (try? await eventStore.requestAccess(to: .event)) ?? false
            case .authorized:
                return true
            default:
                return false
            }
        }
    }

    @available(iOS 17, *)
    private func requestWriteAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            eventStore.requestWriteOnlyAccessToEvents { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }
}
