//
//  ParentSettingsView.swift
//  uniapp
//
//  Created on 2024.
//

import SwiftUI

private struct ParentGlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

private extension View {
    func parentGlassCard() -> some View {
        modifier(ParentGlassCardModifier())
    }
}

private let parentBackgroundGradient = LinearGradient(
    colors: [Color(hex: "F8FAFC"), Color(hex: "F1F5F9")],
    startPoint: .top,
    endPoint: .bottom
)

// ✅ 家长设置 (无修改)
struct ParentSettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                parentBackgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ParentLanguageSelectionSection()
                        
                        ParentDataSharingStatusCard()
                        
                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "bell.fill",
                                iconColor: Color(hex: "6366F1"),
                                title: loc.tr("parent_email_notifications"),
                                value: loc.tr("on"),
                                action: {}
                            )
                            Divider().padding(.leading, 50)
                            SettingsRow(
                                icon: "bell.badge.fill",
                                iconColor: Color(hex: "F59E0B"),
                                title: loc.tr("parent_important_alerts"),
                                value: loc.tr("on"),
                                action: {}
                            )
                            Divider().padding(.leading, 50)
                            SettingsRow(
                                icon: "clock.fill",
                                iconColor: Color(hex: "10B981"),
                                title: loc.tr("parent_daily_summary"),
                                value: "8:00 AM",
                                action: {}
                            )
                        }
                        .parentGlassCard()
                        
                        RoleSwitchCard()
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.tr("tab_parent_settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(loc.tr("done")) {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "6366F1"))
                }
            }
        }
    }
}

private struct ParentLanguageSelectionSection: View {
    @EnvironmentObject var loc: LocalizationService
    private let languages = LocalizationService.Language.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc.tr("profile_language"))
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(Array(languages.enumerated()), id: \.element) { index, language in
                    languageButton(for: language)
                    
                    if index < languages.count - 1 {
                        Divider().padding(.leading, 20)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func languageButton(for language: LocalizationService.Language) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                loc.language = language
            }
        }) {
            HStack {
                Text(language.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                if loc.language == language {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color(hex: "6366F1"))
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
        }
    }
}
struct ParentDataSharingStatusCard: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.tr("parent_data_sharing_status"))
                .font(.headline)
                .padding(.bottom, 8)
            
            HStack {
                Text(loc.tr("data_sharing_grades"))
                Spacer()
                Text(appState.shareGrades ? "On" : "Off")
                    .foregroundColor(appState.shareGrades ? .green : .red)
                    .fontWeight(.medium)
            }
            
            Divider()
            
            HStack {
                Text(loc.tr("data_sharing_calendar"))
                Spacer()
                Text(appState.shareCalendar ? "On" : "Off")
                    .foregroundColor(appState.shareCalendar ? .green : .red)
                    .fontWeight(.medium)
            }
            
            Text(loc.tr("parent_data_sharing_controlled"))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .parentGlassCard()
    }
}
