//
//  ParentDashboardView.swift
//  uniapp
//
//
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
        
        var id: String {
            switch self {
            case .settings:
                return "settings"
            case .todoDetail(let todo):
                return "todo-\(todo.id)"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 学生状态卡片
                        StudentStatusCard()
                        
                        // 即将截止的任务
                        if !appState.todoManager.upcomingDeadlines.isEmpty {
                            UpcomingDeadlinesCard(
                                onTodoTap: { todo in
                                    activeSheet = .todoDetail(todo)
                                }
                            )
                        }
                        
                        // 学业总览
                        AcademicOverviewCard()
                        
                        // 本周总结
                        WeeklySummaryCard()
                        
                        // 出勤热力图
                        AttendanceHeatmapCard()
                        
                        // 根据共享设置显示内容
                        if appState.shareGrades {
                            AssignmentProgressCard()
                        } else {
                            DataNotSharedView(dataType: "成绩信息")
                        }
                        
                        // 活动参与
                        ActivityParticipationCard()
                    }
                    .padding()
                }
            }
            .navigationTitle("家长中心")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
                }
            }
        }
    }
}

// MARK: - 学生状态卡片
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

// MARK: - 状态指示器
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

// MARK: - 学业总览卡片
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

// MARK: - 本周总结卡片
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

// MARK: - 出勤热力图卡片
struct AttendanceHeatmapCard: View {
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
            
            HStack(spacing: 12) {
                // 月度统计
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
                
                // 周度统计
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

// MARK: - 作业进度卡片
struct AssignmentProgressCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "F59E0B"))
                
                Text("📝 作业进度")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 12) {
                ProgressRow(title: "已完成", value: 12, total: 15, color: Color(hex: "10B981"))
                ProgressRow(title: "进行中", value: 2, total: 15, color: Color(hex: "F59E0B"))
                ProgressRow(title: "即将截止", value: 1, total: 15, color: Color(hex: "EF4444"))
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

struct ProgressRow: View {
    let title: String
    let value: Int
    let total: Int
    let color: Color
    
    var percentage: Double {
        Double(value) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(value)/\(total)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - 活动参与卡片
struct ActivityParticipationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "EC4899"))
                
                Text("🎯 活动参与")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 12) {
                ActivityRow(icon: "book.fill", title: "学术活动", count: 3, color: Color(hex: "6366F1"))
                ActivityRow(icon: "person.3.fill", title: "社交活动", count: 2, color: Color(hex: "EC4899"))
                ActivityRow(icon: "figure.run", title: "运动健康", count: 1, color: Color(hex: "10B981"))
            }
            
            Text("本月总计参与 6 次活动")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .padding(.top, 4)
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

struct ActivityRow: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(count) 次")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
        }
        .padding(12)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 数据未共享视图
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
