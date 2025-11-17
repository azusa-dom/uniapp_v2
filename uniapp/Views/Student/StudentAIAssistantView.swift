import SwiftUI

// MARK: - 学生端 AI 助手 ViewModel
@MainActor
class StudentAIAssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isProcessing = false
    @Published var isConfigured = false
    
    private let presetAnswers: [String: String] = [
        "我有哪些即将到期的作业？": "以下是未来一周的作业：\n• 数据方法报告：11 月 10 日\n• AI 模型训练：11 月 12 日\n• Python Lab 6：11 月 13 日\n建议先完成数据方法报告。",
        "帮我总结一下未读邮件": "你有 3 封未读邮件：\n1. 学院通知：讲座教室改到 Roberts 106\n2. 图书馆提醒：11 月 14 日前归还《Deep Learning》\n3. Career Service：Google 校园宣讲报名截止 11 月 15 日中午"
    ]
    
    init() {
        isConfigured = !Config.deepSeekAPIKey.isEmpty
    }
    
    func sendMessage(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMessage = ChatMessage(text: trimmed, isUser: true)
        messages.append(userMessage)
        inputText = ""
        isProcessing = true
        
        if let preset = presetAnswers[trimmed] {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            messages.append(ChatMessage(text: preset, isUser: false))
            isProcessing = false
            return
        }
        
        guard isConfigured else {
            messages.append(ChatMessage(text: "AI 服务未配置，当前运行在演示模式。", isUser: false))
            isProcessing = false
            return
        }
        
        do {
            let reply = try await AIService.shared.sendConversation(messages)
            messages.append(ChatMessage(text: reply, isUser: false))
        } catch let aiError as AIError {
            messages.append(ChatMessage(text: "AI 错误：\(aiError.localizedDescription)", isUser: false))
        } catch {
            messages.append(ChatMessage(text: "AI 发生错误：\(error.localizedDescription)", isUser: false))
        }
        
        isProcessing = false
    }
}

// MARK: - 学生端 AI 助手视图
struct StudentAIAssistantView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var viewModel: StudentAIAssistantViewModel
    
    private let quickPrompts = [
        "我今天的课表是什么？",
        "帮我总结一下未读邮件",
        "我有哪些即将到期的作业？",
        "请给我一份学习计划建议"
    ]
    
    var body: some View {
        ZStack {
            LinearGradient.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if !viewModel.isConfigured {
                    configurationBanner
                }
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            if viewModel.messages.isEmpty {
                                welcomeSection
                            } else {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                
                                if viewModel.isProcessing {
                                    typingIndicator
                                        .id("processing")
                                }
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                    }
                    .onChangeCompat(viewModel.messages.last?.id) { _ in
                        guard let id = viewModel.messages.last?.id else { return }
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
                
                ChatInputBar(
                    text: $viewModel.inputText,
                    placeholder: "问我任何关于学业与校园生活的问题...",
                    isProcessing: viewModel.isProcessing
                ) {
                    handleSend()
                }
            }
        }
        .navigationTitle(loc.tr("ai_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleSend() {
        let text = viewModel.inputText
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        Task {
            await viewModel.sendMessage(text)
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 54))
                    .foregroundColor(Color(hex: "6366F1"))
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                    )
                
                Text("AI 学习助手")
                    .font(.system(size: 22, weight: .bold))
                Text("我可以帮你整理待办、总结课程、规划学习。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("试试这些问题")
                    .font(.headline)
                
                ForEach(quickPrompts, id: \.self) { prompt in
                    Button {
                        Task { await viewModel.sendMessage(prompt) }
                    } label: {
                        HStack {
                            Text(prompt)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                    }
                }
            }
        }
        .padding(.vertical, 40)
    }
    
    private var typingIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .scaleEffect(viewModel.isProcessing ? 1 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.15),
                        value: viewModel.isProcessing
                    )
            }
        }
        .padding(.vertical, 12)
    }
    
    private var configurationBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color(hex: "F97316"))
            Text("未检测到 DeepSeek API Key，AI 将使用演示模式。请在 Config.swift 或安全存储中添加。")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}
