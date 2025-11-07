////

//  ParentAcademicDetailView.swift//  ParentAcademicDetailView.swift

//  uniapp//  uniapp

////

//  家长学业详情：成绩展示 + 待办事项 + AI分析//  家长学业详情：成绩展示 + 待办事项 + AI分析

////

import SwiftUI

import SwiftUI

struct ParentAcademicDetailView: View {

struct ParentAcademicDetailView: View {    @EnvironmentObject var loc: LocalizationService

    @EnvironmentObject var loc: LocalizationService    @EnvironmentObject var appState: AppState

    @EnvironmentObject var appState: AppState    

        private let courses: [CourseSummary] = [

    private let courses: [CourseSummary] = [        .init(name: "数据方法与健康研究", grade: 87, assignments: 100, participation: 100, average: 65),

        .init(name: "数据方法与健康研究", grade: 87, assignments: 100, participation: 100, average: 65),        .init(name: "数据科学与统计", grade: 72, assignments: 75, participation: 95, average: 68),

        .init(name: "数据科学与统计", grade: 72, assignments: 75, participation: 95, average: 68),        .init(name: "健康数据科学原理", grade: 67, assignments: 80, participation: 100, average: 70)

        .init(name: "健康数据科学原理", grade: 67, assignments: 80, participation: 100, average: 70)    ]

    ]    

        @State private var selectedTab = 0

    @State private var selectedTab = 0    

        var body: some View {

    var body: some View {        VStack(spacing: 0) {

        VStack(spacing: 0) {            // 顶部Tab切换

            // 顶部Tab切换            segmentedControl

            segmentedControl            

                        ScrollView(showsIndicators: false) {

            ScrollView(showsIndicators: false) {                VStack(spacing: 24) {

                VStack(spacing: 24) {                    if selectedTab == 0 {

                    if selectedTab == 0 {                        // 成绩概览tab

                        // 成绩概览tab                        overallSummary

                        overallSummary                        aiInsights

                        aiInsights                        courseList

                        courseList                        performanceTrend

                        performanceTrend                    } else {

                    } else {                        // 待办事项tab

                        // 待办事项tab                        todoSection

                        todoSection                    }

                    }                }

                }                .padding(.vertical, 20)

                .padding(.vertical, 20)            }

            }        }

        }        .navigationTitle(loc.tr("parent_academic_detail_title"))

        .navigationTitle("学业总览")        .navigationBarTitleDisplayMode(.inline)

        .navigationBarTitleDisplayMode(.inline)    }

    }    

        private var segmentedControl: some View {

    // MARK: - Tab切换控制        HStack(spacing: 0) {

    private var segmentedControl: some View {            TabButton(title: "成绩概览", isSelected: selectedTab == 0) {

        HStack(spacing: 0) {                withAnimation(.spring(response: 0.3)) {

            TabButton(title: "成绩概览", isSelected: selectedTab == 0) {                    selectedTab = 0

                withAnimation(.spring(response: 0.3)) {                }

                    selectedTab = 0            }

                }            

            }            TabButton(title: "待办事项", isSelected: selectedTab == 1) {

                            withAnimation(.spring(response: 0.3)) {

            TabButton(title: "待办事项", isSelected: selectedTab == 1) {                    selectedTab = 1

                withAnimation(.spring(response: 0.3)) {                }

                    selectedTab = 1            }

                }        }

            }        .padding(.horizontal)

        }        .padding(.top, 12)

        .padding(.horizontal)        .padding(.bottom, 8)

        .padding(.top, 12)        .background(Color(UIColor.systemBackground))

        .padding(.bottom, 8)    }

        .background(Color(UIColor.systemBackground))    

    }    private var overallSummary: some View {

            VStack(spacing: 16) {

    // MARK: - 总体成绩概览            Text("79.6 分")

    private var overallSummary: some View {                .font(.system(size: 48, weight: .bold))

        VStack(spacing: 16) {                .foregroundColor(.primary)

            Text("81.7 分")            

                .font(.system(size: 48, weight: .bold))            Text("🏆 一等学位水平")

                .foregroundColor(.primary)                .font(.system(size: 16, weight: .semibold))

                            .foregroundColor(Color(hex: "F59E0B"))

            Text("🏆 一等学位水平")                .padding(.horizontal, 16)

                .font(.system(size: 16, weight: .semibold))                .padding(.vertical, 8)

                .foregroundColor(Color(hex: "F59E0B"))                .background(Color(hex: "F59E0B").opacity(0.1))

                .padding(.horizontal, 16)                .clipShape(Capsule())

                .padding(.vertical, 8)            

                .background(Color(hex: "F59E0B").opacity(0.1))            HStack(spacing: 4) {

                .clipShape(Capsule())                Image(systemName: "arrow.up.right")

                                .foregroundColor(Color(hex: "10B981"))

            HStack(spacing: 24) {                Text("+2.3 分")

                StatItem(icon: "chart.line.uptrend.xyaxis", value: "Top 15%", label: "班级排名")                    .font(.system(size: 16, weight: .semibold))

                Divider().frame(height: 40)                    .foregroundColor(Color(hex: "10B981"))

                StatItem(icon: "arrow.up.right", value: "+2.3", label: "较上月", color: Color(hex: "10B981"))                Text("比上月进步")

                Divider().frame(height: 40)                    .font(.system(size: 14))

                StatItem(icon: "checkmark.circle.fill", value: "85%", label: "作业完成率")                    .foregroundColor(.secondary)

            }            }

        }        }

        .frame(maxWidth: .infinity)        .frame(maxWidth: .infinity)

        .padding(24)        .padding()

        .background(        .background(

            RoundedRectangle(cornerRadius: 16)            RoundedRectangle(cornerRadius: 16)

                .fill(Color.white)                .fill(Color.white)

                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)

        )        )

        .padding(.horizontal)        .padding(.horizontal)

    }    }

        

    // MARK: - AI智能分析    private var courseList: some View {

    private var aiInsights: some View {        VStack(alignment: .leading, spacing: 16) {

        VStack(alignment: .leading, spacing: 16) {            Text("📚 各科成绩")

            HStack {                .font(.system(size: 18, weight: .bold))

                Image(systemName: "sparkles")                .padding(.horizontal)

                    .font(.system(size: 16))            

                    .foregroundColor(Color(hex: "8B5CF6"))            ForEach(courses) { course in

                                CourseSummaryRow(course: course)

                Text("AI 学业分析")                    .padding(.horizontal)

                    .font(.system(size: 18, weight: .bold))            }

            }        }

                }

            VStack(alignment: .leading, spacing: 12) {}

                InsightRow(

                    icon: "chart.bar.fill",private struct CourseSummaryRow: View {

                    color: "10B981",    let course: CourseSummary

                    title: "强项学科",    

                    content: "数据方法与健康研究表现优异（87分），实践能力突出"    private var gradeColor: Color {

                )        switch course.grade {

                        case 70...:

                InsightRow(            return Color(hex: "10B981")

                    icon: "lightbulb.fill",        case 60..<70:

                    color: "F59E0B",            return Color(hex: "F59E0B")

                    title: "提升建议",        default:

                    content: "数据科学与统计需加强（72分），建议增加练习时间，提高作业完成率"            return Color(hex: "EF4444")

                )        }

                    }

                InsightRow(    

                    icon: "target",    var body: some View {

                    color: "6366F1",        VStack(alignment: .leading, spacing: 12) {

                    title: "目标预测",            HStack {

                    content: "按当前进度，期末预计可达83-85分，有望获得优等学位"                VStack(alignment: .leading, spacing: 4) {

                )                    Text(course.name)

                                        .font(.system(size: 16, weight: .semibold))

                InsightRow(                        .foregroundColor(.primary)

                    icon: "person.2.fill",                    Text("平均分: \(course.average)")

                    color: "EC4899",                        .font(.system(size: 12))

                    title: "学习习惯",                        .foregroundColor(.secondary)

                    content: "课堂参与度高（平均95%），建议保持并多参加Study Group"                }

                )                Spacer()

            }                Text("\(course.grade) 分")

        }                    .font(.system(size: 18, weight: .bold))

        .padding(20)                    .foregroundColor(gradeColor)

        .background(            }

            RoundedRectangle(cornerRadius: 16)            

                .fill(Color.white)            HStack(spacing: 16) {

                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)                metric(title: "作业完成度", value: "\(course.assignments)%", highlight: course.assignments >= 80)

        )                metric(title: "课堂参与", value: "\(course.participation)%", highlight: course.participation >= 90)

        .padding(.horizontal)            }

    }        }

            .padding(16)

    // MARK: - 各科成绩列表        .background(

    private var courseList: some View {            RoundedRectangle(cornerRadius: 16)

        VStack(alignment: .leading, spacing: 16) {                .fill(Color.white)

            Text("📚 各科详情")                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)

                .font(.system(size: 18, weight: .bold))        )

                .padding(.horizontal)    }

                

            ForEach(courses) { course in    private func metric(title: String, value: String, highlight: Bool) -> some View {

                CourseSummaryCard(course: course)        VStack(alignment: .leading, spacing: 4) {

                    .padding(.horizontal)            Text(title)

            }                .font(.system(size: 11))

        }                .foregroundColor(.secondary)

    }            Text(value)

                    .font(.system(size: 13, weight: .semibold))

    // MARK: - 成绩趋势                .foregroundColor(highlight ? Color(hex: "10B981") : Color(hex: "F59E0B"))

    private var performanceTrend: some View {        }

        VStack(alignment: .leading, spacing: 16) {    }

            Text("📈 成绩趋势")}

                .font(.system(size: 18, weight: .bold))

                .padding(.horizontal)private struct CourseSummary: Identifiable {

                let id = UUID()

            VStack(spacing: 12) {    let name: String

                TrendRow(month: "9月", score: 79.2, change: 0)    let grade: Int

                TrendRow(month: "10月", score: 79.4, change: +0.2)    let assignments: Int

                TrendRow(month: "11月", score: 81.7, change: +2.3)    let participation: Int

            }    let average: Int

            .padding(16)}

            .background(

                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - 待办事项区域
    private var todoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if appState.todoManager.todos.isEmpty {
                EmptyTodoView()
            } else {
                ForEach(appState.todoManager.todos.filter { !$0.isCompleted }.prefix(10)) { todo in
                    ParentTodoCard(todo: todo)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Tab按钮组件
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? Color(hex: "6366F1") : .secondary)
                
                Rectangle()
                    .fill(isSelected ? Color(hex: "6366F1") : Color.clear)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 统计项组件
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = Color(hex: "6366F1")
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - AI洞察行组件
struct InsightRow: View {
    let icon: String
    let color: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(content)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - 课程成绩卡片
struct CourseSummaryCard: View {
    let course: CourseSummary
    
    private var gradeColor: Color {
        switch course.grade {
        case 70...:
            return Color(hex: "10B981")
        case 60..<70:
            return Color(hex: "F59E0B")
        default:
            return Color(hex: "EF4444")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("班级平均: \(course.average)分")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(course.grade)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(gradeColor)
                    
                    Text("分")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            // 作业和参与度进度条
            VStack(spacing: 12) {
                ProgressRow(label: "作业完成", value: course.assignments, color: "6366F1")
                ProgressRow(label: "课堂参与", value: course.participation, color: "10B981")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

// MARK: - 进度条组件
struct ProgressRow: View {
    let label: String
    let value: Int
    let color: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(value)%")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: color))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(Color(hex: color))
                        .frame(width: geometry.size.width * CGFloat(value) / 100, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - 趋势行组件
struct TrendRow: View {
    let month: String
    let score: Double
    let change: Double
    
    var body: some View {
        HStack {
            Text(month)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
            
            Text(String(format: "%.1f", score))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            if change > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                    Text(String(format: "+%.1f", change))
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(Color(hex: "10B981"))
            } else if change < 0 {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 12))
                    Text(String(format: "%.1f", change))
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(Color(hex: "EF4444"))
            } else {
                Text("—")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 家长待办卡片
struct ParentTodoCard: View {
    let todo: TodoItem
    
    private var urgencyColor: Color {
        guard let dueDate = todo.dueDate else { return Color(hex: "6B7280") }
        let interval = dueDate.timeIntervalSince(Date())
        
        if interval < 0 {
            return Color(hex: "EF4444")
        } else if interval < 86400 {
            return Color(hex: "F59E0B")
        } else {
            return Color(hex: "6366F1")
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(urgencyColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(urgencyColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(todo.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(todo.category)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if let dueDate = todo.dueDate {
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(dueDate, style: .date)
                            .font(.system(size: 12))
                            .foregroundColor(urgencyColor)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - 空待办视图
struct EmptyTodoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "10B981"))
            
            Text("所有任务都已完成！")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("孩子表现很棒，暂无待办事项")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

struct CourseSummary: Identifiable {
    let id = UUID()
    let name: String
    let grade: Int
    let assignments: Int
    let participation: Int
    let average: Int
}
