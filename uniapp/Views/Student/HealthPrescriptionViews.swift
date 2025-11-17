//
//  HealthPrescriptionViews.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI

// MARK: - 添加处方视图
struct AddPrescriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var healthManager: HealthManager
    
    @State private var medicineName = ""
    @State private var dosage = ""
    @State private var frequency = ""
    @State private var duration = ""
    @State private var prescribedBy = ""
    @State private var prescribedDate = Date()
    @State private var purpose = ""
    @State private var notes = ""
    @State private var reminderEnabled = false
    @State private var reminderTimes: [Date] = []
    
    let frequencyOptions = ["每日1次", "每日2次", "每日3次", "每日4次", "按需服用"]
    let durationOptions = ["3天", "5天", "7天", "10天", "14天", "30天"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("药品名称", text: $medicineName)
                    TextField("剂量（如：500mg）", text: $dosage)
                    
                    Picker("服用频率", selection: $frequency) {
                        ForEach(frequencyOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    Picker("疗程", selection: $duration) {
                        ForEach(durationOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("处方信息")) {
                    TextField("开方医生", text: $prescribedBy)
                    DatePicker("开方日期", selection: $prescribedDate, displayedComponents: .date)
                    TextField("用途/病症", text: $purpose)
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section(header: Text("用药提醒")) {
                    Toggle("启用提醒", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        ForEach(reminderTimes.indices, id: \.self) { index in
                            DatePicker("提醒时间 \(index + 1)", selection: $reminderTimes[index], displayedComponents: .hourAndMinute)
                        }
                        
                        Button(action: {
                            reminderTimes.append(Date())
                        }) {
                            Label("添加提醒时间", systemImage: "plus.circle")
                        }
                    }
                }
                
                Button(action: savePrescription) {
                    Text("保存")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color(hex: "6366F1"))
                .disabled(medicineName.isEmpty || dosage.isEmpty)
            }
            .navigationTitle("添加处方")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func savePrescription() {
        let prescription = HealthPrescription(
            medicineName: medicineName,
            dosage: dosage,
            frequency: frequency.isEmpty ? frequencyOptions[0] : frequency,
            duration: duration.isEmpty ? durationOptions[0] : duration,
            prescribedBy: prescribedBy,
            prescribedDate: prescribedDate,
            purpose: purpose,
            notes: notes,
            isActive: true,
            reminderEnabled: reminderEnabled,
            reminderTimes: reminderTimes
        )
        
        healthManager.addPrescription(prescription)
        dismiss()
    }
}

// MARK: - 处方详情视图
struct HealthPrescriptionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var healthManager: HealthManager
    
    let prescription: HealthPrescription
    @State private var showingEditView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 药品名称和状态
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(prescription.medicineName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(prescription.isActive ? "进行中" : "已完成")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(prescription.isActive ? Color(hex: "10B981") : Color.secondary)
                                .cornerRadius(12)
                        }
                        
                        Text(prescription.purpose)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .glassCard()
                    
                    // 用药详情
                    VStack(alignment: .leading, spacing: 16) {
                        Text("用药详情")
                            .font(.headline)
                        
                        DetailRow(icon: "pills.fill", label: "剂量", value: prescription.dosage)
                        DetailRow(icon: "clock.fill", label: "频率", value: prescription.frequency)
                        DetailRow(icon: "calendar", label: "疗程", value: prescription.duration)
                        DetailRow(icon: "stethoscope", label: "开方医生", value: prescription.prescribedBy)
                        DetailRow(icon: "calendar.badge.clock", label: "开方日期", value: formatDate(prescription.prescribedDate))
                    }
                    .padding()
                    .glassCard()
                    
                    // 备注
                    if !prescription.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("备注")
                                .font(.headline)
                            
                            Text(prescription.notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .glassCard()
                    }
                    
                    // 用药提醒
                    if prescription.reminderEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(Color(hex: "F59E0B"))
                                Text("用药提醒")
                                    .font(.headline)
                            }
                            
                            ForEach(prescription.reminderTimes, id: \.self) { time in
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                    Text(formatTime(time))
                                        .font(.body)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .glassCard()
                    }
                    
                    // 用药记录
                    MedicationHistorySection(prescription: prescription)
                        .environmentObject(healthManager)
                }
                .padding()
            }
            .background(DesignSystem.backgroundGradient.ignoresSafeArea())
            .navigationTitle("处方详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEditView = true }) {
                            Label("编辑", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            healthManager.togglePrescriptionStatus(prescription)
                        }) {
                            Label(
                                prescription.isActive ? "标记为已完成" : "标记为进行中",
                                systemImage: prescription.isActive ? "checkmark.circle" : "arrow.clockwise"
                            )
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            healthManager.deletePrescription(prescription)
                            dismiss()
                        }) {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditPrescriptionView(prescription: prescription)
                .environmentObject(healthManager)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "6366F1"))
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct MedicationHistorySection: View {
    @EnvironmentObject var healthManager: HealthManager
    let prescription: HealthPrescription
    
    var recentLogs: [MedicationLog] {
        healthManager.getMedicationLogs(for: prescription, days: 7)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近7天用药记录")
                .font(.headline)
            
            if recentLogs.isEmpty {
                Text("暂无用药记录")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(recentLogs) { log in
                    HStack {
                        Image(systemName: log.isTaken ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(log.isTaken ? Color(hex: "10B981") : Color(hex: "EF4444"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatDateTime(log.takenDate))
                                .font(.subheadline)
                            
                            if !log.notes.isEmpty {
                                Text(log.notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Text(log.isTaken ? "已服用" : "未服用")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Button(action: {
                healthManager.logMedication(prescriptionId: prescription.id, isTaken: true)
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("记录今日已服用")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "10B981"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .glassCard()
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 编辑处方视图
struct EditPrescriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var healthManager: HealthManager
    
    let prescription: HealthPrescription
    
    @State private var medicineName: String
    @State private var dosage: String
    @State private var frequency: String
    @State private var duration: String
    @State private var prescribedBy: String
    @State private var prescribedDate: Date
    @State private var purpose: String
    @State private var notes: String
    @State private var reminderEnabled: Bool
    @State private var reminderTimes: [Date]
    
    let frequencyOptions = ["每日1次", "每日2次", "每日3次", "每日4次", "按需服用"]
    let durationOptions = ["3天", "5天", "7天", "10天", "14天", "30天"]
    
    init(prescription: HealthPrescription) {
        self.prescription = prescription
        _medicineName = State(initialValue: prescription.medicineName)
        _dosage = State(initialValue: prescription.dosage)
        _frequency = State(initialValue: prescription.frequency)
        _duration = State(initialValue: prescription.duration)
        _prescribedBy = State(initialValue: prescription.prescribedBy)
        _prescribedDate = State(initialValue: prescription.prescribedDate)
        _purpose = State(initialValue: prescription.purpose)
        _notes = State(initialValue: prescription.notes)
        _reminderEnabled = State(initialValue: prescription.reminderEnabled)
        _reminderTimes = State(initialValue: prescription.reminderTimes)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("药品名称", text: $medicineName)
                    TextField("剂量", text: $dosage)
                    
                    Picker("服用频率", selection: $frequency) {
                        ForEach(frequencyOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    Picker("疗程", selection: $duration) {
                        ForEach(durationOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("处方信息")) {
                    TextField("开方医生", text: $prescribedBy)
                    DatePicker("开方日期", selection: $prescribedDate, displayedComponents: .date)
                    TextField("用途/病症", text: $purpose)
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section(header: Text("用药提醒")) {
                    Toggle("启用提醒", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        ForEach(reminderTimes.indices, id: \.self) { index in
                            DatePicker("提醒时间 \(index + 1)", selection: $reminderTimes[index], displayedComponents: .hourAndMinute)
                        }
                        
                        Button(action: {
                            reminderTimes.append(Date())
                        }) {
                            Label("添加提醒时间", systemImage: "plus.circle")
                        }
                    }
                }
                
                Button(action: saveChanges) {
                    Text("保存修改")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color(hex: "6366F1"))
            }
            .navigationTitle("编辑处方")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        let updatedPrescription = HealthPrescription(
            id: prescription.id,
            medicineName: medicineName,
            dosage: dosage,
            frequency: frequency,
            duration: duration,
            prescribedBy: prescribedBy,
            prescribedDate: prescribedDate,
            purpose: purpose,
            notes: notes,
            isActive: prescription.isActive,
            reminderEnabled: reminderEnabled,
            reminderTimes: reminderTimes
        )
        
        healthManager.updatePrescription(updatedPrescription)
        dismiss()
    }
}
