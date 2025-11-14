//
//  RootView.swift
//  uniapp
//
//  Created on 2024.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        Group {
            if appState.isLoggedIn {
                if appState.userRole == .student {
                    StudentTabView()
                } else {
                    ParentTabView()
                }
            } else {
                LoginView { token in
                    withAnimation(.spring()) {
                        appState.userRole = token.role
                        appState.isLoggedIn = true
                    }
                }
            }
        }
        .environment(
            \.locale,
            loc.language == .chinese ? Locale(identifier: "zh_CN") : Locale(identifier: "en_US")
        )
    }
}
// 学生端 Tab（7个）
struct StudentTabView: View {
    @EnvironmentObject var loc: LocalizationService
    @StateObject private var aiViewModel = StudentAIAssistantViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1. 首页
            StudentDashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label(loc.tr("tab_home"), systemImage: "house.fill")
                }
                .tag(0)
            
            // 2. 活动与日历（合并）
            StudentCalendarView()
                .tabItem {
                    Label("活动日历", systemImage: "calendar")
                }
                .tag(1)
            
            // 3. 学业
            StudentAcademicsView()
                .tabItem {
                    Label(loc.tr("tab_academics"), systemImage: "graduationcap.fill")
                }
                .tag(2)
            
            // 4. AI
            StudentAIAssistantView()
                .environmentObject(aiViewModel)
                .tabItem {
                    Label(loc.tr("tab_ai"), systemImage: "sparkles")
                }
                .tag(3)

            // 5. 健康
            StudentHealthView()
                .tabItem {
                    Label("健康", systemImage: "heart.text.square")
                }
                .tag(4)
            
            // 6. 邮箱
            StudentEmailView()
                .tabItem {
                    Label(loc.tr("tab_email"), systemImage: "envelope.fill")
                }
                .tag(5)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
        .accentColor(Color(hex: "8B5CF6"))
    }
}
