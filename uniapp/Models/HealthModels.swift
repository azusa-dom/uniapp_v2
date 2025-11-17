//
//  健康数据管理.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import Foundation
import Combine

// MARK: - 预约时间段
struct AppointmentTimeSlot: Identifiable {
    let id = UUID()
    let time: String
    let isAvailable: Bool
    let isRecommended: Bool
}

// MARK: - 医生
struct Doctor: Identifiable {
    let id = UUID()
    let name: String
    let title: String
    let department: String
    let specialization: String
    let experience: Int
    let available: Bool
}

// MARK: - 科室
struct Department: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    
    static let allDepartments = [
        Department(name: "全科", icon: "heart.text.square", color: "6366F1"),
        Department(name: "骨科", icon: "figure.walk", color: "10B981"),
        Department(name: "内科", icon: "cross.case", color: "F59E0B"),
        Department(name: "皮肤科", icon: "hand.raised", color: "EC4899"),
        Department(name: "眼科", icon: "eye", color: "8B5CF6")
    ]
}

// MARK: - 紧急联系人
struct EmergencyContact {
    let name: String
    let phone: String
    let relationship: String
}

// MARK: - 医疗预约
struct MedicalAppointment {
    let id = UUID()
    let appointmentNumber: String
    let doctor: Doctor
    let date: Date
    let timeSlot: String
    let location: String
    let appointmentType: AppointmentType
    let reason: [String]
    let description: String
    let needsTranslation: Bool
    let attachments: [String]
    let emergencyContact: EmergencyContact
    var status: AppointmentStatus
    var remindersSent: [String]
    
    enum AppointmentType { case newSymptom, followUp }
    enum AppointmentStatus { case scheduled, completed, cancelled }
}

// MARK: - 医疗记录
struct MedicalRecord: Identifiable {
    let id = UUID()
    let date: Date
    let type: String // e.g., "全科门诊", "专科复诊"
    let location: String
    let department: String
    let doctor: String?
    let chiefComplaint: String? // 主诉
    let diagnosis: String // 诊断
    let prescription: [String] // 处方药品
    let checkResults: [String: String]? // 检查结果 e.g., ["血常规": "正常"]
    let advice: String // 医嘱
    let nextAppointment: Date? // 下次复诊
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - 处方
struct Prescription: Identifiable {
    let id = UUID()
    let medicationName: String // 药品名称
    let specification: String // 规格 e.g., "10mg / 片"
    let dosage: String // 用法用量 e.g., "每日1次，每次1片，饭后"
    let totalQuantity: Int // 总量
    var remainingQuantity: Int // 剩余量
    let prescribedBy: String // 开具医生
    let prescriptionDate: Date
    let validUntil: Date
    var status: PrescriptionStatus
    let reminderEnabled: Bool
    let reminderTime: Date?
    let notes: String // 注意事项
    
    enum PrescriptionStatus: String {
        case active = "使用中"
        case completed = "已完成"
        case expired = "已过期"
    }
    
    var progressPercentage: Double {
        return Double(remainingQuantity) / Double(totalQuantity)
    }
}

// MARK: - 数据管理器 (单例)
class HealthDataManager: ObservableObject {
    static let shared = HealthDataManager()
    
    @Published var doctors: [Doctor]
    @Published var medicalRecords: [MedicalRecord]
    @Published var prescriptions: [Prescription]
    @Published var appointments: [MedicalAppointment]
    @Published var allergies: [String]
    
    init() {
        // 模拟数据
        let drSmith = Doctor(name: "Dr. Smith", title: "GP", department: "全科", specialization: "全科医学", experience: 10, available: true)
        let drJones = Doctor(name: "Dr. Jones", title: "专家", department: "骨科", specialization: "运动损伤", experience: 15, available: true)
        
        self.doctors = [drSmith, drJones]
        
        self.medicalRecords = [
            .init(date: Date().addingTimeInterval(-86400 * 10), type: "全科门诊", location: "UCL Health Centre", department: "全科", doctor: "Dr. Smith", chiefComplaint: "咳嗽，喉咙痛", diagnosis: "上呼吸道感染", prescription: ["布洛芬 200mg", "止咳糖浆"], checkResults: nil, advice: "多喝水，休息。如发烧不退请复诊。", nextAppointment: nil),
            .init(date: Date().addingTimeInterval(-86400 * 30), type: "专科复诊", location: "UCLH", department: "骨科", doctor: "Dr. Jones", chiefComplaint: "膝盖疼痛复查", diagnosis: "膝盖扭伤恢复中", prescription: ["物理治疗"], checkResults: ["X光": "未见骨折"], advice: "继续康复训练", nextAppointment: Date().addingTimeInterval(86400 * 60))
        ]
        
        self.prescriptions = [
            .init(medicationName: "布洛芬 200mg", specification: "200mg / 片", dosage: "需要时服用，每日不超过3次", totalQuantity: 20, remainingQuantity: 15, prescribedBy: "Dr. Smith", prescriptionDate: Date().addingTimeInterval(-86400 * 10), validUntil: Date().addingTimeInterval(86400 * 20), status: .active, reminderEnabled: false, reminderTime: nil, notes: "可能引起肠胃不适，饭后服用。"),
            .init(medicationName: "氯雷他定", specification: "10mg / 片", dosage: "每日1次，每次1片", totalQuantity: 30, remainingQuantity: 0, prescribedBy: "Dr. Smith", prescriptionDate: Date().addingTimeInterval(-86400 * 60), validUntil: Date().addingTimeInterval(-86400 * 30), status: .completed, reminderEnabled: false, reminderTime: nil, notes: "用于季节性过敏。")
        ]
        
        self.appointments = [
            .init(appointmentNumber: "UCL-12345", doctor: drSmith, date: Date().addingTimeInterval(86400 * 3), timeSlot: "10:30", location: "全科诊室", appointmentType: .followUp, reason: ["复诊"], description: "咳嗽复诊", needsTranslation: false, attachments: [], emergencyContact: .init(name: "Zoya Huo", phone: "12345", relationship: "本人"), status: .scheduled, remindersSent: [])
        ]
        
        self.allergies = ["青霉素", "花粉"]
    }
}
