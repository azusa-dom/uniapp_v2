//
//  CampusActivitiesView.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI

// MARK: - 校园活动主视图
struct CampusActivitiesView: View {
    @EnvironmentObject var loc: LocalizationService
    @State private var selectedType: String = "全部"
    
    private let activityData = CampusActivityData.shared
    
    var filteredActivities: [CampusActivity] {
        if selectedType == "全部" {
            return activityData.activities
        } else {
            return activityData.activities.filter { $0.type.rawValue == selectedType }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Filter Pills
                    filterPillsSection
                    
                    // Activities List
                    activitiesListSection
                }
            }
            .navigationTitle("🎯 校园活动")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("发现精彩的UCL校园活动")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            Color.white.opacity(0.9)
                .blur(radius: 10)
        )
    }
    
    // MARK: - Filter Pills Section
    private var filterPillsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(activityData.activityTypes, id: \.self) { type in
                    FilterPill(
                        title: type,
                        isSelected: selectedType == type,
                        color: activityData.getTypeColor(for: type)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedType = type
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Activities List Section
    @ViewBuilder
    private var activitiesListSection: some View {
        if filteredActivities.isEmpty {
            emptyStateView
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredActivities) { activity in
                        CampusActivityCard(activity: activity)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "F59E0B").opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Text("✨")
                    .font(.system(size: 40))
            }
            
            Text("暂无该类型的活动")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("稍后再来看看吧")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Filter Pill Component
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let color: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.white.opacity(0.8)
                        }
                    }
                )
                .clipShape(Capsule())
                .shadow(color: isSelected ? Color(hex: "6366F1").opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Activity Card Component
struct CampusActivityCard: View {
    let activity: CampusActivity
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Time Indicator
            timeIndicator
            
            // Content
            contentSection
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Time Indicator
    private var timeIndicator: some View {
        VStack(spacing: 4) {
            Text(activity.startTime)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: activity.typeColor))
            
            if let endTime = activity.endTime {
                Rectangle()
                    .fill(Color(hex: activity.typeColor).opacity(0.3))
                    .frame(width: 2, height: 20)
                
                Text(endTime)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 60)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and Icon
            HStack(alignment: .top, spacing: 12) {
                Text(activity.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: activity.typeColor).opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: activity.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: activity.typeColor))
                }
            }
            
            // Type Badge
            Text(activity.type.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: activity.typeColor))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(hex: activity.typeColor).opacity(0.1))
                .clipShape(Capsule())
            
            // Location
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: activity.typeColor))
                
                Text(activity.location)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Description
            Text(activity.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
struct CampusActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        CampusActivitiesView()
            .environmentObject(LocalizationService())
    }
}
