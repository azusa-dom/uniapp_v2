//
//  HealthManagementModels.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI
import Foundation

// MARK: - 处方记录
struct HealthPrescription: Identifiable {
    let id: UUID
    var medicineName: String          // 药品名称
    var dosage: String                // 剂量
    var frequency: String             // 频率（每日几次）
    var duration: String              // 疗程（几天）
    var prescribedBy: String          // 开方医生
    var prescribedDate: Date          // 开方日期
    var purpose: String               // 用途/病症
    var notes: String                 // 备注
    var isActive: Bool                // 是否正在服用
    var reminderEnabled: Bool         // 是否启用提醒
    var reminderTimes: [Date]         // 提醒时间
    
    init(
        id: UUID = UUID(),
        medicineName: String = "",
        dosage: String = "",
        frequency: String = "",
        duration: String = "",
        prescribedBy: String = "",
        prescribedDate: Date = Date(),
        purpose: String = "",
        notes: String = "",
        isActive: Bool = true,
        reminderEnabled: Bool = false,
        reminderTimes: [Date] = []
    ) {
        self.id = id
        self.medicineName = medicineName
        self.dosage = dosage
        self.frequency = frequency
        self.duration = duration
        self.prescribedBy = prescribedBy
        self.prescribedDate = prescribedDate
        self.purpose = purpose
        self.notes = notes
        self.isActive = isActive
        self.reminderEnabled = reminderEnabled
        self.reminderTimes = reminderTimes
    }
}

// MARK: - 过敏史
struct AllergyRecord: Identifiable, Codable {
    let id: UUID
    var allergen: String              // 过敏原
    var allergyType: AllergyType      // 过敏类型
    var severity: AllergySeverity     // 严重程度
    var symptoms: [String]            // 症状
    var discoveredDate: Date?         // 发现日期
    var notes: String                 // 备注
    
    enum AllergyType: String, Codable, CaseIterable {
        case drug = "药物"
        case food = "食物"
        case environmental = "环境"
        case other = "其他"
    }
    
    enum AllergySeverity: String, Codable, CaseIterable {
        case mild = "轻度"
        case moderate = "中度"
        case severe = "重度"
        case lifeThreatening = "危及生命"
        
        var color: Color {
            switch self {
            case .mild: return Color(hex: "10B981")
            case .moderate: return Color(hex: "F59E0B")
            case .severe: return Color(hex: "EF4444")
            case .lifeThreatening: return Color(hex: "DC2626")
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        allergen: String = "",
        allergyType: AllergyType = .drug,
        severity: AllergySeverity = .mild,
        symptoms: [String] = [],
        discoveredDate: Date? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.allergen = allergen
        self.allergyType = allergyType
        self.severity = severity
        self.symptoms = symptoms
        self.discoveredDate = discoveredDate
        self.notes = notes
    }
}

// MARK: - 用药记录（打卡）
struct MedicationLog: Identifiable, Codable {
    let id: UUID
    let prescriptionId: UUID
    let takenDate: Date
    var isTaken: Bool
    var notes: String
    
    init(
        id: UUID = UUID(),
        prescriptionId: UUID,
        takenDate: Date,
        isTaken: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.prescriptionId = prescriptionId
        self.takenDate = takenDate
        self.isTaken = isTaken
        self.notes = notes
    }
}

// MARK: - 健康数据管理器
class HealthManager: ObservableObject {
    @Published var prescriptions: [HealthPrescription] = []
    @Published var allergies: [AllergyRecord] = []
    @Published var medicationLogs: [MedicationLog] = []
    
    init() {
        loadMockData()
        loadFromUserDefaults()
    }
    
    // MARK: - 处方管理
    
    func addPrescription(_ prescription: HealthPrescription) {
        prescriptions.append(prescription)
        savePrescriptions()
    }
    
    func updatePrescription(_ prescription: HealthPrescription) {
        if let index = prescriptions.firstIndex(where: { $0.id == prescription.id }) {
            prescriptions[index] = prescription
            savePrescriptions()
        }
    }
    
    func deletePrescription(_ prescription: HealthPrescription) {
        prescriptions.removeAll { $0.id == prescription.id }
        savePrescriptions()
    }
    
    func togglePrescriptionStatus(_ prescription: HealthPrescription) {
        if let index = prescriptions.firstIndex(where: { $0.id == prescription.id }) {
            prescriptions[index].isActive.toggle()
            savePrescriptions()
        }
    }
    
    var activePrescriptions: [HealthPrescription] {
        prescriptions.filter { $0.isActive }
    }
    
    var inactivePrescriptions: [HealthPrescription] {
        prescriptions.filter { !$0.isActive }
    }
    
    // MARK: - 过敏史管理
    
    func addAllergy(_ allergy: AllergyRecord) {
        allergies.append(allergy)
        saveAllergies()
    }
    
    func updateAllergy(_ allergy: AllergyRecord) {
        if let index = allergies.firstIndex(where: { $0.id == allergy.id }) {
            allergies[index] = allergy
            saveAllergies()
        }
    }
    
    func deleteAllergy(_ allergy: AllergyRecord) {
        allergies.removeAll { $0.id == allergy.id }
        saveAllergies()
    }
    
    // MARK: - 用药记录
    
    func logMedication(prescriptionId: UUID, isTaken: Bool, notes: String = "") {
        let log = MedicationLog(
            prescriptionId: prescriptionId,
            takenDate: Date(),
            isTaken: isTaken,
            notes: notes
        )
        medicationLogs.append(log)
        saveMedicationLogs()
    }
    
    func getMedicationLogs(for prescription: HealthPrescription, days: Int = 7) -> [MedicationLog] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return medicationLogs
            .filter { $0.prescriptionId == prescription.id && $0.takenDate >= startDate }
            .sorted { $0.takenDate > $1.takenDate }
    }
    
    // MARK: - 持久化
    
    private func savePrescriptions() {
        // 简化：暂时不持久化，使用内存存储
        // 如果需要持久化，可以使用 PropertyListEncoder 或自定义编码
    }
    
    private func saveAllergies() {
        // 简化：暂时不持久化
    }
    
    private func saveMedicationLogs() {
        // 简化：暂时不持久化
    }
    
    private func loadFromUserDefaults() {
        // 暂时不加载，使用模拟数据
    }
    
    // MARK: - 模拟数据
    
    private func loadMockData() {
        // 加载模拟数据
        if prescriptions.isEmpty {
            prescriptions = [
                HealthPrescription(
                    medicineName: "阿莫西林胶囊",
                    dosage: "500mg",
                    frequency: "每日3次",
                    duration: "7天",
                    prescribedBy: "张医生",
                    prescribedDate: Date().addingTimeInterval(-86400 * 2),
                    purpose: "上呼吸道感染",
                    notes: "饭后服用",
                    isActive: true,
                    reminderEnabled: true,
                    reminderTimes: [
                        Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
                        Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!,
                        Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
                    ]
                ),
                HealthPrescription(
                    medicineName: "布洛芬缓释胶囊",
                    dosage: "300mg",
                    frequency: "每日2次",
                    duration: "5天",
                    prescribedBy: "李医生",
                    prescribedDate: Date().addingTimeInterval(-86400 * 10),
                    purpose: "头痛、发热",
                    notes: "疼痛时服用",
                    isActive: false
                )
            ]
        }
        
        if allergies.isEmpty {
            allergies = [
                AllergyRecord(
                    allergen: "青霉素",
                    allergyType: .drug,
                    severity: .severe,
                    symptoms: ["皮疹", "呼吸困难", "面部肿胀"],
                    discoveredDate: Date().addingTimeInterval(-86400 * 365 * 5),
                    notes: "2019年首次发现，严重过敏反应"
                ),
                AllergyRecord(
                    allergen: "海鲜",
                    allergyType: .food,
                    severity: .moderate,
                    symptoms: ["皮肤瘙痒", "红疹"],
                    discoveredDate: Date().addingTimeInterval(-86400 * 365 * 3),
                    notes: "虾、蟹类过敏"
                ),
                AllergyRecord(
                    allergen: "花粉",
                    allergyType: .environmental,
                    severity: .mild,
                    symptoms: ["打喷嚏", "流鼻涕", "眼睛痒"],
                    discoveredDate: Date().addingTimeInterval(-86400 * 365 * 2),
                    notes: "春季花粉过敏"
                )
            ]
        }
    }
}

