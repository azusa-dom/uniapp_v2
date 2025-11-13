//
//  UCLApp.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI

@main
struct uniappApp: App {
    // 注册全局状态
    @StateObject private var appState = AppState()
    @StateObject private var loc = LocalizationService()

    var body: some Scene {
        WindowGroup {
            // 登录逻辑
            // 为演示方便，我们假设已登录
            // 你可以将 appState.isLoggedIn 初始值设为 false 来显示 LoginView
            if appState.isLoggedIn {
                // RootView 是根视图，它会根据 appState.userRole 自动切换
                RootView()
                    .environmentObject(appState)
                    .environmentObject(loc)
            } else {
                // 登录视图 (使用 LoginModule.swift 中的 LoginView)
                LoginView { token in
                    withAnimation(.spring()) {
                        appState.userRole = token.role
                        appState.isLoggedIn = true
                    }
                }
                .environmentObject(appState)
                .environmentObject(loc)
            }
        }
    }
}
