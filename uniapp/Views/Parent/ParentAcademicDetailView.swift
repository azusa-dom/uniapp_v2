//
//  ParentAcademicDetailView.swift
//  uniapp
//
//  Created on 2024.
//
import SwiftUI

struct ParentAcademicDetailView: View {
    @EnvironmentObject var loc: LocalizationService
    
    private let courses: [CourseSummary] = [
        .init(name: "数据方法与健康研究", grade: 87, assignments: 100, participation: 100, average: 65),
        .init(name: "数据科学与统计", grade: 72, assignments: 75, participation: 95, average: 68),
        .init(name: "健康数据科学原理", grade: 67, assignments: 80, participation: 100, average: 70)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                overallSummary
                courseList
            }
            .padding(.vertical)
        }
        .navigationTitle(loc.tr("parent_academic_detail_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var overallSummary: some View {
        VStack(spacing: 16) {
            Text("79.6 分")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primary)
            
            Text("🏆 一等学位水平")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "F59E0B"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "F59E0B").opacity(0.1))
                .clipShape(Capsule())
            
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .foregroundColor(Color(hex: "10B981"))
                Text("+2.3 分")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "10B981"))
                Text("比上月进步")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var courseList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📚 各科成绩")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)
            
            ForEach(courses) { course in
                CourseSummaryRow(course: course)
                    .padding(.horizontal)
            }
        }
    }
}

private struct CourseSummaryRow: View {
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("平均分: \(course.average)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(course.grade) 分")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(gradeColor)
            }
            
            HStack(spacing: 16) {
                metric(title: "作业完成度", value: "\(course.assignments)%", highlight: course.assignments >= 80)
                metric(title: "课堂参与", value: "\(course.participation)%", highlight: course.participation >= 90)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
    
    private func metric(title: String, value: String, highlight: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(highlight ? Color(hex: "10B981") : Color(hex: "F59E0B"))
        }
    }
}

private struct CourseSummary: Identifiable {
    let id = UUID()
    let name: String
    let grade: Int
    let assignments: Int
    let participation: Int
    let average: Int
}

