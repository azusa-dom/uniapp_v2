//  StudentHealthView.swift
//  uniapp
//
//  学生健康中心：专业 iOS 风格设计
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

// MARK: - 学生健康主视图
struct StudentHealthView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @StateObject private var healthData = HealthDataManager()
    @State private var range: RangeFilter = .day
    @State private var selectedMetric: HealthMetric? = nil
    @State private var showingMedicalRecords = false
    @State private var showingPrescriptions = false
    @State private var showingAppointments = false
    @State private var showingAppointmentBooking = false
    
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
                        // 健康档案快捷入口
                        healthRecordsSection
                        
                        // 30天健康监测趋势
                        dailyHealthTrendsSection
                        
                        rangeSelector
                        metricsGrid
                        tipsSection
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("健康")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
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
            .sheet(isPresented: $showingAppointmentBooking) {
                AppointmentBookingView()
                    .environmentObject(loc)
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
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
                    showingAppointmentBooking = true
                }
                
                HealthRecordButton(
                    icon: "allergens",
                    title: "过敏史",
                    count: healthData.allergies.count,
                    color: "F59E0B"
                ) {
                    // 打开过敏史
                }
            }
        }
    }
    
    // MARK: - 30天健康监测趋势
    private var dailyHealthTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("30天健康监测趋势")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            // 睡眠趋势
            HealthTrendCard(
                title: "睡眠质量",
                icon: "bed.double.fill",
                color: "6366F1",
                data: healthData.dailyHealthData
            ) { day in
                TrendDataPoint(
                    day: day.day,
                    value: day.sleepHours,
                    label: "\(String(format: "%.1f", day.sleepHours))h",
                    detail: "深睡:\(String(format: "%.1f", day.deepSleepHours))h 醒:\(day.nightAwakenings)次"
                )
            }
            
            // 运动活动趋势
            HealthTrendCard(
                title: "每日步数",
                icon: "figure.walk",
                color: "10B981",
                data: healthData.dailyHealthData
            ) { day in
                TrendDataPoint(
                    day: day.day,
                    value: Double(day.stepsPerDay),
                    label: "\(day.stepsPerDay)步",
                    detail: "久坐:\(String(format: "%.1f", day.sittingHoursPerDay))h"
                )
            }
            
            // 压力水平趋势
            HealthTrendCard(
                title: "压力指数",
                icon: "waveform.path.ecg",
                color: "F59E0B",
                data: healthData.dailyHealthData
            ) { day in
                TrendDataPoint(
                    day: day.day,
                    value: day.stressScore,
                    label: String(format: "%.1f", day.stressScore),
                    detail: day.stressLevel
                )
            }
            
            // 过敏和就诊事件
            HealthEventCard(
                title: "健康事件",
                icon: "exclamationmark.triangle.fill",
                color: "EF4444",
                data: healthData.dailyHealthData
            )
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
}

// MARK: - 趋势数据点
struct TrendDataPoint {
    let day: Int
    let value: Double
    let label: String
    let detail: String
}

// MARK: - 健康趋势卡片
struct HealthTrendCard<Data: RandomAccessCollection>: View where Data.Element == DailyHealthData {
    let title: String
    let icon: String
    let color: String
    let data: Data
    let transform: (DailyHealthData) -> TrendDataPoint
    
    private var trendData: [TrendDataPoint] {
        data.map(transform)
    }
    
    private var minValue: Double {
        trendData.map { $0.value }.min() ?? 0
    }
    
    private var maxValue: Double {
        trendData.map { $0.value }.max() ?? 100
    }
    
    private var avgValue: Double {
        let sum = trendData.reduce(0.0) { $0 + $1.value }
        return sum / Double(trendData.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: color))
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("平均")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", avgValue))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: color))
                }
            }
            
            // 简化的趋势线图
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let points = trendData.enumerated().map { index, point in
                    let x = CGFloat(index) / CGFloat(max(trendData.count - 1, 1)) * width
                    let normalizedValue = (point.value - minValue) / max(maxValue - minValue, 0.01)
                    let y = height - (CGFloat(normalizedValue) * height * 0.8 + height * 0.1)
                    return CGPoint(x: x, y: y)
                }
                
                ZStack {
                    // 背景网格
                    Path { path in
                        for i in 0...4 {
                            let y = CGFloat(i) * height / 4
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                    }
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    
                    // 趋势线
                    Path { path in
                        guard points.count > 1 else { return }
                        path.move(to: points[0])
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(Color(hex: color), lineWidth: 2)
                    
                    // 数据点
                    ForEach(0..<points.count, id: \.self) { index in
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 4, height: 4)
                            .position(points[index])
                    }
                }
            }
            .frame(height: 120)
            
            // 统计信息
            HStack {
                StatBadge(label: "最低", value: String(format: "%.1f", minValue), color: color)
                StatBadge(label: "最高", value: String(format: "%.1f", maxValue), color: color)
                StatBadge(label: "样本", value: "\(trendData.count)天", color: color)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - 健康事件卡片
struct HealthEventCard<Data: RandomAccessCollection>: View where Data.Element == DailyHealthData {
    let title: String
    let icon: String
    let color: String
    let data: Data
    
    private var allergyDays: [Int] {
        data.filter { $0.allergyAttackToday > 0 }.map { $0.day }
    }
    
    private var visitDays: [Int] {
        data.filter { $0.visitToday > 0 }.map { $0.day }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: color))
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                // 过敏事件
                HStack {
                    Image(systemName: "allergens")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "F59E0B"))
                        .frame(width: 24)
                    
                    Text("过敏发作")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(allergyDays.count)次")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(hex: "F59E0B").opacity(0.1))
                .cornerRadius(8)
                
                if !allergyDays.isEmpty {
                    Text("发生日期: 第 \(allergyDays.map(String.init).joined(separator: ", ")) 天")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // 就诊事件
                HStack {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(width: 24)
                    
                    Text("医疗就诊")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(visitDays.count)次")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "EF4444"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(hex: "EF4444").opacity(0.1))
                .cornerRadius(8)
                
                if !visitDays.isEmpty {
                    Text("就诊日期: 第 \(visitDays.map(String.init).joined(separator: ", ")) 天")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - 统计徽章
struct StatBadge: View {
    let label: String
    let value: String
    let color: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: color))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(hex: color).opacity(0.1))
        .cornerRadius(8)
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
