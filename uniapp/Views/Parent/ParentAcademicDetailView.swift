//
//  ParentAcademicDetailView.swift
//  uniapp
//
//  家长端学业详情 - 只显示已完成课程的成绩
//
import SwiftUI

struct ParentAcademicDetailView: View {
    @EnvironmentObject var loc: LocalizationService
    @State private var selectedSemester = "本学期"
    
    // 只显示已完成的课程（有最终成绩的）
    // 排除课程表中正在上的课程：数据方法与健康研究、数据科学与统计、Python健康研究编程、医疗人工智能、健康数据科学原理
    private let completedCourses: [CompletedCourse] = [
        // Term 1 已完成课程（上学期）
        .init(
            name: "医疗高级机器学习",
            code: "CHME0017",
            finalGrade: 85,
            credit: 15,
            gradeLevel: "Merit",
            semester: "上学期",
            components: [
                .init(name: "作业", percentage: 40, score: 87),
                .init(name: "课堂参与", percentage: 10, score: 90),
                .init(name: "期中考试", percentage: 25, score: 82),
                .init(name: "期末考试", percentage: 25, score: 84)
            ]
        ),
        .init(
            name: "数据科学流行病学",
            code: "CHME0008",
            finalGrade: 69,
            credit: 15,
            gradeLevel: "Merit",
            semester: "上学期",
            components: [
                .init(name: "作业", percentage: 40, score: 72),
                .init(name: "课堂参与", percentage: 10, score: 78),
                .init(name: "期中考试", percentage: 25, score: 65),
                .init(name: "期末考试", percentage: 25, score: 68)
            ]
        ),
        
        // 本学期暂无已完成课程（当前课程都还在进行中）
    ]
    
    let semesters = ["全部", "本学期", "上学期"]
    
    var filteredCourses: [CompletedCourse] {
        if selectedSemester == "全部" {
            return completedCourses
        }
        return completedCourses.filter { $0.semester == selectedSemester }
    }
    
    var overallAverage: Double {
        guard !completedCourses.isEmpty else { return 0 }
        let total = completedCourses.reduce(0.0) { $0 + Double($1.finalGrade) }
        return total / Double(completedCourses.count)
    }
    
    var body: some View {
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
                    // 总体成绩概览
                    overallSummaryCard
                    
                    // 学期筛选器
                    semesterPicker
                    
                    // 已完成课程列表
                    if filteredCourses.isEmpty {
                        emptyStateView
                    } else {
                        courseListSection
                    }
                    
                    // 成绩说明
                    gradeExplanationCard
                }
                .padding()
            }
        }
        .navigationTitle("学业详情")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    // MARK: - 总体成绩概览
    private var overallSummaryCard: some View {
        VStack(spacing: 20) {
            // 平均分
            VStack(spacing: 8) {
                Text(String(format: "%.1f", overallAverage))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(gradeColor(for: Int(overallAverage)))
                
                Text("总平均分")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            // 学位等级
            HStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 14))
                
                Text(degreeClassification(for: overallAverage))
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(Color(hex: "F59E0B"))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color(hex: "F59E0B").opacity(0.1))
            )
            
            Divider()
                .padding(.vertical, 4)
            
            // 统计信息
            HStack(spacing: 20) {
                StatItem(
                    icon: "checkmark.circle.fill",
                    label: "已完成",
                    value: "\(completedCourses.count)",
                    color: Color(hex: "10B981")
                )
                
                StatItem(
                    icon: "hourglass",
                    label: "进行中",
                    value: "5",  // 课程表中的课程数量
                    color: Color(hex: "6366F1")
                )
                
                StatItem(
                    icon: "star.fill",
                    label: "学分",
                    value: "\(completedCourses.reduce(0) { $0 + $1.credit })",
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
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }
    
    // MARK: - 学期选择器
    private var semesterPicker: some View {
        Picker("学期", selection: $selectedSemester) {
            ForEach(semesters, id: \.self) { semester in
                Text(semester).tag(semester)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "6366F1"))
            
            Text("本学期课程进行中")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("课程结束后将显示最终成绩")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            // 提示正在上的课程
            VStack(alignment: .leading, spacing: 8) {
                Text("当前课程：")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    OngoingCourseTag(name: "数据方法与健康研究")
                    OngoingCourseTag(name: "数据科学与统计")
                    OngoingCourseTag(name: "Python 健康研究编程")
                    OngoingCourseTag(name: "医疗人工智能")
                    OngoingCourseTag(name: "健康数据科学原理")
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 课程列表
    private var courseListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("已完成课程")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(filteredCourses.count) 门")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            ForEach(filteredCourses) { course in
                CompletedCourseCard(course: course)
            }
        }
    }
    
    // MARK: - 成绩说明
    private var gradeExplanationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("UCL 成绩评级")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                GradeExplanationRow(range: "70-100", level: "一等学位 (Distinction)", color: "10B981")
                GradeExplanationRow(range: "60-69", level: "二等学位 (Merit)", color: "F59E0B")
                GradeExplanationRow(range: "50-59", level: "及格 (Pass)", color: "6366F1")
                GradeExplanationRow(range: "0-49", level: "不及格 (Fail)", color: "EF4444")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Functions
    private func gradeColor(for grade: Int) -> Color {
        switch grade {
        case 70...100: return Color(hex: "10B981")
        case 60..<70: return Color(hex: "F59E0B")
        case 50..<60: return Color(hex: "6366F1")
        default: return Color(hex: "EF4444")
        }
    }
    
    private func degreeClassification(for average: Double) -> String {
        switch Int(average) {
        case 70...100: return "一等学位水平 (Distinction)"
        case 60..<70: return "二等学位水平 (Merit)"
        case 50..<60: return "及格水平 (Pass)"
        default: return "需要努力"
        }
    }
}

// MARK: - 数据模型
struct CompletedCourse: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let finalGrade: Int
    let credit: Int
    let gradeLevel: String
    let semester: String
    let components: [GradeComponent]
    
    struct GradeComponent: Identifiable {
        let id = UUID()
        let name: String
        let percentage: Int
        let score: Int
    }
    
    var gradeColor: Color {
        switch finalGrade {
        case 70...100: return Color(hex: "10B981")
        case 60..<70: return Color(hex: "F59E0B")
        case 50..<60: return Color(hex: "6366F1")
        default: return Color(hex: "EF4444")
        }
    }
}

// MARK: - 子组件

struct StatItem: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CompletedCourseCard: View {
    let course: CompletedCourse
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 课程头部
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(course.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Label(course.code, systemImage: "number")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(course.credit) 学分")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(course.finalGrade)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(course.gradeColor)
                    
                    Text(course.gradeLevel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(course.gradeColor)
                }
            }
            
            // 成绩组成
            if showDetails {
                Divider()
                
                VStack(spacing: 10) {
                    ForEach(course.components) { component in
                        HStack {
                            HStack(spacing: 6) {
                                Text(component.name)
                                    .font(.system(size: 13))
                                    .foregroundColor(.primary)
                                
                                Text("(\(component.percentage)%)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(component.score)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(course.gradeColor)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // 展开/收起按钮
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    showDetails.toggle()
                }
            }) {
                HStack {
                    Text(showDetails ? "收起详情" : "查看详情")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "6366F1"))
                    
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "6366F1"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

struct OngoingCourseTag: View {
    let name: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: "6366F1"))
                .frame(width: 6, height: 6)
            
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(.primary)
        }
    }
}

struct GradeExplanationRow: View {
    let range: String
    let level: String
    let color: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(range)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 60, alignment: .leading)
            
            Text(level)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Circle()
                .fill(Color(hex: color))
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }
}