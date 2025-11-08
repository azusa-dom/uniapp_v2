//  ParentHealthView.swift
//  uniapp
//
//  家长健康观察：专业 iOS 风格设计
//

import SwiftUI

struct ParentHealthOverview: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let unit: String
    let icon: String
    let status: String
    let color: String
    let progress: Double
    let note: String
}

struct ParentHealthView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @State private var range: RangeFilter = .week
    @State private var selected: ParentHealthOverview? = nil
    
    enum RangeFilter: String, CaseIterable, Identifiable {
        case day = "今日"
        case week = "7天"
        case month = "30天"
        var id: String { rawValue }
    }
    
    private func data(for range: RangeFilter) -> [ParentHealthOverview] {
        switch range {
        case .day:
            return [
                .init(title: "睡眠", value: "7.2", unit: "小时", icon: "bed.double.fill", status: "良好", color: "6366F1", progress: 0.72, note: "睡眠时长充足。"),
                .init(title: "心率", value: "73", unit: "bpm", icon: "heart.fill", status: "正常", color: "EF4444", progress: 0.55, note: "静息心率正常。"),
                .init(title: "步数", value: "8,100", unit: "步", icon: "figure.walk", status: "活跃", color: "10B981", progress: 0.81, note: "活动充足。"),
                .init(title: "压力", value: "中等", unit: "", icon: "waveform.path.ecg", status: "需关注", color: "F59E0B", progress: 0.5, note: "建议适当休息。")
            ]
        case .week:
            return [
                .init(title: "平均睡眠", value: "6.9", unit: "小时", icon: "bed.double.fill", status: "略低", color: "6366F1", progress: 0.69, note: "尝试提高到 ≥7h。"),
                .init(title: "平均心率", value: "74", unit: "bpm", icon: "heart.fill", status: "正常", color: "EF4444", progress: 0.56, note: "保持充足运动与休息。"),
                .init(title: "总步数", value: "52k", unit: "步", icon: "figure.walk", status: "活跃", color: "10B981", progress: 0.88, note: "运动表现良好。"),
                .init(title: "压力指数", value: "0.42", unit: "", icon: "waveform.path.ecg", status: "正常", color: "F59E0B", progress: 0.42, note: "保持适度放松。")
            ]
        case .month:
            return [
                .init(title: "平均睡眠", value: "7.1", unit: "小时", icon: "bed.double.fill", status: "改善", color: "6366F1", progress: 0.71, note: "睡眠节奏更稳定。"),
                .init(title: "平均心率", value: "71", unit: "bpm", icon: "heart.fill", status: "良好", color: "EF4444", progress: 0.52, note: "心血管恢复良好。"),
                .init(title: "总步数", value: "211k", unit: "步", icon: "figure.walk", status: "活跃", color: "10B981", progress: 0.9, note: "每周保持高活动。"),
                .init(title: "压力均值", value: "0.38", unit: "", icon: "waveform.path.ecg", status: "稳定", color: "F59E0B", progress: 0.38, note: "压力控制良好。")
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
                        filterBar
                        overviewGrid
                        careSection
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
            .sheet(item: $selected) { item in
                ParentHealthDetailView(item: item)
                    .environmentObject(loc)
                    .environmentObject(appState)
            }
        }
    }
    
    private var filterBar: some View {
        Picker("时间范围", selection: $range) {
            ForEach(RangeFilter.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 8)
    }
    
    private var overviewGrid: some View {
        let items = data(for: range)
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(items) { item in
                ParentHealthCard(item: item)
                    .onTapGesture {
                        selected = item
                    }
            }
        }
    }
    
    private var careSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("关怀建议")
                .font(.system(size: 18, weight: .bold))
            
            VStack(spacing: 10) {
                ParentHealthTipRow(icon: "moon.stars.fill", color: "6366F1", text: "鼓励保持规律作息，避免熬夜")
                ParentHealthTipRow(icon: "figure.run", color: "10B981", text: "一起制定每周运动计划")
                ParentHealthTipRow(icon: "bubble.left.and.bubble.right.fill", color: "8B5CF6", text: "每周倾听孩子学习与情绪")
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

struct ParentHealthCard: View {
    let item: ParentHealthOverview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图标和状态
            HStack {
                Image(systemName: item.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(hex: item.color))
                
                Spacer()
                
                Text(item.status)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: item.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(hex: item.color).opacity(0.15))
                    )
            }
            
            // 标题
            Text(item.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            // 数值
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(item.value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: item.color))
                
                if !item.unit.isEmpty {
                    Text(item.unit)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // 进度条
            ProgressView(value: item.progress)
                .tint(Color(hex: item.color))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct ParentHealthTipRow: View {
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

struct ParentHealthDetailView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    let item: ParentHealthOverview
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
                                Image(systemName: item.icon)
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(Color(hex: item.color))
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(Color(hex: item.color).opacity(0.15))
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.system(size: 18, weight: .bold))
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text(item.value)
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(hex: item.color))
                                        
                                        if !item.unit.isEmpty {
                                            Text(item.unit)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Text(item.status)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color(hex: item.color))
                                }
                                
                                Spacer()
                            }
                            
                            Text(item.note)
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
                        
                        // 关怀建议
                        VStack(alignment: .leading, spacing: 12) {
                            Text("建议")
                                .font(.system(size: 18, weight: .bold))
                            
                            VStack(spacing: 10) {
                                ParentHealthTipRow(icon: "person.crop.circle.badge.questionmark", color: "6366F1", text: "与孩子交流当前学习压力来源")
                                ParentHealthTipRow(icon: "cup.and.saucer.fill", color: "F59E0B", text: "建立晚间放松例行活动")
                                ParentHealthTipRow(icon: "figure.cooldown", color: "10B981", text: "鼓励晨间或课后散步")
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
            .navigationTitle(item.title)
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

struct ParentHealthView_Previews: PreviewProvider {
    static var previews: some View {
        ParentHealthView()
            .environmentObject(LocalizationService())
            .environmentObject(AppState())
    }
}
