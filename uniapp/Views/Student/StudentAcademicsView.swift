import SwiftUI
import Foundation // 需要用于 UUID 和 Date

// MARK: - 3. 主视图 (StudentAcademicsView)
// (这是你的主文件)

struct StudentAcademicsView: View {
    @EnvironmentObject var loc: LocalizationService
    
    // 使用 @StateObject 在这里创建和持有 ViewModel 实例
    @StateObject private var viewModel = AcademicViewModel()
    @EnvironmentObject var appState: AppState
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
    @State private var selectedTab: AcademicsTab = .overview
    @State private var showingAddModule = false
    @State private var selectedTodo: TodoItem?
    
    // 统一的即将截止数据源（与首页同步）
    private var upcomingDeadlines: [TodoItem] {
        let active = appState.todoManager.todos.filter { !$0.isCompleted }
        let sorted = active.sorted { lhs, rhs in
            let lhsDate = lhs.dueDate ?? Date.distantFuture
            let rhsDate = rhs.dueDate ?? Date.distantFuture
            return lhsDate < rhsDate
        }
        return Array(sorted.prefix(3))
    }
    
    enum AcademicsTab {
        case overview, inProgress, completed
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(
                    colors: [Color(hex: "F8F9FF"), Color(hex: "EEF2FF")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // GPA 总览卡片 (自动使用 viewModel.currentGPA)
                        gpaOverviewCard
                        
                        // 分段控制器
                        segmentedControl
                        
                        // 内容区域
                        switch selectedTab {
                        case .overview:
                            overviewSection
                        case .inProgress:
                            inProgressSection
                        case .completed:
                            completedSection
                        }
                    }
                    .padding(.horizontal, 16)
                    .id(appState.todoManager.todos.count) // 强制刷新当 todos 变化时
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("学业")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddModule = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }
            .sheet(isPresented: $showingAddModule) {
                // 使用全新的 AddModuleView
                AddModuleView(viewModel: viewModel)
            }
        }
        // !! 重要：为 NavigationView 注入 viewModel，
        // 这样所有 NavigationLink 都能访问到它
        .environmentObject(viewModel)
    }
    
    // MARK: - GPA Overview Card
    private var gpaOverviewCard: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("当前 GPA")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            // **自动更新**
                            Text(String(format: "%.2f", viewModel.currentGPA))
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("/ 4.0")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // ... (gpaChange 模拟数据) ...
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.gpaChange >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .font(.system(size: 12))
                            Text(String(format: "%+.2f", viewModel.gpaChange))
                                .font(.system(size: 12, weight: .semibold))
                            Text("vs 上学期")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 12) {
                        gpaStatPill(label: "学分", value: "\(viewModel.completedCredits)")
                        gpaStatPill(label: "课程", value: "\(viewModel.completedCourses)/\(viewModel.totalCourses)")
                        gpaStatPill(label: "等级", value: viewModel.gradeLevel) // 自动计算
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 160)
        .shadow(color: Color(hex: "6366F1").opacity(0.2), radius: 12, x: 0, y: 6)
    }
    
    private func gpaStatPill(label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.18))
        .clipShape(Capsule())
    }
    
    // MARK: - Segmented Control
    private var segmentedControl: some View {
        HStack(spacing: 0) {
            segmentButton(tab: .overview, title: "总览", icon: "chart.bar.fill")
            segmentButton(tab: .inProgress, title: "进行中", icon: "clock.fill")
            segmentButton(tab: .completed, title: "已完成", icon: "checkmark.circle.fill")
        }
        .padding(4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
    
    private func segmentButton(tab: AcademicsTab, title: String, icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(selectedTab == tab ? .white : Color(hex: "6B7280"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                selectedTab == tab ?
                    LinearGradient(
                        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                : nil
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(spacing: 16) {
            quickStatsGrid
            moduleStatusSummary
            upcomingAssignmentsSection
        }
    }
    
    private var quickStatsGrid: some View {
        HStack(spacing: 10) {
            quickStatCard(
                icon: "star.fill",
                title: "最高分",
                value: "\(Int(viewModel.highestGrade.rounded()))%", // 自动计算
                color: Color(hex: "10B981")
            )
            
            quickStatCard(
                icon: "chart.bar.fill",
                title: "平均分",
                value: "\(Int(viewModel.averageGrade.rounded()))%", // 自动计算
                color: Color(hex: "6366F1")
            )
            
            quickStatCard(
                icon: "clock.badge.exclamationmark.fill",
                title: "待交",
                value: "\(viewModel.pendingAssignments)", // 自动计算
                color: Color(hex: "F59E0B")
            )
        }
    }
    
    private var moduleStatusSummary: some View {
        HStack(spacing: 12) {
            statusCard(
                title: "进行中",
                value: "\(viewModel.inProgressModules.count)",
                detail: "课程",
                colors: [Color(hex: "7C3AED"), Color(hex: "A78BFA")]
            )
            statusCard(
                title: "已结课",
                value: "\(viewModel.completedModules.count)",
                detail: "课程",
                colors: [Color(hex: "C084FC"), Color(hex: "E0C3FC")]
            )
        }
    }
    
    private func statusCard(title: String, value: String, detail: String, colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            Text(detail)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        )
    }
    
    private func quickStatCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    private var upcomingAssignmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "F59E0B"))
                
                Text("即将截止")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
                Text("\(upcomingDeadlines.count) 项")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            if upcomingDeadlines.isEmpty {
                emptyStateView(
                    icon: "checkmark.circle.fill",
                    message: "暂无待办事项",
                    color: Color(hex: "10B981")
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(upcomingDeadlines) { todo in
                        UpcomingTodoCard(todo: todo)
                            .onTapGesture {
                                selectedTodo = todo
                            }
                    }
                }
            }
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
    
    // MARK: - In Progress Section
    private var inProgressSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.inProgressModules) { module in
                // **重要**：
                // 1. NavigationLink 在这里
                // 2. 目标是 ModuleDetailView
                // 3. .environmentObject(viewModel) 已经由顶层 NavigationView 注入
                NavigationLink(destination: ModuleDetailView(module: module)) {
                    InProgressModuleCard(module: module) {
                        viewModel.markModule(module, completed: true)
                    }
                }
                .buttonStyle(.plain)
            }
            
            if viewModel.inProgressModules.isEmpty {
                emptyStateView(
                    icon: "graduationcap.fill",
                    message: "当前没有进行中的课程",
                    color: Color(hex: "6366F1")
                )
            }
        }
    }
    
    // MARK: - Completed Section
    private var completedSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.completedModules) { module in
                // **崩溃修复**：
                // 1. NavigationLink 在这里
                // 2. 目标是 ModuleDetailView
                // 3. .environmentObject(viewModel) 已经由顶层 NavigationView 注入
                NavigationLink(destination: ModuleDetailView(module: module)) {
                    // 4. CompletedModuleCard (修复版) 只负责显示 UI
                    CompletedModuleCard(module: module) {
                        viewModel.markModule(module, completed: false)
                    }
                }
                .buttonStyle(.plain)
            }
            
            if viewModel.completedModules.isEmpty {
                emptyStateView(
                    icon: "books.vertical.fill",
                    message: "暂无已完成课程",
                    color: Color(hex: "6B7280")
                )
            }
        }
    }
    
    // MARK: - Empty State View
    private func emptyStateView(icon: String, message: String, color: Color) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}


// MARK: - 4. 卡片视图 (Cards)

struct InProgressModuleCard: View {
    @EnvironmentObject var loc: LocalizationService
    let module: Module
    let markComplete: () -> Void
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.displayName(isChinese: isChinese))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(module.code)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    // **适配**：使用 predictedMark
                    let predictedMark = module.predictedMark
                    if predictedMark > 0 {
                        Text("\(Int(predictedMark.rounded()))%")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "8B5CF6"))
                        
                        Text("预估")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    } else {
                        Text("进行中")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "F59E0B"))
                    }
                }
            }
            
            // 进度条 (使用自动计算的 progressPercentage)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.15))
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * module.progressPercentage) // **适配**
                }
            }
            .frame(height: 5)
            
            HStack {
                Text("\(Int(module.progressPercentage * 100))% 完成") // **适配**
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text("已出分: \(module.completedAssignments)/\(module.totalAssignments)")
                     .font(.system(size: 11, weight: .medium))
                     .foregroundColor(.secondary)
            }
                
            Button {
                markComplete()
            } label: {
                Text("标记为已结课")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "7C3AED"))
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "7C3AED").opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}


struct CompletedModuleCard: View {
    @EnvironmentObject var loc: LocalizationService
    let module: Module
    let markInProgress: () -> Void
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
    var body: some View {
        // **崩溃修复**：
        // 删除了此处的 NavigationLink。
        // 它现在只是一个普通的 HStack，由外部的 NavigationLink 包裹。
        HStack(spacing: 14) {
            // 成绩显示
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(gradeColor(module.finalMark).opacity(0.12)) // **适配**
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 2) {
                    Text("\(Int(module.finalMark.rounded()))") // **适配**
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(gradeColor(module.finalMark)) // **适配**
                    
                    Text(gradeLabel(module.finalMark)) // **适配**
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(gradeColor(module.finalMark)) // **适配**
                }
            }
            
            // 课程信息
            VStack(alignment: .leading, spacing: 6) {
                Text(module.displayName(isChinese: isChinese))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Text(module.code)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(module.credits) 学分")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // (移除了 "vs 平均" 的对比，因为新模型中默认没有班级平均分)
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
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
        .contextMenu {
            Button("移回进行中") {
                markInProgress()
            }
        }
    }
    
    // (辅助函数)
    private func gradeColor(_ mark: Double) -> Color {
        if mark >= 70 { return Color(hex: "10B981") }
        if mark >= 60 { return Color(hex: "8B5CF6") }
        if mark >= 50 { return Color(hex: "F59E0B") }
        return Color(hex: "EF4444")
    }
    
    private func gradeLabel(_ mark: Double) -> String {
        if mark >= 70 { return "FIRST" }
        if mark >= 60 { return "2:1" }
        if mark >= 50 { return "2:2" }
        if mark >= 40 { return "THIRD" }
        return "FAIL"
    }
}


// MARK: - Upcoming Todo Card (与首页同步)
struct UpcomingTodoCard: View {
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

struct UpcomingAssignmentCard: View {
    let assignment: AcademicAssignment
    
    // (这部分视图和逻辑与你的原始代码保持一致)
    private var daysUntilDue: Int {
        let calendar = Calendar.current
        let now = Date()
        return calendar.dateComponents([.day], from: now, to: assignment.dueDate).day ?? 0
    }
    
    private var urgencyColor: Color {
        if daysUntilDue <= 2 { return Color(hex: "EF4444") }
        if daysUntilDue <= 5 { return Color(hex: "F59E0B") }
        return Color(hex: "6366F1")
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(urgencyColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                VStack(spacing: 0) {
                    Text("\(daysUntilDue)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(urgencyColor)
                    
                    Text("天")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(urgencyColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(assignment.course)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(assignment.dueDate, style: .date)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(urgencyColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}


// MARK: - 5. 课程详情页 (ModuleDetailView)
// (全新重构，用于显示和编辑分数)

struct ModuleDetailView: View {
    @EnvironmentObject var viewModel: AcademicViewModel
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    
    // 使用 @State 来管理模块的本地副本，以便编辑
    @State private var module: Module
    private var originalModule: Module // 存储原始数据
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
    // 跟踪是否有改动
    private var hasChanges: Bool {
        module != originalModule
    }
    
    init(module: Module) {
        self._module = State(initialValue: module)
        self.originalModule = module
    }
    
    var body: some View {
        ZStack {
            // 背景色
            LinearGradient(
                colors: [Color(hex: "F8F9FF"), Color(hex: "EEF2FF")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 课程基本信息卡片
                    moduleInfoCard
                    
                    // 成绩构成 (新)
                    gradeBreakdownSection
                }
                .padding(16)
            }
        }
        .navigationTitle("课程详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 仅当有改动时显示 "保存" 按钮
            if hasChanges {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.updateModule(module)
                        // dismiss() // (可选) 保存后自动退出
                    }
                    .foregroundColor(Color(hex: "6366F1"))
                }
            }
        }
    }
    
    // 卡片 1: 课程信息 (显示自动计算的分数)
    private var moduleInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(module.displayName(isChinese: isChinese))
                        .font(.system(size: 18, weight: .bold))
                    Text(module.code)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("\(module.credits) 学分")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 显示预估分或最终分
                VStack(spacing: 4) {
                    // **适配**：根据是否完成显示不同分数
                    let mark = module.isCompleted ? module.finalMark : module.predictedMark
                    Text(String(format: "%.1f", mark))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(gradeColor(mark))
                    Text(module.isCompleted ? "最终成绩" : "预估成绩")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // 状态切换 (绑定到 @State 副本)
            Toggle("课程已结课", isOn: $module.isCompleted.animation())
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "7C3AED")))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    // 卡片 2: 成绩构成 (可编辑)
    private var gradeBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 成绩构成")
                .font(.system(size: 16, weight: .bold))
            
            // 循环 $module.assessments，使其可绑定
            ForEach($module.assessments) { $assessment in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(assessment.name)
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        Text("权重 \(assessment.weight, specifier: "%.0f")%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // **核心：分数输入框**
                    HStack {
                        Text("得分 (%)")
                        Spacer()
                        // 使用 TextField 来绑定 score (Double?)
                        TextField("未出分", value: $assessment.score, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "6366F1"))
                            .frame(maxWidth: 80)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
    
    // (辅助函数)
    private func gradeColor(_ mark: Double) -> Color {
        if mark >= 70 { return Color(hex: "10B981") }
        if mark >= 60 { return Color(hex: "8B5CF6") }
        if mark >= 50 { return Color(hex: "F59E0B") }
        return Color(hex: "EF4444")
    }
}


// MARK: - 6. 添加课程页 (AddModuleView)
// (全新重构，支持动态考核项)

struct AddModuleView: View {
    @ObservedObject var viewModel: AcademicViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var code: String = ""
    @State private var credits: Int = 15
    @State private var isCompleted = false
    
    // 关键: 临时的考核项数组
    @State private var assessments: [Assessment] = [
        // 默认提供一个模板
        Assessment(name: "期末考试", weight: 100.0, score: nil)
    ]
    
    // 检查权重总和
    private var totalWeight: Double {
        assessments.reduce(0) { $0 + $1.weight }
    }
    
    // 检查是否可以保存
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !code.trimmingCharacters(in: .whitespaces).isEmpty &&
        totalWeight == 100.0 // 必须为 100
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Section 1: 课程基本信息
                Section(header: Text("课程信息")) {
                    TextField("课程名称", text: $name)
                    TextField("课程代码", text: $code)
                        .textInputAutocapitalization(.characters)
                    Stepper("学分：\(credits)", value: $credits, in: 0...60, step: 15)
                    Toggle("课程已结课", isOn: $isCompleted.animation())
                }
                
                // Section 2: 考核构成 (动态)
                Section(header: assessmentHeader) {
                    // 循环显示所有考核项
                    ForEach($assessments) { $assessment in
                        assessmentEditorRow(for: $assessment)
                    }
                    .onDelete(perform: removeAssessment) // 允许左滑删除
                    
                    // 添加新考核项的按钮
                    Button(action: addAssessment) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("添加考核项")
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // 如果是“已结课”，提供输入分数的地方
                if isCompleted {
                    Section(header: Text("输入最终成绩")) {
                        ForEach($assessments) { $assessment in
                            HStack {
                                Text(assessment.name)
                                Spacer()
                                TextField("得分", value: $assessment.score, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: 80)
                            }
                        }
                    }
                }
            }
            .navigationTitle("添加课程")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveModule()
                        dismiss()
                    }
                    .disabled(!canSave) // 如果权重不为100或信息不全，则禁用
                }
            }
        }
    }
    
    // 考核 Section 的 Header，动态显示权重总和
    private var assessmentHeader: some View {
        HStack {
            Text("考核构成")
            Spacer()
            Text("总权重: \(totalWeight, specifier: "%.0f")%")
                .foregroundColor(totalWeight == 100 ? .green : .red)
                .font(.caption.bold())
        }
    }
    
    /// 单个考核项的编辑行
    private func assessmentEditorRow(for assessment: Binding<Assessment>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("考核项名称 (例如: 期末考试)", text: assessment.name)
                .font(.system(size: 15))
            
            HStack {
                Text("权重 (%)")
                Spacer()
                TextField("Weight", value: assessment.weight, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 80)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 辅助功能
    
    private func addAssessment() {
        // 添加一个新的、空白的考核项
        assessments.append(Assessment(name: "", weight: 0, score: nil))
    }
    
    private func removeAssessment(at offsets: IndexSet) {
        assessments.remove(atOffsets: offsets)
    }
    
    private func saveModule() {
        guard canSave else { return }
        viewModel.addModule(
            name: name,
            code: code,
            credits: credits,
            assessments: assessments,
            isCompleted: isCompleted
        )
    }
}


// MARK: - 7. 辅助工具 (Helpers)

// MARK: - 8. 预览 (Preview)

struct StudentAcademicsView_Previews: PreviewProvider {
    static var previews: some View {
        StudentAcademicsView()
            .environmentObject(LocalizationService())
    }
}
