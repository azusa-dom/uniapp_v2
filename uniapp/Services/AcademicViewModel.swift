//
//  AcademicViewModel.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI
import Combine

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
                .init(name: "统计习题集", grade: 0, submitted: false, dueDate: "11月8日")
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
                .init(name: "统计建模", grade: 0, submitted: false, dueDate: "11月10日")
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
            moduleAverage: 62
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
                .init(name: "可视化作业", grade: 90, submitted: true, dueDate: "10月25日")
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
            moduleAverage: 64
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
                .init(name: "NLP 文本分析", grade: 95, submitted: true, dueDate: "11月2日")
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
    
    var overallAverage: Double {
        let validModules = modules.filter { $0.mark > 0 }
        if validModules.isEmpty { return 0 }
        let totalMark = validModules.reduce(0) { $0 + $1.mark }
        return totalMark / Double(validModules.count)
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

