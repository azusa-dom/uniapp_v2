//
//  ParentCampusView.swift
//  uniapp
//
//  家长端 - 校园生活视图
//

import SwiftUI

struct ParentCampusView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var viewModel: UCLAPIViewModel
    
    @State private var selectedFilter: ActivityFilter = .all
    
    var filteredActivities: [UCLAPIEvent] {
        switch selectedFilter {
        case .all:
            return viewModel.events
        case .thisWeek:
            let weekFromNow = Date().addingTimeInterval(7*24*3600)
            return viewModel.events.filter { $0.startDate >= Date() && $0.startDate <= weekFromNow }
        case .recommended:
            return viewModel.events.filter { $0.isRecommended }
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
                                    CampusActivityCard(activity: activity)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle(loc.language == .chinese ? "校园活动" : "Campus Activities")
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
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
                    FilterChip(
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
struct FilterChip: View {
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
            .foregroundColor(isSelected ? .white : Color(hex: "6366F1"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? LinearGradient(colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - 校园统计卡片
struct CampusStatsCard: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var viewModel: UCLAPIViewModel
    
    private var totalActivities: Int {
        viewModel.events.count
    }
    
    private var recommendedActivities: Int {
        viewModel.events.filter { $0.isRecommended }.count
    }
    
    var body: some View {
        HStack(spacing: 12) {
            CampusStatItem(
                icon: "star.fill",
                value: "\(totalActivities)",
                label: loc.language == .chinese ? "全部活动" : "Total",
                color: Color(hex: "6366F1")
            )
            
            Divider()
            
            CampusStatItem(
                icon: "sparkles",
                value: "\(recommendedActivities)",
                label: loc.language == .chinese ? "推荐" : "Recommended",
                color: Color(hex: "8B5CF6")
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
struct CampusActivityCard: View {
    @EnvironmentObject var loc: LocalizationService
    let activity: UCLAPIEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 顶部状态标签
            HStack {
                // 推荐标签
                if activity.isRecommended {
                    StatusBadge(
                        icon: "sparkles",
                        text: loc.language == .chinese ? "推荐" : "Recommended",
                        color: Color(hex: "8B5CF6")
                    )
                }
                
                Spacer()
                
                // 活动类型
                if !activity.eventType.isEmpty {
                    Text(activity.eventType.capitalized)
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
                        .foregroundColor(Color(hex: "6366F1"))
                    Text(activity.startDate, style: .date)
                        .font(.subheadline)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(Color(hex: "6366F1"))
                    Text(activity.startDate, style: .time)
                        .font(.subheadline)
                }
                
                if let location = activity.location {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(Color(hex: "6366F1"))
                        Text(location)
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
                        .foregroundColor(Color(hex: "F59E0B"))
                    Text(loc.language == .chinese ? "与学习方向高度相关" : "Highly relevant to major")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(Color(hex: "F59E0B"))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(hex: "F59E0B").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .glassCard()
    }
}

// MARK: - 状态标签
struct StatusBadge: View {
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
    case all, thisWeek, recommended
    
    var icon: String {
        switch self {
        case .all: return "star.fill"
        case .thisWeek: return "calendar"
        case .recommended: return "sparkles"
        }
    }
    
    var emptyIcon: String {
        switch self {
        case .all: return "star.slash"
        case .thisWeek: return "calendar.badge.exclamationmark"
        case .recommended: return "sparkle.magnifyingglass"
        }
    }
    
    func displayName(loc: LocalizationService) -> String {
        switch self {
        case .all: return loc.language == .chinese ? "全部" : "All"
        case .thisWeek: return loc.language == .chinese ? "本周" : "This Week"
        case .recommended: return loc.language == .chinese ? "推荐" : "Recommended"
        }
    }
    
    func emptyMessage(loc: LocalizationService) -> String {
        switch self {
        case .all: return loc.language == .chinese ? "暂无校园活动" : "No campus activities"
        case .thisWeek: return loc.language == .chinese ? "本周暂无活动" : "No activities this week"
        case .recommended: return loc.language == .chinese ? "暂无推荐活动" : "No recommended activities"
        }
    }
}

// MARK: - Preview
#Preview {
    ParentCampusView()
        .environmentObject(LocalizationService())
        .environmentObject(UCLAPIViewModel())
}
