//
//  ChatMessage.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import Foundation
import SwiftUI

// MARK: - AI 聊天
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var timestamp: Date = Date()
}
