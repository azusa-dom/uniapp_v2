
//
//  StudentAcademicsView.swift
//  uniapp
//
//  Created on 2024.
//

import SwiftUI

// MARK: - 数据模型

struct Module: Identifiable {
    let id = UUID()
    var name: String
    var code: String
    var mark: Double
    var assignments: Double
    var participation: Double
    var midterm: Double
    var final: Double
    var moduleAverage: Int
    var assignmentList: [ModuleAssignment]
    
    init(name: String, code: String, mark: Double, assignments: Double, participation: Double, midterm: Double, final: Double, moduleAverage: Int = 65, assignmentList: [ModuleAssignment] = []) {
        self.name = name
        self.code = code
        self.mark = mark
        self.assignments = assignments
        self.participation = participation
        self.midterm = midterm
        self.final = final
        self.moduleAverage = moduleAverage
        self.assignmentList = assignmentList
    }
    
    var gradeBreakdown: [GradeComponent] {
        return [
            GradeComponent(component: "作业", weight: 40, grade: Int(assignments)),
            GradeComponent(component: "课堂参与", weight: 10, grade: Int(participation)),
            GradeComponent(component: "期中考试", weight: 25, grade: Int(midterm)),
            GradeComponent(component: "期末考试", weight: 25, grade: Int(final))
        ]
    }
    
    struct ModuleAssignment: Identifiable {
        let id = UUID()
        var name: String
        var grade: Int
        var submitted: Bool
        var dueDate: String
    }
    
    struct GradeComponent: Identifiable {
        let id = UUID()
        var component: String
        var weight: Int
        var grade: Int
    }
}

struct Assignment: Identifiable {
    let id = UUID()
    var title: String
    var course: String
    var score: Double
    var total: Double
    var isCompleted: Bool
}

struct WeeklySchedule: Identifiable {
    let id = UUID()
    var dayOfWeek: String
    var courseName: String
    var courseCode: String
    var time: String
    var location: String
    var color: String
}

// MARK: - ViewModel

class AcademicViewModel: ObservableObject {
    @Published var modules: [Module] = [
        Module(
            name: "数据方法与健康研究",
            code: "CHME0013",
            mark: 87,
            assignments: 90,
            participation: 95,
            midterm: 85,
            final: 86,
            moduleAverage: 65,
            assignmentList: [
                .init(name: "数据分析作业", grade: 90, submitted: true, dueDate: "11月1日"),
                .init(name: "Python 项目", grade: 88, submitted: true, dueDate: "10月20日"),
                .init(name: "统计习题集", grade: 0, submitted: false, dueDate: "11月8日"),
                .init(name: "研究设计报告", grade: 0, submitted: false, dueDate: "11月20日"),
                .init(name: "模拟试卷", grade: 0, submitted: false, dueDate: "12月1日")
            ]
        ),
        Module(
            name: "数据科学与统计",
            code: "CHME0007",
            mark: 72,
            assignments: 75,
            participation: 80,
            midterm: 68,
            final: 70,
            moduleAverage: 68,
            assignmentList: [
                .init(name: "回归分析", grade: 75, submitted: true, dueDate: "10月15日"),
                .init(name: "统计建模", grade: 0, submitted: false, dueDate: "11月10日"),
                .init(name: "多元分析练习", grade: 0, submitted: false, dueDate: "11月25日"),
                .init(name: "概率论小测", grade: 0, submitted: false, dueDate: "12月3日")
            ]
        ),
        Module(
            name: "健康数据科学原理",
            code: "CHME0006",
            mark: 67,
            assignments: 70,
            participation: 75,
            midterm: 62,
            final: 65,
            moduleAverage: 62,
            assignmentList: [
                .init(name: "文献综述作业", grade: 76, submitted: true, dueDate: "10月30日"),
                .init(name: "数据系统案例分析", grade: 0, submitted: false, dueDate: "11月18日"),
                .init(name: "小组讨论演示", grade: 0, submitted: false, dueDate: "11月28日"),
                .init(name: "模块测验", grade: 0, submitted: false, dueDate: "12月5日")
            ]
        ),
        Module(
            name: "Python 健康研究编程",
            code: "CHME0011",
            mark: 86,
            assignments: 88,
            participation: 90,
            midterm: 84,
            final: 86,
            moduleAverage: 70,
            assignmentList: [
                .init(name: "数据清洗项目", grade: 88, submitted: true, dueDate: "10月5日"),
                .init(name: "可视化作业", grade: 90, submitted: true, dueDate: "10月25日"),
                .init(name: "脚本优化练习", grade: 0, submitted: false, dueDate: "11月15日"),
                .init(name: "Pandas 期末练习", grade: 0, submitted: false, dueDate: "11月30日"),
                .init(name: "代码规范检查", grade: 0, submitted: false, dueDate: "12月6日")
            ]
        ),
        Module(
            name: "数据科学流行病学",
            code: "CHME0008",
            mark: 69,
            assignments: 72,
            participation: 78,
            midterm: 65,
            final: 68,
            moduleAverage: 64,
            assignmentList: [
                .init(name: "研究设计报告", grade: 72, submitted: true, dueDate: "11月10日"),
                .init(name: "数据集清理练习", grade: 0, submitted: false, dueDate: "11月28日"),
                .init(name: "流行病模型推导", grade: 0, submitted: false, dueDate: "12月5日"),
                .init(name: "R 代码应用测试", grade: 0, submitted: false, dueDate: "12月8日")
            ]
        ),
        Module(
            name: "医疗人工智能",
            code: "CHME0016",
            mark: 91,
            assignments: 93,
            participation: 95,
            midterm: 88,
            final: 90,
            moduleAverage: 72,
            assignmentList: [
                .init(name: "CNN 图像分类", grade: 93, submitted: true, dueDate: "10月18日"),
                .init(name: "NLP 文本分析", grade: 95, submitted: true, dueDate: "11月2日"),
                .init(name: "Transformer 文献讨论", grade: 0, submitted: false, dueDate: "11月25日"),
                .init(name: "期末模型复现", grade: 0, submitted: false, dueDate: "12月10日")
            ]
        ),
        Module(
            name: "医疗高级机器学习",
            code: "CHME0017",
            mark: 85,
            assignments: 87,
            participation: 90,
            midterm: 82,
            final: 84,
            moduleAverage: 68
        ),
        Module(
            name: "Essentials of Informatics for Healthcare Systems",
            code: "CHME0021",
            mark: 0,
            assignments: 0,
            participation: 0,
            midterm: 0,
            final: 0,
            moduleAverage: 66,
            assignmentList: [
                .init(name: "HL7/FHIR 解析作业", grade: 0, submitted: false, dueDate: "11月22日"),
                .init(name: "医院 IT 基础设施分析", grade: 0, submitted: false, dueDate: "12月1日")
            ]
        ),
        Module(
            name: "Applied Computational Genomics",
            code: "CHME0012",
            mark: 0,
            assignments: 0,
            participation: 0,
            midterm: 0,
            final: 0,
            moduleAverage: 64,
            assignmentList: [
                .init(name: "SNP 变异分析", grade: 0, submitted: false, dueDate: "11月30日"),
                .init(name: "基因组可视化报告", grade: 0, submitted: false, dueDate: "12月12日")
            ]
        ),
        Module(
            name: "Health Economics & Decision Modelling",
            code: "CHME0030",
            mark: 0,
            assignments: 0,
            participation: 0,
            midterm: 0,
            final: 0,
            moduleAverage: 63,
            assignmentList: [
                .init(name: "决策树模型构建", grade: 0, submitted: false, dueDate: "11月27日"),
                .init(name: "Markov 模型小组项目", grade: 0, submitted: false, dueDate: "12月10日")
            ]
        )
    ]
    
    @Published var assignments: [Assignment] = [
        Assignment(title: "数据分析作业", course: "数据方法", score: 90, total: 100, isCompleted: true),
        Assignment(title: "Python 项目", course: "Python 编程", score: 88, total: 100, isCompleted: true),
        Assignment(title: "统计习题集", course: "数据科学与统计", score: 75, total: 100, isCompleted: true),
        Assignment(title: "AI 模型训练", course: "医疗人工智能", score: 93, total: 100, isCompleted: true),
        Assignment(title: "回归分析报告", course: "数据科学与统计", score: 0, total: 100, isCompleted: false),
        Assignment(title: "流行病学案例分析", course: "数据科学流行病学", score: 72, total: 100, isCompleted: true),
    ]
    
    @Published var weeklySchedule: [WeeklySchedule] = [
        WeeklySchedule(dayOfWeek: "周一", courseName: "数据方法与健康研究", courseCode: "CHME0013", time: "10:00 - 12:00", location: "Cruciform Building B.3.05", color: "6366F1"),
        WeeklySchedule(dayOfWeek: "周二", courseName: "数据科学与统计", courseCode: "CHME0007", time: "14:00 - 16:00", location: "Foster Court 114", color: "8B5CF6"),
        WeeklySchedule(dayOfWeek: "周三", courseName: "Python 健康研究编程", courseCode: "CHME0011", time: "09:00 - 11:00", location: "Roberts Building G06 Sir Ambrose Fleming LT", color: "10B981"),
        WeeklySchedule(dayOfWeek: "周四", courseName: "医疗人工智能", courseCode: "CHME0016", time: "13:00 - 15:00", location: "Cruciform Building B.4.01", color: "EF4444"),
        WeeklySchedule(dayOfWeek: "周五", courseName: "健康数据科学原理", courseCode: "CHME0006", time: "11:00 - 13:00", location: "UCL East Building One 1.03", color: "F59E0B")
    ]
    
    var overallAverage: Double {
        let validModules = modules.filter { $0.mark > 0 }
        if validModules.isEmpty { return 0 }
        let totalMark = validModules.reduce(0) { $0 + $1.mark }
        return totalMark / Double(validModules.count)
    }
    
    var completedModulesCount: Int {
        modules.filter { $0.mark > 0 }.count
    }
    
    var totalModulesCount: Int {
        modules.count
    }
    
    func addModule(name: String, code: String, mark: Double, assignments: Double, participation: Double, midterm: Double, final: Double) {
        modules.append(Module(
            name: name,
            code: code,
            mark: mark,
            assignments: assignments,
            participation: participation,
            midterm: midterm,
            final: final
        ))
    }
    
    func addAssignment(title: String, course: String, score: Double, total: Double, isCompleted: Bool) {
        assignments.append(Assignment(title: title, course: course, score: score, total: total, isCompleted: isCompleted))
    }
}

// MARK: - 主视图

struct StudentAcademicsView: View {
    @EnvironmentObject var loc: LocalizationService
    @StateObject private var viewModel = AcademicViewModel()
    @State private var selectedTab: AcademicsTab = .modules
    
    @State private var showingAddModule = false
    @State private var showingAddAssignment = false
    
    enum AcademicsTab {
        case modules, assignments, schedule
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Academics", selection: $selectedTab) {
                        Text(loc.tr("academics_modules")).tag(AcademicsTab.modules)
                        Text(loc.tr("academics_assignments")).tag(AcademicsTab.assignments)
                        Text("课程表").tag(AcademicsTab.schedule)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(.ultraThinMaterial)
                    
                    if selectedTab == .modules {
                        ModuleGradesView(viewModel: viewModel)
                    } else if selectedTab == .assignments {
                        AssignmentScoresView(viewModel: viewModel)
                    } else {
                        WeeklyScheduleView(viewModel: viewModel)
                    }
                }
            }
            .navigationTitle(loc.tr("tab_academics"))
            .toolbar {
                Button(action: {
                    if selectedTab == .modules {
                        showingAddModule = true
                    } else {
                        showingAddAssignment = true
                    }
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddModule) {
                AddModuleView { name, code, mark in
                    viewModel.addModule(name: name, code: code, mark: mark, assignments: 0, participation: 0, midterm: 0, final: 0)
                    showingAddModule = false
                }
            }
            .sheet(isPresented: $showingAddAssignment) {
                AddAssignmentView { title, course, score, total, completed in
                    viewModel.addAssignment(title: title, course: course, score: score, total: total, isCompleted: completed)
                    showingAddAssignment = false
                }
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

// MARK: - 课程成绩视图

struct ModuleGradesView: View {
    @EnvironmentObject var loc: LocalizationService
    @ObservedObject var viewModel: AcademicViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 总平均分概览
                OverallAverageGauge(average: viewModel.overallAverage)
                
                // 课程统计
                HStack(spacing: 12) {
                    ModuleStatBadge(
                        icon: "checkmark.circle.fill",
                        label: "已评分",
                        value: "\(viewModel.completedModulesCount)",
                        color: "10B981"
                    )
                    
                    ModuleStatBadge(
                        icon: "hourglass",
                        label: "进行中",
                        value: "\(viewModel.totalModulesCount - viewModel.completedModulesCount)",
                        color: "F59E0B"
                    )
                    
                    ModuleStatBadge(
                        icon: "books.vertical.fill",
                        label: "总课程",
                        value: "\(viewModel.totalModulesCount)",
                        color: "6366F1"
                    )
                }
                .padding(.horizontal)
                
                // 课程列表
                VStack(alignment: .leading, spacing: 16) {
                    Text("我的课程")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.modules) { module in
                        EnhancedModuleCard(module: module)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - 模块统计徽章

struct ModuleStatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: color))
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - 增强版课程卡片

struct EnhancedModuleCard: View {
    let module: Module
    
    var body: some View {
        NavigationLink(destination: ModuleDetailView(module: module)) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 16) {
                    // 课程标题和成绩
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(module.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(2)
                            
                            Text(module.code)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            if module.mark > 0 {
                                Text("\(Int(module.mark))")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(markColor(module.mark))
                                
                                Text(gradeLabel(module.mark))
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(markColor(module.mark))
                                    .clipShape(Capsule())
                            } else {
                                Image(systemName: "hourglass")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "F59E0B"))
                                
                                Text("进行中")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color(hex: "F59E0B"))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // 统计信息
                    HStack(spacing: 16) {
                        if module.mark > 0 {
                            StatBadge(
                                icon: "chart.line.uptrend.xyaxis",
                                label: "比平均",
                                value: "+\(Int(module.mark) - module.moduleAverage)",
                                color: Color(hex: "10B981")
                            )
                            
                            StatBadge(
                                icon: "person.3",
                                label: "班级平均",
                                value: "\(module.moduleAverage)",
                                color: Color(hex: "6B7280")
                            )
                        }
                        
                        if !module.assignmentList.isEmpty {
                            let completed = module.assignmentList.filter { $0.submitted }.count
                            StatBadge(
                                icon: "doc.text",
                                label: "作业",
                                value: "\(completed)/\(module.assignmentList.count)",
                                color: completed == module.assignmentList.count ? Color(hex: "10B981") : Color(hex: "F59E0B")
                            )
                        }
                    }
                    
                    // 进度条
                    if module.mark > 0 {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [markColor(module.mark), markColor(module.mark).opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(module.mark) / 100)
                            }
                        }
                        .frame(height: 6)
                    }
                }
                .padding(20)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func markColor(_ mark: Double) -> Color {
        if mark >= 80 { return Color(hex: "10B981") }
        if mark >= 70 { return Color(hex: "8B5CF6") }
        if mark >= 60 { return Color(hex: "F59E0B") }
        return Color(hex: "EF4444")
    }
    
    func gradeLabel(_ mark: Double) -> String {
        if mark >= 70 { return "First" }
        if mark >= 60 { return "2:1" }
        if mark >= 50 { return "2:2" }
        if mark >= 40 { return "Third" }
        return "Fail"
    }
}

// MARK: - 统计徽章

struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - 课程详情视图

struct ModuleDetailView: View {
    @EnvironmentObject var loc: LocalizationService
    let module: Module
    
    var body: some View {
        ZStack {
            DesignSystem.backgroundGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 课程基本信息
                    VStack(alignment: .leading, spacing: 12) {
                        Text(module.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text(module.code)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("\(Int(module.mark))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(markColor(module.mark))
                                Text("/100")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text(gradeLevel(module.mark))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(markColor(module.mark))
                                .clipShape(Capsule())
                            
                            Text(gradeDescription(module.mark))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .glassCard()
                    
                    // 成绩构成
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📊 成绩构成")
                            .font(.headline)
                        
                        ForEach(module.gradeBreakdown) { component in
                            GradeBreakdownRow(
                                title: component.component,
                                score: component.grade,
                                weight: component.weight
                            )
                        }
                    }
                    .padding()
                    .glassCard()
                    
                    // 作业列表
                    if !module.assignmentList.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📝 作业列表")
                                .font(.headline)
                            
                            ForEach(module.assignmentList) { assignment in
                                ModuleAssignmentRow(assignment: assignment)
                            }
                        }
                        .padding()
                        .glassCard()
                    }
                    
                    // 学习建议
                    VStack(alignment: .leading, spacing: 12) {
                        Text("💡 学习建议")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            if module.mark >= 70 {
                                SuggestionRow(icon: "checkmark.circle.fill", text: "继续保持优秀表现", color: .green)
                                SuggestionRow(icon: "star.fill", text: "可以尝试更有挑战性的内容", color: .green)
                            } else if module.mark >= 60 {
                                SuggestionRow(icon: "arrow.up.circle.fill", text: "再努力一点可以达到一等", color: .orange)
                                SuggestionRow(icon: "book.fill", text: "重点复习薄弱环节", color: .orange)
                            } else {
                                SuggestionRow(icon: "exclamationmark.triangle.fill", text: "需要加强学习", color: .red)
                                SuggestionRow(icon: "person.2.fill", text: "建议寻求导师帮助", color: .red)
                            }
                        }
                    }
                    .padding()
                    .glassCard()
                }
                .padding()
            }
        }
        .navigationTitle("课程详情")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    func markColor(_ mark: Double) -> Color {
        if mark >= 80 { return Color(hex: "10B981") }
        if mark >= 70 { return Color(hex: "8B5CF6") }
        if mark >= 60 { return Color(hex: "F59E0B") }
        return Color(hex: "EF4444")
    }
    
    func gradeLevel(_ score: Double) -> String {
        switch score {
        case 70...100: return "一等学位 First Class"
        case 60..<70: return "二等一 Upper Second"
        case 50..<60: return "二等二 Lower Second"
        case 40..<50: return "三等 Third Class"
        default: return "不及格 Fail"
        }
    }
    
    func gradeDescription(_ score: Double) -> String {
        switch score {
        case 70...100: return "优秀 - 一等学位水平!"
        case 60..<70: return "良好 - 二等一水平"
        case 50..<60: return "中等 - 二等二水平"
        case 40..<50: return "及格 - 三等学位"
        default: return "不及格 - 需要重修"
        }
    }
}

// MARK: - 模块作业行

struct ModuleAssignmentRow: View {
    let assignment: Module.ModuleAssignment
    
    var body: some View {
        HStack {
            Image(systemName: assignment.submitted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(assignment.submitted ? Color(hex: "10B981") : Color(hex: "F59E0B"))
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(assignment.submitted ? "已提交 · \(assignment.dueDate)" : "截止 · \(assignment.dueDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if assignment.submitted && assignment.grade > 0 {
                Text("\(assignment.grade)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(assignment.grade >= 70 ? Color(hex: "10B981") : Color(hex: "F59E0B"))
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 建议行

struct SuggestionRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 成绩构成行

struct GradeBreakdownRow: View {
    let title: String
    let score: Int
    let weight: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(score)% (\(weight)%)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignSystem.primaryGradient)
                        .frame(width: geometry.size.width * CGFloat(score) / 100)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - 作业分数视图

struct AssignmentScoresView: View {
    @EnvironmentObject var loc: LocalizationService
    @ObservedObject var viewModel: AcademicViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(loc.tr("academics_assignments"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.assignments) { assignment in
                        AssignmentGaugeRowView(assignment: assignment)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - 作业环形图行

struct AssignmentGaugeRowView: View {
    let assignment: Assignment
    
    var body: some View {
        HStack {
            if assignment.isCompleted {
                Gauge(value: assignment.score, in: 0...assignment.total) { }
                    .gaugeStyle(CircularGaugeStyle(tint: markColor(assignment.score / assignment.total * 100), thickness: 6))
                    .frame(width: 50, height: 50)
            } else {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                    Image(systemName: "hourglass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(assignment.course)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if assignment.isCompleted {
                Text("\(Int(assignment.score))/\(Int(assignment.total))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(markColor(assignment.score / assignment.total * 100))
            } else {
                Text("进行中")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .glassCard()
    }
    
    func markColor(_ mark: Double) -> Color {
        if mark >= 80 { return .green }
        if mark >= 70 { return Color(hex: "8B5CF6") }
        if mark >= 60 { return .orange }
        return .red
    }
}

// MARK: - 总平均分环形图

struct OverallAverageGauge: View {
    @EnvironmentObject var loc: LocalizationService
    let average: Double
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: average / 100)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "8B5CF6"),
                                Color(hex: "6366F1"),
                                Color(hex: "A855F7")
                            ]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: average)
                
                VStack(spacing: 8) {
                    Text("\(average, specifier: "%.1f")")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "8B5CF6"))
                    
                    Text("总平均分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                GradeLabel(grade: gradeLevel(average), color: gradeColor(average))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前等级")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(gradeDescription(average))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    func gradeColor(_ mark: Double) -> Color {
        if mark >= 80 { return .green }
        if mark >= 70 { return Color(hex: "8B5CF6") }
        if mark >= 60 { return .orange }
        return .red
    }
    
    func gradeLevel(_ score: Double) -> String {
        switch score {
        case 70...100: return "一等学位 First Class"
        case 60..<70: return "二等一 Upper Second"
        case 50..<60: return "二等二 Lower Second"
        case 40..<50: return "三等 Third Class"
        default: return "不及格 Fail"
        }
    }
    
    func gradeDescription(_ score: Double) -> String {
        switch score {
        case 70...100: return "优秀 - 一等学位水平!"
        case 60..<70: return "良好 - 二等一水平"
        case 50..<60: return "中等 - 二等二水平"
        case 40..<50: return "及格 - 三等学位"
        default: return "不及格 - 需要重修"
        }
    }
}

struct GradeLabel: View {
    let grade: String
    let color: Color
    
    var body: some View {
        Text(grade)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .clipShape(Capsule())
    }
}

// MARK: - 添加课程视图

struct AddModuleView: View {
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var code: String = ""
    @State private var mark: Double = 0
    
    var onSave: (String, String, Double) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(loc.tr("academics_module_name"))) {
                    TextField(loc.tr("academics_module_name"), text: $name)
                    TextField(loc.tr("academics_module_code"), text: $code)
                }
                
                Section(header: Text(loc.tr("academics_mark"))) {
                    Slider(value: $mark, in: 0...100, step: 1)
                    Text("\(Int(mark))")
                }
                
                Button(action: {
                    if !name.isEmpty {
                        onSave(name, code, mark)
                    }
                }) {
                    Text(loc.tr("todo_save"))
                }
                .disabled(name.isEmpty)
            }
            .navigationTitle(loc.tr("academics_add_module"))
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 添加作业视图

struct AddAssignmentView: View {
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var course: String = ""
    @State private var score: Double = 0
    @State private var total: Double = 100
    @State private var isCompleted: Bool = false
    
    var onSave: (String, String, Double, Double, Bool) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(loc.tr("academics_assignment_name"), text: $title)
                    TextField(loc.tr("academics_course_name"), text: $course)
                }
                
                Section {
                    Toggle(loc.tr("academics_completed"), isOn: $isCompleted)
                }
                
                if isCompleted {
                    Section(header: Text(loc.tr("academics_score"))) {
                        HStack {
                            TextField(loc.tr("academics_score"), value: $score, format: .number)
                            Text("/")
                            TextField(loc.tr("academics_total_points"), value: $total, format: .number)
                        }
                    }
                }
                
                Button(action: {
                    if !title.isEmpty {
                        onSave(title, course, score, total, isCompleted)
                    }
                }) {
                    Text(loc.tr("todo_save"))
                }
                .disabled(title.isEmpty)
            }
            .navigationTitle(loc.tr("academics_add_assignment"))
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 课程表视图

struct WeeklyScheduleView: View {
    @EnvironmentObject var loc: LocalizationService
    @ObservedObject var viewModel: AcademicViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("本周课程安排")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.weeklySchedule) { schedule in
                        ScheduleCard(schedule: schedule)
                            .padding(.horizontal)
                    }
                }
                
                // 统计信息
                VStack(alignment: .leading, spacing: 12) {
                    Text("📊 本周统计")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        ScheduleStatCard(
                            icon: "book.fill",
                            label: "总课程",
                            value: "\(viewModel.weeklySchedule.count)",
                            color: "6366F1"
                        )
                        
                        ScheduleStatCard(
                            icon: "clock.fill",
                            label: "总课时",
                            value: "\(viewModel.weeklySchedule.count * 2)h",
                            color: "10B981"
                        )
                        
                        ScheduleStatCard(
                            icon: "list.bullet.rectangle.fill",
                            label: "全部课程",
                            value: "\(viewModel.modules.count)",
                            color: "F59E0B"
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - 课程卡片

struct ScheduleCard: View {
    let schedule: WeeklySchedule
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧日期标签
            VStack(spacing: 4) {
                Text(schedule.dayOfWeek)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
            .frame(width: 50)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: schedule.color))
            )
            
            // 课程信息
            VStack(alignment: .leading, spacing: 8) {
                Text(schedule.courseName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "number")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(schedule.courseCode)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: schedule.color))
                        Text(schedule.time)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: schedule.color))
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(schedule.location)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - 课程表统计卡片

struct ScheduleStatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: color))
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}
