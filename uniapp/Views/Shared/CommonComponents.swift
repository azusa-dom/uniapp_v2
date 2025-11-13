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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("详情")) {
                    Text(todo.title)
                        .font(.headline)
                    Text("分类: \(todo.category)")
                    Text("优先级: \(todo.priority.displayName)")
                    if let dueDate = todo.dueDate {
                        Text("截止时间: \(dueDate, style: .date) \(dueDate, style: .time)")
                    }
                }
                
                if let notes = todo.notes, !notes.isEmpty {
                    Section(header: Text("备注")) {
                        Text(notes)
                    }
                }
            }
            .navigationTitle("待办详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        isPresented = false
                    }
                }
            }
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
