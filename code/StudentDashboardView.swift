// StudentDashboardView.swift
// 选取核心片段用于网页展示

import SwiftUI

struct StudentDashboardView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @StateObject private var activitiesService = UCLActivitiesService()
    @Binding var selectedTab: Int
    @State private var dashboardSelectedTodo: TodoItem?
    @State private var showingTodoDetail = false

    private var pinnedActivities: [UCLActivity] {
        activitiesService.activities.prefix(3).map { $0 }
    }

    private var todayClasses: [TodayClass] {
        [
            TodayClass(
                name: "数据科学与统计",
                code: "CHME0007",
                time: "14:00 - 16:00",
                location: "Cruciform Building, Room 4.18",
                lecturer: "Dr. Johnson"
            ),
            TodayClass(
                name: "健康数据科学原理",
                code: "CHME0006",
                time: "16:30 - 18:30",
                location: "Foster Court, Lecture Theatre",
                lecturer: "Prof. Smith"
            )
        ]
    }

    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        header
                        statsRow
                        todayClassesSection
                        upcomingDeadlinesSection
                        recommendationsSection
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 30)
                }
            }
            .sheet(item: $dashboardSelectedTodo) { todo in
                TodoDetailView(todo: todo, isPresented: $showingTodoDetail)
                    .environmentObject(loc)
                    .environmentObject(appState)
            }
            .navigationTitle(loc.tr("tab_home"))
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if activitiesService.activities.isEmpty {
                    activitiesService.loadActivities()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.tr("home_welcome") + " Zoya")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            Text("MSc Health Data Science · Year 1")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                quickActionButton(icon: "envelope.fill", title: loc.tr("home_qa_email")) {
                    selectedTab = 4
                }

                quickActionButton(icon: "sparkles", title: loc.tr("home_qa_activities")) {
                    selectedTab = 5
                }
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            DashboardStatCard(
                title: loc.tr("home_deadlines"),
                value: "\(appState.todoManager.upcomingDeadlines.count)",
                icon: "clock.fill",
                color: Color(hex: "F59E0B")
            )

            DashboardStatCard(
                title: loc.tr("home_today_classes"),
                value: "\(todayClasses.count)",
                icon: "book.fill",
                color: Color(hex: "6366F1")
            )

            DashboardStatCard(
                title: loc.tr("home_todo"),
                value: "\(appState.todoManager.todos.filter { !$0.isCompleted }.count)",
                icon: "checkmark.circle.fill",
                color: Color(hex: "10B981")
            )
        }
    }

    private var todayClassesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📚 " + loc.tr("home_today_classes"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: { selectedTab = 1 }) {
                    Text("查看全部")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6366F1"))
                }
            }

            if todayClasses.isEmpty {
                StudentEmptyStateCard(
                    icon: "checkmark.circle.fill",
                    message: "今天没有课程，好好利用这段时间！",
                    color: "10B981"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(todayClasses) { classItem in
                        TodayClassCard(classItem: classItem)
                            .onTapGesture { selectedTab = 1 }
                    }
                }
            }
        }
    }

    private var upcomingDeadlinesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("⏰ " + loc.tr("home_deadlines"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                if !appState.todoManager.upcomingDeadlines.isEmpty {
                    Button(action: { selectedTab = 2 }) {
                        Text("查看全部")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }

            if appState.todoManager.upcomingDeadlines.isEmpty {
                StudentEmptyStateCard(
                    icon: "checkmark.circle.fill",
                    message: "暂无待办事项，所有任务都已完成！",
                    color: "10B981"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(appState.todoManager.upcomingDeadlines.prefix(3)) { todo in
                        DeadlineCard(todo: todo)
                            .onTapGesture {
                                dashboardSelectedTodo = todo
                                showingTodoDetail = true
                            }
                    }
                }
            }
        }
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🎯 " + loc.tr("home_recommendations"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                if !pinnedActivities.isEmpty {
                    Button(action: { selectedTab = 5 }) {
                        Text("查看全部")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }

            if activitiesService.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if pinnedActivities.isEmpty {
                StudentEmptyStateCard(
                    icon: "sparkles",
                    message: "暂无活动，稍后再来看看吧",
                    color: "F59E0B"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(pinnedActivities) { activity in
                        RecommendationActivityCard(activity: activity)
                            .onTapGesture { selectedTab = 5 }
                    }
                }
            }
        }
    }

    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TodayClass: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let time: String
    let location: String
    let lecturer: String
}

struct TodayClassCard: View {
    let classItem: TodayClass

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(classItem.time.split(separator: "-").first?.trimmingCharacters(in: .whitespaces) ?? "")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "6366F1"))

                Rectangle()
                    .fill(Color(hex: "6366F1").opacity(0.3))
                    .frame(width: 2, height: 20)

                Text(classItem.time.split(separator: "-").last?.trimmingCharacters(in: .whitespaces) ?? "")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)

            VStack(alignment: .leading, spacing: 6) {
                Text(classItem.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(classItem.code)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "6366F1"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(hex: "6366F1").opacity(0.1))
                    .clipShape(Capsule())

                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "F59E0B"))

                    Text(classItem.location)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "10B981"))

                    Text(classItem.lecturer)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct DeadlineCard: View {
    let todo: TodoItem

    private var timeRemaining: String {
        guard let dueDate = todo.dueDate else { return "无截止时间" }

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
        guard let dueDate = todo.dueDate else { return Color(hex: "6B7280") }

        let interval = dueDate.timeIntervalSince(Date())

        if interval < 0 {
            return Color(hex: "EF4444")
        } else if interval < 86400 {
            return Color(hex: "F59E0B")
        } else if interval < 259200 {
            return Color(hex: "8B5CF6")
        } else {
            return Color(hex: "10B981")
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

            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(todo.category)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Text(timeRemaining)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(urgencyColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(urgencyColor.opacity(0.1))
                    .clipShape(Capsule())
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

