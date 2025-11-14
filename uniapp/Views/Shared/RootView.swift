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
    @EnvironmentObject var viewModel: UCLAPIViewModel
    
    var body: some View {
        Group {
            if appState.isLoggedIn {
                if appState.userRole == .student {
                    StudentTabView()
                        .environmentObject(viewModel)
                } else {
                    ParentTabView()
                        .environmentObject(viewModel)
                }
            } else {
                LoginView()
            }
        }
        .environment(
            \.locale,
            loc.language == .chinese ? Locale(identifier: "zh_CN") : Locale(identifier: "en_US")
        )
    }
}

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    @State private var selectedRole: UserRole = .student
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6"), Color(hex: "EC4899")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Picker("Language", selection: $loc.language) {
                    ForEach(LocalizationService.Language.allCases) { lang in
                        Text(lang.rawValue).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 60)
                .padding(.top, 20)
                .background(Color.clear)
                .shadow(radius: 5)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text(loc.tr("login_title"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(loc.tr("login_subtitle"))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 40)
                
                VStack(spacing: 20) {
                    Text(loc.tr("login_select_role"))
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        RoleButton(
                            icon: "person.fill",
                            title: loc.tr("login_student"),
                            role: .student,
                            selectedRole: $selectedRole
                        )
                        
                        RoleButton(
                            icon: "person.2.fill",
                            title: loc.tr("login_parent"),
                            role: .parent,
                            selectedRole: $selectedRole
                        )
                    }
                }
                .padding(.bottom, 40)
                
                Button(action: {
                    withAnimation(.spring(response: 0.5)) {
                        appState.userRole = selectedRole
                        appState.isLoggedIn = true
                    }
                }) {
                    Text(selectedRole == .student ? loc.tr("login_button_student") : loc.tr("login_button_parent"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "8B5CF6"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                
                Spacer()
                Spacer()
            }
        }
    }
}

struct RoleButton: View {
    let icon: String
    let title: String
    let role: UserRole
    @Binding var selectedRole: UserRole
    
    private var isSelected: Bool { selectedRole == role }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedRole = role
            }
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(isSelected ? Color(hex: "8B5CF6") : .white)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
    }
}
// 学生端 Tab（5个）
struct StudentTabView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var viewModel: UCLAPIViewModel
    @StateObject private var aiViewModel = StudentAIAssistantViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1. 首页
            StudentDashboardView(selectedTab: $selectedTab)
                .environmentObject(viewModel)
                .tabItem {
                    Label(loc.tr("tab_home"), systemImage: "house.fill")
                }
                .tag(0)
            
            // 2. 活动与日历（合并）
            StudentCalendarView()
                .environmentObject(viewModel)
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

            // 5+. 健康
            StudentHealthView()
                .tabItem {
                    Label("健康", systemImage: "heart.text.square")
                }
                .tag(6)
            
            // 5. 邮箱
            StudentEmailView()
                .tabItem {
                    Label(loc.tr("tab_email"), systemImage: "envelope.fill")
                }
                .tag(4)
        }
        .accentColor(Color(hex: "8B5CF6"))
    }
}

// 家长端 Tab（5个 - 重新设计）
struct ParentTabView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var viewModel: UCLAPIViewModel
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
                .environmentObject(viewModel)
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
                .environmentObject(viewModel)
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
        .accentColor(Color(hex: "6366F1"))
    }
}
