//
//  StudentProfileView.swift
//  uniapp
//


import SwiftUI

struct StudentProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @State private var showingLanguageSheet = false
    @State private var showingAvatarPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex:"F8FAFC"), Color(hex:"F1F5F9"), Color(hex:"E0E7FF").opacity(0.3)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 个人资料头部
                        ProfileHeaderCard(showingAvatarPicker: $showingAvatarPicker)
                            .environmentObject(appState)
                            .environmentObject(loc)

                        // 设置卡片
                        SettingsCard(showingLanguageSheet: $showingLanguageSheet)
                            .environmentObject(loc)

                        // 数据共享
                        DataSharingCard()
                            .environmentObject(appState)
                            .environmentObject(loc)

                        // 退出登录
                        LogoutCard()
                            .environmentObject(appState)
                            .environmentObject(loc)

                        // 角色切换
                        RoleSwitchCard()
                            .environmentObject(appState)
                            .environmentObject(loc)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(loc.tr("profile_title"))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingLanguageSheet) {
                LanguageSelectionSheet()
                    .environmentObject(loc)
            }
            .sheet(isPresented: $showingAvatarPicker) {
                AvatarPickerView(selectedIcon: $appState.avatarIcon)
                    .environmentObject(loc)
            }
        }
    }
}

// MARK: - 个人资料头部卡片
struct ProfileHeaderCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @Binding var showingAvatarPicker: Bool

    var body: some View {
        VStack(spacing: 20) {
            Button { showingAvatarPicker = true } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color(hex:"8B5CF6").opacity(0.3), Color(hex:"EC4899").opacity(0.3)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 10)

                    Circle()
                        .fill(
                            LinearGradient(colors: [Color(hex:"8B5CF6"), Color(hex:"EC4899")],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: appState.avatarIcon)
                                .font(.system(size: 45, weight: .medium))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color(hex:"8B5CF6").opacity(0.4), radius: 15, x: 0, y: 8)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex:"8B5CF6"))
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .offset(x: 35, y: 35)
                }
            }
            .buttonStyle(ScaleButtonStyle())

            VStack(spacing: 8) {
                Text(appState.studentName.isEmpty ? "Zoya Huo" : appState.studentName)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                Text(appState.studentProgram.isEmpty ? "MSc Health Data Science" : appState.studentProgram)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    Image(systemName: "number").font(.system(size: 12)).foregroundColor(Color(hex:"8B5CF6"))
                    Text("\(loc.tr("profile_student_id")) \(appState.studentId.isEmpty ? "20241234" : appState.studentId)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color(hex:"8B5CF6").opacity(0.1)))
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
                            LinearGradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
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
            SettingsRow(icon: "globe", iconColor: Color(hex:"3B82F6"),
                        title: loc.tr("profile_language"),
                        value: loc.language.rawValue) { showingLanguageSheet = true }

            Divider().padding(.leading, 56)

            SettingsRow(icon: "bell.fill", iconColor: Color(hex:"F59E0B"),
                        title: loc.tr("profile_notifications"), value: loc.tr("on")) {}

            Divider().padding(.leading, 56)

            SettingsRow(icon: "lock.shield.fill", iconColor: Color(hex:"10B981"),
                        title: loc.tr("profile_privacy"), value: "") {}
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.3), lineWidth: 1))
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
        )
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let action: ()->Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(iconColor.opacity(0.15)).frame(width: 40, height: 40)
                    Image(systemName: icon).font(.system(size: 18, weight: .semibold)).foregroundColor(iconColor)
                }
                Text(title).font(.system(size: 16, weight: .medium))
                Spacer()
                if !value.isEmpty {
                    Text(value).font(.system(size: 15)).foregroundColor(.secondary)
                }
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 数据共享卡片
struct DataSharingCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill").font(.system(size: 18)).foregroundColor(Color(hex:"8B5CF6"))
                Text(loc.tr("data_sharing_title")).font(.system(size: 18, weight: .bold))
            }
            .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $appState.shareGrades) {
                    HStack(spacing: 12) {
                        Image(systemName: "graduationcap.fill").foregroundColor(Color(hex:"3B82F6"))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.tr("data_sharing_grades")).font(.system(size: 15, weight: .semibold))
                            Text(loc.tr("data_sharing_grades_desc")).font(.system(size: 13)).foregroundColor(.secondary)
                        }
                    }
                }
                .tint(Color(hex:"8B5CF6"))
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.5)))

            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $appState.shareCalendar) {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar").foregroundColor(Color(hex:"F59E0B"))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.tr("data_sharing_calendar")).font(.system(size: 15, weight: .semibold))
                            Text(loc.tr("data_sharing_calendar_desc")).font(.system(size: 13)).foregroundColor(.secondary)
                        }
                    }
                }.tint(Color(hex:"8B5CF6"))
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.5)))

            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill").font(.system(size: 12)).foregroundColor(Color(hex:"8B5CF6").opacity(0.7))
                Text(loc.tr("data_sharing_desc")).font(.system(size: 12)).foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.3), lineWidth: 1))
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
        Button { showingAlert = true } label: {
            HStack(spacing: 12) {
                Image(systemName:"rectangle.portrait.and.arrow.right").foregroundColor(Color(hex:"EF4444")).font(.system(size: 18, weight: .semibold))
                Text(loc.tr("profile_logout")).foregroundColor(Color(hex:"EF4444")).font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex:"EF4444").opacity(0.05))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex:"EF4444").opacity(0.3), lineWidth: 1.5))
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .alert(loc.tr("profile_logout_confirm"), isPresented: $showingAlert) {
            Button(loc.tr("cancel"), role: .cancel) {}
            Button(loc.tr("profile_logout"), role: .destructive) {
                withAnimation(.spring(response: 0.4)) { appState.isLoggedIn = false }
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
        Button {
            withAnimation(.spring(response: 0.4)) {
                appState.userRole = appState.userRole == .student ? .parent : .student
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "arrow.left.arrow.right.circle.fill").font(.system(size: 22)).foregroundColor(.white)
                Text(appState.userRole == .student ? loc.tr("profile_switch_parent") : loc.tr("profile_switch_student"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundColor(.white.opacity(0.7))
            }
            .padding(18)
            .background(LinearGradient(colors: [Color(hex:"8B5CF6"), Color(hex:"6366F1")], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex:"8B5CF6").opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - 语言选择弹窗
struct LanguageSelectionSheet: View {
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                let backgroundColor = Color(hex:"F8FAFC")
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(LocalizationService.Language.allCases) { language in
                            languageButton(for: language)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.tr("language_selection_title"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func languageButton(for language: LocalizationService.Language) -> some View {
        let isSelected = loc.language == language
        let circleColor = isSelected ? Color(hex:"8B5CF6").opacity(0.15) : Color.gray.opacity(0.1)
        let textColor = isSelected ? Color(hex:"8B5CF6") : Color.secondary
        
        Button {
            withAnimation(.spring(response: 0.3)) {
                loc.language = language
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                dismiss()
            }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 44, height: 44)
                    Text(language == .chinese ? "中" : "EN")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(textColor)
                }
                Text(language.rawValue)
                    .font(.system(size: 17, weight: .medium))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex:"8B5CF6"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(hex:"8B5CF6").opacity(0.05) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color(hex:"8B5CF6").opacity(0.3) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - 头像选择器（与设置页共享）
struct AvatarPickerView: View {
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: String

    private let avatars = [
        "person.fill","person.circle.fill","graduationcap.fill",
        "face.smiling.fill","brain.head.profile","star.fill",
        "sun.max.fill","moon.fill","laptopcomputer",
        "heart.fill","bolt.fill","leaf.fill"
    ]
    private let columns = [GridItem(.adaptive(minimum: 85), spacing: 16)]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex:"F8FAFC").ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(avatars, id: \.self) { icon in
                            Button {
                                withAnimation(.spring(response: 0.3)) { selectedIcon = icon }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { dismiss() }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill( selectedIcon == icon
                                               ? LinearGradient(colors: [Color(hex:"8B5CF6"), Color(hex:"EC4899")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                               : LinearGradient(colors: [Color.gray.opacity(0.15)], startPoint: .top, endPoint: .bottom)
                                        )
                                        .frame(width: 85, height: 85)
                                    Image(systemName: icon).font(.system(size: 38))
                                        .foregroundColor(selectedIcon == icon ? .white : .secondary)
                                    if selectedIcon == icon {
                                        Circle().fill(Color.white).frame(width: 28, height: 28)
                                            .overlay(Image(systemName:"checkmark").font(.system(size: 14, weight: .bold)).foregroundColor(Color(hex:"8B5CF6")))
                                            .offset(x: 28, y: -28)
                                    }
                                }
                                .shadow(color: selectedIcon == icon ? Color(hex:"8B5CF6").opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(loc.tr("profile_select_avatar"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.tr("done")) { dismiss() }
                        .foregroundColor(Color(hex:"8B5CF6"))
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - 缩放按钮样式
// ✅ ScaleButtonStyle 现在定义在 Color+Extensions.swift 中

