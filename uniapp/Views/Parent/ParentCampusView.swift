
//
//  ParentCampusView.swift
//  uniapp
//
//  Created by 748 on 14/11/2025.
//

// MARK: - ParentCampusView.swift
// 文件位置: uniapp/Views/Parent/ParentCampusView.swift

import SwiftUI

struct ParentCampusView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var uclVM: UCLAPIViewModel
    
    @State private var selectedFilter: ActivityFilter = .all
    @State private var selectedActivity: UCLAPIViewModel.UCLAPIEvent? = nil
    @State private var showingActivityDetail = false
    
    var filteredActivities: [UCLAPIViewModel.UCLAPIEvent] {
        switch selectedFilter {
        case .all:
            return uclVM.events
        case .registered:
            return uclVM.events.filter { $0.isStudentJoined }
        case .recommended:
            return uclVM.events.filter { $0.isRecommended }
        case .thisWeek:
            let weekFromNow = Date().addingTimeInterval(7*24*3600)
            return uclVM.events.filter { $0.startTime >= Date() && $0.startTime <= weekFromNow }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 筛选器
                    ActivityFilterBar(selectedFilter: $selectedFilter)
                        .padding()
                    
                    // 活动列表
                    if filteredActivities.isEmpty {
                        EmptyCampusActivitiesView(filter: selectedFilter)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                // 统计卡片
                                CampusStatsCard()
                                
                                // 活动列表
                                ForEach(filteredActivities) { activity in
                                    ParentCampusActivityCard(activity: activity) {
                                        selectedActivity = activity
                                        showingActivityDetail = true
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle(loc.language == .chinese ? "校园活动" : "Campus Activities")
            .sheet(isPresented: $showingActivityDetail) {
                if let activity = selectedActivity {
                    ActivityDetailView(activity: activity)
                }
            }
        }
    }
}

// MARK: - 活动筛选栏
struct ActivityFilterBar: View {
    @EnvironmentObject var loc: LocalizationService
    @Binding var selectedFilter: ActivityFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ActivityFilter.allCases, id: \.self) { filter in
                    ParentFilterChip(
                        title: filter.displayName(loc: loc),
                        isSelected: selectedFilter == filter,
                        icon: filter.icon
                    ) {
                        withAnimation(.spring()) {
                            selectedFilter = filter
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 筛选芯片
struct ParentFilterChip: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : DesignSystem.primaryColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        DesignSystem.primaryGradient
                    } else {
                        Color.white
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - 校园统计卡片
struct CampusStatsCard: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var uclVM: UCLAPIViewModel
    
    private var totalActivities: Int {
        uclVM.events.count
    }
    
    private var joinedActivities: Int {
        uclVM.events.filter { $0.isStudentJoined }.count
    }
    
    private var recommendedActivities: Int {
        uclVM.events.filter { $0.isRecommended }.count
    }
    
    var body: some View {
        HStack(spacing: 12) {
            CampusStatItem(
                icon: "star.fill",
                value: "\(totalActivities)",
                label: loc.language == .chinese ? "全部活动" : "Total",
                color: DesignSystem.primaryColor
            )
            
            Divider()
            
            CampusStatItem(
                icon: "checkmark.circle.fill",
                value: "\(joinedActivities)",
                label: loc.language == .chinese ? "已参加" : "Joined",
                color: DesignSystem.successColor
            )
            
            Divider()
            
            CampusStatItem(
                icon: "sparkles",
                value: "\(recommendedActivities)",
                label: loc.language == .chinese ? "推荐" : "Recommended",
                color: DesignSystem.secondaryColor
            )
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 统计项
struct CampusStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 校园活动卡片
struct ParentCampusActivityCard: View {
    @EnvironmentObject var loc: LocalizationService
    let activity: UCLAPIViewModel.UCLAPIEvent
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // 顶部状态标签
                HStack {
                    // 参与状态
                    if activity.isStudentJoined {
                        ActivityStatusBadge(
                            icon: "checkmark.circle.fill",
                            text: loc.language == .chinese ? "已报名" : "Registered",
                            color: DesignSystem.successColor
                        )
                    }
                    
                    // 推荐标签
                    if activity.isRecommended {
                        ActivityStatusBadge(
                            icon: "sparkles",
                            text: loc.language == .chinese ? "推荐" : "Recommended",
                            color: DesignSystem.secondaryColor
                        )
                    }
                    
                    Spacer()
                    
                    // 活动类型
                    if let category = activity.category {
                        Text(category)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                }
                
                // 活动标题
                Text(activity.title)
                    .font(.headline)
                    .lineLimit(2)
                
                // 时间和地点
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(DesignSystem.primaryColor)
                        Text(activity.startTime, style: .date)
                            .font(.subheadline)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(DesignSystem.primaryColor)
                        Text(activity.startTime, style: .time)
                            .font(.subheadline)
                    }
                    
                    if !activity.location.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                                .foregroundColor(DesignSystem.primaryColor)
                            Text(activity.location)
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                    }
                }
                .foregroundColor(.secondary)
                
                // 活动描述
                if let description = activity.eventDescription {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                // 相关性标签（如果是推荐活动）
                if activity.isRecommended {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption2)
                            .foregroundColor(DesignSystem.warningColor)
                        Text(loc.language == .chinese ? "与学习方向高度相关" : "Highly relevant to major")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(DesignSystem.warningColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(DesignSystem.warningColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 状态标签
struct ActivityStatusBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - 空状态视图
struct EmptyCampusActivitiesView: View {
    @EnvironmentObject var loc: LocalizationService
    let filter: ActivityFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: filter.emptyIcon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(filter.emptyMessage(loc: loc))
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - 筛选枚举
enum ActivityFilter: CaseIterable {
    case all, thisWeek, registered, recommended
    
    var icon: String {
        switch self {
        case .all: return "star.fill"
        case .thisWeek: return "calendar"
        case .registered: return "checkmark.circle.fill"
        case .recommended: return "sparkles"
        }
    }
    
    var emptyIcon: String {
        switch self {
        case .all: return "star.slash"
        case .thisWeek: return "calendar.badge.exclamationmark"
        case .registered: return "person.crop.circle.badge.questionmark"
        case .recommended: return "sparkle.magnifyingglass"
        }
    }
    
    func displayName(loc: LocalizationService) -> String {
        switch self {
        case .all: return loc.language == .chinese ? "全部" : "All"
        case .thisWeek: return loc.language == .chinese ? "本周" : "This Week"
        case .registered: return loc.language == .chinese ? "已参加" : "Registered"
        case .recommended: return loc.language == .chinese ? "推荐" : "Recommended"
        }
    }
    
    func emptyMessage(loc: LocalizationService) -> String {
        switch self {
        case .all: return loc.language == .chinese ? "暂无校园活动" : "No campus activities"
        case .thisWeek: return loc.language == .chinese ? "本周暂无活动" : "No activities this week"
        case .registered: return loc.language == .chinese ? "尚未参加任何活动" : "No registered activities"
        case .recommended: return loc.language == .chinese ? "暂无推荐活动" : "No recommended activities"
        }
    }
}

// MARK: - 为 UCLAPIEvent 添加扩展属性
extension UCLAPIViewModel.UCLAPIEvent {
    // 这些属性应该在你的实际 UCLAPIEvent 模型中添加
    // 这里仅作为示例展示如何使用
    var isStudentJoined: Bool {
        // 实际实现应从数据模型中读取
        // 这里用随机值模拟
        return Bool.random()
    }
    
    var isRecommended: Bool {
        // 实际实现应从数据模型中读取
        // 这里用随机值模拟
        return Bool.random()
    }
    
    var eventDescription: String? {
        return description
    }
    
    var category: String? {
        // 实际实现应从数据模型中读取
        // 基于事件类型返回分类
        if title.lowercased().contains("workshop") {
            return "Workshop"
        } else if title.lowercased().contains("seminar") {
            return "Seminar"
        } else if title.lowercased().contains("social") {
            return "Social"
        }
        return "Event"
    }
}

// MARK: - 活动详情视图
struct ActivityDetailView: View {
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    let activity: UCLAPIViewModel.UCLAPIEvent
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // 标题
                        VStack(alignment: .leading, spacing: 12) {
                            Text(activity.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            // 状态标签
                            HStack(spacing: 8) {
                                if activity.isStudentJoined {
                                    ActivityStatusBadge(
                                        icon: "checkmark.circle.fill",
                                        text: loc.language == .chinese ? "已报名" : "Registered",
                                        color: DesignSystem.successColor
                                    )
                                }
                                
                                if activity.isRecommended {
                                    ActivityStatusBadge(
                                        icon: "sparkles",
                                        text: loc.language == .chinese ? "推荐" : "Recommended",
                                        color: DesignSystem.secondaryColor
                                    )
                                }
                                
                                if let category = activity.category {
                                    Text(category)
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        
                        // 时间和地点信息卡片
                        VStack(alignment: .leading, spacing: 16) {
                            // 日期和时间
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .font(.title3)
                                    .foregroundColor(DesignSystem.primaryColor)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(loc.language == .chinese ? "日期" : "Date")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(activity.startTime, style: .date)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            // 时间
                            HStack(spacing: 12) {
                                Image(systemName: "clock")
                                    .font(.title3)
                                    .foregroundColor(DesignSystem.primaryColor)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(loc.language == .chinese ? "时间" : "Time")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(activity.startTime, style: .time) - \(activity.endTime, style: .time)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            // 地点
                            if !activity.location.isEmpty {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(DesignSystem.primaryColor)
                                        .frame(width: 32)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(loc.language == .chinese ? "地点" : "Location")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(activity.location)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                        
                        // 活动描述
                        if let description = activity.eventDescription {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(loc.language == .chinese ? "活动详情" : "Activity Details")
                                    .font(.headline)
                                
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            )
                        }
                        
                        // 相关性提示（如果是推荐活动）
                        if activity.isRecommended {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.title3)
                                    .foregroundColor(DesignSystem.warningColor)
                                
                                Text(loc.language == .chinese ? "与学习方向高度相关" : "Highly relevant to major")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(DesignSystem.warningColor.opacity(0.1))
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.language == .chinese ? "活动详情" : "Activity Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.language == .chinese ? "完成" : "Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
