//
//  StudentAIAssistantView.swift
//  uniapp
//
//  完美演示版 - 包含7轮投资人演示对话
//

import SwiftUI

// MARK: - 学生端 AI 助手 ViewModel
class StudentAIAssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isProcessing = false
    
    // 投资人演示对话预设（7轮完整对话）
    private let demoConversations: [(user: String, ai: String)] = [
        (
            user: "我下周的 deadline 有哪些？",
            ai: """
            📋 **为您整理了下周的重要截止日期：**
            
            🔴 **紧急（2天内）**
            • CS Assignment - 11月9日 23:59
              完成进度：60%，还需完成第三部分
            
            🟡 **本周内**
            • 数据科学课程论文 - 11月12日
              建议：开始文献综述部分
            • 健康数据分析报告 - 11月13日
              状态：已收集数据，待分析
            
            💡 我注意到您的 CS Assignment 进度稍慢，需要帮您制定完成计划吗？
            """
        ),
        (
            user: "好的，帮我安排一下",
            ai: """
            ✅ **已为您制定完成计划：**
            
            **今天晚上 (3小时)**
            19:00-22:00 - 完成第三部分代码
            建议地点：Main Library (开放至23:00)
            
            **明天 (2小时)**
            14:00-16:00 - 代码测试与调试
            16:00-17:00 - 撰写文档说明
            
            📌 已自动添加到您的日历
            🔔 将在每个时间段前30分钟提醒您
            
            另外，图书馆3楼有 CS 课程的 Study Group，明天下午2点开始，要帮您预约座位吗？
            """
        ),
        (
            user: "预约一下，顺便问下我这周还有什么课？",
            ai: """
            ✅ **已预约图书馆3楼座位（明天14:00）**
            
            📅 **本周剩余课程安排：**
            
            **今天（周五）**
            无课程安排 - 适合专注完成作业
            
            **下周一**
            • 09:00-11:00 数据科学与统计
              地点：Cruciform Building, Room 4.18
              📝 需携带上周的实验报告
            
            **下周二**
            • 14:00-16:00 健康数据科学原理
              地点：Foster Court, Lecture Theatre
              💡 本次讲座与您的报告主题相关
            
            **下周三**
            • 10:00-12:00 数据方法与健康研究
              地点：Rockefeller Building
            
            ⚠️ **提醒：**周一的课程需要提交实验报告，目前状态显示"未提交"
            """
        ),
        (
            user: "实验报告是什么内容来着？",
            ai: """
            📊 **数据科学与统计 - Week 7 实验报告**
            
            **要求内容：**
            1. Python 数据清洗过程（20%）
            2. 探索性数据分析 EDA（30%）
            3. 统计检验结果（30%）
            4. 可视化图表（20%）
            
            **提交格式：**Jupyter Notebook + PDF
            **字数要求：**1500-2000字
            
            📎 **您的相关资料：**
            • Week 7 实验数据集（已下载）
            • 课堂演示代码（已保存到Drive）
            • 参考论文 x3（已整理）
            
            💡 根据您之前的作业表现，建议重点关注数据可视化部分，这是您的强项，可以多拿分！
            
            需要我帮您调取之前的数据集和代码吗？
            """
        ),
        (
            user: "调取一下，另外我想知道我目前的成绩情况",
            ai: """
            ✅ **已为您准备好实验材料：**
            📁 Week 7 数据集 → Google Drive/UCL/DataScience/
            💻 参考代码 → 已发送到邮箱
            
            ---
            
            📊 **您的成绩分析报告**
            
            **总体表现：**一等学位水平 (81.7分)
            **排名：**Top 15% in your cohort
            
            **各科详情：**
            
            🟢 **数据方法与健康研究：87分**
            • 作业完成度：100%
            • 课堂参与：95%
            • 优势：数据分析能力强
            
            🟡 **数据科学与统计：72分**
            • 作业完成度：75%（⚠️ 需提升）
            • 课堂参与：95%
            • 改进建议：提高作业完成率
            
            🟡 **健康数据科学原理：67分**
            • 作业完成度：80%
            • 课堂参与：100%
            • 改进建议：加强理论知识
            
            📈 **趋势分析：**
            • 较上月提升 +2.3分
            • 如果按时提交下周两份作业，预计总分可达 83-85分
            
            💡 **个性化建议：**
            您在实践项目中表现出色，但理论考试相对较弱。建议多参加 Study Group，与同学讨论理论概念。
            """
        ),
        (
            user: "那我应该怎么提升到85分以上？",
            ai: """
            🎯 **冲刺85+计划（可实现！）**
            
            **短期目标（本月）：+3-4分**
            
            **1️⃣ 提交质量作业（+2分）**
            • 下周两份作业都按时交 → +1.5分
            • 实验报告加强可视化 → +0.5分
            
            **2️⃣ 提升薄弱科目（+1.5分）**
            • 健康数据科学：补齐3次缺席的 Reading
            • 数据统计：完成 Optional Exercise
            
            **3️⃣ 额外加分项（+0.5分）**
            • 参加下周的 Research Seminar
            • 向教授提交 Bonus Question
            
            **长期策略（本学期）：**
            ✅ 每周至少参加1次 Office Hour
            ✅ 组建学习小组，互相讨论
            ✅ 提前2天完成作业，留出修改时间
            
            📅 **已为您安排：**
            • 周一 15:00 - Dr. Johnson Office Hour（已预约）
            • 周三 18:00 - Study Group Session
            • 周五 10:00 - Research Seminar（已加入日历）
            
            💪 根据数据分析，您的学习曲线呈上升趋势，按此计划执行，85+完全可以达成！
            
            需要我每天给您发送进度提醒吗？
            """
        ),
        (
            user: "好的，麻烦了！对了，明天图书馆几点开门？",
            ai: """
            📚 **UCL Main Library 开放时间**
            
            **明天（周六）**
            10:00 AM - 8:00 PM
            
            ⚠️ **特别提醒：**
            • 周末通常座位紧张，建议9:45到达
            • 3楼 Silent Study Zone 是最安静的
            • 已为您预约的座位在3楼，14:00可用
            
            **其他可选地点：**
            🔹 Science Library: 9:00-18:00
            🔹 IOE Library: 10:00-17:00
            🔹 Student Centre: 8:00-20:00（有咖啡）
            
            💡 根据您的习惯，您通常在下午学习效率最高，建议：
            • 上午在宿舍完成轻量任务
            • 下午去图书馆处理重要作业
            
            需要我帮您规划明天的学习时间表吗？
            """
        )
    ]
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(text: text, isUser: true)
        messages.append(userMessage)
        isProcessing = true
        
        // 检查是否是演示对话
        if let demoResponse = demoConversations.first(where: { $0.user == text })?.ai {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let aiMessage = ChatMessage(text: demoResponse, isUser: false)
                self.messages.append(aiMessage)
                self.isProcessing = false
            }
        } else {
            // 智能回复
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let response = self.generateSmartResponse(for: text)
                let aiMessage = ChatMessage(text: response, isUser: false)
                self.messages.append(aiMessage)
                self.isProcessing = false
            }
        }
    }
    
    // 智能回复生成
    private func generateSmartResponse(for query: String) -> String {
        let lowercased = query.lowercased()
        
        // 图书馆相关
        if lowercased.contains("图书馆") || lowercased.contains("library") {
            if lowercased.contains("时间") || lowercased.contains("开门") || lowercased.contains("time") {
                return """
                📚 **UCL 主图书馆开放时间:**
                
                周一至周五: 8:00 AM - 12:00 AM
                周六至周日: 10:00 AM - 8:00 PM
                
                ✨ 需要我为您介绍图书馆的其他服务吗?
                • 自习室预订
                • 打印服务
                • 数据库访问
                """
            }
            return "UCL 图书馆位于 Gower Street。需要了解开放时间吗?"
        }
        
        // 成绩相关
        if lowercased.contains("成绩") || lowercased.contains("分数") || lowercased.contains("grade") {
            return """
            📊 **根据您的成绩数据分析:**
            
            • 总平均分: 81.7分 (一等学位水平)
            • 最强科目: 数据方法 (87分)
            • 需要加强: 数据科学与统计 (72分)
            
            💡 **建议:** 
            1. 增加数据科学课程的学习时间
            2. 多参与课堂讨论提高参与分
            
            需要详细的学习计划吗?
            """
        }
        
        // 课程相关
        if lowercased.contains("课程") || lowercased.contains("class") || lowercased.contains("chme") {
            return """
            📅 **您的下一节课:**
            
            数据科学与统计
            • 时间: 今天下午 2:00 PM
            • 地点: Cruciform Building, Room 4.18
            • 讲师: Dr. Johnson
            
            需要查看本周完整课程表吗?
            """
        }
        
        // 作业相关
        if lowercased.contains("作业") || lowercased.contains("assignment") || lowercased.contains("deadline") {
            return """
            📝 **您有 2 项即将截止的作业:**
            
            1. CS Assignment (2天后)
               进度：60%
            2. 数据科学论文 (5天后)
               状态：待开始
            
            需要我帮您制定完成计划吗?
            """
        }
        
        // 默认回复
        return """
        我理解您的问题: "\(query)"
        
        我可以帮您:
        • 📚 查询图书馆信息
        • 📊 分析成绩趋势
        • 📅 查看课程安排
        • 📝 管理作业截止日期
        • 🎯 制定学习计划
        
        请告诉我您最感兴趣的是哪一项?
        """
    }
    
    func setContext(userPrompt: String, aiResponse: String) {
        messages = []
        let userMessage = ChatMessage(text: userPrompt, isUser: true)
        messages.append(userMessage)
        
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiMessage = ChatMessage(text: aiResponse, isUser: false)
            self.messages.append(aiMessage)
            self.isProcessing = false
        }
    }
}

// MARK: - 学生端 AI 助手视图
struct StudentAIAssistantView: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var viewModel: StudentAIAssistantViewModel
    
    // 功能类别定义
    let categories = [
        ("📋", "学业规划", "查看截止日期、安排学习计划"),
        ("📊", "成绩分析", "了解当前成绩、获取提升建议"),
        ("📅", "课程安排", "查询课表、了解课程详情"),
        ("📚", "校园资源", "图书馆、自习室、学习资料")
    ]
    
    // 隐藏的演示问题（用于内部逻辑，不直接显示给用户）
    private let demoQuestions = [
        "我下周的 deadline 有哪些？",
        "好的，帮我安排一下",
        "预约一下，顺便问下我这周还有什么课？",
        "实验报告是什么内容来着？",
        "调取一下，另外我想知道我目前的成绩情况",
        "那我应该怎么提升到85分以上？",
        "好的，麻烦了！对了，明天图书馆几点开门？"
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // 优雅的背景渐变
                LinearGradient(
                    colors: [
                        Color(hex: "F8FAFC"),
                        Color(hex: "F1F5F9"),
                        Color(hex: "E0E7FF").opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if viewModel.messages.isEmpty {
                        // 欢迎界面
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 32) {
                                // AI 图标
                                VStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: "8B5CF6"),
                                                        Color(hex: "6366F1")
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 100, height: 100)
                                            .shadow(color: Color(hex: "8B5CF6").opacity(0.3), radius: 20, x: 0, y: 10)
                                        
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 48))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text(loc.tr("ai_assistant_title"))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Text(loc.tr("ai_assistant_subtitle"))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.top, 60)
                                
                                // 功能类别卡片
                                VStack(spacing: 16) {
                                    Text(loc.tr("ai_quick_start"))
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    ForEach(categories, id: \.0) { category in
                                        StudentCategoryButton(
                                            icon: category.0,
                                            title: category.1,
                                            description: category.2
                                        ) {
                                            // 根据类别触发相应的演示对话
                                            handleCategoryTap(category.1)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 20)
                        }
                    } else {
                        // 对话界面
                        ScrollViewReader { proxy in
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.messages) { message in
                                        MessageBubble(message: message)
                                            .id(message.id)
                                    }
                                    
                                    if viewModel.isProcessing {
                                        HStack(spacing: 12) {
                                            ProgressView()
                                                .tint(Color(hex: "8B5CF6"))
                                            
                                            Text(loc.tr("ai_thinking"))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .id("processing")
                                    }
                                }
                                .padding()
                            }
                            .onChange(of: viewModel.messages.count) { _ in
                                if let lastMessage = viewModel.messages.last {
                                    withAnimation {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    
                    // 输入栏
                    ChatInputBar(
                        text: $viewModel.inputText,
                        onSend: {
                            let text = viewModel.inputText
                            viewModel.inputText = ""
                            viewModel.sendMessage(text)
                        },
                        placeholder: loc.tr("ai_placeholder")
                    )
                }
            }
            .navigationTitle(loc.tr("ai_title"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 根据类别触发相应的演示对话
    private func handleCategoryTap(_ category: String) {
        switch category {
        case "学业规划":
            viewModel.sendMessage(demoQuestions[0])
        case "成绩分析":
            viewModel.sendMessage(demoQuestions[4])
        case "课程安排":
            viewModel.sendMessage(demoQuestions[2])
        case "校园资源":
            viewModel.sendMessage(demoQuestions[6])
        default:
            // 默认使用第一个演示问题
            viewModel.sendMessage(demoQuestions[0])
        }
    }
}

// MARK: - 聊天消息数据模型
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - 消息气泡
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding()
                    .background(
                        message.isUser ?
                        AnyView(
                            LinearGradient(
                                colors: [Color(hex: "8B5CF6"), Color(hex: "6366F1")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        ) :
                        AnyView(Color.white.opacity(0.8))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser { Spacer() }
        }
    }
}

// MARK: - 学生端类别按钮
struct StudentCategoryButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(Color(hex: "8B5CF6").opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    // 提取emoji或使用系统图标
                    if let emoji = icon.first, emoji.isEmoji {
                        Text(String(emoji))
                            .font(.title2)
                    } else {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color(hex: "8B5CF6"))
                            .font(.system(size: 20))
                    }
                }
                
                // 类别文本
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "8B5CF6").opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(StudentScaleButtonStyle())
    }
}

// MARK: - 输入栏
struct ChatInputBar: View {
    @Binding var text: String
    let onSend: () -> Void
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "8B5CF6"), Color(hex: "6366F1")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .disabled(text.isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Character Extension (判断Emoji)
extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

// MARK: - 缩放按钮样式
struct StudentScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

