//
//  ParentTodoView.swift
//  uniapp
//
//  Created on 2024.
//

import SwiftUI


// MARK: - Parent Todo View
struct ParentTodoView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState

    @State private var showingAddTodoSheet = false
    @State private var selectedTodo: TodoItem? = nil
    @State private var showingTodoDetail = false
    @State private var showingCompleted = false

    var incompleteTodos: [TodoItem] {
        appState.todoManager.todos.filter { !$0.isCompleted }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
    }

    var completedTodos: [TodoItem] {
        appState.todoManager.todos.filter { $0.isCompleted }
            .sorted { $0.createdDate > $1.createdDate }
    }

    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 统计卡片
                        HStack(spacing: 16) {
                            ParentTodoStatCard(
                                title: "待完成",
                                value: "\(incompleteTodos.count)",
                                icon: "circle",
                                color: Color(hex: "F59E0B")
                            )

                            ParentTodoStatCard(
                                title: "已完成",
                                value: "\(completedTodos.count)",
                                icon: "checkmark.circle.fill",
                                color: Color(hex: "10B981")
                            )

                            ParentTodoStatCard(
                                title: "即将截止",
                                value: "\(appState.todoManager.upcomingDeadlines.count)",
                                icon: "clock.fill",
                                color: Color(hex: "EF4444")
                            )
                        }
                        .padding(.horizontal)

                        // 待完成任务
                        if !incompleteTodos.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("待完成任务")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Button(action: {
                                        showingCompleted.toggle()
                                    }) {
                                        Text(showingCompleted ? "隐藏已完成" : "显示已完成")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "6366F1"))
                                    }
                                }
                                .padding(.horizontal)

                                VStack(spacing: 12) {
                                    ForEach(incompleteTodos) { todo in
                                        ParentTodoRow(todo: todo)
                                            .onTapGesture {
                                                selectedTodo = todo
                                                showingTodoDetail = true
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // 已完成任务（可选显示）
                        if showingCompleted && !completedTodos.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("已完成任务")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)

                                VStack(spacing: 12) {
                                    ForEach(completedTodos.prefix(10)) { todo in
                                        ParentTodoRow(todo: todo, isCompleted: true)
                                            .opacity(0.7)
                                    }
                                }
                                .padding(.horizontal)

                                if completedTodos.count > 10 {
                                    Text("还有 \(completedTodos.count - 10) 个已完成任务")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                }
                            }
                        }

                        // 空状态
                        if incompleteTodos.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(Color(hex: "10B981"))

                                Text("所有任务都已完成！")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text("继续保持，加油！")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("待办事项")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingAddTodoSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }
            .sheet(isPresented: $showingAddTodoSheet) {
                ParentAddTodoView { newTitle, dueDate, priority, category, notes in
                    let newTodo = TodoItem(
                        title: newTitle,
                        dueDate: dueDate,
                        priority: priority,
                        category: category,
                        notes: notes
                    )
                    appState.todoManager.addTodo(newTodo)
                    showingAddTodoSheet = false
                }
            }
            .sheet(item: $selectedTodo) { todo in
                TodoDetailView(todo: todo, isPresented: $showingTodoDetail)
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

// 家长端待办事项行
struct ParentTodoRow: View {
    let todo: TodoItem
    var isCompleted: Bool = false

    var formattedDueDate: String {
        guard let dueDate = todo.dueDate else { return "无截止时间" }

        let now = Date()
        let timeInterval = dueDate.timeIntervalSince(now)

        if timeInterval < 0 {
            return "已过期"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)分钟后"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)小时后"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)天后"
        }
    }

    var priorityColor: Color {
        Color(hex: todo.priority.color)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 优先级指示器
            ZStack {
                Circle()
                    .fill(priorityColor.opacity(0.2))
                    .frame(width: 40, height: 40)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "10B981"))
                } else {
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 12, height: 12)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(todo.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted)

                    Spacer()

                    if !isCompleted && todo.dueDate != nil {
                        Text(formattedDueDate)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(todo.isOverdue ? Color(hex: "EF4444") : Color(hex: "F59E0B"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill((todo.isOverdue ? Color(hex: "EF4444") : Color(hex: "F59E0B")).opacity(0.1))
                            )
                    }
                }

                HStack(spacing: 12) {
                    Text(todo.source)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    if !todo.category.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(todo.category)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Text("•")
                        .foregroundColor(.secondary)
                    Text(todo.priority.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(priorityColor)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// 统计卡片组件
struct ParentTodoStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct ParentAddTodoView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var dueDate = Date()
    @State private var priority: TodoPriority = .medium
    @State private var category = "作业"
    @State private var notes = ""

    let onSave: (String, Date?, TodoPriority, String, String?) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("标题")) {
                    TextField("标题", text: $title)
                }

                Section(header: Text("截止日期")) {
                    DatePicker("截止日期", selection: $dueDate)
                }

                Section(header: Text("优先级")) {
                    Picker("优先级", selection: $priority) {
                        ForEach(TodoPriority.allCases, id: \.self) { value in
                            Text(value.displayName).tag(value)
                        }
                    }
                }

                Section(header: Text("分类")) {
                    TextField("分类", text: $category)
                }

                Section(header: Text("备注")) {
                    TextField("备注", text: $notes)
                }
            }
            .navigationTitle("新建待办")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(title, dueDate, priority, category, notes.isEmpty ? nil : notes)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
