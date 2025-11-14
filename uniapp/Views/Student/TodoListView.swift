//
//  TodoListView.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI

// MARK: - 待办事项列表视图
struct TodoListView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    @State private var selectedCategory: String = "全部"
    @State private var selectedStatus: TodoStatus? = nil
    @State private var selectedCourse: String? = nil
    @State private var showingAddTodo = false
    @State private var selectedTodo: TodoItem? = nil
    @State private var showingDeleteAlert = false
    @State private var todoToDelete: TodoItem? = nil
    
    private let categories = ["全部", "作业", "考试", "项目", "阅读", "实验", "论文", "其他"]
    
    var filteredTodos: [TodoItem] {
        var todos = appState.todoManager.todos
        
        // 按分类筛选
        if selectedCategory != "全部" {
            todos = todos.filter { $0.category == selectedCategory }
        }
        
        // 按状态筛选
        if let status = selectedStatus {
            todos = todos.filter { $0.status == status }
        }
        
        // 按课程筛选
        if let course = selectedCourse {
            todos = todos.filter { $0.courseCode == course }
        }
        
        // 排序：未完成优先，然后按截止日期
        return todos.sorted { lhs, rhs in
            if lhs.status != rhs.status {
                if lhs.status == .completed { return false }
                if rhs.status == .completed { return true }
            }
            
            let lhsDate = lhs.dueDate ?? Date.distantFuture
            let rhsDate = rhs.dueDate ?? Date.distantFuture
            return lhsDate < rhsDate
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 筛选栏
                    filterBar
                    
                    // 列表
                    if filteredTodos.isEmpty {
                        emptyStateView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredTodos) { todo in
                                    TodoListCard(todo: todo)
                                        .environmentObject(appState)
                                        .onTapGesture {
                                            selectedTodo = todo
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                todoToDelete = todo
                                                showingDeleteAlert = true
                                            } label: {
                                                Label("删除", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("待办事项")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTodo = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView()
                    .environmentObject(appState)
                    .environmentObject(loc)
            }
            .sheet(item: $selectedTodo) { todo in
                TodoDetailView(todo: todo, isPresented: Binding(
                    get: { selectedTodo != nil },
                    set: { if !$0 { selectedTodo = nil } }
                ))
                .environmentObject(appState)
                .environmentObject(loc)
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) {
                    todoToDelete = nil
                }
                Button("删除", role: .destructive) {
                    if let todo = todoToDelete {
                        appState.deleteTodo(todo)
                        todoToDelete = nil
                    }
                }
            } message: {
                if let todo = todoToDelete {
                    Text("确定要删除「\(todo.title)」吗？此操作无法撤销。")
                }
            }
        }
    }
    
    // MARK: - 筛选栏
    private var filterBar: some View {
        VStack(spacing: 12) {
            // 分类筛选
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        TodoFilterChip(
                            title: category,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // 状态筛选
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    TodoFilterChip(
                        title: "全部",
                        isSelected: selectedStatus == nil
                    ) {
                        withAnimation {
                            selectedStatus = nil
                        }
                    }
                    
                    ForEach(TodoStatus.allCases) { status in
                        TodoFilterChip(
                            title: status.rawValue,
                            isSelected: selectedStatus == status,
                            color: Color(hex: status.color)
                        ) {
                            withAnimation {
                                selectedStatus = selectedStatus == status ? nil : status
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.9))
    }
    
    // MARK: - 空状态
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(Color(hex: "10B981").opacity(0.3))
            
            Text("暂无待办事项")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
            
            Text("点击右上角 + 按钮添加待办")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 待办列表卡片
struct TodoListCard: View {
    @EnvironmentObject var appState: AppState
    let todo: TodoItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 状态指示器
            Button {
                appState.toggleTodo(todo)
            } label: {
                Image(systemName: todo.status.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: todo.status.color))
            }
            .buttonStyle(.plain)
            
            // 内容
            VStack(alignment: .leading, spacing: 6) {
                Text(todo.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .strikethrough(todo.status == .completed)
                
                HStack(spacing: 8) {
                    // 分类标签
                    Text(todo.category)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "6366F1"))
                        .clipShape(Capsule())
                    
                    // 优先级标签
                    Text(todo.priority.displayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: todo.priority.color))
                        .clipShape(Capsule())
                    
                    // 状态标签
                    Text(todo.status.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: todo.status.color))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    // 截止日期
                    if let dueDate = todo.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(formatDate(dueDate))
                                .font(.system(size: 11))
                        }
                        .foregroundColor(todo.isOverdue ? Color(hex: "EF4444") : .secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 筛选标签
struct TodoFilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color? = nil
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Group {
                        if isSelected {
                            if let color = color {
                                color
                            } else {
                                LinearGradient(
                                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        } else {
                            Color.white.opacity(0.8)
                        }
                    }
                )
                .clipShape(Capsule())
                .shadow(color: isSelected ? (color?.opacity(0.3) ?? Color(hex: "6366F1").opacity(0.3)) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}

