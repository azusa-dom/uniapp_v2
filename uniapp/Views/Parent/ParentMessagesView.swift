//
//  ParentMessagesView.swift
//  uniapp
//
//  家长端 - 消息 & AI助手视图（合并）
//

import SwiftUI

struct ParentMessagesView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 分段选择器
                    Picker("", selection: $selectedSegment) {
                        Text(loc.language == .chinese ? "AI助手" : "AI Assistant").tag(0)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // 内容区域 - 目前只有AI助手，可以后续扩展消息功能
                    if selectedSegment == 0 {
                        // 复用现有的 ParentAIAssistantView
                        ParentAIAssistantContentView()
                    }
                }
            }
            .navigationTitle(loc.language == .chinese ? "AI助手" : "AI Assistant")
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

// MARK: - AI助手内容视图（简化版）
struct ParentAIAssistantContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    
    @State private var userInput = ""
    @State private var chatHistory: [AIMessage] = []
    
    // AI 快捷问题
    private let suggestedQuestions: [SuggestedQuestion] = [
        SuggestedQuestion(
            icon: "doc.text.fill",
            questionEN: "How many assignments does she have this week?",
            questionCN: "她这周有多少作业？"
        ),
        SuggestedQuestion(
            icon: "calendar.badge.clock",
            questionEN: "What's her schedule like today?",
            questionCN: "她今天的课程安排是什么样的？"
        ),
        SuggestedQuestion(
            icon: "graduationcap.fill",
            questionEN: "How are her grades this semester?",
            questionCN: "她这学期成绩怎么样？"
        ),
        SuggestedQuestion(
            icon: "heart.fill",
            questionEN: "How is her health condition?",
            questionCN: "她的健康状况如何？"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 聊天历史
            ScrollView {
                VStack(spacing: 20) {
                    if chatHistory.isEmpty {
                        EmptyAIChatView(suggestedQuestions: suggestedQuestions) { question in
                            askQuestion(question)
                        }
                    } else {
                        ForEach(chatHistory) { message in
                            AIMessageView(message: message)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // 输入区域
            HStack(spacing: 12) {
                TextField(loc.language == .chinese ? "向AI助手提问..." : "Ask AI Assistant...",
                          text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    if !userInput.isEmpty {
                        askQuestion(userInput)
                        userInput = ""
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(userInput.isEmpty ? .gray : Color(hex: "6366F1"))
                }
                .disabled(userInput.isEmpty)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
    
    private func askQuestion(_ question: String) {
        // 用户消息
        let userMessage = AIMessage(
            id: UUID(),
            text: question,
            isUser: true,
            timestamp: Date()
        )
        chatHistory.append(userMessage)
        
        // 模拟 AI 响应
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let aiResponse = generateMockResponse(for: question)
            let aiMessage = AIMessage(
                id: UUID(),
                text: aiResponse,
                isUser: false,
                timestamp: Date()
            )
            withAnimation {
                chatHistory.append(aiMessage)
            }
        }
    }
    
    private func generateMockResponse(for question: String) -> String {
        // 简单的模拟响应
        if question.lowercased().contains("assignment") || question.contains("作业") {
            return loc.language == .chinese
                ? "根据学业记录，\(appState.studentName) 本周有 3 个待完成作业。"
                : "\(appState.studentName) has 3 pending assignments this week."
        } else if question.lowercased().contains("schedule") || question.contains("课程") {
            return loc.language == .chinese
                ? "今天 \(appState.studentName) 有两节课：深度学习（10:00-12:00）和医学统计（14:00-16:00）。"
                : "Today \(appState.studentName) has two classes: Deep Learning (10:00-12:00) and Medical Statistics (14:00-16:00)."
        } else if question.lowercased().contains("grade") || question.contains("成绩") {
            return loc.language == .chinese
                ? "\(appState.studentName) 这学期的成绩表现不错！平均分是 72.5，属于一等荣誉等级。"
                : "\(appState.studentName) is doing well this semester! Her average grade is 72.5, First Class Honours level."
        } else {
            return loc.language == .chinese
                ? "我已经查看了 \(appState.studentName) 的相关信息。您还有什么想了解的吗？"
                : "I've reviewed \(appState.studentName)'s information. Is there anything specific you'd like to know?"
        }
    }
}

// MARK: - 空 AI 聊天视图
struct EmptyAIChatView: View {
    @EnvironmentObject var loc: LocalizationService
    let suggestedQuestions: [SuggestedQuestion]
    let onQuestionTap: (String) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // AI 图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text(loc.language == .chinese ? "AI 家长助手" : "AI Parent Assistant")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(loc.language == .chinese ? "我可以帮您了解孩子的学业、健康和校园生活" : "I can help you understand your child's academics, health, and campus life")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // 建议问题
            VStack(alignment: .leading, spacing: 12) {
                Text(loc.language == .chinese ? "试试这些问题：" : "Try asking:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                ForEach(suggestedQuestions) { question in
                    Button(action: {
                        onQuestionTap(loc.language == .chinese ? question.questionCN : question.questionEN)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: question.icon)
                                .font(.title3)
                                .foregroundColor(Color(hex: "6366F1"))
                                .frame(width: 30)
                            
                            Text(loc.language == .chinese ? question.questionCN : question.questionEN)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .glassCard()
                    }
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - AI 消息视图
struct AIMessageView: View {
    let message: AIMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if !message.isUser {
                        Image(systemName: "brain.head.profile")
                            .font(.caption)
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                    
                    Text(message.text)
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            message.isUser ?
                            LinearGradient(colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [Color.gray.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(message.isUser ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

// MARK: - 数据模型
struct SuggestedQuestion: Identifiable {
    let id = UUID()
    let icon: String
    let questionEN: String
    let questionCN: String
}

struct AIMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
}

// MARK: - Preview
#Preview {
    ParentMessagesView()
        .environmentObject(AppState())
        .environmentObject(LocalizationService())
}
