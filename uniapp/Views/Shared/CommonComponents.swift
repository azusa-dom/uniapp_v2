//
//  共享视图.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI

// MARK: - 待办事项详情
struct TodoDetailView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    let todo: TodoItem
    @Binding var isPresented: Bool
    
    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedCategory: String = ""
    @State private var editedPriority: TodoPriority = .medium
    @State private var editedStatus: TodoStatus = .notStarted
    @State private var editedDueDate: Date = Date()
    @State private var hasDueDate: Bool = true
    @State private var editedNotes: String = ""
    @State private var showingDeleteAlert = false
    
    private let categories = ["作业", "考试", "项目", "阅读", "实验", "论文", "其他"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if isEditing {
                            editView
                        } else {
                            detailView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditing ? "编辑待办" : "待办详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("保存") {
                            saveChanges()
                        }
                        .fontWeight(.semibold)
                    } else {
                        Menu {
                            Button {
                                startEditing()
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }
                            
                            Button {
                                appState.toggleTodo(todo)
                            } label: {
                                Label(
                                    todo.status == .completed ? "标记为未完成" : "标记为已完成",
                                    systemImage: todo.status == .completed ? "arrow.counterclockwise" : "checkmark.circle"
                                )
                            }
                            
                            Divider()
                            
                            Button(role: .destructive) {
                                showingDeleteAlert = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    appState.deleteTodo(todo)
                    isPresented = false
                }
            } message: {
                Text("确定要删除「\(todo.title)」吗？此操作无法撤销。")
            }
            .onAppear {
                if !isEditing {
                    loadTodoData()
                }
            }
        }
    }
    
    // MARK: - 详情视图
    private var detailView: some View {
        VStack(spacing: 16) {
            // 标题卡片
            VStack(alignment: .leading, spacing: 12) {
                Text(todo.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    StatusBadge(status: todo.status)
                    PriorityBadge(priority: todo.priority)
                    CategoryBadge(category: todo.category)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .glassCard()
            
            // 信息卡片
            VStack(alignment: .leading, spacing: 16) {
                if let dueDate = todo.dueDate {
                    TodoInfoRow(icon: "calendar", label: "截止时间", value: formatDateTime(dueDate))
                }
                
                if let courseCode = todo.courseCode {
                    TodoInfoRow(icon: "book.fill", label: "课程", value: courseCode)
                }
                
                TodoInfoRow(icon: "clock.fill", label: "创建时间", value: formatDateTime(todo.createdDate))
            }
            .padding()
            .glassCard()
            
            // 备注卡片
            if let notes = todo.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("备注")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(notes)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .glassCard()
            }
            
            // 状态切换按钮
            Button {
                appState.toggleTodo(todo)
            } label: {
                HStack {
                    Image(systemName: todo.status == .completed ? "arrow.counterclockwise" : "checkmark.circle.fill")
                    Text(todo.status == .completed ? "标记为未完成" : "标记为已完成")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.top, 8)
            
            // 删除按钮
            Button {
                showingDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("删除待办")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "EF4444"))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - 编辑视图
    private var editView: some View {
        VStack(spacing: 20) {
            // 标题
            VStack(alignment: .leading, spacing: 8) {
                Text("标题")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                TextField("请输入标题", text: $editedTitle)
                    .textFieldStyle(.roundedBorder)
            }
            
            // 分类
            VStack(alignment: .leading, spacing: 8) {
                Text("分类")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("分类", selection: $editedCategory) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // 优先级
            VStack(alignment: .leading, spacing: 8) {
                Text("优先级")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("优先级", selection: $editedPriority) {
                    ForEach(TodoPriority.allCases, id: \.self) { priority in
                        Text(priority.displayName).tag(priority)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // 状态
            VStack(alignment: .leading, spacing: 8) {
                Text("状态")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("状态", selection: $editedStatus) {
                    ForEach(TodoStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // 截止日期
            VStack(alignment: .leading, spacing: 8) {
                Toggle("设置截止日期", isOn: $hasDueDate)
                
                if hasDueDate {
                    DatePicker("截止时间", selection: $editedDueDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            
            // 备注
            VStack(alignment: .leading, spacing: 8) {
                Text("备注")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                TextEditor(text: $editedNotes)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
    }
    
    // MARK: - 辅助方法
    private func loadTodoData() {
        editedTitle = todo.title
        editedCategory = todo.category
        editedPriority = todo.priority
        editedStatus = todo.status
        editedDueDate = todo.dueDate ?? Date()
        hasDueDate = todo.dueDate != nil
        editedNotes = todo.notes ?? ""
    }
    
    private func startEditing() {
        loadTodoData()
        isEditing = true
    }
    
    private func saveChanges() {
        var updatedTodo = todo
        updatedTodo.title = editedTitle
        updatedTodo.category = editedCategory
        updatedTodo.priority = editedPriority
        updatedTodo.status = editedStatus
        updatedTodo.dueDate = hasDueDate ? editedDueDate : nil
        updatedTodo.notes = editedNotes.isEmpty ? nil : editedNotes
        
        appState.updateTodo(updatedTodo)
        isEditing = false
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 辅助视图组件
struct StatusBadge: View {
    let status: TodoStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.system(size: 10))
            Text(status.rawValue)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color(hex: status.color))
        .clipShape(Capsule())
    }
}

struct PriorityBadge: View {
    let priority: TodoPriority
    
    var body: some View {
        Text(priority.displayName)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(hex: priority.color))
            .clipShape(Capsule())
    }
}

struct CategoryBadge: View {
    let category: String
    
    var body: some View {
        Text(category)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(hex: "6366F1"))
            .clipShape(Capsule())
    }
}

struct TodoInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6366F1"))
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
        }
    }
}


// MARK: - 聊天组件
// ✅ ChatInputBar 和 MessageBubble 现在定义在 ChatComponents.swift 中

// MARK: - 角色切换卡片
// ✅ RoleSwitchCard 现在定义在 StudentProfileView.swift 中

// MARK: - 设置行
// ✅ SettingsRow 现在定义在 StudentProfileView.swift 中

// MARK: - Design System
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
    
    static let backgroundGradient: LinearGradient = LinearGradient(
        colors: [
            Color(hex: "F8F9FF"),
            Color(hex: "EEF2FF"),
            Color(hex: "E0E7FF")
        ],
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
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}

// MARK: - onChange 兼容处理
private struct OnChangeCompatibilityModifier<Value: Equatable>: ViewModifier {
    let value: Value
    let action: (Value) -> Void
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            content.onChange(of: value, perform: action)
        }
    }
}

extension View {
    func onChangeCompat<Value: Equatable>(_ value: Value, perform action: @escaping (Value) -> Void) -> some View {
        modifier(OnChangeCompatibilityModifier(value: value, action: action))
    }
}
