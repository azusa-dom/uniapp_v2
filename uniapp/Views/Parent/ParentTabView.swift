//
//  ParentTabView.swift
//  uniapp
//
//  Created by Claude
//  家长端Tab导航结构
//

import SwiftUI

struct ParentTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @StateObject private var uclVM = UCLAPIViewModel()

    @State private var selectedTab = 0

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
    }
}

#Preview {
    ParentTabView()
        .environmentObject(AppState())
        .environmentObject(LocalizationService())
}
