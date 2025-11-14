// MARK: - ParentAcademicsView.swift
// 文件位置: uniapp/Views/Parent/ParentAcademicsView.swift

import SwiftUI

struct ParentAcademicsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 分段选择器
                    Picker("", selection: $selectedSegment) {
                        Text(loc.language == .chinese ? "学业" : "Academics").tag(0)
                        Text(loc.language == .chinese ? "课表" : "Schedule").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // 内容区域
                    TabView(selection: $selectedSegment) {
                        // 学业概览
                        AcademicsOverviewSection()
                            .tag(0)
                        
                        // 课表
                        ScheduleSection()
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle(loc.language == .chinese ? "学业与课表" : "Academics & Schedule")
        }
    }
}

// MARK: - 学业概览部分
struct AcademicsOverviewSection: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    // 模拟数据 - 实际应从 ViewModel 获取
    private let modules: [AcademicModule] = [
        AcademicModule(
            name: "Deep Learning for Healthcare",
            nameCN: "医疗深度学习",
            code: "COMP0189",
            credits: 15,
            mark: 78,
            status: ModuleStatus.completed,
            assignments: [
                Assignment(title: "Neural Networks Lab", titleCN: "神经网络实验", dueDate: Date().addingTimeInterval(-7*24*3600), completed: true),
                Assignment(title: "Final Project", titleCN: "期末项目", dueDate: Date().addingTimeInterval(14*24*3600), completed: false)
            ]
        ),
        AcademicModule(
            name: "Medical Statistics",
            nameCN: "医学统计",
            code: "STAT0020",
            credits: 15,
            mark: 72,
            status: ModuleStatus.inProgress,
            assignments: [
                Assignment(title: "Statistical Analysis Report", titleCN: "统计分析报告", dueDate: Date().addingTimeInterval(7*24*3600), completed: false)
            ]
        ),
        AcademicModule(
            name: "Health Informatics",
            nameCN: "健康信息学",
            code: "COMP0188",
            credits: 15,
            mark: 68,
            status: ModuleStatus.inProgress,
            assignments: []
        )
    ]
    
    private var averageGrade: Double {
        let total = modules.reduce(0.0) { $0 + $1.mark }
        return total / Double(modules.count)
    }
    
    var body: some View {
        ScrollView {
            if appState.shareGrades {
                VStack(spacing: 20) {
                    // 总体成绩概览
                    OverallGradeCard(averageGrade: averageGrade, modules: modules)
                    
                    // 模块列表
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.language == .chinese ? "课程模块" : "Course Modules")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(modules) { module in
                            ModuleDetailCard(module: module)
                        }
                    }
                    
                    // 近期作业
                    UpcomingAssignmentsCard(modules: modules)
                }
                .padding()
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    DataNotSharedView(dataType: loc.language == .chinese ? "学业信息" : "Academic Information")
                        .padding()
                    Spacer()
                }
            }
        }
    }
}

// MARK: - 总体成绩卡片
struct OverallGradeCard: View {
    @EnvironmentObject var loc: LocalizationService
    let averageGrade: Double
    let modules: [AcademicModule]
    
    private var totalCredits: Int {
        modules.reduce(0) { $0 + $1.credits }
    }
    
    private var completedCredits: Int {
        modules.filter { $0.status == .completed }.reduce(0) { $0 + $1.credits }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc.language == .chinese ? "总体概览" : "Overall Summary")
                .font(.headline)
            
            HStack(spacing: 20) {
                // 平均成绩环形图
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .trim(from: 0, to: averageGrade / 100)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [DesignSystem.primaryColor, DesignSystem.secondaryColor]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 2) {
                            Text(String(format: "%.1f", averageGrade))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(loc.language == .chinese ? "平均分" : "Average")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(gradeLevel(for: averageGrade))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(gradeColor(for: averageGrade).opacity(0.2))
                        .foregroundColor(gradeColor(for: averageGrade))
                        .clipShape(Capsule())
                }
                
                // 统计信息
                VStack(alignment: .leading, spacing: 12) {
                    StatRow(
                        icon: "book.closed.fill",
                        title: loc.language == .chinese ? "已修课程" : "Completed Modules",
                        value: "\(modules.filter { $0.status == .completed }.count) / \(modules.count)"
                    )
                    
                    StatRow(
                        icon: "graduationcap.fill",
                        title: loc.language == .chinese ? "已获学分" : "Credits Earned",
                        value: "\(completedCredits) / \(totalCredits)"
                    )
                    
                    StatRow(
                        icon: "doc.text.fill",
                        title: loc.language == .chinese ? "待办作业" : "Pending",
                        value: "\(pendingAssignmentsCount)",
                        valueColor: DesignSystem.warningColor
                    )
                }
                
                Spacer()
            }
        }
        .padding()
        .glassCard()
    }
    
    private var pendingAssignmentsCount: Int {
        modules.flatMap { $0.assignments }.filter { !$0.completed }.count
    }
    
    private func gradeColor(for grade: Double) -> Color {
        if grade >= 70 { return DesignSystem.successColor }
        else if grade >= 60 { return Color.blue }
        else if grade >= 50 { return DesignSystem.warningColor }
        else { return DesignSystem.errorColor }
    }
    
    private func gradeLevel(for grade: Double) -> String {
        if grade >= 70 { return loc.language == .chinese ? "一等荣誉" : "First Class" }
        else if grade >= 60 { return loc.language == .chinese ? "二等一" : "2:1" }
        else if grade >= 50 { return loc.language == .chinese ? "二等二" : "2:2" }
        else if grade >= 40 { return loc.language == .chinese ? "三等" : "Third" }
        else { return loc.language == .chinese ? "不及格" : "Fail" }
    }
}

// MARK: - 统计行组件
struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(DesignSystem.primaryColor)
                .frame(width: 20)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - 模块详情卡片
struct ModuleDetailCard: View {
    @EnvironmentObject var loc: LocalizationService
    let module: AcademicModule
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 模块头部
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(loc.language == .chinese ? module.nameCN : module.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 8) {
                        Text(module.code)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(module.credits) " + (loc.language == .chinese ? "学分" : "credits"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // 状态标签
                        Text(module.status.displayName(loc: loc))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(module.status.color.opacity(0.2))
                            .foregroundColor(module.status.color)
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // 成绩
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(module.mark))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(gradeColor(for: module.mark))
                    Text(loc.language == .chinese ? "分数" : "Mark")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // 作业列表（可展开）
            if !module.assignments.isEmpty {
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(loc.language == .chinese ? "作业 (\(module.assignments.count))" : "Assignments (\(module.assignments.count))")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(DesignSystem.primaryColor)
                }
                
                if isExpanded {
                    ForEach(module.assignments) { assignment in
                        AssignmentRow(assignment: assignment)
                    }
                }
            }
        }
        .padding()
        .glassCard()
    }
    
    private func gradeColor(for mark: Double) -> Color {
        if mark >= 70 { return DesignSystem.successColor }
        else if mark >= 60 { return Color.blue }
        else if mark >= 50 { return DesignSystem.warningColor }
        else { return DesignSystem.errorColor }
    }
}

// MARK: - 作业行组件
struct AssignmentRow: View {
    @EnvironmentObject var loc: LocalizationService
    let assignment: Assignment
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: assignment.completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(assignment.completed ? DesignSystem.successColor : .gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.language == .chinese ? assignment.titleCN : assignment.title)
                    .font(.caption)
                    .strikethrough(assignment.completed)
                
                Text(assignment.dueDate, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !assignment.completed && assignment.dueDate < Date().addingTimeInterval(3*24*3600) {
                Text(loc.language == .chinese ? "即将截止" : "Due Soon")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(DesignSystem.warningColor.opacity(0.1))
                    .foregroundColor(DesignSystem.warningColor)
                    .clipShape(Capsule())
            }
        }
        .padding(.leading, 20)
    }
}

// MARK: - 近期作业卡片
struct UpcomingAssignmentsCard: View {
    @EnvironmentObject var loc: LocalizationService
    let modules: [AcademicModule]
    
    private var upcomingAssignments: [(module: AcademicModule, assignment: Assignment)] {
        var result: [(module: AcademicModule, assignment: Assignment)] = []
        for module in modules {
            for assignment in module.assignments where !assignment.completed {
                result.append((module: module, assignment: assignment))
            }
        }
        return result.sorted(by: { $0.assignment.dueDate < $1.assignment.dueDate })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.language == .chinese ? "即将截止的作业" : "Upcoming Assignments")
                .font(.headline)
            
            if upcomingAssignments.isEmpty {
                Text(loc.language == .chinese ? "暂无待完成作业" : "No pending assignments")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(upcomingAssignments.indices, id: \.self) { index in
                    let item = upcomingAssignments[index]
                    UpcomingAssignmentRow(module: item.module, assignment: item.assignment)
                }
            }
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 即将截止作业行
struct UpcomingAssignmentRow: View {
    @EnvironmentObject var loc: LocalizationService
    let module: AcademicModule
    let assignment: Assignment
    
    private var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: assignment.dueDate).day ?? 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 日期指示器
            VStack(spacing: 2) {
                Text("\(daysUntilDue)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(daysUntilDue <= 2 ? DesignSystem.errorColor : DesignSystem.primaryColor)
                Text(loc.language == .chinese ? "天" : "days")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background((daysUntilDue <= 2 ? DesignSystem.errorColor : DesignSystem.primaryColor).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(loc.language == .chinese ? assignment.titleCN : assignment.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(module.code)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(assignment.dueDate, style: .date)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 课表部分
struct ScheduleSection: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    @StateObject private var viewModel = UCLAPIViewModel()
    @StateObject private var activitiesService = UCLActivitiesService()
    @StateObject private var timetableViewModel = TimetableViewModel()
    
    @State private var selectedDate = Date()
    @State private var viewMode: CalendarViewMode = .day
    @State private var showingImportSuccess = false
    @State private var showingImportError = false
    @State private var importErrorMessage = ""
    @State private var importedCount = 0
    @State private var isImporting = false
    @State private var showingEventDetail: UCLAPIViewModel.UCLAPIEvent?
    
    private var eventsForSelectedDate: [UCLAPIViewModel.UCLAPIEvent] {
        events(on: selectedDate)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if appState.shareCalendar {
                VStack(spacing: 24) {
                    // 顶部控制栏
                    topControlBar
                    
                    // 日历视图切换
                    calendarViewSection
                    
                    // 今日日程
                    todayScheduleSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            } else {
                VStack {
                    Spacer()
                    DataNotSharedView(dataType: loc.language == .chinese ? "课表信息" : "Schedule")
                        .padding()
                    Spacer()
                }
            }
        }
        .onAppear {
            loadData()
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
        .sheet(item: $showingEventDetail) { event in
            EventDetailSheet(event: event)
        }
    }
    
    // MARK: - 顶部控制栏
    private var topControlBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(loc.language == .chinese ? "课表" : "Schedule")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(formattedDateString(selectedDate))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
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
    
    // MARK: - 辅助方法
    private func loadData() {
        // viewModel.events 只用于手动添加的日程，不用于课程表
        // 课程表数据由 timetableViewModel 管理，它会自动从 MockData.timetableEvents 加载
        // 这样避免重复显示课程
        
        if activitiesService.activities.isEmpty {
            activitiesService.loadActivities()
        }
    }
    
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
    
    private func events(on date: Date) -> [UCLAPIViewModel.UCLAPIEvent] {
        var allEvents: [UCLAPIViewModel.UCLAPIEvent] = []
        
        // 添加 TimetableViewModel 的课程事件（使用中英文标题）
        // 这是课程表的主要数据源，已经处理了重复事件生成和语言本地化
        let isChinese = loc.language == .chinese
        let timetableEvents = timetableViewModel.events(for: date).map { timetableEvent in
            UCLAPIViewModel.UCLAPIEvent(
                id: UUID(uuidString: timetableEvent.id) ?? UUID(),
                title: timetableEvent.localizedTitle(isChinese: isChinese),
                startTime: timetableEvent.startTime,
                endTime: timetableEvent.endTime,
                location: timetableEvent.localizedLocation(isChinese: isChinese),
                type: .api,
                description: "\(timetableEvent.localizedType(isChinese: isChinese)) | \(loc.language == .chinese ? "讲师" : "Instructor"): \(timetableEvent.localizedInstructor(isChinese: isChinese))"
            )
        }
        allEvents.append(contentsOf: timetableEvents)
        
        // 添加手动添加的日程（如果有的话）
        let manualEvents = viewModel.events
            .filter { event in
                // 只添加手动添加的事件，排除课程表事件
                event.type == .manual
            }
            .compactMap { occurrence(for: $0, on: date) }
        allEvents.append(contentsOf: manualEvents)
        
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

// MARK: - 周日期选择器
struct WeekDaySelector: View {
    @EnvironmentObject var loc: LocalizationService
    @Binding var selectedDay: Int
    
    private let weekDays = [
        (1, "Sun", "日"),
        (2, "Mon", "一"),
        (3, "Tue", "二"),
        (4, "Wed", "三"),
        (5, "Thu", "四"),
        (6, "Fri", "五"),
        (7, "Sat", "六")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(weekDays, id: \.0) { day in
                    WeekDayButton(
                        weekday: day.0,
                        label: loc.language == .chinese ? day.2 : day.1,
                        isSelected: selectedDay == day.0
                    ) {
                        withAnimation(.spring()) {
                            selectedDay = day.0
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - 周日期按钮
struct WeekDayButton: View {
    let weekday: Int
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
                
                if isSelected {
                    Circle()
                        .fill(DesignSystem.primaryColor)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .foregroundColor(isSelected ? DesignSystem.primaryColor : .secondary)
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(isSelected ? DesignSystem.primaryColor.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - 当日课表视图
struct DayScheduleView: View {
    @EnvironmentObject var loc: LocalizationService
    let weekday: Int
    let classes: [ScheduleClass]
    
    private var dayName: String {
        let days = [
            (1, "Sunday", "周日"),
            (2, "Monday", "周一"),
            (3, "Tuesday", "周二"),
            (4, "Wednesday", "周三"),
            (5, "Thursday", "周四"),
            (6, "Friday", "周五"),
            (7, "Saturday", "周六")
        ]
        let day = days.first { $0.0 == weekday }
        return loc.language == .chinese ? day?.2 ?? "" : day?.1 ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(dayName)
                .font(.headline)
                .padding(.horizontal)
            
            if classes.isEmpty {
                EmptyDayView()
            } else {
                ForEach(classes.indices, id: \.self) { index in
                    ScheduleClassCard(scheduleClass: classes[index])
                }
            }
        }
    }
}

// MARK: - 空白日视图
struct EmptyDayView: View {
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text(loc.language == .chinese ? "这天没有课程安排" : "No classes scheduled")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .glassCard()
    }
}

// MARK: - 课程卡片
struct ScheduleClassCard: View {
    @EnvironmentObject var loc: LocalizationService
    let scheduleClass: ScheduleClass
    
    var body: some View {
        HStack(spacing: 16) {
            // 时间指示器
            VStack(alignment: .center, spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundColor(DesignSystem.primaryColor)
                
                Text(scheduleClass.time)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 70)
            
            Divider()
            
            // 课程信息
            VStack(alignment: .leading, spacing: 6) {
                Text(loc.language == .chinese ? scheduleClass.courseNameCN : scheduleClass.courseName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 8) {
                    Label(
                        loc.language == .chinese ? scheduleClass.locationCN : scheduleClass.location,
                        systemImage: "mappin.circle.fill"
                    )
                    
                    if !scheduleClass.room.isEmpty {
                        Text("• \(scheduleClass.room)")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if let instructor = scheduleClass.instructor {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                        Text(instructor)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 数据模型
struct AcademicModule: Identifiable {
    let id = UUID()
    let name: String
    let nameCN: String
    let code: String
    let credits: Int
    let mark: Double
    let status: ModuleStatus
    let assignments: [Assignment]
}

enum ModuleStatus {
    case completed, inProgress, upcoming
    
    var color: Color {
        switch self {
        case .completed: return DesignSystem.successColor
        case .inProgress: return DesignSystem.primaryColor
        case .upcoming: return .gray
        }
    }
    
    func displayName(loc: LocalizationService) -> String {
        switch self {
        case .completed: return loc.language == .chinese ? "已完成" : "Completed"
        case .inProgress: return loc.language == .chinese ? "进行中" : "In Progress"
        case .upcoming: return loc.language == .chinese ? "即将开始" : "Upcoming"
        }
    }
}

struct Assignment: Identifiable {
    let id = UUID()
    let title: String
    let titleCN: String
    let dueDate: Date
    let completed: Bool
}

struct ScheduleClass: Identifiable {
    let id = UUID()
    let courseName: String
    let courseNameCN: String
    let time: String
    let location: String
    let locationCN: String
    let room: String
    let instructor: String?
}

