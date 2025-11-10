//
//  ParentDashboardView.swift
//  uniapp
//
//  家长中心 - 增强版
//

import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @State private var showingSettings = false
    @State private var selectedTodo: TodoItem? = nil
    @State private var showingTodoDetail = false
    
    // 使用枚举管理不同的 modal 状态
    @State private var activeSheet: ParentDashboardSheet?
    
    enum ParentDashboardSheet: Identifiable {
        case settings
        case todoDetail(TodoItem)
        case health
        case email
        
        var id: String {
            switch self {
            case .settings:
                return "settings"
            case .todoDetail(let todo):
                return "todo-\(todo.id)"
            case .health:
                return "health"
            case .email:
                return "email"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 学生状态卡片
                        StudentStatusCard()
                        
                        // 快捷入口
                        QuickAccessCard(onHealthTap: {
                            activeSheet = .health
                        }, onEmailTap: {
                            activeSheet = .email
                        })
                        
                        // 学业总览
                        AcademicOverviewCard()
                        
                        // 待办事项（合并了原来的截止任务和作业进度）
                        TodoOverviewCard(
                            onTodoTap: { todo in
                                activeSheet = .todoDetail(todo)
                            }
                        )
                        
                        // 本周学习统计
                        WeeklySummaryCard()
                        
                        // 出勤热力图（增强版）
                        AttendanceHeatmapCardEnhanced()
                    }
                    .padding()
                }
            }
            .navigationTitle("家长中心")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        activeSheet = .settings
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .settings:
                    ParentSettingsView()
                        .environmentObject(appState)
                        .environmentObject(loc)
                case .todoDetail(let todo):
                    TodoDetailView(
                        todo: todo,
                        isPresented: Binding(
                            get: { activeSheet != nil },
                            set: { if !$0 { activeSheet = nil } }
                        )
                    )
                    .environmentObject(appState)
                    .environmentObject(loc)
                case .health:
                    ParentHealthView()
                        .environmentObject(appState)
                        .environmentObject(loc)
                case .email:
                    ParentEmailView()
                        .environmentObject(appState)
                        .environmentObject(loc)
                }
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

// MARK: - 学生状态卡片（保持原样）
struct StudentStatusCard: View {
    var body: some View {
        VStack(spacing: 20) {
            // 头部信息
            HStack(spacing: 16) {
                // 头像
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 15, x: 0, y: 8)
                    
                    Text("ZH")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // 学生信息
                VStack(alignment: .leading, spacing: 6) {
                    Text("Zoya Huo")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("MSc Health Data Science")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "building.2")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6366F1"))
                        
                        Text("University College London")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // 状态指示器
            HStack(spacing: 12) {
                ParentStatusIndicator(
                    icon: "checkmark.circle.fill",
                    title: "活跃",
                    subtitle: "学习状态良好",
                    color: Color(hex: "10B981")
                )
                
                ParentStatusIndicator(
                    icon: "clock.fill",
                    title: "准时",
                    subtitle: "按时完成任务",
                    color: Color(hex: "6366F1")
                )
                
                ParentStatusIndicator(
                    icon: "star.fill",
                    title: "优秀",
                    subtitle: "学术表现优异",
                    color: Color(hex: "F59E0B")
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }
}

// MARK: - 状态指示器（保持原样）
struct ParentStatusIndicator: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 健康与医疗卡片
struct QuickAccessCard: View {
    @EnvironmentObject var appState: AppState
    let onHealthTap: () -> Void
    let onEmailTap: () -> Void
    
    // 模拟医生预约数据
    private var upcomingAppointment: String? {
        "11月15日 14:00 Dr. Sarah Johnson"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "EF4444"))
                
                Text("健康与医疗")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onHealthTap) {
                    Text("查看详情")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                }
            }
            
            // 健康数据概览
            HStack(spacing: 12) {
                HealthQuickStat(icon: "bed.double.fill", label: "睡眠", value: "6.8h", color: Color(hex: "6366F1"))
                HealthQuickStat(icon: "heart.fill", label: "心率", value: "72", color: Color(hex: "EF4444"))
                HealthQuickStat(icon: "figure.walk", label: "步数", value: "8.2k", color: Color(hex: "10B981"))
            }
            
            Divider()
            
            // 医生预约
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Text("即将到来的预约")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                if let appointment = upcomingAppointment {
                    HStack(spacing: 8) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(appointment)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "F59E0B").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text("暂无预约")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // 最近医生反馈
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "10B981"))
                    
                    Text("最近医生反馈")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("病情稳定，继续规律用药")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("11月8日 · 风湿免疫科")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "10B981").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }
}

struct HealthQuickStat: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 学业总览卡片（使用真实数据）
struct AcademicOverviewCard: View {
    @EnvironmentObject var loc: LocalizationService
    
    // 与StudentAcademicsView完全一致的真实数据
    private let allModules: [(name: String, code: String, mark: Double)] = [
        ("数据方法与健康研究", "CHME0013", 87),
        ("Python 健康研究编程", "CHME0011", 86),
        ("医疗人工智能", "CHME0016", 91),
        ("医疗高级机器学习", "CHME0017", 85),
        ("数据科学与统计", "CHME0007", 72),
        ("数据科学流行病学", "CHME0008", 69),
        ("健康数据科学原理", "CHME0006", 67),
        ("Informatics for Healthcare", "CHME0021", 0),
        ("Computational Genomics", "CHME0012", 0),
        ("Health Economics", "CHME0030", 0)
    ]
    
    private var completedModules: [(name: String, code: String, mark: Double)] {
        allModules.filter { $0.mark > 0 }
    }
    
    private var overallAverage: Double {
        let completed = completedModules
        guard !completed.isEmpty else { return 0 }
        return completed.reduce(0) { $0 + $1.mark } / Double(completed.count)
    }
    
    private var gradeLevel: String {
        let avg = overallAverage
        if avg >= 70 { return "一等学位 First Class" }
        if avg >= 60 { return "二等一 Upper Second" }
        if avg >= 50 { return "二等二 Lower Second" }
        if avg >= 40 { return "三等 Third Class" }
        return "不及格"
    }
    
    private var topModules: [(name: String, code: String, mark: Double)] {
        Array(completedModules.sorted { $0.mark > $1.mark }.prefix(3))
    }
    
    var body: some View {
        NavigationLink(destination: ParentAcademicDetailView()) {
            VStack(alignment: .leading, spacing: 20) {
                // 标题
                HStack {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "6366F1"))
                    
                    Text("学业总览")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                
                // 总平均分
                HStack(alignment: .center, spacing: 16) {
                    Text(String(format: "%.1f", overallAverage))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(overallAverage >= 70 ? Color(hex: "10B981") : Color(hex: "8B5CF6"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("平均分")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text(gradeLevel)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(overallAverage >= 70 ? Color(hex: "10B981") : Color(hex: "8B5CF6"))
                            .clipShape(Capsule())
                        
                        Text("\(completedModules.count)/\(allModules.count) 门已评分")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // 显示前3门最高分课程
                VStack(spacing: 12) {
                    ForEach(topModules, id: \.code) { module in
                        HStack(spacing: 12) {
                            // 排名图标
                            ZStack {
                                Circle()
                                    .fill(gradeColor(module.mark).opacity(0.15))
                                    .frame(width: 24, height: 24)
                                
                                Text(topModules.firstIndex(where: { $0.code == module.code }).map { "\($0 + 1)" } ?? "")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(gradeColor(module.mark))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(module.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Text(module.code)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(Int(module.mark))")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(gradeColor(module.mark))
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func gradeColor(_ mark: Double) -> Color {
        if mark >= 80 { return Color(hex: "10B981") }
        if mark >= 70 { return Color(hex: "8B5CF6") }
        if mark >= 60 { return Color(hex: "F59E0B") }
        return Color(hex: "EF4444")
    }
}

// MARK: - 待办事项卡片 (新增 - 替代原来的即将截止和作业进度)
struct TodoOverviewCard: View {
    @EnvironmentObject var appState: AppState
    let onTodoTap: (TodoItem) -> Void
    
    var upcomingTodos: [TodoItem] {
        appState.todoManager.upcomingDeadlines.prefix(3).map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checklist")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "F59E0B"))
                
                Text("待办事项")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 统计标签
                HStack(spacing: 4) {
                    Text("\(appState.todoManager.upcomingDeadlines.count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Text("项任务")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            if upcomingTodos.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "10B981"))
                    
                    Text("太棒了！暂无待办事项")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                VStack(spacing: 12) {
                    ForEach(upcomingTodos) { todo in
                        Button(action: {
                            onTodoTap(todo)
                        }) {
                            TodoItemRow(todo: todo)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }
}

struct TodoItemRow: View {
    let todo: TodoItem
    
    var priorityColor: Color {
        switch todo.priority {
        case .urgent: return Color(hex: "DC2626")
        case .high: return Color(hex: "EF4444")
        case .medium: return Color(hex: "F59E0B")
        case .low: return Color(hex: "10B981")
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 优先级指示器
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label(todo.timeLeftDescription, systemImage: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(todo.isUrgent ? Color(hex: "EF4444") : .secondary)
                    
                    if !todo.category.isEmpty {
                        Text("·")
                            .foregroundColor(.secondary)
                        
                        Text(todo.category)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 本周数据统计卡片（基于真实数据）
struct WeeklySummaryCard: View {
    @EnvironmentObject var appState: AppState
    
    // 计算本周课程数（从周课表）
    private var weeklyCoursesCount: Int {
        5 // 每周固定5门课（周一到周五各一门）
    }
    
    // 计算本周待办/作业数
    private var weeklyTodosCount: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now) else { return 0 }
        
        return appState.todoManager.todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return dueDate >= now && dueDate <= weekFromNow
        }.count
    }
    
    // 计算本周完成的待办数
    private var completedThisWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return 0 }
        
        return appState.todoManager.todos.filter { todo in
            todo.isCompleted && todo.createdDate >= weekAgo && todo.createdDate <= now
        }.count
    }
    
    // 计算出勤率（基于固定数据）
    private var attendanceRate: Int {
        95 // 根据热力图数据计算
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "8B5CF6"))
                
                Text("📊 本周数据")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            // 统计网格
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                WeeklyStat(
                    icon: "book.fill",
                    value: "\(weeklyCoursesCount)",
                    label: "门课程",
                    color: Color(hex: "6366F1")
                )
                WeeklyStat(
                    icon: "pencil",
                    value: "\(weeklyTodosCount)",
                    label: "项待办",
                    color: Color(hex: "F59E0B")
                )
                WeeklyStat(
                    icon: "checkmark.circle.fill",
                    value: "\(attendanceRate)%",
                    label: "出勤率",
                    color: Color(hex: "10B981")
                )
                WeeklyStat(
                    icon: "checkmark.square.fill",
                    value: "\(completedThisWeek)",
                    label: "已完成",
                    color: Color(hex: "EC4899")
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }
}

struct WeeklyStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 出勤日历热力图卡片（日历格式）
struct AttendanceHeatmapCardEnhanced: View {
    // 最近30天的出勤数据（true=出席，false=缺席，nil=未来/周末）
    private let attendanceCalendar: [Int: Bool?] = {
        var calendar: [Int: Bool?] = [:]
        let today = 10 // 假设今天是11月10日
        
        // 11月份数据（1-30日）
        for day in 1...30 {
            if day > today {
                calendar[day] = nil // 未来日期
            } else if day % 7 == 0 || day % 7 == 6 {
                calendar[day] = nil // 周末不上课
            } else if day == 6 {
                calendar[day] = false // 11月6日缺席
            } else {
                calendar[day] = true // 其他工作日出席
            }
        }
        
        return calendar
    }()
    
    private let weekdays = ["一", "二", "三", "四", "五", "六", "日"]
    
    // 计算11月1日是周几（2025年11月1日是周六）
    private let firstDayOfWeek = 5 // 0=周日, 1=周一...6=周六
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "10B981"))
                
                Text("� 出勤日历")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("11月")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // 日历网格
            VStack(spacing: 6) {
                // 星期标题
                HStack(spacing: 0) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 4)
                
                // 日期格子（6周显示完整月份）
                ForEach(0..<6) { week in
                    HStack(spacing: 6) {
                        ForEach(0..<7) { weekday in
                            let dayNumber = week * 7 + weekday - firstDayOfWeek + 1
                            
                            if dayNumber > 0 && dayNumber <= 30 {
                                // 有效日期
                                let status = attendanceCalendar[dayNumber]
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            status == nil ? Color.gray.opacity(0.1) :
                                            status == true ? Color(hex: "10B981") : Color(hex: "EF4444")
                                        )
                                    
                                    Text("\(dayNumber)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(
                                            status == nil ? .secondary : .white
                                        )
                                }
                                .frame(height: 36)
                            } else {
                                // 空白格子
                                Color.clear
                                    .frame(height: 36)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // 统计摘要
            HStack(spacing: 12) {
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Text("18")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "10B981"))
                        Text("/")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text("19")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("本月出席")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "10B981").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(spacing: 6) {
                    Text("95%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "6366F1"))
                    
                    Text("出勤率")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "6366F1").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(spacing: 6) {
                    Text("1")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "EF4444"))
                    
                    Text("缺席")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "EF4444").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // 图例说明
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "10B981"))
                        .frame(width: 12, height: 12)
                    Text("出席")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "EF4444"))
                        .frame(width: 12, height: 12)
                    Text("缺席")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 12, height: 12)
                    Text("周末/未来")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }
}

// MARK: - 数据未共享视图（保留备用）
struct DataNotSharedView: View {
    let dataType: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "F59E0B"))
            
            Text("\(dataType)未共享")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("学生尚未开启此数据共享")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "F59E0B").opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}

// MARK: - TodoItem 扩展（用于显示）
extension TodoItem {
    var timeLeftDescription: String {
        guard let dueDate = dueDate else { return "无截止日期" }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: dueDate)
        
        if let days = components.day, days > 0 {
            return "\(days) 天后截止"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) 小时后截止"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) 分钟后截止"
        } else {
            return "已截止"
        }
    }
    
    var isUrgent: Bool {
        guard let dueDate = dueDate else { return false }
        
        let now = Date()
        let hoursLeft = Calendar.current.dateComponents([.hour], from: now, to: dueDate).hour ?? 0
        return hoursLeft <= 24
    }
}