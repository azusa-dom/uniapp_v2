// MARK: - ParentMessagesView.swift
// 文件位置: uniapp/Views/Parent/ParentMessagesView.swift

import SwiftUI

struct ParentMessagesView: View {
    @EnvironmentObject var loc: LocalizationService
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient
                    .ignoresSafeArea()
                
                // 直接显示 AI 助手内容
                ParentAIAssistantContentView()
            }
            .navigationTitle(loc.language == .chinese ? "AI 助手" : "AI Assistant")
        }
    }
}

// MARK: - AI助手内容视图
struct ParentAIAssistantContentView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    
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
            questionEN: "Is she taking her medications regularly?",
            questionCN: "她有按时服药吗？"
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
                        .foregroundColor(userInput.isEmpty ? .gray : DesignSystem.primaryColor)
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
        // 简单的模拟响应 - 实际应接入真实 AI
        if question.lowercased().contains("assignment") || question.contains("作业") {
            return loc.language == .chinese
                ? "根据学业记录，\(appState.studentName) 本周有 3 个待完成作业：深度学习期末项目（14天后截止）、统计分析报告（7天后截止），以及一个小组演示准备。"
                : "\(appState.studentName) has 3 pending assignments this week: Deep Learning Final Project (due in 14 days), Statistical Analysis Report (due in 7 days), and a group presentation preparation."
        } else if question.lowercased().contains("schedule") || question.contains("课程") {
            return loc.language == .chinese
                ? "今天 \(appState.studentName) 有两节课：上午10点-12点是深度学习课（罗伯茨楼309室），下午2点-4点是医学统计课（十字楼LT1）。"
                : "Today \(appState.studentName) has two classes: Deep Learning from 10:00-12:00 (Roberts Building, Room 309) and Medical Statistics from 14:00-16:00 (Cruciform Building, LT1)."
        } else if question.lowercased().contains("grade") || question.contains("成绩") {
            return loc.language == .chinese
                ? "\(appState.studentName) 这学期的成绩表现不错！平均分是 72.5，属于一等荣誉等级。深度学习课程得了 78 分，医学统计 72 分，健康信息学 68 分。"
                : "\(appState.studentName) is doing well this semester! Her average grade is 72.5, which is First Class Honours level. She scored 78 in Deep Learning, 72 in Medical Statistics, and 68 in Health Informatics."
        } else if question.lowercased().contains("medication") || question.contains("服药") {
            return loc.language == .chinese
                ? "根据用药打卡记录，\(appState.studentName) 本周的服药完成率是 85%（7天中完成了6天）。她正在按照医嘱服用阿达木单抗生物制剂和对乙酰氨基酚。"
                : "According to medication logs, \(appState.studentName) has an 85% adherence rate this week (6 out of 7 days). She's taking Adalimumab (biologic) and Paracetamol as prescribed."
        } else {
            return loc.language == .chinese
                ? "我已经查看了 \(appState.studentName) 的相关信息。您还有什么想了解的吗？我可以帮您查看她的学业、课表、健康记录等信息。"
                : "I've reviewed \(appState.studentName)'s information. Is there anything specific you'd like to know? I can help you check her academics, schedule, health records, and more."
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
                    .fill(DesignSystem.primaryGradient)
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
                                .foregroundColor(DesignSystem.primaryColor)
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
                            .foregroundColor(DesignSystem.primaryColor)
                    }
                    
                    Text(message.text)
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(message.isUser ? DesignSystem.primaryGradient : LinearGradient(colors: [Color.gray.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
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

