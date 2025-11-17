//
//  PrescriptionsView.swift
//  uniapp
//
//  处方记录视图
//

import SwiftUI

struct PrescriptionsView: View {
    @EnvironmentObject var loc: LocalizationService
    @StateObject private var healthData = HealthDataManager()
    @State private var selectedFilter: PrescriptionFilter = .active
    @State private var selectedPrescription: Prescription? = nil
    
    enum PrescriptionFilter: String, CaseIterable {
        case active = "使用中"
        case completed = "已完成"
        case all = "全部"
        
        var id: String { rawValue }
    }
    
    var filteredPrescriptions: [Prescription] {
        switch selectedFilter {
        case .active:
            return healthData.prescriptions.filter { $0.status == .active }
        case .completed:
            return healthData.prescriptions.filter { $0.status == .completed }
        case .all:
            return healthData.prescriptions
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "F8FAFC"),
                        Color(hex: "EEF2FF"),
                        Color(hex: "E0E7FF").opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 筛选器
                    filterBar
                    
                    // 处方列表
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(filteredPrescriptions) { prescription in
                                PrescriptionCard(prescription: prescription)
                                    .onTapGesture {
                                        selectedPrescription = prescription
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("处方记录")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedPrescription) { prescription in
                PrescriptionDetailView(prescription: prescription)
                    .environmentObject(loc)
            }
        }
    }
    
    private var filterBar: some View {
        Picker("筛选", selection: $selectedFilter) {
            ForEach(PrescriptionFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

// MARK: - 处方卡片
struct PrescriptionCard: View {
    let prescription: Prescription
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 药品名称和状态
            HStack {
                Text(prescription.medicationName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(prescription.status.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor)
                    .clipShape(Capsule())
            }
            
            // 规格和用法
            VStack(alignment: .leading, spacing: 6) {
                PrescriptionInfoRow(icon: "info.circle", text: prescription.specification, color: "6366F1")
                PrescriptionInfoRow(icon: "clock", text: prescription.dosage, color: "F59E0B")
            }
            
            // 剩余数量进度条
            if prescription.status == .active {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("剩余")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(prescription.remainingQuantity)/\(prescription.totalQuantity)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                    
                    ProgressView(value: prescription.progressPercentage)
                        .tint(progressColor)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
            }
            
            // 用药提醒
            if prescription.reminderEnabled, let time = prescription.reminderTime {
                HStack(spacing: 6) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "10B981"))
                    
                    Text("提醒: \(formatTime(time))")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            // 医生和有效期
            HStack {
                Text(prescription.prescribedBy)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("有效至 \(formatDate(prescription.validUntil))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var statusColor: Color {
        switch prescription.status {
        case .active:
            return Color(hex: "10B981")
        case .completed:
            return Color(hex: "6B7280")
        case .expired:
            return Color(hex: "EF4444")
        }
    }
    
    private var progressColor: Color {
        if prescription.progressPercentage > 0.5 {
            return Color(hex: "10B981")
        } else if prescription.progressPercentage > 0.2 {
            return Color(hex: "F59E0B")
        } else {
            return Color(hex: "EF4444")
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - 处方信息行组件
struct PrescriptionInfoRow: View {
    let icon: String
    let text: String
    let color: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: color))
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 处方详情
struct PrescriptionDetailView: View {
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    let prescription: Prescription
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "F8FAFC"),
                        Color(hex: "EEF2FF"),
                        Color(hex: "E0E7FF").opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // 药品信息卡片
                        medicationInfoCard
                        
                        // 用法用量
                        dosageCard
                        
                        // 剩余数量
                        if prescription.status == .active {
                            remainingCard
                        }
                        
                        // 用药提醒
                        if prescription.reminderEnabled {
                            reminderCard
                        }
                        
                        // 注意事项
                        if !prescription.notes.isEmpty {
                            notesCard
                        }
                        
                        // 处方信息
                        prescriptionInfoCard
                    }
                    .padding()
                }
            }
            .navigationTitle(prescription.medicationName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var medicationInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pills.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "EF4444"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(prescription.medicationName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(prescription.specification)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(prescription.status.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        prescription.status == .active ? Color(hex: "10B981") : Color(hex: "6B7280")
                    )
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var dosageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(Color(hex: "6366F1"))
                Text("用法用量")
                    .font(.system(size: 16, weight: .bold))
            }
            
            Text(prescription.dosage)
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var remainingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color(hex: "10B981"))
                Text("剩余数量")
                    .font(.system(size: 16, weight: .bold))
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text("\(prescription.remainingQuantity)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("/ \(prescription.totalQuantity)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: prescription.progressPercentage)
                .tint(Color(hex: "6366F1"))
                .scaleEffect(x: 1, y: 3, anchor: .center)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(Color(hex: "F59E0B"))
                Text("用药提醒")
                    .font(.system(size: 16, weight: .bold))
            }
            
            if let time = prescription.reminderTime {
                HStack {
                    Text("每日")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(time))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "10B981"))
                        .font(.system(size: 24))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(hex: "EF4444"))
                Text("注意事项")
                    .font(.system(size: 16, weight: .bold))
            }
            
            Text(prescription.notes)
                .font(.system(size: 14))
                .foregroundColor(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var prescriptionInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(Color(hex: "6366F1"))
                Text("处方信息")
                    .font(.system(size: 16, weight: .bold))
            }
            
            VStack(spacing: 10) {
                PrescriptionDetailRow(label: "开具医生", value: prescription.prescribedBy)
                Divider()
                PrescriptionDetailRow(label: "处方日期", value: formatDate(prescription.prescriptionDate))
                Divider()
                PrescriptionDetailRow(label: "有效期至", value: formatDate(prescription.validUntil))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - 信息详情行
struct PrescriptionDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.primary)
        }
    }
}

struct PrescriptionsView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionsView()
            .environmentObject(LocalizationService())
    }
}
