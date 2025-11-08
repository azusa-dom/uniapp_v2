//
//  MedicalRecordsView.swift
//  uniapp
//
//  就诊历史视图
//

import SwiftUI

struct MedicalRecordsView: View {
    @EnvironmentObject var loc: LocalizationService
    @StateObject private var healthData = HealthDataManager()
    @State private var selectedFilter: RecordFilter = .all
    @State private var selectedRecord: MedicalRecord? = nil
    
    enum RecordFilter: String, CaseIterable {
        case all = "全部"
        case thisSemester = "本学期"
        case lastSemester = "上学期"
        
        var id: String { rawValue }
    }
    
    var filteredRecords: [MedicalRecord] {
        healthData.medicalRecords.sorted { $0.date > $1.date }
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
                    
                    // 记录列表
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(filteredRecords) { record in
                                MedicalRecordCard(record: record)
                                    .onTapGesture {
                                        selectedRecord = record
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("就诊历史")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .sheet(item: $selectedRecord) { record in
                MedicalRecordDetailView(record: record)
                    .environmentObject(loc)
            }
        }
    }
    
    private var filterBar: some View {
        Picker("筛选", selection: $selectedFilter) {
            ForEach(RecordFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

// MARK: - 就诊记录卡片
struct MedicalRecordCard: View {
    let record: MedicalRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 日期和类型
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text(record.formattedDate)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(record.type)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "6366F1"))
                    .clipShape(Capsule())
            }
            
            // 医生和科室
            if let doctor = record.doctor {
                HStack(spacing: 8) {
                    Image(systemName: "stethoscope")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(doctor)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("·")
                        .foregroundColor(.secondary)
                    
                    Text(record.department)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "building.2")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(record.department)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            // 诊断
            if !record.diagnosis.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "10B981"))
                    
                    Text(record.diagnosis)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
            
            // 查看详情提示
            HStack {
                Spacer()
                Text("查看详情")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6366F1"))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6366F1"))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 就诊记录详情
struct MedicalRecordDetailView: View {
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    let record: MedicalRecord
    
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
                        // 基本信息
                        infoSection
                        
                        // 主诉
                        if let complaint = record.chiefComplaint, !complaint.isEmpty {
                            DetailCard(title: "主诉", icon: "exclamationmark.bubble", content: complaint)
                        }
                        
                        // 诊断
                        DetailCard(title: "诊断", icon: "checkmark.seal.fill", content: record.diagnosis)
                        
                        // 处方
                        if !record.prescription.isEmpty {
                            prescriptionSection
                        }
                        
                        // 检查结果
                        if let results = record.checkResults, !results.isEmpty {
                            checkResultsSection(results: results)
                        }
                        
                        // 医嘱
                        if !record.advice.isEmpty {
                            DetailCard(title: "医嘱", icon: "text.bubble.fill", content: record.advice)
                        }
                        
                        // 下次复诊
                        if let nextDate = record.nextAppointment {
                            nextAppointmentSection(date: nextDate)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("就诊详情")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Color(hex: "6366F1"))
                Text(record.formattedDate)
                    .font(.system(size: 16, weight: .semibold))
            }
            
            HStack {
                Image(systemName: "building.2")
                    .foregroundColor(Color(hex: "6366F1"))
                Text(record.location)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            if let doctor = record.doctor {
                HStack {
                    Image(systemName: "stethoscope")
                        .foregroundColor(Color(hex: "6366F1"))
                    Text(doctor)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("·")
                        .foregroundColor(.secondary)
                    Text(record.department)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var prescriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pills.fill")
                    .foregroundColor(Color(hex: "EF4444"))
                Text("处方")
                    .font(.system(size: 16, weight: .bold))
            }
            
            ForEach(record.prescription, id: \.self) { medication in
                HStack {
                    Circle()
                        .fill(Color(hex: "EF4444"))
                        .frame(width: 6, height: 6)
                    Text(medication)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func checkResultsSection(results: [String: String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .foregroundColor(Color(hex: "10B981"))
                Text("检查结果")
                    .font(.system(size: 16, weight: .bold))
            }
            
            ForEach(Array(results.keys.sorted()), id: \.self) { key in
                if let value = results[key] {
                    HStack {
                        Text(key)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        Spacer()
                        Text(value)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    if key != results.keys.sorted().last {
                        Divider()
                    }
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
    
    private func nextAppointmentSection(date: Date) -> some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(Color(hex: "F59E0B"))
                Text("下次复诊")
                    .font(.system(size: 16, weight: .bold))
            }
            
            Text(formatter.string(from: date))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "F59E0B"))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 详情卡片组件
struct DetailCard: View {
    let title: String
    let icon: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "6366F1"))
                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            
            Text(content)
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
}

struct MedicalRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        MedicalRecordsView()
            .environmentObject(LocalizationService())
    }
}
