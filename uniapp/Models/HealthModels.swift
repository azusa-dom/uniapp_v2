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

// MARK: - 每日健康数据
struct DailyHealthData: Identifiable {
    let id = UUID()
    let subjectId: String
    let day: Int
    let sleepHours: Double
    let deepSleepHours: Double
    let nightAwakenings: Int
    let stepsPerDay: Int
    let sittingHoursPerDay: Double
    let stressScore: Double
    let allergyAttackToday: Int
    let visitToday: Int
    
    var date: Date {
        let calendar = Calendar.current
        let baseDate = Date().addingTimeInterval(-Double(30 - day) * 86400)
        return calendar.startOfDay(for: baseDate)
    }
    
    var sleepQuality: String {
        if sleepHours >= 7.0 && nightAwakenings <= 2 {
            return "优秀"
        } else if sleepHours >= 6.0 && nightAwakenings <= 3 {
            return "良好"
        } else if sleepHours >= 5.0 {
            return "一般"
        } else {
            return "较差"
        }
    }
    
    var activityLevel: String {
        if stepsPerDay >= 8000 {
            return "活跃"
        } else if stepsPerDay >= 5000 {
            return "适中"
        } else {
            return "偏少"
        }
    }
    
    var stressLevel: String {
        if stressScore < 5.0 {
            return "低"
        } else if stressScore < 7.0 {
            return "中等"
        } else {
            return "较高"
        }
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
    let title: String  // 添加职称
    let department: String
    let specialization: String  // 添加专长
    let experience: Int  // 添加经验年限
    let available: Bool  // 添加可预约状态
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
    static let shared = HealthDataManager()  // 添加单例
    
    @Published var medicalRecords: [MedicalRecord] = []
    @Published var prescriptions: [Prescription] = []
    @Published var allergies: [AllergyRecord] = []
    @Published var appointments: [MedicalAppointment] = []
    @Published var doctors: [Doctor] = []
    @Published var dailyHealthData: [DailyHealthData] = []
    
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
        loadDailyHealthData()
    }
    
    private func loadDailyHealthData() {
        dailyHealthData = [
            DailyHealthData(subjectId: "001", day: 1, sleepHours: 6.9, deepSleepHours: 1.7, nightAwakenings: 3, stepsPerDay: 5200, sittingHoursPerDay: 9.4, stressScore: 6.6, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 2, sleepHours: 6.3, deepSleepHours: 1.8, nightAwakenings: 3, stepsPerDay: 4900, sittingHoursPerDay: 9.3, stressScore: 6.7, allergyAttackToday: 1, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 3, sleepHours: 6.5, deepSleepHours: 1.5, nightAwakenings: 2, stepsPerDay: 5300, sittingHoursPerDay: 9.8, stressScore: 5.9, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 4, sleepHours: 6.8, deepSleepHours: 1.6, nightAwakenings: 3, stepsPerDay: 4700, sittingHoursPerDay: 9.0, stressScore: 6.9, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 5, sleepHours: 6.3, deepSleepHours: 1.5, nightAwakenings: 2, stepsPerDay: 5200, sittingHoursPerDay: 9.9, stressScore: 6.4, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 6, sleepHours: 6.4, deepSleepHours: 2.0, nightAwakenings: 3, stepsPerDay: 5200, sittingHoursPerDay: 10.0, stressScore: 6.3, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 7, sleepHours: 6.6, deepSleepHours: 1.7, nightAwakenings: 3, stepsPerDay: 5300, sittingHoursPerDay: 9.0, stressScore: 6.4, allergyAttackToday: 1, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 8, sleepHours: 6.9, deepSleepHours: 2.0, nightAwakenings: 3, stepsPerDay: 5100, sittingHoursPerDay: 9.8, stressScore: 6.6, allergyAttackToday: 1, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 9, sleepHours: 6.7, deepSleepHours: 1.7, nightAwakenings: 3, stepsPerDay: 4800, sittingHoursPerDay: 9.0, stressScore: 6.5, allergyAttackToday: 1, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 10, sleepHours: 6.7, deepSleepHours: 1.6, nightAwakenings: 3, stepsPerDay: 5000, sittingHoursPerDay: 9.1, stressScore: 6.0, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 11, sleepHours: 6.5, deepSleepHours: 2.0, nightAwakenings: 4, stepsPerDay: 5100, sittingHoursPerDay: 9.3, stressScore: 6.9, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 12, sleepHours: 6.6, deepSleepHours: 1.9, nightAwakenings: 2, stepsPerDay: 5000, sittingHoursPerDay: 9.2, stressScore: 6.2, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 13, sleepHours: 6.8, deepSleepHours: 1.8, nightAwakenings: 3, stepsPerDay: 5300, sittingHoursPerDay: 9.0, stressScore: 5.8, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 14, sleepHours: 6.4, deepSleepHours: 1.6, nightAwakenings: 2, stepsPerDay: 5300, sittingHoursPerDay: 8.8, stressScore: 6.0, allergyAttackToday: 1, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 15, sleepHours: 6.6, deepSleepHours: 1.8, nightAwakenings: 4, stepsPerDay: 5000, sittingHoursPerDay: 9.5, stressScore: 6.5, allergyAttackToday: 2, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 16, sleepHours: 6.3, deepSleepHours: 2.0, nightAwakenings: 3, stepsPerDay: 5400, sittingHoursPerDay: 8.7, stressScore: 7.2, allergyAttackToday: 2, visitToday: 1),
            DailyHealthData(subjectId: "001", day: 17, sleepHours: 6.3, deepSleepHours: 1.7, nightAwakenings: 3, stepsPerDay: 5300, sittingHoursPerDay: 9.9, stressScore: 6.8, allergyAttackToday: 1, visitToday: 1),
            DailyHealthData(subjectId: "001", day: 18, sleepHours: 6.9, deepSleepHours: 1.8, nightAwakenings: 3, stepsPerDay: 5400, sittingHoursPerDay: 10.2, stressScore: 6.3, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 19, sleepHours: 6.7, deepSleepHours: 1.9, nightAwakenings: 2, stepsPerDay: 5100, sittingHoursPerDay: 9.2, stressScore: 6.3, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 20, sleepHours: 6.6, deepSleepHours: 1.7, nightAwakenings: 2, stepsPerDay: 5300, sittingHoursPerDay: 9.5, stressScore: 6.0, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 21, sleepHours: 6.5, deepSleepHours: 1.8, nightAwakenings: 4, stepsPerDay: 5100, sittingHoursPerDay: 9.0, stressScore: 6.4, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 22, sleepHours: 6.3, deepSleepHours: 2.0, nightAwakenings: 3, stepsPerDay: 5200, sittingHoursPerDay: 9.5, stressScore: 6.6, allergyAttackToday: 1, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 23, sleepHours: 6.8, deepSleepHours: 1.6, nightAwakenings: 2, stepsPerDay: 4800, sittingHoursPerDay: 8.9, stressScore: 6.9, allergyAttackToday: 2, visitToday: 1),
            DailyHealthData(subjectId: "001", day: 24, sleepHours: 6.4, deepSleepHours: 1.7, nightAwakenings: 4, stepsPerDay: 5300, sittingHoursPerDay: 9.9, stressScore: 6.7, allergyAttackToday: 1, visitToday: 1),
            DailyHealthData(subjectId: "001", day: 25, sleepHours: 6.9, deepSleepHours: 1.5, nightAwakenings: 3, stepsPerDay: 5300, sittingHoursPerDay: 9.6, stressScore: 6.1, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 26, sleepHours: 6.3, deepSleepHours: 1.9, nightAwakenings: 3, stepsPerDay: 4900, sittingHoursPerDay: 9.9, stressScore: 6.5, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 27, sleepHours: 6.9, deepSleepHours: 1.8, nightAwakenings: 2, stepsPerDay: 5400, sittingHoursPerDay: 9.2, stressScore: 6.2, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 28, sleepHours: 6.4, deepSleepHours: 1.7, nightAwakenings: 3, stepsPerDay: 5100, sittingHoursPerDay: 9.3, stressScore: 6.6, allergyAttackToday: 0, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 29, sleepHours: 6.8, deepSleepHours: 1.9, nightAwakenings: 3, stepsPerDay: 5100, sittingHoursPerDay: 9.8, stressScore: 6.4, allergyAttackToday: 1, visitToday: 0),
            DailyHealthData(subjectId: "001", day: 30, sleepHours: 6.5, deepSleepHours: 1.5, nightAwakenings: 2, stepsPerDay: 5000, sittingHoursPerDay: 9.1, stressScore: 6.8, allergyAttackToday: 2, visitToday: 1)
        ]
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
                title: "主任医师",
                department: "全科",
                specialization: "强直性脊柱炎、类风湿关节炎",
                experience: 15,
                available: true,
                specialties: ["强直性脊柱炎", "类风湿关节炎", "系统性红斑狼疮"],
                languages: ["English"],
                consultationCount: 5,
                nextAvailableDate: now.addingTimeInterval(86400 * 7),
                photoURL: nil
            ),
            Doctor(
                name: "Dr. James Smith",
                title: "副主任医师",
                department: "骨科",
                specialization: "骨关节疾病、运动损伤",
                experience: 10,
                available: true,
                specialties: ["自身免疫性疾病", "关节炎"],
                languages: ["English"],
                consultationCount: 3,
                nextAvailableDate: now.addingTimeInterval(86400 * 10),
                photoURL: nil
            ),
            Doctor(
                name: "Dr. Emily Chen",
                title: "主治医师",
                department: "全科",
                specialization: "全科医疗、慢性病管理",
                experience: 8,
                available: true,
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
