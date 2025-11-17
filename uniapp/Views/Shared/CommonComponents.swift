//
//  CommonComponents.swift
//  uniapp
//
//  Created on 2024.
//

import SwiftUI

// MARK: - Design System
// TODO: 添加 DesignSystem 相关代码

// MARK: - Card Components
// TODO: 添加各种 Card 组件

// MARK: - Row Components
// TODO: 添加各种 Row 组件


// MARK: - 15. Custom Gauge Style
struct DesignSystem {
    // ✅ 新的色彩系统
    static let primaryColor = Color(hex: "6366F1")
    static let secondaryColor = Color(hex: "8B5CF6")
    static let successColor = Color(hex: "10B981")
    static let warningColor = Color(hex: "F59E0B")
    static let errorColor = Color(hex: "EF4444")
    
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "F8FAFC"), Color(hex: "F1F5F9")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // ✅ 卡片样式
    static func cardStyle() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}

// MARK: - 16. Custom Gauge Style
struct CircularGaugeStyle: GaugeStyle {
    var tint: Gradient
    var thickness: CGFloat = 12.0

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: thickness, lineCap: .round))

            Circle()
                .trim(from: 0, to: configuration.value)
                .stroke(tint, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            configuration.currentValueLabel
        }
    }
}

extension CircularGaugeStyle {
    init(tint: Color, thickness: CGFloat = 12.0) {
        self.init(tint: Gradient(colors: [tint, tint]), thickness: thickness)
    }
}

// MARK: - Todo Detail View
struct TodoDetailView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    let todo: TodoItem
    @Binding var isPresented: Bool

    @State private var showingDeleteAlert = false

    // ✅ 添加创建时间的 formatter
    var createdDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: loc.language == .chinese ? "zh_CN" : "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var formattedDueDate: String {
        guard let dueDate = todo.dueDate else { return loc.tr("no_due_date") }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: loc.language == .chinese ? "zh_CN" : "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter.string(from: dueDate)
    }

    var timeRemaining: String {
        guard let dueDate = todo.dueDate else { return "" }

        let now = Date()
        let timeInterval = dueDate.timeIntervalSince(now)

        if timeInterval < 0 {
            let overdueTime = abs(timeInterval)
            if overdueTime < 3600 {
                let minutes = Int(overdueTime / 60)
                return loc.language == .chinese ? "已过期 \(minutes) 分钟" : "Overdue by \(minutes) minutes"
            } else if overdueTime < 86400 {
                let hours = Int(overdueTime / 3600)
                return loc.language == .chinese ? "已过期 \(hours) 小时" : "Overdue by \(hours) hours"
            } else {
                let days = Int(overdueTime / 86400)
                return loc.language == .chinese ? "已过期 \(days) 天" : "Overdue by \(days) days"
            }
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return loc.language == .chinese ? "\(minutes) 分钟后截止" : "Due in \(minutes) minutes"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return loc.language == .chinese ? "\(hours) 小时后截止" : "Due in \(hours) hours"
        } else {
            let days = Int(timeInterval / 86400)
            return loc.language == .chinese ? "\(days) 天后截止" : "Due in \(days) days"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // 标题区域
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Circle()
                                .fill(Color(hex: todo.priority.color).opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .fill(Color(hex: todo.priority.color))
                                        .frame(width: 16, height: 16)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(todo.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)

                                HStack(spacing: 12) {
                                    Text(todo.source)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)

                                    Text("•")
                                        .foregroundColor(.secondary)

                                    Text(todo.category)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // 优先级和状态
                        HStack(spacing: 12) {
                            Label(todo.priority.displayName, systemImage: "flag.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: todo.priority.color))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: todo.priority.color).opacity(0.1))
                                .clipShape(Capsule())

                            if todo.isCompleted {
                                Label(loc.tr("completed"), systemImage: "checkmark.circle.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "10B981"))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "10B981").opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    // 截止时间
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.tr("todo_due_date"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(Color(hex: "F59E0B"))
                                .font(.system(size: 16))

                            Text(formattedDueDate)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)

                            Spacer()

                            Text(timeRemaining)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(todo.isOverdue ? Color(hex: "EF4444") : Color(hex: "F59E0B"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill((todo.isOverdue ? Color(hex: "EF4444") : Color(hex: "F59E0B")).opacity(0.1))
                                )
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // 备注
                    if let notes = todo.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.tr("todo_notes"))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)

                            Text(notes)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // 创建时间
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.tr("created_time"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(Color(hex: "6366F1"))
                                .font(.system(size: 16))

                            // ✅ 直接使用 createdDateFormatter
                            Text(createdDateFormatter.string(from: todo.createdDate))
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .background(DesignSystem.backgroundGradient.ignoresSafeArea())
            .navigationTitle(loc.tr("todo_detail"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar(content: {
                ToolbarItem(placement: .automatic) {
                    Button(loc.tr("cancel")) {
                        isPresented = false
                    }
                    .foregroundColor(Color(hex: "6366F1"))
                }

                ToolbarItem(placement: .automatic) {
                    Menu {
                        if !todo.isCompleted {
                            Button(action: {
                                appState.todoManager.toggleCompletion(todo)
                                isPresented = false
                            }) {
                                Label(loc.tr("mark_as_complete"), systemImage: "checkmark.circle")
                            }
                        }

                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Label(loc.tr("delete_task"), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Color(hex: "6366F1"))
                            .font(.system(size: 20))
                    }
                }
            })
            .alert(loc.tr("confirm_delete"), isPresented: $showingDeleteAlert) {
                Button(loc.tr("delete"), role: .destructive) {
                    appState.todoManager.deleteTodo(todo)
                    isPresented = false
                }
                Button(loc.tr("cancel"), role: .cancel) {}
            } message: {
                Text(loc.tr("confirm_delete_message"))
            }
        }  // ✅ NavigationView 结束
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }  // ✅ body 结束
}  // ✅ struct 结束

// MARK: - Parent Dashboard Cards

struct UpcomingDeadlinesCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    let onTodoTap: (TodoItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📅 " + loc.tr("upcoming_deadlines"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            if appState.todoManager.upcomingDeadlines.isEmpty {
                Text(loc.tr("no_upcoming_deadlines"))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            } else {
                ForEach(appState.todoManager.upcomingDeadlines) { todo in
                    Button(action: {
                        onTodoTap(todo)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(todo.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)

                                if let dueDate = todo.dueDate {
                                    Text(dueDate, style: .relative)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            Circle()
                                .fill(Color(hex: todo.priority.color).opacity(0.2))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text(todo.priority.displayName)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(hex: todo.priority.color))
                                )
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

struct PlaceholderWeeklySummaryCard: View {
    @EnvironmentObject var loc: LocalizationService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 " + loc.tr("weekly_summary"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            Text(loc.tr("weekly_summary_desc"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

struct PlaceholderAttendanceHeatmapCard: View {
    @EnvironmentObject var loc: LocalizationService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📈 " + loc.tr("attendance_heatmap"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            Text(loc.tr("monthly_attendance"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

struct AttendanceReportCard: View {
    @EnvironmentObject var loc: LocalizationService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("✅ " + loc.tr("attendance_report"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            Text(loc.tr("total_attendance"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

struct PlaceholderAssignmentProgressCard: View {
    @EnvironmentObject var loc: LocalizationService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📝 " + loc.tr("assignment_progress"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            Text(loc.tr("assignment_completed"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

struct PlaceholderActivityParticipationCard: View {
    @EnvironmentObject var loc: LocalizationService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎯 " + loc.tr("activity_participation"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            Text(loc.tr("monthly_participation"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

struct PlaceholderDataNotSharedView: View {
    @EnvironmentObject var loc: LocalizationService
    let dataType: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "F59E0B"))

            Text(loc.language == .chinese ? "\(dataType)未共享" : "\(dataType) Not Shared")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)

            Text(loc.tr("data_not_shared_desc"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}
