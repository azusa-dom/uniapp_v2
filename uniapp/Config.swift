//
//  Config.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import Foundation

struct Config {
    private static let fallbackGeminiKey = "AIzaSyAxKnZTfa0y7NlMqQ7ljOg1U1NKCMBmqOA"
    
    static var geminiAPIKey: String {
        // 方案1：从 Info.plist 读取
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
              !key.isEmpty,
              key != "YOUR_API_KEY_HERE" else {
            // 如果 Info.plist 中没有配置，返回一个占位符（仅用于开发）
            // ⚠️ 警告：生产环境必须从 Info.plist 配置
            print("⚠️ 警告：请在 Info.plist 中添加 GEMINI_API_KEY")
            return fallbackGeminiKey
        }
        return key
    }
}
