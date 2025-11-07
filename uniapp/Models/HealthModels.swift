//
//  HealthModels.swift
//  uniapp
//
//  健康档案数据模型
//

import SwiftUI
import Foundation

// MARK: - 就诊记录
struct MedicalRecord: Identifiable {
    let id = UUID()
    let date: Date
    let type: String
    let doctor: String?
    let department: String
    let location: String
    let chiefComplaint: String?
    let diagnosis: String
    let prescription: [String]
    let advice: String
    let nextAppointment: Date?
    let checkResults: [String: String]?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - 处方记录
struct Prescription: Identifiable {
    let id = UUID()
    let medicationName: String
    let specification: String
    let dosage: String
    let prescriptionDate: Date
    let validUntil: Date
    let prescribedBy: String
    let remainingQuantity: Int
    let totalQuantity: Int
    let reminderEnabled: Bool
    let reminderTime: Date?
    let notes: String
    let status: PrescriptionStatus
    let completionDate: Date?
    
    enum PrescriptionStatus: String {
        case active = "使用中"
        case completed = "已完成"
        case expired = "已过期"
    }
    
    var progressPercentage: Double {
        Double(remainingQuantity) / Double(totalQuantity)
    }
}

// MARK: - 过敏史
struct AllergyRecord: Identifiable {
    let id = UUID()
    let allergen: String
    let allergyType: AllergyType
    let severity: AllergySeverity
    let reaction: String
    let recordedDate: Date
    let notes: String
    
    enum AllergyType: String {
        case medication = "药物过敏"
        case food = "食物过敏"
        case environment = "环境过敏"
        case other = "其他"
    }
    
    enum AllergySeverity: String {
        case mild = "轻度"
        case moderate = "中度"
        case severe = "重度"
    }
}

// MARK: - 预约记录
struct MedicalAppointment: Identifiable {
    let id = UUID()
    let appointmentNumber: String
    let doctor: Doctor
    let date: Date
    let timeSlot: String
    let location: String
    let appointmentType: AppointmentType
    let reason: [String]
    let description: String?
    let needsTranslation: Bool
    let attachments: [String]
    let emergencyContact: EmergencyContact
    let status: AppointmentStatus
    let remindersSent: [Date]
    
    enum AppointmentType: String {
        case followUp = "常规复诊"
        case newSymptom = "新症状咨询"
        case testReview = "检查结果解读"
        case urgent = "紧急预约"
    }
    
    enum AppointmentStatus: String {
        case scheduled = "已预约"
        case confirmed = "已确认"
        case completed = "已完成"
        case cancelled = "已取消"
        case noShow = "未到"
    }
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        return formatter.string(from: date) + " " + timeSlot
    }
}

// MARK: - 医生信息
struct Doctor: Identifiable {
    let id = UUID()
    let name: String
    let department: String
    let specialties: [String]
    let languages: [String]
    let consultationCount: Int
    let nextAvailableDate: Date?
    let photoURL: String?
    
    var supportsChineseDescription: String {
        languages.contains("中文") ? "🇨🇳 可提供中文服务" : ""
    }
}

// MARK: - 紧急联系人
struct EmergencyContact: Codable {
    let name: String
    let phone: String
    let relationship: String
}

// MARK: - 可用时间段
struct TimeSlot: Identifiable {
    let id = UUID()
    let time: String
    let isAvailable: Bool
    let isRecommended: Bool
}

// MARK: - 健康数据管理器
class HealthDataManager: ObservableObject {
    @Published var medicalRecords: [MedicalRecord] = []
    @Published var prescriptions: [Prescription] = []
    @Published var allergies: [AllergyRecord] = []
    @Published var appointments: [MedicalAppointment] = []
    @Published var doctors: [Doctor] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // 加载示例数据
        loadSampleMedicalRecords()
        loadSamplePrescriptions()
        loadSampleAllergies()
        loadSampleDoctors()
        loadSampleAppointments()
    }
    
    private func loadSampleMedicalRecords() {
        medicalRecords = [
            MedicalRecord(
                date: Date().addingTimeInterval(-86400 * 0),
                type: "强直性脊柱炎复查",
                doctor: "Dr. Sarah Johnson",
                department: "风湿免疫科",
                location: "Rheumatology Clinic, Room 2.15",
                chiefComplaint: "晨僵症状，腰背疼痛评估",
                diagnosis: "强直性脊柱炎病情稳定",
                prescription: ["阿达木单抗", "塞来昔布", "乌帕替尼"],
                advice: "继续规律用药，注意保暖，适度运动",
                nextAppointment: Date().addingTimeInterval(86400 * 92),
                checkResults: nil
            ),
            MedicalRecord(
                date: Date().addingTimeInterval(-86400 * 11),
                type: "心电图检查",
                doctor: nil,
                department: "心脏科检查室",
                location: "Cardiology Lab",
                chiefComplaint: nil,
                diagnosis: "窦性心律，心率72次/分，各项指标正常",
                prescription: [],
                advice: "无心脏异常，可继续使用生物制剂",
                nextAppointment: nil,
                checkResults: [
                    "心率": "72 bpm",
                    "节律": "窦性心律",
                    "PR间期": "正常",
                    "QRS波": "正常"
                ]
            ),
            MedicalRecord(
                date: Date().addingTimeInterval(-86400 * 17),
                type: "血常规检查",
                doctor: nil,
                department: "实验室检查",
                location: "Laboratory",
                chiefComplaint: nil,
                diagnosis: "炎症指标控制良好",
                prescription: [],
                advice: "继续目前治疗方案",
                nextAppointment: nil,
                checkResults: [
                    "白细胞": "6.8 x10^9/L（正常）",
                    "血红蛋白": "138g/L（正常）",
                    "血小板": "245 x10^9/L（正常）",
                    "ESR": "15mm/h（轻度升高）",
                    "CRP": "8mg/L（正常范围内）"
                ]
            )
        ]
    }
    
    private func loadSamplePrescriptions() {
        let now = Date()
        prescriptions = [
            Prescription(
                medicationName: "阿达木单抗注射液",
                specification: "40mg/0.8ml 预充式注射器",
                dosage: "每周一次，皮下注射",
                prescriptionDate: now,
                validUntil: now.addingTimeInterval(86400 * 92),
                prescribedBy: "Dr. Sarah Johnson",
                remainingQuantity: 10,
                totalQuantity: 12,
                reminderEnabled: true,
                reminderTime: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: now),
                notes: "注射前检查有无感染症状，注射后观察过敏反应",
                status: .active,
                completionDate: nil
            ),
            Prescription(
                medicationName: "塞来昔布胶囊",
                specification: "200mg",
                dosage: "每日一次，餐后服用",
                prescriptionDate: now,
                validUntil: now.addingTimeInterval(86400 * 92),
                prescribedBy: "Dr. Sarah Johnson",
                remainingQuantity: 60,
                totalQuantity: 90,
                reminderEnabled: true,
                reminderTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: now),
                notes: "如有胃部不适及时就医",
                status: .active,
                completionDate: nil
            ),
            Prescription(
                medicationName: "乌帕替尼片",
                specification: "15mg",
                dosage: "每日一粒，固定时间服用",
                prescriptionDate: now.addingTimeInterval(-86400 * 49),
                validUntil: now.addingTimeInterval(86400 * 134),
                prescribedBy: "Dr. James Smith",
                remainingQuantity: 120,
                totalQuantity: 180,
                reminderEnabled: true,
                reminderTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: now),
                notes: "定期监测肝功能",
                status: .active,
                completionDate: nil
            )
        ]
    }
    
    private func loadSampleAllergies() {
        allergies = [
            AllergyRecord(
                allergen: "无已知药物过敏",
                allergyType: .medication,
                severity: .mild,
                reaction: "无",
                recordedDate: Date().addingTimeInterval(-86400 * 63),
                notes: "入学体检记录"
            )
        ]
    }
    
    private func loadSampleDoctors() {
        let now = Date()
        doctors = [
            Doctor(
                name: "Dr. Sarah Johnson",
                department: "风湿免疫科",
                specialties: ["强直性脊柱炎", "类风湿关节炎", "系统性红斑狼疮"],
                languages: ["English"],
                consultationCount: 5,
                nextAvailableDate: now.addingTimeInterval(86400 * 7),
                photoURL: nil
            ),
            Doctor(
                name: "Dr. James Smith",
                department: "风湿免疫科",
                specialties: ["自身免疫性疾病", "关节炎"],
                languages: ["English"],
                consultationCount: 3,
                nextAvailableDate: now.addingTimeInterval(86400 * 10),
                photoURL: nil
            ),
            Doctor(
                name: "Dr. Emily Chen",
                department: "全科医生",
                specialties: ["全科医疗", "慢性病管理"],
                languages: ["English", "中文"],
                consultationCount: 0,
                nextAvailableDate: now.addingTimeInterval(86400 * 4),
                photoURL: nil
            )
        ]
    }
    
    private func loadSampleAppointments() {
        let now = Date()
        appointments = [
            MedicalAppointment(
                appointmentNumber: "UCL-20251115-143",
                doctor: doctors[0],
                date: now.addingTimeInterval(86400 * 7),
                timeSlot: "14:30-15:00",
                location: "Rheumatology Clinic, Room 2.15",
                appointmentType: .followUp,
                reason: ["定期复查"],
                description: "强直性脊柱炎常规复诊",
                needsTranslation: false,
                attachments: [],
                emergencyContact: EmergencyContact(name: "妈妈", phone: "+86 138 xxxx xxxx", relationship: "母亲"),
                status: .scheduled,
                remindersSent: []
            )
        ]
    }
}
