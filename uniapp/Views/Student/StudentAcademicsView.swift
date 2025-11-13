//
//  学生学业.swift
//  uniappv3
//
//  Created by 748 on 12/11/2025.
//

//
//  StudentAcademicsView.swift
//  uniapp
//
//  Created on 2024.
//
//  ✅ 已修复：
//  - 移除了内部的数据模型（Module, Assignment）定义，
//    因为它们现在位于 `共享数据模型.swift`
//  - 移除了内部的 ViewModel（AcademicViewModel）定义，
//    因为它现在位于 `AcademicViewModel.swift`
//

import SwiftUI

// MARK: - 主视图

struct StudentAcademicsView: View {
    @EnvironmentObject var loc: LocalizationService
    
    // ✅ 更改：
    // AcademicViewModel 现在是从 `AcademicViewModel.swift` 文件中加载的
    @StateObject private var viewModel = AcademicViewModel()
    
    @State private var selectedTab: AcademicsTab = .modules
    
    @State private var showingAddModule = false
    @State private var showingAddAssignment = false
    
    enum AcademicsTab {
        case modules, assignments
    }
    
    var body: some View {
        // ✅ 保持：
        // 这里的 NavigationView 是必需的，因为它允许
        // `NavigationLink` (例如 EnhancedModuleCard)
        // 正确地跳转到 `ModuleDetailView`
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Academics", selection: $selectedTab) {
                        Text(loc.tr("academics_modules")).tag(AcademicsTab.modules)
                        Text(loc.tr("academics_assignments")).tag(AcademicsTab.assignments)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(.ultraThinMaterial)
                    
                    if selectedTab == .modules {
                        ModuleGradesView(viewModel: viewModel)
                    } else {
                        AssignmentScoresView(viewModel: viewModel)
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
                        }
                    }
                    
                    // 统计信息
                    HStack(spacing: 16) {
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
        .navigationBarTitleDisplayMode(.inline)
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
                    .gaugeStyle(.accessoryCircular)
                    .tint(markColor(assignment.score / assignment.total * 100))
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
                .fill(Color(.systemBackground))
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
            .navigationBarItems(trailing: Button("取消") { dismiss() })
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
            .navigationBarItems(trailing: Button("取消") { dismiss() })
        }
    }
}
