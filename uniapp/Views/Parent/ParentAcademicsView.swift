//
//  ParentAcademicsView.swift
//  uniapp
//
//  家长端 - 学业 & 课表视图（合并）
//

import SwiftUI

struct ParentAcademicsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var viewModel: UCLAPIViewModel
    
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 分段选择器
                    Picker("", selection: $selectedSegment) {
                        Text(loc.language == .chinese ? "学业" : "Academics").tag(0)
                        Text(loc.language == .chinese ? "课表" : "Schedule").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // 内容区域
                    if selectedSegment == 0 {
                        AcademicsOverviewSection()
                    } else {
                        ScheduleSection()
                    }
                }
            }
            .navigationTitle(loc.language == .chinese ? "学业与课表" : "Academics & Schedule")
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

// MARK: - 学业概览部分
struct AcademicsOverviewSection: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        ScrollView {
            if appState.shareGrades {
                VStack(spacing: 20) {
                    // 继续使用现有的 AcademicOverviewCard
                    AcademicOverviewCard()
                    
                    // 待办作业卡片
                    TodoOverviewCard(onTodoTap: { _ in })
                }
                .padding()
            } else {
                VStack {
                    Spacer()
                    DataNotSharedView(dataType: loc.language == .chinese ? "学业信息" : "Academic Information")
                        .padding()
                    Spacer()
                }
            }
        }
    }
}

// MARK: - 课表部分
struct ScheduleSection: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    @State private var selectedWeekDay = Calendar.current.component(.weekday, from: Date())
    
    // 简化的周课表数据（实际应从MockData获取）
    private func classesForWeekday(_ weekday: Int) -> [ScheduleClass] {
        // 这里简化处理，实际应该从 MockData.timetableEvents 过滤
        switch weekday {
        case 2: // 周一
            return [
                ScheduleClass(courseName: "Deep Learning", courseNameCN: "深度学习", time: "10:00-12:00", location: "Roberts Building", locationCN: "罗伯茨楼", room: "309", instructor: "Dr. Smith"),
                ScheduleClass(courseName: "Statistics", courseNameCN: "统计学", time: "14:00-16:00", location: "Cruciform", locationCN: "十字楼", room: "LT1", instructor: "Prof. Johnson")
            ]
        case 3: // 周二
            return [
                ScheduleClass(courseName: "Health Informatics", courseNameCN: "健康信息学", time: "13:00-15:00", location: "Main Campus", locationCN: "主校区", room: "B05", instructor: "Dr. Lee")
            ]
        case 4: // 周三
            return [
                ScheduleClass(courseName: "Machine Learning Lab", courseNameCN: "机器学习实验", time: "10:00-13:00", location: "Computer Lab", locationCN: "机房", room: "G01", instructor: "Dr. Chen")
            ]
        case 6: // 周五
            return [
                ScheduleClass(courseName: "Research Seminar", courseNameCN: "研究讨论课", time: "15:00-17:00", location: "UCL East", locationCN: "UCL东校区", room: "204", instructor: nil)
            ]
        default:
            return []
        }
    }
    
    var body: some View {
        ScrollView {
            if appState.shareCalendar {
                VStack(spacing: 20) {
                    // 周选择器
                    WeekDaySelector(selectedDay: $selectedWeekDay)
                    
                    // 当日课表
                    DayScheduleView(
                        weekday: selectedWeekDay,
                        classes: classesForWeekday(selectedWeekDay)
                    )
                }
                .padding()
            } else {
                VStack {
                    Spacer()
                    DataNotSharedView(dataType: loc.language == .chinese ? "课表信息" : "Schedule")
                        .padding()
                    Spacer()
                }
            }
        }
    }
}

// MARK: - 周日期选择器
struct WeekDaySelector: View {
    @EnvironmentObject var loc: LocalizationService
    @Binding var selectedDay: Int
    
    private let weekDays = [
        (1, "Sun", "日"),
        (2, "Mon", "一"),
        (3, "Tue", "二"),
        (4, "Wed", "三"),
        (5, "Thu", "四"),
        (6, "Fri", "五"),
        (7, "Sat", "六")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(weekDays, id: \.0) { day in
                    WeekDayButton(
                        weekday: day.0,
                        label: loc.language == .chinese ? day.2 : day.1,
                        isSelected: selectedDay == day.0
                    ) {
                        withAnimation(.spring()) {
                            selectedDay = day.0
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - 周日期按钮
struct WeekDayButton: View {
    let weekday: Int
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
                
                if isSelected {
                    Circle()
                        .fill(Color(hex: "6366F1"))
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .foregroundColor(isSelected ? Color(hex: "6366F1") : .secondary)
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: "6366F1").opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - 当日课表视图
struct DayScheduleView: View {
    @EnvironmentObject var loc: LocalizationService
    let weekday: Int
    let classes: [ScheduleClass]
    
    private var dayName: String {
        let days = [
            (1, "Sunday", "周日"),
            (2, "Monday", "周一"),
            (3, "Tuesday", "周二"),
            (4, "Wednesday", "周三"),
            (5, "Thursday", "周四"),
            (6, "Friday", "周五"),
            (7, "Saturday", "周六")
        ]
        let day = days.first { $0.0 == weekday }
        return loc.language == .chinese ? day?.2 ?? "" : day?.1 ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(dayName)
                .font(.headline)
                .padding(.horizontal)
            
            if classes.isEmpty {
                EmptyDayView()
            } else {
                ForEach(classes.indices, id: \.self) { index in
                    ScheduleClassCard(scheduleClass: classes[index])
                }
            }
        }
    }
}

// MARK: - 空白日视图
struct EmptyDayView: View {
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text(loc.language == .chinese ? "这天没有课程安排" : "No classes scheduled")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .glassCard()
    }
}

// MARK: - 课程卡片
struct ScheduleClassCard: View {
    @EnvironmentObject var loc: LocalizationService
    let scheduleClass: ScheduleClass
    
    var body: some View {
        HStack(spacing: 16) {
            // 时间指示器
            VStack(alignment: .center, spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text(scheduleClass.time)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 70)
            
            Divider()
            
            // 课程信息
            VStack(alignment: .leading, spacing: 6) {
                Text(loc.language == .chinese ? scheduleClass.courseNameCN : scheduleClass.courseName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 8) {
                    Label(
                        loc.language == .chinese ? scheduleClass.locationCN : scheduleClass.location,
                        systemImage: "mappin.circle.fill"
                    )
                    
                    if !scheduleClass.room.isEmpty {
                        Text("• \(scheduleClass.room)")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if let instructor = scheduleClass.instructor {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                        Text(instructor)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 数据模型
struct ScheduleClass: Identifiable {
    let id = UUID()
    let courseName: String
    let courseNameCN: String
    let time: String
    let location: String
    let locationCN: String
    let room: String
    let instructor: String?
}

// MARK: - Preview
#Preview {
    ParentAcademicsView()
        .environmentObject(AppState())
        .environmentObject(LocalizationService())
        .environmentObject(UCLAPIViewModel())
}
