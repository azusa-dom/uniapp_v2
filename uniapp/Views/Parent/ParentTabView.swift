//
//  ParentTabView.swift
//  uniapp
//
//  Created by 748 on 14/11/2025.
//
// MARK: - ParentTabView.swift
// 文件位置: uniapp/Views/Parent/ParentTabView.swift

import SwiftUI

struct ParentTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @StateObject private var uclVM = UCLAPIViewModel()
    @StateObject private var activitiesService = UCLActivitiesService()
    
    @State private var selectedTab = 0
    @State private var hasLoadedActivities = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 首页
            ParentDashboardView()
                .tabItem {
                    Label(loc.language == .chinese ? "首页" : "Home",
                          systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 2: 学业 & 课表
            ParentAcademicsView()
                .tabItem {
                    Label(loc.language == .chinese ? "学业" : "Academics",
                          systemImage: "book.fill")
                }
                .tag(1)
            
            // Tab 3: 健康 & 就医
            ParentHealthView()
                .tabItem {
                    Label(loc.language == .chinese ? "健康" : "Health",
                          systemImage: "heart.fill")
                }
                .tag(2)
            
            // Tab 4: 校园生活
            ParentCampusView()
                .tabItem {
                    Label(loc.language == .chinese ? "活动" : "Campus",
                          systemImage: "star.fill")
                }
                .tag(3)
            
            // Tab 5: 消息 & AI
            ParentMessagesView()
                .tabItem {
                    Label(loc.language == .chinese ? "消息" : "Messages",
                          systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(4)
        }
        .environmentObject(uclVM)
        .accentColor(DesignSystem.primaryColor)
        .onAppear {
            loadCampusActivities()
        }
    }
    
    // MARK: - 加载校园活动数据
    private func loadCampusActivities() {
        // 避免重复添加
        guard !hasLoadedActivities else { return }
        
        // 加载活动数据
        if activitiesService.activities.isEmpty {
            activitiesService.loadActivities()
            // 等待数据加载完成（异步加载）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                convertAndAddActivities()
            }
        } else {
            convertAndAddActivities()
        }
    }
    
    // MARK: - 转换并添加活动数据
    private func convertAndAddActivities() {
        guard !hasLoadedActivities else { return }
        
        let isChinese = loc.language == .chinese
        
        // 直接从 MockData.activities 加载并转换（与学生端保持一致）
        let activityEvents = MockData.activities.map { activity in
            return UCLAPIViewModel.UCLAPIEvent(
                id: UUID(uuidString: activity.id) ?? UUID(),
                title: activity.localizedTitle(isChinese: isChinese),
                startTime: activity.startDate,
                endTime: activity.endDate,
                location: activity.localizedLocation(isChinese: isChinese),
                type: .manual,
                description: activity.localizedDescription(isChinese: isChinese),
                recurrenceRule: nil,
                reminderTime: .fifteenMin
            )
        }
        
        // 添加到 uclVM.events
        // 注意：这里只添加活动数据，课程数据由 TimetableViewModel 在 ParentAcademicDetailView 中管理
        uclVM.events.append(contentsOf: activityEvents)
        hasLoadedActivities = true
    }
}

