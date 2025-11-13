import SwiftUI
import GoogleGenerativeAI // 1. 导入 SDK

// MARK: - 学生端 AI 助手 ViewModel
class StudentAIAssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isProcessing = false
    
    // 2. 初始化 Gemini 模型
    private var genAIModel: GenerativeModel?
    
    // (您的演示对话 - 保持不变)
    private let demoConversations: [(user: String, ai: String)] = [
        // ... (您那 7 轮完美的演示对话放在这里) ...
        (
            user: "我下周的 deadline 有哪些？",
            ai: "为您整理了下周的重要截止日期：..."
        ),
        // ... (其他对话) ...
        (
            user: "好的，麻烦了！对了，明天图书馆几点开门？",
            ai: "UCL Main Library 开放时间..."
        )
    ]
    
    init() {
        // ✅ 从配置读取 API Key
        let apiKey = Config.geminiAPIKey
        
        // 检查 Key 是否有效
        if !apiKey.isEmpty && apiKey.starts(with: "AIzaSy") && apiKey.count > 40 {
            self.genAIModel = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
        } else {
            print("⚠️ 警告：Gemini API 密钥无效或未设置。请在 Info.plist 中添加 GEMINI_API_KEY")
            // 即使没有 Key，演示模式依然可以运行
        }
    }
    
    // 4. 重写 sendMessage 函数，使其支持
    @MainActor // 确保所有 UI 更新都在主线程
    func sendMessage(_ text: String) async { // <-- 改为 async 异步函数
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(text: text, isUser: true)
        self.messages.append(userMessage)
        self.inputText = "" // 发送后清空输入框
        self.isProcessing = true
        
        // ---
        // 核心逻辑：检查是否为演示对话
        // ---
        if let demoResponse = demoConversations.first(where: { $0.user == text })?.ai {
            //
            // 模式 1: 命中预设的演示回答
            //
            // 模拟网络延迟
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 模拟1.2秒延迟
            
            let aiMessage = ChatMessage(text: demoResponse, isUser: false)
            self.messages.append(aiMessage)
            self.isProcessing = false
            
        } else {
            //
            // 模式 2: 未命中演示，调用真实 Gemini API
            //
            guard let model = genAIModel else {
                // 如果 API Key 无效或模型未初始化
                let errorMsg = "AI 服务未配置。API 密钥无效或未设置。"
                self.messages.append(ChatMessage(text: errorMsg, isUser: false))
                self.isProcessing = false
                return
            }
            
            do {
                // (可选) 注入上下文，让 AI 知道自己的角色
                let systemPrompt = "你是一个专门帮助UCL（伦敦大学学院）学生的AI学业助手。请始终使用中文回答。用户的提问是："
                
                // 发送请求
                let response = try await model.generateContent(systemPrompt + text)
                
                var aiText = "抱歉，我无法回答这个问题。"
                if let newText = response.text {
                    aiText = newText
                }
                
                let aiMessage = ChatMessage(text: aiText, isUser: false)
                self.messages.append(aiMessage)
                
            } catch {
                // 处理 API 错误
                let errorMsg = "AI 发生错误: \(error.localizedDescription)"
                self.messages.append(ChatMessage(text: errorMsg, isUser: false))
            }
            
            self.isProcessing = false
        }
    }
    
    // (原来的 generateSmartResponse 和 setContext 函数可以删除了，它们已被 API 调用取代)
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
        NavigationStack {
            ZStack {
                LinearGradient.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                        .onChange(of: viewModel.messages.last?.id) {
                            guard let id = viewModel.messages.last?.id else { return }
                            withAnimation {
                                proxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                    
                    ChatInputBar(
                        text: $viewModel.inputText,
                        placeholder: "问我任何关于学业与校园生活的问题...",
                        isProcessing: viewModel.isProcessing,
                        onSend: handleSend
                    )
                }
            }
            .navigationTitle(loc.tr("ai_title"))
            .navigationBarTitleDisplayMode(.inline)
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
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.9))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 12)
    }
    
    private var typingIndicator: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(Color(hex: "6366F1"))
            Text("思考中...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
        )
    }
    
    private func handleSend() {
        let text = viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        Task {
            await viewModel.sendMessage(text)
        }
    }
}
