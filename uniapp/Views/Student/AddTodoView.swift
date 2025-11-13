//
//  AddTodoView.swift
//  uniapp
//
//  用户添加自定义待办事项（已修复 toolbar 重载歧义，跨平台稳定）
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
    
    private let categories = ["作业", "考试", "项目", "阅读", "实验", "论文", "其他"]
    
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
            // ✅ 关键：按平台拆分 toolbar，避免重载歧义
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                    }
                }
                #endif
            }
            .alert("提示", isPresented: $showingValidationAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
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
                    "请选择截止时间",
                    selection: $dueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(14)
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - 备注
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("备注")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            TextEditor(text: $notes)
                .frame(minHeight: 120)
                .padding(12)
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - 添加按钮
    private var addButton: some View {
        Button {
            validateAndSave()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text("添加到待办")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 10, x: 0, y: 4)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 8)
    }
    
    // MARK: - 校验并保存
    private func validateAndSave() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            validationMessage = "请输入标题"
            showingValidationAlert = true
            return
        }
        
        let newTodo = TodoItem(
            title: trimmed,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority,
            category: category,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        appState.addTodo(newTodo)  // ✅ 直接添加到 appState
        dismiss()
    }
}

// MARK: - 小组件

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : Color(hex: "374151"))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.white.opacity(0.9)
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color(hex: "6366F1").opacity(isSelected ? 0 : 0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
            .onTapGesture(perform: onTap)
    }
}

private struct PriorityChip: View {
    let priority: TodoPriority
    let isSelected: Bool
    let onTap: () -> Void
    
    private var title: String {
        switch priority {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        case .urgent: return "急"
        }
    }
    
    private var color: Color {
        switch priority {
        case .low: return Color(hex: "10B981")
        case .medium: return Color(hex: "F59E0B")
        case .high: return Color(hex: "EF4444")
        case .urgent: return Color(hex: "DC2626")
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title).font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(isSelected ? .white : color)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(isSelected ? color : Color.white.opacity(0.9))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .onTapGesture(perform: onTap)
    }
}
