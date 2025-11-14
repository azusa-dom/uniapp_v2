//  StudentHealthView.swift
//  uniapp
//


import SwiftUI

// MARK: - 健康指标模型
struct HealthMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let unit: String
    let icon: String
    let trend: Trend
    let color: String
    let progress: Double
    let description: String
    
    enum Trend { case up, down, stable }
    
    var trendIcon: String {
        switch trend { 
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    var trendColor: Color {
        switch trend { 
        case .up: return Color(hex: "10B981")
        case .down: return Color(hex: "EF4444")
        case .stable: return Color(hex: "6B7280")
        }
    }
}

struct AppointmentCategory: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: String
}

struct BookingSlot: Identifiable {
    let id = UUID()
    let timeRange: String
    let doctor: String
    let location: String
    let capacity: String
}

struct ServiceFlowStep: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let icon: String
    let color: String
}

// MARK: - 学生健康主视图
struct StudentHealthView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @StateObject private var healthData = HealthDataManager()
    @State private var range: RangeFilter = .day
    @State private var selectedMetric: HealthMetric? = nil
    @State private var showingMedicalRecords = false
    @State private var showingPrescriptions = false
    @State private var showingHealthManagement = false
    @State private var showingRemoteConsultForm = false
    @State private var showConsultSuccess = false
    @State private var selectedAppointmentCategory: AppointmentCategory? = nil
    @State private var bookingCategory: AppointmentCategory? = nil
    @State private var showBookingSuccess = false
    @State private var lastBookingSummary: String = ""
    @State private var wearablesEnabled = false
    @State private var showingWearableSetup = false
    
    enum RangeFilter: String, CaseIterable, Identifiable { 
        case day = "今日"
        case week = "7天"
        case month = "30天"
        var id: String { rawValue }
    }
    
    private func metrics(for range: RangeFilter) -> [HealthMetric] {
        switch range {
        case .day:
            return [
                .init(title: "睡眠", value: "7.4", unit: "小时", icon: "bed.double.fill", trend: .up, color: "6366F1", progress: 0.74, description: "昨晚睡眠 7 小时 24 分，质量良好。建议维持 ≥7h。"),
                .init(title: "心率", value: "72", unit: "bpm", icon: "heart.fill", trend: .stable, color: "EF4444", progress: 0.55, description: "当前静息心率 72 次/分，属正常范围。"),
                .init(title: "步数", value: "8,520", unit: "步", icon: "figure.walk", trend: .up, color: "10B981", progress: 0.85, description: "今日步数已接近 10,000 步目标。继续加油！"),
                .init(title: "压力", value: "中等", unit: "", icon: "waveform.path.ecg", trend: .stable, color: "F59E0B", progress: 0.50, description: "压力处于可控状态，适当休息避免累积。")
            ]
        case .week:
            return [
                .init(title: "平均睡眠", value: "6.9", unit: "小时", icon: "bed.double.fill", trend: .down, color: "6366F1", progress: 0.69, description: "近 7 天平均睡眠略低于建议值，尝试提前 30 分钟入睡。"),
                .init(title: "平均心率", value: "74", unit: "bpm", icon: "heart.fill", trend: .up, color: "EF4444", progress: 0.57, description: "静息心率略升高，建议规律运动与充足休息。"),
                .init(title: "总步数", value: "52,300", unit: "步", icon: "figure.walk", trend: .up, color: "10B981", progress: 0.95, description: "步数活跃度优秀，保持活动水平。"),
                .init(title: "压力指数", value: "0.42", unit: "", icon: "waveform.path.ecg", trend: .up, color: "F59E0B", progress: 0.42, description: "压力略升，适度放松。")
            ]
        case .month:
            return [
                .init(title: "平均睡眠", value: "7.1", unit: "小时", icon: "bed.double.fill", trend: .up, color: "6366F1", progress: 0.71, description: "整体睡眠改善明显。"),
                .init(title: "平均心率", value: "71", unit: "bpm", icon: "heart.fill", trend: .down, color: "EF4444", progress: 0.52, description: "心率略有下降，体现恢复良好。"),
                .init(title: "总步数", value: "211k", unit: "步", icon: "figure.walk", trend: .up, color: "10B981", progress: 0.88, description: "持续保持高活动水平。"),
                .init(title: "压力均值", value: "0.38", unit: "", icon: "waveform.path.ecg", trend: .down, color: "F59E0B", progress: 0.38, description: "压力控制良好。")
            ]
        }
    }
    
    var body: some View {
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
                    telemedicineSection
                    appointmentSection
                    serviceFlowSection
                    // 健康档案快捷入口
                    healthRecordsSection
                    
                    if wearablesEnabled {
                        wearableStatusHeader
                        rangeSelector
                        metricsGrid
                        tipsSection
                    } else {
                        wearableOptInSection
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("健康")
        .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedMetric) { metric in
                HealthMetricDetailView(metric: metric)
                    .environmentObject(loc)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingMedicalRecords) {
                MedicalRecordsView()
                    .environmentObject(loc)
            }
            .sheet(isPresented: $showingPrescriptions) {
                PrescriptionsView()
                    .environmentObject(loc)
            }
            .sheet(isPresented: $showingHealthManagement) {
                HealthManagementView()
                    .environmentObject(loc)
            }
            .sheet(isPresented: $showingRemoteConsultForm) {
                RemoteConsultFormSheet {
                    showConsultSuccess = true
                }
            }
            .sheet(item: $selectedAppointmentCategory) { category in
                AppointmentCategoryDetailSheet(category: category) { selectedCategory in
                    bookingCategory = selectedCategory
                }
            }
            .sheet(item: $bookingCategory) { category in
                AppointmentBookingSheet(category: category) { summary in
                    lastBookingSummary = summary
                    showBookingSuccess = true
                }
            }
            .sheet(isPresented: $showingWearableSetup) {
                WearableConnectSheet(isEnabled: $wearablesEnabled)
            }
            .alert("请求已提交", isPresented: $showConsultSuccess) {
                Button("好的", role: .cancel) { }
            } message: {
                Text("我们已收到你的远程问诊需求，护理团队将 15 分钟内联系你。")
            }
            .alert("预约成功", isPresented: $showBookingSuccess) {
                Button("好的", role: .cancel) { }
            } message: {
                Text(lastBookingSummary.isEmpty ? "我们已为你保留该项目，稍后会在行程中更新提醒。" : lastBookingSummary)
            }
    }
    
    private var appointmentCategories: [AppointmentCategory] {
        [
            .init(title: "心理评估", subtitle: "情绪支持 / 压力管理", icon: "brain.head.profile", color: "8B5CF6"),
            .init(title: "过敏检测", subtitle: "呼吸道 / 食物过敏", icon: "allergens", color: "F59E0B"),
            .init(title: "身体检查", subtitle: "基础体检 / 运动安心", icon: "stethoscope", color: "10B981"),
            .init(title: "综合问诊", subtitle: "多学科联合评估", icon: "cross.case.fill", color: "EF4444")
        ]
    }
    
    private var serviceFlowSteps: [ServiceFlowStep] {
        [
            .init(title: "提交症状", detail: "用 2 分钟填写症状问卷与既往史，方便医生快速了解情况。", icon: "doc.text.fill", color: "6366F1"),
            .init(title: "匹配医生", detail: "根据你的需求匹配合适的校医院团队与心理/体检专家。", icon: "person.2.circle.fill", color: "3B82F6"),
            .init(title: "在线问诊", detail: "医生通过短信 / 电话 / 视频三种方式与您沟通，完成初诊。", icon: "message.badge.waveform.fill", color: "10B981"),
            .init(title: "线下面诊", detail: "必要时直接预约线下时间段，抵达即可完成评估与检验。", icon: "calendar.badge.plus", color: "F59E0B")
        ]
    }
    
    // MARK: - 远程问诊
    private var telemedicineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("一键问诊")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text("随时发起远程医疗咨询，锁定合适的医生团队。提交症状后我们将在 15 分钟内回复。")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Button {
                showingRemoteConsultForm = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "phone.badge.waveform")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("联系远程医生")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("支持文字 / 电话 / 视频")
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.forward.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "4C6EF5"), Color(hex: "63B3ED")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
        )
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - 预约面诊
    private var appointmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("预约面诊")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    Text("按需选择大项服务，固定时间段即可完成所有检查。")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    selectedAppointmentCategory = appointmentCategories.first
                } label: {
                    Text("立即预约")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(hex: "10B981").opacity(0.15))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(appointmentCategories) { category in
                    AppointmentCategoryCard(category: category) {
                        selectedAppointmentCategory = category
                    }
                }
            }
        }
    }
    
    // MARK: - 服务流程
    private var serviceFlowSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("服务流程")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 14) {
                ForEach(serviceFlowSteps) { step in
                    ServiceFlowRow(step: step)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
            )
            .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
        }
    }
    
    private var wearableStatusHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("穿戴设备数据")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Text("数据已接入，15 分钟自动刷新")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    showingWearableSetup = true
                } label: {
                    Text("管理")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(hex: "6366F1").opacity(0.15))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.9))
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
    
    private var wearableOptInSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("穿戴设备未接入")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text("开启后可查看 Apple Watch / Oura 等设备同步的睡眠、心率与步数趋势。")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Button {
                showingWearableSetup = true
            } label: {
                HStack {
                    Image(systemName: "applewatch.side.right")
                        .font(.system(size: 22, weight: .medium))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("立即连接") .font(.system(size: 15, weight: .semibold))
                        Text("支持 Apple Health / Fitbit / Garmin")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "0EA5E9"), Color(hex: "6366F1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.92))
        )
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - 健康档案区域
    private var healthRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("健康档案")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                HealthRecordButton(
                    icon: "doc.text.fill",
                    title: "就诊历史",
                    count: healthData.medicalRecords.count,
                    color: "6366F1"
                ) {
                    showingMedicalRecords = true
                }
                
                HealthRecordButton(
                    icon: "pills.fill",
                    title: "处方记录",
                    count: healthData.prescriptions.filter { $0.status == .active }.count,
                    color: "EF4444"
                ) {
                    showingPrescriptions = true
                }
            }
            
            HStack(spacing: 12) {
                HealthRecordButton(
                    icon: "calendar.badge.plus",
                    title: "预约面诊",
                    count: healthData.appointments.filter { $0.status == .scheduled }.count,
                    color: "10B981"
                ) {
                    selectedAppointmentCategory = appointmentCategories.first
                }
                
                HealthRecordButton(
                    icon: "allergens",
                    title: "健康管理",
                    count: 0,
                    color: "F59E0B"
                ) {
                    showingHealthManagement = true
                }
            }
        }
    }
    
    // MARK: - Range Selector
    private var rangeSelector: some View {
        Picker("时间范围", selection: $range) {
            ForEach(RangeFilter.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 8)
    }
    
    // MARK: - Metrics Grid
    private var metricsGrid: some View {
        let data = metrics(for: range)
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(data) { metric in
                HealthMetricCard(metric: metric)
                    .onTapGesture {
                        selectedMetric = metric
                    }
            }
        }
    }
    
    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("健康建议")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 10) {
                HealthTipRow(icon: "moon.stars.fill", color: "6366F1", text: "保持 7-9 小时睡眠可提升认知与记忆力")
                HealthTipRow(icon: "figure.run", color: "10B981", text: "每天 30 分钟中强度运动有助缓解压力")
                HealthTipRow(icon: "heart.text.square", color: "EF4444", text: "关注静息心率变化，及时调整作息")
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - 健康档案按钮
struct HealthRecordButton: View {
    let icon: String
    let title: String
    let count: Int
    let color: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: color))
                    
                    Spacer()
                    
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: color))
                    }
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.8))
            )
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 指标卡片
struct HealthMetricCard: View {
    let metric: HealthMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图标和趋势
            HStack {
                Image(systemName: metric.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(hex: metric.color))
                
                Spacer()
                
                Image(systemName: metric.trendIcon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(metric.trendColor)
            }
            
            // 标题
            Text(metric.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            // 数值
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(metric.value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: metric.color))
                
                if !metric.unit.isEmpty {
                    Text(metric.unit)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // 进度条
            ProgressView(value: metric.progress)
                .tint(Color(hex: metric.color))
                .scaleEffect(x: 1, y: 2, anchor: .center)
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

// MARK: - 健康建议行
struct HealthTipRow: View {
    let icon: String
    let color: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: color))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color(hex: color).opacity(0.15))
                )
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct AppointmentCategoryCard: View {
    let category: AppointmentCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(hex: category.color))
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: category.color).opacity(0.12))
                    )
                
                Text(category.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(category.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.85))
            )
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ServiceFlowRow: View {
    let step: ServiceFlowStep
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: step.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: step.color))
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: step.color).opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text(step.detail)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct RemoteConsultFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var symptomSummary = ""
    @State private var duration = ""
    @State private var contactMethod = "文字"
    @State private var urgencyIndex = 0
    @State private var shareVitals = false
    @State private var attachments = false
    let onSubmit: () -> Void
    
    private let contactOptions = ["文字", "电话", "视频"]
    private let urgencyLabels = ["常规（24h 内）", "加急（6h 内）", "紧急（1h 内）"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("症状与既往史") {
                    TextEditor(text: $symptomSummary)
                        .frame(minHeight: 120)
                        .overlay(alignment: .topLeading) {
                            if symptomSummary.isEmpty {
                                Text("例如：三天发热伴随咽痛，无过敏史")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                                    .padding(.horizontal, 4)
                            }
                        }
                    TextField("症状持续时长（如 3 天）", text: $duration)
                    Toggle("允许同步可穿戴设备数据", isOn: $shareVitals)
                    Toggle("将最近体检/化验报告附加给医生", isOn: $attachments)
                }
                
                Section("联系偏好") {
                    Picker("联系方式", selection: $contactMethod) {
                        ForEach(contactOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    Picker("紧急程度", selection: $urgencyIndex) {
                        ForEach(urgencyLabels.indices, id: \.self) { index in
                            Text(urgencyLabels[index]).tag(index)
                        }
                    }
                }
                
                Section("提示") {
                    Label("我们的校医院护士将先进行分诊，再邀请医生加入。", systemImage: "stethoscope")
                    Label("如遇生命危险请直接拨打 120 或校园急救电话。", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "EF4444"))
                }
            }
            .navigationTitle("一键问诊")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("发送请求") {
                        onSubmit()
                        dismiss()
                    }
                    .disabled(symptomSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct AppointmentCategoryDetailSheet: View {
    let category: AppointmentCategory
    let onReserve: (AppointmentCategory) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var highlights: [String] {
        switch category.title {
        case "心理评估":
            return ["临床心理师 1:1 初诊，30 分钟", "提供情绪量表与压力管理方案", "必要时联动校外心理资源"]
        case "过敏检测":
            return ["含常见食物/花粉 20+ 项", "配备急救药品，流程安全", "结果 48h 内同步 App"]
        case "身体检查":
            return ["基础生命体征 + 血常规", "运动风险筛查，附报告", "可选身体成分/心电图"]
        default:
            return ["跨科室联合问诊，协调后勤", "覆盖呼吸、消化等常见疾病", "如需外院转诊会有专人协助"]
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: category.icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Color(hex: category.color))
                            .frame(width: 64, height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(hex: category.color).opacity(0.12))
                            )
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(category.title)
                                .font(.system(size: 22, weight: .bold))
                            Text(category.subtitle)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("服务亮点")
                            .font(.system(size: 18, weight: .semibold))
                        ForEach(highlights, id: \.self) { item in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: category.color))
                                Text(item)
                                    .font(.system(size: 15))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                    )
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("准备材料")
                            .font(.system(size: 18, weight: .semibold))
                        Text("学生证、近期体检/病历（如有）、既往处方或用药清单。提前 10 分钟到达即可完成签到。")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(uiColor: .tertiarySystemBackground))
                    )
                }
                .padding()
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(category.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("预约该项目") {
                        dismiss()
                        onReserve(category)
                    }
                }
            }
        }
    }
}

struct AppointmentBookingSheet: View {
    let category: AppointmentCategory
    let onConfirm: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var selectedSlotID: UUID?
    @State private var note = ""
    
    private var slots: [BookingSlot] {
        AppointmentBookingSheet.slotMap[category.title] ?? AppointmentBookingSheet.slotMap["default"]!
    }
    
    private var selectedSlot: BookingSlot? {
        guard let id = selectedSlotID else { return nil }
        return slots.first { $0.id == id }
    }
    
    private static let slotMap: [String: [BookingSlot]] = [
        "心理评估": [
            .init(timeRange: "09:00 - 09:40", doctor: "王心宇 医师", location: "心理中心 A 室", capacity: "剩 2 位"),
            .init(timeRange: "11:00 - 11:40", doctor: "刘若晴 咨询师", location: "心理中心 B 室", capacity: "剩 1 位"),
            .init(timeRange: "15:00 - 15:40", doctor: "陈柏廷 医师", location: "心理中心 A 室", capacity: "剩 3 位")
        ],
        "过敏检测": [
            .init(timeRange: "08:30 - 09:10", doctor: "郭晓宁 医师", location: "校医院检验科 201", capacity: "剩 4 位"),
            .init(timeRange: "13:30 - 14:10", doctor: "郭晓宁 医师", location: "校医院检验科 201", capacity: "剩 2 位")
        ],
        "身体检查": [
            .init(timeRange: "10:00 - 10:30", doctor: "体检团队", location: "体检中心 1F", capacity: "剩 5 位"),
            .init(timeRange: "14:30 - 15:00", doctor: "体检团队", location: "体检中心 1F", capacity: "剩 4 位")
        ],
        "综合问诊": [
            .init(timeRange: "09:30 - 10:10", doctor: "综合门诊组", location: "校医院门诊 305", capacity: "剩 2 位"),
            .init(timeRange: "16:00 - 16:40", doctor: "综合门诊组", location: "校医院门诊 305", capacity: "剩 1 位")
        ],
        "default": [
            .init(timeRange: "09:00 - 09:30", doctor: "校医院团队", location: "校医院门诊", capacity: "可预约")
        ]
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("选择日期") {
                    DatePicker("到访日期", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
                
                Section("可用时间段") {
                    ForEach(slots) { slot in
                        Button {
                            selectedSlotID = slot.id
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(slot.timeRange)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text("\(slot.doctor) · \(slot.location)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(slot.capacity)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(hex: "10B981"))
                                    if selectedSlotID == slot.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(hex: "10B981"))
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                if let slot = selectedSlot {
                    Section("到访信息") {
                        Label(slot.location, systemImage: "mappin.and.ellipse")
                        Label(slot.doctor, systemImage: "person.fill")
                    }
                }
                
                Section("备注（选填）") {
                    TextField("想告诉医生的情况", text: $note)
                }
                
                Section("温馨提示") {
                    Label("请提前 10 分钟到场完成签到。", systemImage: "clock.badge.checkmark")
                    Label("如需取消请至少提前 3 小时。", systemImage: "bell.slash")
                }
            }
            .navigationTitle("\(category.title)预约")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("确认预约") {
                        if let slot = selectedSlot {
                            let dateText = AppointmentBookingSheet.dateFormatter.string(from: selectedDate)
                            let summary = "\(category.title) · \(dateText) · \(slot.timeRange) @ \(slot.location)"
                            onConfirm(summary)
                        } else {
                            onConfirm("")
                        }
                        dismiss()
                    }
                    .disabled(selectedSlot == nil)
                }
            }
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter
    }()
}

struct WearableConnectSheet: View {
    @Binding var isEnabled: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var tempEnabled = false
    @State private var selectedService = "Apple Health"
    @State private var shareSleep = true
    @State private var shareHeartRate = true
    @State private var shareSteps = true
    private let services = ["Apple Health", "Fitbit", "Garmin", "Oura"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("连接状态") {
                    Toggle("启用穿戴数据同步", isOn: $tempEnabled)
                }
                
                Section("选择服务") {
                    Picker("数据来源", selection: $selectedService) {
                        ForEach(services, id: \.self) { service in
                            Text(service).tag(service)
                        }
                    }
                }
                
                Section("共享内容") {
                    Toggle("睡眠时长与质量", isOn: $shareSleep)
                    Toggle("心率 / HRV", isOn: $shareHeartRate)
                    Toggle("活动量 / 步数", isOn: $shareSteps)
                }
                
                Section("隐私提醒") {
                    Label("数据仅用于个人健康洞察，可随时停止同步。", systemImage: "lock.shield")
                }
            }
            .navigationTitle("穿戴设备")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        isEnabled = tempEnabled
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempEnabled = isEnabled
            }
        }
    }
}

// MARK: - 详情视图
struct HealthMetricDetailView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    let metric: HealthMetric
    @Environment(\.dismiss) var dismiss
    
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
                    VStack(spacing: 24) {
                        // 概览卡片
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: metric.icon)
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(Color(hex: metric.color))
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(Color(hex: metric.color).opacity(0.15))
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(metric.title)
                                        .font(.system(size: 18, weight: .bold))
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text(metric.value)
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(hex: metric.color))
                                        
                                        if !metric.unit.isEmpty {
                                            Text(metric.unit)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            Text(metric.description)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.8))
                        )
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
                        // 趋势图占位
                        VStack(alignment: .leading, spacing: 12) {
                            Text("趋势")
                                .font(.system(size: 18, weight: .bold))
                            
                            // 简单的趋势图占位
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 200)
                                
                                Text("趋势图\n(接入真实数据后显示)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.8))
                        )
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
                        // 建议
                        VStack(alignment: .leading, spacing: 12) {
                            Text("建议")
                                .font(.system(size: 18, weight: .bold))
                            
                            VStack(spacing: 10) {
                                HealthTipRow(icon: "lightbulb.fill", color: "F59E0B", text: "保持规律作息，固定睡眠时间")
                                HealthTipRow(icon: "figure.run", color: "10B981", text: "适度运动有助于改善睡眠质量")
                                HealthTipRow(icon: "drop.fill", color: "6366F1", text: "保持充足水分摄入")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.8))
                        )
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(metric.title)
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
}

// MARK: - 预览
struct StudentHealthView_Previews: PreviewProvider {
    static var previews: some View {
        StudentHealthView()
            .environmentObject(LocalizationService())
            .environmentObject(AppState())
    }
}
