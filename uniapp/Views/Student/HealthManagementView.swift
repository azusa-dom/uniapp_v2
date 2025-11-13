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
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 标签栏
                    healthTabBar
                    
                    // 内容区域
                    TabView(selection: $selectedTab) {
                        PrescriptionsManagementView()
                            .environmentObject(healthManager)
                            .tag(HealthTab.prescriptions)
                        
                        AllergiesManagementView()
                            .environmentObject(healthManager)
                            .tag(HealthTab.allergies)
                        
                        MedicationLogsView()
                            .environmentObject(healthManager)
                            .tag(HealthTab.logs)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("健康管理")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var healthTabBar: some View {
        HStack(spacing: 0) {
            ForEach(HealthTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                        
                        Text(tab.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == tab ? Color(hex: "6366F1") : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color(.systemBackground).opacity(0.95))
        .overlay(
            Rectangle()
                .fill(Color(hex: "6366F1"))
                .frame(width: UIScreen.main.bounds.width / CGFloat(HealthTab.allCases.count), height: 3)
                .offset(x: tabIndicatorOffset),
            alignment: .bottom
        )
    }
    
    private var tabIndicatorOffset: CGFloat {
        let tabWidth = UIScreen.main.bounds.width / CGFloat(HealthTab.allCases.count)
        let index = CGFloat(HealthTab.allCases.firstIndex(of: selectedTab) ?? 0)
        return (index - 1) * tabWidth
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
        ZStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // 统计卡片
                    statsCards
                    
                    // 筛选切换
                    filterToggle
                    
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
                }
                .padding()
            }
            
            // 添加按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddPrescription = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "6366F1"))
                            .clipShape(Circle())
                            .shadow(color: Color(hex: "6366F1").opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
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
    
    private var statsCards: some View {
        HStack(spacing: 12) {
            HealthStatCard(
                icon: "pills.fill",
                title: "正在服用",
                value: "\(healthManager.activePrescriptions.count)",
                color: Color(hex: "6366F1")
            )
            
            HealthStatCard(
                icon: "checkmark.circle.fill",
                title: "已完成",
                value: "\(healthManager.inactivePrescriptions.count)",
                color: Color(hex: "10B981")
            )
            
            HealthStatCard(
                icon: "bell.fill",
                title: "今日提醒",
                value: "\(healthManager.activePrescriptions.filter { $0.reminderEnabled }.count)",
                color: Color(hex: "F59E0B")
            )
        }
    }
    
    private var filterToggle: some View {
        HStack {
            Button(action: { withAnimation { showActiveOnly = true } }) {
                Text("正在服用")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(showActiveOnly ? .white : .primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(showActiveOnly ? Color(hex: "6366F1") : Color.clear)
                    .cornerRadius(20)
            }
            
            Button(action: { withAnimation { showActiveOnly = false } }) {
                Text("历史记录")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(!showActiveOnly ? .white : .primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(!showActiveOnly ? Color(hex: "6366F1") : Color.clear)
                    .cornerRadius(20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(24)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "pills")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(showActiveOnly ? "暂无正在服用的处方" : "暂无历史处方记录")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("点击右下角 + 按钮添加处方")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - 统计卡片
struct HealthStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassCard()
    }
}

// MARK: - 处方卡片
struct HealthPrescriptionCard: View {
    @EnvironmentObject var healthManager: HealthManager
    let prescription: HealthPrescription
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(prescription.medicineName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(prescription.purpose)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if prescription.isActive {
                    Image(systemName: "circle.fill")
                        .font(.caption)
                        .foregroundColor(Color(hex: "10B981"))
                }
            }
            
            Divider()
            
            HStack(spacing: 20) {
                InfoPill(icon: "pills", text: prescription.dosage)
                InfoPill(icon: "clock", text: prescription.frequency)
                InfoPill(icon: "calendar", text: prescription.duration)
            }
            
            HStack {
                Label(prescription.prescribedBy, systemImage: "stethoscope")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatDate(prescription.prescribedDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if prescription.reminderEnabled {
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Text("已启用提醒")
                        .font(.caption)
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .glassCard()
        .contextMenu {
            Button(action: {
                healthManager.togglePrescriptionStatus(prescription)
            }) {
                Label(
                    prescription.isActive ? "标记为已完成" : "标记为进行中",
                    systemImage: prescription.isActive ? "checkmark.circle" : "arrow.clockwise"
                )
            }
            
            Button(role: .destructive, action: {
                healthManager.deletePrescription(prescription)
            }) {
                Label("删除", systemImage: "trash")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
