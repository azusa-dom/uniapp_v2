//
//  StudentProfileView.swift
//  uniapp
//
//  完美设计版 - 所有功能完整
//

import SwiftUI

struct StudentProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @State private var showingLanguageSheet = false
    @State private var showingAvatarPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 优雅的背景渐变
                LinearGradient(
                    colors: [
                        Color(hex: "F8FAFC"),
                        Color(hex: "F1F5F9"),
                        Color(hex: "E0E7FF").opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 个人资料头部
                        ProfileHeaderCard(showingAvatarPicker: $showingAvatarPicker)
                        
                        // 设置卡片
                        SettingsCard(showingLanguageSheet: $showingLanguageSheet)
                        
                        // 数据共享
                        DataSharingCard()
                        
                        // 退出登录
                        LogoutCard()
                        
                        // 角色切换
                        RoleSwitchCard()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(loc.tr("profile_title"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .sheet(isPresented: $showingLanguageSheet) {
                LanguageSelectionSheet()
            }
            .sheet(isPresented: $showingAvatarPicker) {
                AvatarPickerView(selectedIcon: $appState.avatarIcon)
            }
        }
    }
}

// MARK: - 个人资料头部卡片
struct ProfileHeaderCard: View {
    @EnvironmentObject var appState: AppState
    @Binding var showingAvatarPicker: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // 头像按钮
            Button(action: {
                showingAvatarPicker = true
            }) {
                ZStack {
                    // 外圈光晕
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "8B5CF6").opacity(0.3),
                                    Color(hex: "EC4899").opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 10)
                    
                    // 主头像
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "8B5CF6"),
                                    Color(hex: "EC4899")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: appState.avatarIcon)
                                .font(.system(size: 45, weight: .medium))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color(hex: "8B5CF6").opacity(0.4), radius: 15, x: 0, y: 8)
                    
                    // 编辑按钮
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "8B5CF6"))
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .offset(x: 35, y: 35)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
            // 用户信息
            VStack(spacing: 8) {
                Text("Zoya Huo")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("MSc Health Data Science")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                
                // 学号标签
                HStack(spacing: 6) {
                    Image(systemName: "number")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B5CF6"))
                    
                    Text("Student ID: 20241234")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(hex: "8B5CF6").opacity(0.1))
                )
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
        )
    }
}

// MARK: - 设置卡片
struct SettingsCard: View {
    @EnvironmentObject var loc: LocalizationService
    @Binding var showingLanguageSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            SettingsRow(
                icon: "globe",
                iconColor: Color(hex: "3B82F6"),
                title: loc.tr("profile_language"),
                value: loc.language.rawValue,
                action: { showingLanguageSheet = true }
            )
            
            Divider()
                .padding(.leading, 56)
            
            SettingsRow(
                icon: "bell.fill",
                iconColor: Color(hex: "F59E0B"),
                title: loc.tr("profile_notifications"),
                value: loc.tr("on"),
                action: {}
            )
            
            Divider()
                .padding(.leading, 56)
            
            SettingsRow(
                icon: "lock.shield.fill",
                iconColor: Color(hex: "10B981"),
                title: loc.tr("profile_privacy"),
                value: "",
                action: {}
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
        )
    }
}

// MARK: - 设置行组件
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                // 标题
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 值
                if !value.isEmpty {
                    Text(value)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 数据共享卡片
struct DataSharingCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "8B5CF6"))
                
                Text(loc.tr("data_sharing_title"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 4)
            
            // 成绩共享
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $appState.shareGrades) {
                    HStack(spacing: 12) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "3B82F6"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.tr("data_sharing_grades"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("与家长共享成绩信息")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(Color(hex: "8B5CF6"))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.5))
            )
            
            // 日历共享
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $appState.shareCalendar) {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "F59E0B"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.tr("data_sharing_calendar"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("与家长共享日程安排")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(Color(hex: "8B5CF6"))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.5))
            )
            
            // 说明文字
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "8B5CF6").opacity(0.7))
                
                Text(loc.tr("data_sharing_desc"))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
        )
    }
}

// MARK: - 退出登录卡片
struct LogoutCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @State private var showingAlert = false
    
    var body: some View {
        Button(action: {
            showingAlert = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "EF4444"))
                
                Text(loc.tr("profile_logout"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "EF4444"))
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "EF4444").opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "EF4444").opacity(0.3), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .alert(loc.tr("profile_logout_confirm"), isPresented: $showingAlert) {
            Button(loc.tr("cancel"), role: .cancel) {}
            Button(loc.tr("profile_logout"), role: .destructive) {
                withAnimation(.spring(response: 0.4)) {
                    appState.isLoggedIn = false
                }
            }
        } message: {
            Text(loc.tr("profile_logout_message"))
        }
    }
}

// MARK: - 角色切换卡片
struct RoleSwitchCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4)) {
                appState.userRole = appState.userRole == .student ? .parent : .student
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                
                Text(appState.userRole == .student ? loc.tr("profile_switch_parent") : loc.tr("profile_switch_student"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(18)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "8B5CF6"),
                        Color(hex: "6366F1")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "8B5CF6").opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - 语言选择弹窗
struct LanguageSelectionSheet: View {
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F8FAFC").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(LocalizationService.Language.allCases) { language in
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    loc.language = language
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    dismiss()
                                }
                            }) {
                                HStack(spacing: 16) {
                                    // 语言图标
                                    ZStack {
                                        Circle()
                                            .fill(loc.language == language ?
                                                  Color(hex: "8B5CF6").opacity(0.15) :
                                                  Color.gray.opacity(0.1))
                                            .frame(width: 44, height: 44)
                                        
                                        Text(language == .chinese ? "中" : "EN")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(loc.language == language ?
                                                           Color(hex: "8B5CF6") :
                                                           .secondary)
                                    }
                                    
                                    // 语言名称
                                    Text(language.rawValue)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    // 选中标记
                                    if loc.language == language {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(hex: "8B5CF6"))
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(loc.language == language ?
                                              Color(hex: "8B5CF6").opacity(0.05) :
                                              Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(loc.language == language ?
                                                       Color(hex: "8B5CF6").opacity(0.3) :
                                                       Color.clear,
                                                       lineWidth: 2)
                                        )
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("选择语言")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(loc.tr("done")) {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "8B5CF6"))
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - 头像选择器
struct AvatarPickerView: View {
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    @Binding var selectedIcon: String
    
    let avatars = [
        "person.fill", "person.circle.fill", "graduationcap.fill",
        "face.smiling.fill", "brain.head.profile", "star.fill",
        "sun.max.fill", "moon.fill", "laptopcomputer",
        "heart.fill", "bolt.fill", "leaf.fill"
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 85), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F8FAFC").ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(avatars, id: \.self) { icon in
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedIcon = icon
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    dismiss()
                                }
                            }) {
                                ZStack {
                                    // 背景
                                    Circle()
                                        .fill(
                                            selectedIcon == icon ?
                                            LinearGradient(
                                                colors: [Color(hex: "8B5CF6"), Color(hex: "EC4899")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                colors: [Color.gray.opacity(0.15)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(width: 85, height: 85)
                                    
                                    // 图标
                                    Image(systemName: icon)
                                        .font(.system(size: 38))
                                        .foregroundColor(selectedIcon == icon ? .white : .secondary)
                                    
                                    // 选中标记
                                    if selectedIcon == icon {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 28, height: 28)
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(Color(hex: "8B5CF6"))
                                            )
                                            .offset(x: 28, y: -28)
                                    }
                                }
                                .shadow(color: selectedIcon == icon ?
                                       Color(hex: "8B5CF6").opacity(0.3) :
                                       .clear,
                                       radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(loc.tr("profile_select_avatar"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(loc.tr("done")) {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "8B5CF6"))
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - 缩放按钮样式
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
