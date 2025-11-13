//
//  MedicationLogsView.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI

// MARK: - 用药打卡视图
struct MedicationLogsView: View {
    @EnvironmentObject var healthManager: HealthManager
    
    @State private var selectedDate = Date()
    @State private var selectedPrescription: HealthPrescription?
    
    var activePrescriptions: [HealthPrescription] {
        healthManager.activePrescriptions
    }
    
    var todayLogs: [MedicationLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return healthManager.medicationLogs.filter { log in
            log.takenDate >= startOfDay && log.takenDate < endOfDay
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // 日期选择器
                dateSelector
                
                // 今日待服药列表
                if !activePrescriptions.isEmpty {
                    todayMedicationsSection
                } else {
                    emptyState
                }
                
                // 今日打卡记录
                if !todayLogs.isEmpty {
                    todayLogsSection
                }
            }
            .padding()
        }
        .sheet(item: $selectedPrescription) { prescription in
            MedicationLogDetailView(prescription: prescription, selectedDate: selectedDate)
                .environmentObject(healthManager)
        }
    }
    
    private var dateSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择日期")
                .font(.headline)
            
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
        }
        .padding()
        .glassCard()
    }
    
    private var todayMedicationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日待服药")
                .font(.headline)
            
            ForEach(activePrescriptions) { prescription in
                MedicationCard(prescription: prescription, selectedDate: selectedDate)
                    .environmentObject(healthManager)
                    .onTapGesture {
                        selectedPrescription = prescription
                    }
            }
        }
    }
    
    private var todayLogsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日打卡记录")
                .font(.headline)
            
            ForEach(todayLogs.sorted { $0.takenDate > $1.takenDate }) { log in
                if let prescription = healthManager.prescriptions.first(where: { $0.id == log.prescriptionId }) {
                    LogCard(log: log, prescription: prescription)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "pills")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("暂无正在服用的处方")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("添加处方后即可进行用药打卡")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - 用药卡片
struct MedicationCard: View {
    @EnvironmentObject var healthManager: HealthManager
    let prescription: HealthPrescription
    let selectedDate: Date
    
    var hasLoggedToday: Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return healthManager.medicationLogs.contains { log in
            log.prescriptionId == prescription.id &&
            log.takenDate >= startOfDay &&
            log.takenDate < endOfDay &&
            log.isTaken
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 状态指示器
            ZStack {
                Circle()
                    .fill(hasLoggedToday ? Color(hex: "10B981").opacity(0.2) : Color(hex: "F59E0B").opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: hasLoggedToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(hasLoggedToday ? Color(hex: "10B981") : Color(hex: "F59E0B"))
            }
            
            // 药品信息
            VStack(alignment: .leading, spacing: 6) {
                Text(prescription.medicineName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(prescription.dosage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(prescription.frequency)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 打卡按钮
            Button(action: {
                healthManager.logMedication(
                    prescriptionId: prescription.id,
                    isTaken: !hasLoggedToday
                )
            }) {
                Text(hasLoggedToday ? "已打卡" : "打卡")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(hasLoggedToday ? Color(hex: "10B981") : Color(hex: "6366F1"))
                    .cornerRadius(8)
            }
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 打卡记录卡片
struct LogCard: View {
    let log: MedicationLog
    let prescription: HealthPrescription
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: log.isTaken ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(log.isTaken ? Color(hex: "10B981") : Color(hex: "EF4444"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(prescription.medicineName)
                    .font(.headline)
                
                Text(formatDateTime(log.takenDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !log.notes.isEmpty {
                    Text(log.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(log.isTaken ? "已服用" : "未服用")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(log.isTaken ? Color(hex: "10B981") : Color(hex: "EF4444"))
        }
        .padding()
        .glassCard()
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 用药打卡详情视图
struct MedicationLogDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var healthManager: HealthManager
    
    let prescription: HealthPrescription
    let selectedDate: Date
    
    @State private var isTaken = false
    @State private var notes = ""
    
    var existingLog: MedicationLog? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return healthManager.medicationLogs.first { log in
            log.prescriptionId == prescription.id &&
            log.takenDate >= startOfDay &&
            log.takenDate < endOfDay
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("药品信息")) {
                    HStack {
                        Text("药品名称")
                        Spacer()
                        Text(prescription.medicineName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("剂量")
                        Spacer()
                        Text(prescription.dosage)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("频率")
                        Spacer()
                        Text(prescription.frequency)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("打卡信息")) {
                    Toggle("已服用", isOn: $isTaken)
                    
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Button(action: saveLog) {
                    Text(existingLog != nil ? "更新记录" : "保存记录")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color(hex: "6366F1"))
            }
            .navigationTitle("用药打卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let log = existingLog {
                    isTaken = log.isTaken
                    notes = log.notes
                }
            }
        }
    }
    
    private func saveLog() {
        healthManager.logMedication(
            prescriptionId: prescription.id,
            isTaken: isTaken,
            notes: notes
        )
        dismiss()
    }
}

