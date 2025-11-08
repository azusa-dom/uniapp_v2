//
//  AddTodoView.swift
//  uniapp
//
//  用户添加自定义待办事项
//

import SwiftUI

struct AddTodoView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var category: String = "作业"
    @State private var priority: TodoPriority = .medium
    @State private var dueDate: Date = Date()
    @State private var hasDueDate: Bool = true
    @State private var notes: String = ""
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    let categories = ["作业", "考试", "项目", "阅读", "实验", "论文", "其他"]
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        titleSection
                        categorySection
                        prioritySection
                        dueDateSection
                        notesSection
                        addButton
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("添加待办事项")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert("提示", isPresented: $showingValidationAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // MARK: - 标题输入区域
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("标题")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("*")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "EF4444"))
            }
            
            TextField("请输入待办事项标题", text: $title)
                .font(.system(size: 16))
                .padding(16)
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - 分类选择区域
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("分类")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { cat in
                        CategoryChip(
                            title: cat,
                            isSelected: category == cat
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                category = cat
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 优先级选择区域
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("优先级")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 12) {
                ForEach(TodoPriority.allCases, id: \.self) { p in
                    PriorityChip(
                        priority: p,
                        isSelected: priority == p
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            priority = p
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 截止日期区域
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("截止日期")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $hasDueDate)
                    .labelsHidden()
            }
            
            if hasDueDate {
                DatePicker(
                    "",
                    selection: $dueDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding(16)
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - 备注区域
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "note.text")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("备注")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            TextEditor(text: $notes)
                .font(.system(size: 15))
                .frame(height: 120)
                .padding(12)
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    // MARK: - 添加按钮
    private var addButton: some View {
        Button {
            addTodoItem()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                
                Text("添加待办事项")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.top, 20)
    }
    
    // MARK: - 添加待办事项逻辑
    private func addTodoItem() {
        // 验证标题
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "请输入待办事项标题"
            showingValidationAlert = true
            return
        }
        
        // 创建新的待办事项
        let newTodo = TodoItem(
            title: title,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority,
            category: category,
            notes: notes.isEmpty ? nil : notes,
            isCompleted: false,
            createdDate: Date(),
            source: "用户创建"
        )
        
        // 添加到管理器
        appState.todoManager.addTodo(newTodo)
        
        // 关闭视图
        dismiss()
    }
}

// MARK: - 分类芯片组件
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(hex: "6366F1"))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    isSelected
                        ? LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        : LinearGradient(
                            colors: [Color(hex: "6366F1").opacity(0.1), Color(hex: "6366F1").opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
                .clipShape(Capsule())
                .shadow(
                    color: isSelected ? Color(hex: "6366F1").opacity(0.3) : .clear,
                    radius: 8,
                    x: 0,
                    y: 2
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 优先级芯片组件
struct PriorityChip: View {
    let priority: TodoPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 12))
                
                Text(priority.displayName)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : Color(hex: priority.color))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? Color(hex: priority.color)
                    : Color(hex: priority.color).opacity(0.15)
            )
            .clipShape(Capsule())
            .shadow(
                color: isSelected ? Color(hex: priority.color).opacity(0.3) : .clear,
                radius: 8,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 预览
struct AddTodoView_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoView()
            .environmentObject(AppState())
            .environmentObject(LocalizationService())
    }
}
