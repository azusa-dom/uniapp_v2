import SwiftUI

@main
struct UCLSmartApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var localizationService = LocalizationService()
    @StateObject private var studentAIViewModel = StudentAIAssistantViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(localizationService)
                .environmentObject(studentAIViewModel)
        }
    }
}

