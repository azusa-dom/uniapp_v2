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

// MARK: - 快捷入口卡片 (新增)
struct QuickAccessCard: View {
    let onHealthTap: () -> Void
    let onEmailTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("快捷入口")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 12) {
                // 健康观察
                Button(action: onHealthTap) {
                    QuickAccessButton(
                        icon: "heart.fill",
                        title: "健康观察",
                        subtitle: "睡眠·运动·压力",
                        color: Color(hex: "EF4444")
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 邮件通知
                Button(action: onEmailTap) {
                    QuickAccessButton(
                        icon: "envelope.fill",
                        title: "邮件通知",
                        subtitle: "3 封未读",
                        color: Color(hex: "8B5CF6")
                    )
                }
                .buttonStyle(PlainButtonStyle())
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

struct QuickAccessButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 学业总览卡片（保持原样）
struct AcademicOverviewCard: View {
    @EnvironmentObject var loc: LocalizationService
    
    private let highlights: [CourseSummary] = [
        .init(name: "数据方法与健康研究", grade: 87, trend: "up"),
        .init(name: "数据科学与统计", grade: 72, trend: "stable"),
        .init(name: "健康数据科学原理", grade: 67, trend: "down")
    ]
    
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
                    Text("81.7")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "10B981"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("平均分")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "10B981"))
                            
                            Text("较上月 +2.3")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "10B981"))
                        }
                        
                        Text("🏆 一等学位水平")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "F59E0B"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(hex: "F59E0B").opacity(0.1))
                            .clipShape(Capsule())
                            .padding(.top, 2)
                    }
                }
                
                Divider()
                
                // 课程列表
                VStack(spacing: 12) {
                    ForEach(highlights) { course in
                        HStack(spacing: 12) {
                            // 趋势图标
                            Image(systemName: course.trendIcon)
                                .font(.system(size: 12))
                                .foregroundColor(course.trendColor)
                                .frame(width: 20)
                            
                            Text(course.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(course.grade) 分")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(course.gradeColor)
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
    
    private struct CourseSummary: Identifiable {
        let id = UUID()
        let name: String
        let grade: Int
        let trend: String
        
        var gradeColor: Color {
            grade >= 70 ? Color(hex: "10B981") : Color(hex: "F59E0B")
        }
        
        var trendIcon: String {
            switch trend {
            case "up": return "arrow.up.right"
            case "down": return "arrow.down.right"
            default: return "arrow.right"
            }
        }
        
        var trendColor: Color {
            switch trend {
            case "up": return Color(hex: "10B981")
            case "down": return Color(hex: "EF4444")
            default: return Color(hex: "6B7280")
            }
        }
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
                    
                    if let category = todo.category {
                        Text("·")
                            .foregroundColor(.secondary)
                        
                        Text(category)
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

// MARK: - 本周总结卡片（保持原样）
struct WeeklySummaryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "8B5CF6"))
                
                Text("📊 本周总结")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            // 统计网格
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                WeeklyStat(icon: "book.fill", value: "3", label: "门课程", color: Color(hex: "6366F1"))
                WeeklyStat(icon: "pencil", value: "2", label: "次作业", color: Color(hex: "F59E0B"))
                WeeklyStat(icon: "checkmark.circle.fill", value: "95%", label: "出勤率", color: Color(hex: "10B981"))
                WeeklyStat(icon: "person.3.fill", value: "3", label: "次小组", color: Color(hex: "EC4899"))
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

// MARK: - 出勤热力图卡片（增强版 - 显示实际热力图）
struct AttendanceHeatmapCardEnhanced: View {
    // 模拟最近4周的出勤数据（周一到周五）
    private let attendanceData: [[Bool]] = [
        // 第一周（3周前）
        [true, true, false, true, true],
        // 第二周（2周前）
        [true, true, true, true, true],
        // 第三周（上周）
        [true, false, true, true, true],
        // 第四周（本周，部分数据）
        [true, true, true, false, false]  // 假设今天是周三
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "10B981"))
                
                Text("📈 出勤热力图")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            // 热力图
            VStack(spacing: 8) {
                // 星期标签
                HStack(spacing: 0) {
                    Text("")
                        .frame(width: 40)
                    
                    ForEach(["周一", "周二", "周三", "周四", "周五"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // 热力图格子
                ForEach(0..<4) { weekIndex in
                    HStack(spacing: 8) {
                        // 周标签
                        Text("W\(weekIndex + 1)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, alignment: .leading)
                        
                        ForEach(0..<5) { dayIndex in
                            let isPresent = attendanceData[weekIndex][dayIndex]
                            let isFuture = weekIndex == 3 && dayIndex >= 3
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    isFuture ? Color.gray.opacity(0.1) :
                                    isPresent ? Color(hex: "10B981") : Color(hex: "EF4444")
                                )
                                .frame(height: 32)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // 统计摘要
            HStack(spacing: 12) {
                // 本月统计
                VStack(spacing: 8) {
                    Text("95%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "10B981"))
                    
                    Text("本月出勤率")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "10B981").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 本周统计
                VStack(spacing: 8) {
                    Text("100%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "6366F1"))
                    
                    Text("本周出勤率")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "6366F1").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // 图例
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
                    Text("未来")
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
        let now = Date()
        let hoursLeft = Calendar.current.dateComponents([.hour], from: now, to: dueDate).hour ?? 0
        return hoursLeft <= 24
    }
}