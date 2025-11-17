//
//  HealthManagementView.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI

// MARK: - 主视图
struct HealthManagementView: View {
    @EnvironmentObject var loc: LocalizationService
    @StateObject private var healthManager = HealthManager()
    
    @State private var selectedTab: HealthTab = .prescriptions
    
    
    enum HealthTab: String, CaseIterable {
        case prescriptions = "处方记录"
        case allergies = "过敏史"
        case logs = "用药打卡"
        
        var icon: String {
            switch self {
            case .prescriptions: return "pills.fill"
            case .allergies: return "exclamationmark.triangle.fill"
            case .logs: return "checkmark.circle.fill"
            }
        }
        
        var color: String {
            switch self {
            case .prescriptions: return "6366F1"
            case .allergies: return "EF4444"
            case .logs: return "10B981"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // ✅ 统一的背景渐变（与其他页面一致）
                LinearGradient(
                    colors: [
                        Color(hex: "F8F9FF"),
                        Color(hex: "EEF2FF"),
                        Color(hex: "E0E7FF")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // ✅ 统一风格的标签栏
                    customTabBar
                    
                    // 内容区域
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            switch selectedTab {
                            case .prescriptions:
                                PrescriptionsManagementView()
                                    .environmentObject(healthManager)
                            case .allergies:
                                AllergiesManagementView()
                                    .environmentObject(healthManager)
                            case .logs:
                                MedicationLogsView()
                                    .environmentObject(healthManager)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("健康管理")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // ✅ 统一风格的标签栏
    private var customTabBar: some View {
        HStack(spacing: 12) {
            ForEach(HealthTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(selectedTab == tab ? 
                                      Color(hex: tab.color).opacity(0.15) : 
                                      Color.clear)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? 
                                               Color(hex: tab.color) : 
                                               .secondary)
                        }
                        
                        Text(tab.rawValue)
                            .font(.system(size: 12, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? 
                                           Color(hex: tab.color) : 
                                           .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == tab ?
                        Color.white.opacity(0.8) :
                        Color.clear
                    )
                    .cornerRadius(16)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.3))
    }
}

// MARK: - 处方记录视图
struct PrescriptionsManagementView: View {
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var loc: LocalizationService
    
    @State private var showingAddPrescription = false
    @State private var selectedHealthPrescription: HealthPrescription?
    @State private var showActiveOnly = true
    
    var displayedPrescriptions: [HealthPrescription] {
        showActiveOnly ? healthManager.activePrescriptions : healthManager.inactivePrescriptions
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // ✅ 统一风格的统计卡片
            statsCards
            
            // ✅ 统一风格的筛选器
            filterSegment
            
            // 处方列表
            if displayedPrescriptions.isEmpty {
                emptyState
            } else {
                ForEach(displayedPrescriptions) { prescription in
                    HealthPrescriptionCard(prescription: prescription)
                        .environmentObject(healthManager)
                        .onTapGesture {
                            selectedHealthPrescription = prescription
                        }
                }
            }
            
            // ✅ 统一风格的添加按钮
            addButton
        }
        .sheet(isPresented: $showingAddPrescription) {
            AddPrescriptionView()
                .environmentObject(healthManager)
        }
        .sheet(item: $selectedHealthPrescription) { prescription in
            HealthPrescriptionDetailView(prescription: prescription)
                .environmentObject(healthManager)
        }
    }
    
    // ✅ 统一风格的统计卡片
    private var statsCards: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "pills.fill",
                title: "正在服用",
                value: "\(healthManager.activePrescriptions.count)",
                color: Color(hex: "6366F1")
            )
            
            StatCard(
                icon: "checkmark.circle.fill",
                title: "已完成",
                value: "\(healthManager.inactivePrescriptions.count)",
                color: Color(hex: "10B981")
            )
            
            StatCard(
                icon: "bell.fill",
                title: "今日提醒",
                value: "\(healthManager.activePrescriptions.filter { $0.reminderEnabled }.count)",
                color: Color(hex: "F59E0B")
            )
        }
    }
    
    // ✅ 统一风格的筛选器
    private var filterSegment: some View {
        HStack(spacing: 0) {
            FilterButton(
                title: "正在服用",
                isSelected: showActiveOnly,
                action: { withAnimation { showActiveOnly = true } }
            )
            
            FilterButton(
                title: "历史记录",
                isSelected: !showActiveOnly,
                action: { withAnimation { showActiveOnly = false } }
            )
        }
        .padding(4)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "pills.circle")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "6366F1").opacity(0.3))
                .padding(.top, 40)
            
            Text(showActiveOnly ? "暂无正在服用的处方" : "暂无历史处方记录")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("点击下方按钮添加您的处方信息")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    // ✅ 统一风格的添加按钮
    private var addButton: some View {
        Button(action: { showingAddPrescription = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                
                Text("添加处方")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 8)
    }
}

// MARK: - 统一的统计卡片组件
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 统一的筛选按钮组件
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "6366F1") : Color.clear)
                .cornerRadius(8)
        }
    }
}

// MARK: - 统一的处方卡片组件
struct HealthPrescriptionCard: View {
    @EnvironmentObject var healthManager: HealthManager
    let prescription: HealthPrescription
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 头部
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(prescription.medicineName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(prescription.purpose)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 状态指示器
                ZStack {
                    Circle()
                        .fill(prescription.isActive ? 
                              Color(hex: "10B981").opacity(0.1) : 
                              Color.gray.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: prescription.isActive ? "circle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(prescription.isActive ? 
                                       Color(hex: "10B981") : 
                                       .gray)
                }
            }
            
            Divider()
            
            // 用药信息
            VStack(spacing: 8) {
                HealthInfoRow(icon: "pills.fill", label: "用量", value: prescription.dosage)
                HealthInfoRow(icon: "clock.fill", label: "频率", value: prescription.frequency)
                HealthInfoRow(icon: "calendar", label: "疗程", value: prescription.duration)
            }
            
            // 底部信息
            HStack {
                Label(prescription.prescribedBy, systemImage: "stethoscope")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatDate(prescription.prescribedDate))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
            
            // 提醒状态
            if prescription.reminderEnabled {
                HStack(spacing: 6) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Text("已启用用药提醒")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "F59E0B").opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .contextMenu {
            Button(action: {
                healthManager.togglePrescriptionStatus(prescription)
            }) {
                Label(
                    prescription.isActive ? "标记为已完成" : "重新激活",
                    systemImage: prescription.isActive ? "checkmark.circle" : "arrow.clockwise"
                )
            }
            
            Divider()
            
            Button(role: .destructive, action: {
                showDeleteAlert = true
            }) {
                Label("删除处方", systemImage: "trash")
            }
        }
        .alert("删除处方", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                healthManager.deletePrescription(prescription)
            }
        } message: {
            Text("确定要删除「\(prescription.medicineName)」吗？此操作无法撤销。")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - 信息行组件
struct HealthInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6366F1"))
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
            
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}


