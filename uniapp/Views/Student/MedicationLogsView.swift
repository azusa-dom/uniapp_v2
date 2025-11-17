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
        VStack(spacing: 16) {
            // ✅ 日期选择器（现代化设计）
            datePicker
            
            // ✅ 统计概览
            statsOverview
            
            // 今日用药列表
            if !activePrescriptions.isEmpty {
                VStack(spacing: 12) {
                    ForEach(activePrescriptions) { prescription in
                        MedicationLogCard(prescription: prescription, selectedDate: selectedDate)
                            .environmentObject(healthManager)
                            .onTapGesture {
                                selectedPrescription = prescription
                            }
                    }
                }
            } else {
                emptyState
            }
        }
        .sheet(item: $selectedPrescription) { prescription in
            MedicationLogDetailView(prescription: prescription, selectedDate: selectedDate)
                .environmentObject(healthManager)
        }
    }
    
    private var datePicker: some View {
        HStack {
            Button(action: { changeDate(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "6366F1"))
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(formatDate(selectedDate))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                if Calendar.current.isDateInToday(selectedDate) {
                    Text("今天")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "6366F1"))
                }
            }
            
            Spacer()
            
            Button(action: { changeDate(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "6366F1"))
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private var statsOverview: some View {
        let completed = activePrescriptions.filter { prescription in
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: selectedDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return healthManager.medicationLogs.contains { log in
                log.prescriptionId == prescription.id &&
                log.takenDate >= startOfDay &&
                log.takenDate < endOfDay &&
                log.isTaken
            }
        }.count
        
        let pending = activePrescriptions.count - completed
        let completionRate = activePrescriptions.isEmpty ? "0%" : String(format: "%.0f%%", (Double(completed) / Double(activePrescriptions.count)) * 100)
        
        return HStack(spacing: 12) {
            StatCard(
                icon: "checkmark.circle.fill",
                title: "已完成",
                value: "\(completed)",
                color: Color(hex: "10B981")
            )
            
            StatCard(
                icon: "clock.fill",
                title: "待服用",
                value: "\(pending)",
                color: Color(hex: "F59E0B")
            )
            
            StatCard(
                icon: "percent",
                title: "完成率",
                value: completionRate,
                color: Color(hex: "6366F1")
            )
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "10B981").opacity(0.3))
                .padding(.top, 40)
            
            Text("今日无用药计划")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("请在处方记录中添加并启用提醒")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - 用药记录卡片（统一风格）
struct MedicationLogCard: View {
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
    
    var scheduledTime: Date {
        // 使用第一个提醒时间，如果没有则使用默认时间
        if let firstReminder = prescription.reminderTimes.first {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: firstReminder)
            return calendar.date(bySettingHour: components.hour ?? 8, minute: components.minute ?? 0, second: 0, of: selectedDate) ?? selectedDate
        }
        return selectedDate
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 时间轴
            VStack(spacing: 4) {
                Text(formatTime(scheduledTime))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(hasLoggedToday ? Color(hex: "10B981") : .primary)
                
                Circle()
                    .fill(hasLoggedToday ? Color(hex: "10B981") : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
            .frame(width: 60)
            
            // 内容
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(prescription.medicineName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if hasLoggedToday {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "10B981"))
                    }
                }
                
                Text(prescription.dosage)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                if hasLoggedToday, let log = getTodayLog() {
                    Text("已于 \(formatTime(log.takenDate)) 服用")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "10B981"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            
            // 打卡按钮
            if !hasLoggedToday {
                Button(action: {
                    healthManager.logMedication(
                        prescriptionId: prescription.id,
                        isTaken: true
                    )
                }) {
                    Text("打卡")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "6366F1"))
                        .cornerRadius(8)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    private func getTodayLog() -> MedicationLog? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return healthManager.medicationLogs.first { log in
            log.prescriptionId == prescription.id &&
            log.takenDate >= startOfDay &&
            log.takenDate < endOfDay &&
            log.isTaken
        }
    }
    
    private func formatTime(_ date: Date) -> String {
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

