// MARK: - ParentDashboardView.swift
// 文件位置: uniapp/Views/Parent/ParentDashboardView.swift

import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var uclVM: UCLAPIViewModel
    @StateObject private var activitiesService = UCLActivitiesService()
    @State private var hasLoadedActivities = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                DesignSystem.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 顶部学生信息卡
                        StudentHeaderCard()
                        
                        // 学业概况卡
                        AcademicSummaryCard()
                        
                        // 今日课表卡
                        TodayScheduleCard()
                        
                        // 健康 & 用药卡
                        HealthSummaryCard()
                        
                        // 本周重要事项
                        WeeklyHighlightsCard()
                        
                        // 校园活动预览
                        CampusActivitiesPreviewCard()
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.language == .chinese ? "家长面板" : "Parent Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ParentSettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(DesignSystem.primaryColor)
                    }
                }
            }
            .onAppear {
                loadCampusActivitiesIfNeeded()
            }
        }
    }
    
    // MARK: - 加载校园活动数据（确保数据已加载）
    private func loadCampusActivitiesIfNeeded() {
        // 如果 uclVM.events 中没有活动数据，则加载
        let hasActivityEvents = uclVM.events.contains { $0.type == .manual }
        
        if !hasActivityEvents && !hasLoadedActivities {
            // 加载活动数据
            if activitiesService.activities.isEmpty {
                activitiesService.loadActivities()
                // 等待数据加载完成
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    convertAndAddActivities()
                }
            } else {
                convertAndAddActivities()
            }
        }
    }
    
    // MARK: - 转换并添加活动数据
    private func convertAndAddActivities() {
        guard !hasLoadedActivities else { return }
        
        let isChinese = loc.language == .chinese
        
        // 直接从 MockData.activities 加载并转换（与学生端保持一致）
        let activityEvents = MockData.activities.map { activity in
            return UCLAPIViewModel.UCLAPIEvent(
                id: UUID(uuidString: activity.id) ?? UUID(),
                title: activity.localizedTitle(isChinese: isChinese),
                startTime: activity.startDate,
                endTime: activity.endDate,
                location: activity.localizedLocation(isChinese: isChinese),
                type: .manual,
                description: activity.localizedDescription(isChinese: isChinese),
                recurrenceRule: nil,
                reminderTime: .fifteenMin
            )
        }
        
        // 添加到 uclVM.events（如果没有添加过）
        if !uclVM.events.contains(where: { $0.type == .manual }) {
            uclVM.events.append(contentsOf: activityEvents)
        }
        hasLoadedActivities = true
    }
}

// MARK: - 学生头部信息卡
struct StudentHeaderCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        HStack(spacing: 16) {
            // 学生头像
            ZStack {
                Circle()
                    .fill(DesignSystem.primaryGradient)
                    .frame(width: 70, height: 70)
                
                Image(systemName: appState.avatarIcon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(appState.studentName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(appState.studentProgram)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "building.columns.fill")
                        .font(.caption)
                    Text("University College London")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 学业概况卡
struct AcademicSummaryCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    // 模拟数据 - 实际应从 ViewModel 获取
    private let averageGrade = 72.5
    private let completedCredits = 60
    private let totalCredits = 180
    private let pendingAssignments = 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(DesignSystem.primaryColor)
                Text(loc.language == .chinese ? "学业概况" : "Academic Overview")
                    .font(.headline)
                Spacer()
                
                if !appState.shareGrades {
                    Image(systemName: "eye.slash.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if appState.shareGrades {
                // 成绩信息
                VStack(spacing: 12) {
                    // 平均分
                    HStack {
                        VStack(alignment: .leading) {
                            Text(loc.language == .chinese ? "平均成绩" : "Average Grade")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f", averageGrade))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(gradeColor(for: averageGrade))
                        }
                        
                        Spacer()
                        
                        // 学位等级标签
                        Text(gradeLevel(for: averageGrade))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(gradeColor(for: averageGrade).opacity(0.2))
                            .foregroundColor(gradeColor(for: averageGrade))
                            .clipShape(Capsule())
                    }
                    
                    Divider()
                    
                    // 学分进度
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(loc.language == .chinese ? "已修学分" : "Credits Earned")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(completedCredits) / \(totalCredits)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        // 进度环
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(completedCredits) / CGFloat(totalCredits))
                                .stroke(DesignSystem.primaryColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(Int((Double(completedCredits) / Double(totalCredits)) * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .frame(width: 60, height: 60)
                    }
                    
                    Divider()
                    
                    // 待办作业
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(DesignSystem.warningColor)
                        Text(loc.language == .chinese ? "本周待完成作业" : "Pending Assignments")
                            .font(.subheadline)
                        Spacer()
                        Text("\(pendingAssignments)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.warningColor)
                    }
                }
            } else {
                // 未共享提示
                DataNotSharedView(dataType: loc.language == .chinese ? "成绩信息" : "Grade Information")
            }
            
            // 查看详情按钮
            if appState.shareGrades {
                NavigationLink(destination: ParentAcademicsView()) {
                    HStack {
                        Text(loc.language == .chinese ? "查看详细学业信息" : "View Details")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(DesignSystem.primaryColor)
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .glassCard()
    }
    
    // 辅助函数：根据分数返回颜色
    private func gradeColor(for grade: Double) -> Color {
        if grade >= 70 { return DesignSystem.successColor }
        else if grade >= 60 { return Color.blue }
        else if grade >= 50 { return DesignSystem.warningColor }
        else { return DesignSystem.errorColor }
    }
    
    // 辅助函数：根据分数返回等级
    private func gradeLevel(for grade: Double) -> String {
        if grade >= 70 {
            return loc.language == .chinese ? "一等荣誉" : "First Class"
        } else if grade >= 60 {
            return loc.language == .chinese ? "二等一荣誉" : "Upper Second"
        } else if grade >= 50 {
            return loc.language == .chinese ? "二等二荣誉" : "Lower Second"
        } else if grade >= 40 {
            return loc.language == .chinese ? "三等" : "Third Class"
        } else {
            return loc.language == .chinese ? "不及格" : "Fail"
        }
    }
}

// MARK: - 今日课表卡
struct TodayScheduleCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    // 模拟今日课程数据 - 实际应从 MockData.timetableEvents 过滤
    private var todayClasses: [TimetableClass] {
        [
            TimetableClass(
                id: UUID(),
                courseName: "Deep Learning",
                courseNameCN: "深度学习",
                time: "10:00 - 12:00",
                location: "Roberts Building",
                locationCN: "罗伯茨大楼",
                room: "Room 309",
                instructor: "Dr. Smith"
            ),
            TimetableClass(
                id: UUID(),
                courseName: "Medical Statistics",
                courseNameCN: "医学统计",
                time: "14:00 - 16:00",
                location: "Cruciform Building",
                locationCN: "十字楼",
                room: "LT1",
                instructor: "Prof. Johnson"
            )
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(DesignSystem.primaryColor)
                Text(loc.language == .chinese ? "今日课表" : "Today's Schedule")
                    .font(.headline)
                Spacer()
                
                if !appState.shareCalendar {
                    Image(systemName: "eye.slash.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if appState.shareCalendar {
                if todayClasses.isEmpty {
                    // 无课程
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DesignSystem.successColor)
                        Text(loc.language == .chinese ? "今日无课程安排" : "No classes today")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                } else {
                    // 课程列表
                    ForEach(todayClasses) { classItem in
                        TimetableClassRow(classItem: classItem)
                    }
                }
                
                // 查看完整课表
                NavigationLink(destination: ParentAcademicsView()) {
                    HStack {
                        Text(loc.language == .chinese ? "查看完整课表" : "View Full Schedule")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(DesignSystem.primaryColor)
                    .padding(.top, 4)
                }
            } else {
                DataNotSharedView(dataType: loc.language == .chinese ? "课表信息" : "Schedule")
            }
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 课程行组件
struct TimetableClassRow: View {
    @EnvironmentObject var loc: LocalizationService
    let classItem: TimetableClass
    
    var body: some View {
        HStack(spacing: 12) {
            // 时间线指示器
            VStack {
                Circle()
                    .fill(DesignSystem.primaryColor)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2)
            }
            .frame(height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(loc.language == .chinese ? classItem.courseNameCN : classItem.courseName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 8) {
                    Label(classItem.time, systemImage: "clock")
                    Label(loc.language == .chinese ? classItem.locationCN : classItem.location,
                          systemImage: "mappin.circle")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if let instructor = classItem.instructor {
                    Text(instructor)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 健康概况卡
struct HealthSummaryCard: View {
    @EnvironmentObject var loc: LocalizationService
    
    // 模拟数据
    private let allergyCount = 3
    private let severeAllergyCount = 1
    private let activeMedicationCount = 2
    private let weeklyComplianceRate = 0.85
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundColor(DesignSystem.errorColor)
                Text(loc.language == .chinese ? "健康 & 用药" : "Health & Medication")
                    .font(.headline)
                Spacer()
            }
            
            // 健康指标
            VStack(spacing: 12) {
                // 过敏信息
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.language == .chinese ? "过敏记录" : "Allergies")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Text("\(allergyCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(loc.language == .chinese ? "项" : "items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // 严重过敏标记
                    if severeAllergyCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(DesignSystem.errorColor)
                            Text("\(severeAllergyCount) " + (loc.language == .chinese ? "严重" : "severe"))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignSystem.errorColor.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                
                Divider()
                
                // 用药信息
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.language == .chinese ? "长期用药" : "Active Medications")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Text("\(activeMedicationCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(loc.language == .chinese ? "种" : "types")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // 本周打卡率
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(loc.language == .chinese ? "本周打卡" : "This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f%%", weeklyComplianceRate * 100))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(complianceColor(for: weeklyComplianceRate))
                    }
                }
            }
            
            // 查看详情
            NavigationLink(destination: ParentHealthView()) {
                HStack {
                    Text(loc.language == .chinese ? "查看健康档案详情" : "View Health Details")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(DesignSystem.primaryColor)
                .padding(.top, 4)
            }
        }
        .padding()
        .glassCard()
    }
    
    private func complianceColor(for rate: Double) -> Color {
        if rate >= 0.8 { return DesignSystem.successColor }
        else if rate >= 0.6 { return DesignSystem.warningColor }
        else { return DesignSystem.errorColor }
    }
}

// MARK: - 本周重要事项卡
struct WeeklyHighlightsCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    // 模拟数据 - 实际应整合 TodoManager 和 HealthDataManager.appointments
    private var upcomingEvents: [UpcomingEvent] {
        [
            UpcomingEvent(
                id: UUID(),
                title: "Machine Learning Project",
                titleCN: "机器学习项目",
                type: .assignment,
                date: Date().addingTimeInterval(2 * 24 * 3600),
                priority: .high
            ),
            UpcomingEvent(
                id: UUID(),
                title: "GP Appointment",
                titleCN: "全科医生预约",
                type: .medical,
                date: Date().addingTimeInterval(3 * 24 * 3600),
                priority: .medium
            ),
            UpcomingEvent(
                id: UUID(),
                title: "Statistics Assignment",
                titleCN: "统计学作业",
                type: .assignment,
                date: Date().addingTimeInterval(5 * 24 * 3600),
                priority: .medium
            )
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Image(systemName: "flag.fill")
                    .foregroundColor(DesignSystem.warningColor)
                Text(loc.language == .chinese ? "本周重要事项" : "Weekly Highlights")
                    .font(.headline)
                Spacer()
            }
            
            if upcomingEvents.isEmpty {
                Text(loc.language == .chinese ? "暂无待办事项" : "No upcoming events")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(upcomingEvents) { event in
                    UpcomingEventRow(event: event)
                }
            }
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 待办事项行
struct UpcomingEventRow: View {
    @EnvironmentObject var loc: LocalizationService
    let event: UpcomingEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: event.type.icon)
                .font(.title3)
                .foregroundColor(event.type.color)
                .frame(width: 32, height: 32)
                .background(event.type.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.language == .chinese ? event.titleCN : event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(event.date, style: .date)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 优先级标签
            if event.priority == .high {
                Text(loc.language == .chinese ? "紧急" : "Urgent")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DesignSystem.errorColor.opacity(0.1))
                    .foregroundColor(DesignSystem.errorColor)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 校园活动预览卡
struct CampusActivitiesPreviewCard: View {
    @EnvironmentObject var uclVM: UCLAPIViewModel
    @EnvironmentObject var loc: LocalizationService
    
    var todayActivities: [UCLAPIViewModel.UCLAPIEvent] {
        let calendar = Calendar.current
        // 只显示活动类型的事件（type == .manual），不包括课程（type == .api）
        return uclVM.events.filter { event in
            event.type == .manual && calendar.isDateInToday(event.startTime)
        }.sorted { $0.startTime < $1.startTime }
        .prefix(2)
        .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(DesignSystem.secondaryColor)
                Text(loc.language == .chinese ? "今日校园活动" : "Today's Campus Events")
                    .font(.headline)
                Spacer()
            }
            
            if todayActivities.isEmpty {
                Text(loc.language == .chinese ? "今日暂无校园活动" : "No campus events today")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(todayActivities) { activity in
                    CampusActivityPreviewRow(activity: activity)
                }
            }
            
            // 查看全部活动
            NavigationLink(destination: ParentCampusView()) {
                HStack {
                    Text(loc.language == .chinese ? "查看所有校园活动" : "View All Activities")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(DesignSystem.primaryColor)
                .padding(.top, 4)
            }
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 活动预览行
struct CampusActivityPreviewRow: View {
    @EnvironmentObject var loc: LocalizationService
    let activity: UCLAPIViewModel.UCLAPIEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // 时间指示器
            VStack {
                Text(activity.startTime, style: .time)
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(DesignSystem.primaryColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if !activity.location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                        Text(activity.location)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 数据未共享视图
struct DataNotSharedView: View {
    @EnvironmentObject var loc: LocalizationService
    let dataType: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.title)
                .foregroundColor(.gray)
            
            Text(loc.language == .chinese ? "学生暂未共享\(dataType)" : "Student hasn't shared \(dataType)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 辅助数据模型
struct TimetableClass: Identifiable {
    let id: UUID
    let courseName: String
    let courseNameCN: String
    let time: String
    let location: String
    let locationCN: String
    let room: String
    let instructor: String?
}

struct UpcomingEvent: Identifiable {
    let id: UUID
    let title: String
    let titleCN: String
    let type: EventType
    let date: Date
    let priority: Priority
    
    enum EventType {
        case assignment, medical, activity
        
        var icon: String {
            switch self {
            case .assignment: return "doc.text.fill"
            case .medical: return "cross.case.fill"
            case .activity: return "star.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .assignment: return DesignSystem.primaryColor
            case .medical: return DesignSystem.errorColor
            case .activity: return DesignSystem.secondaryColor
            }
        }
    }
    
    enum Priority {
        case high, medium, low
    }
}

