//
//  ParentAIAssistantView.swift
//  uniapp
//
//  完美版 - 包含投资人演示对话
//

import SwiftUI

// MARK: - 家长端 AI 助手 ViewModel
class ParentAIAssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isProcessing = false
    
    // 投资人演示对话预设
    private let demoConversations: [(user: String, ai: String)] = [
        (
            user: "Zoya 最近的学习状况怎么样？",
            ai: """
            👋 您好！为您整理了 Zoya 本周的学习报告：
            
            📊 **整体表现：优秀** ⭐️⭐️⭐️⭐️⭐️
            
            **学业表现**
            • 平均成绩：81.7分（一等学位水平）
            • 排名：专业前15%
            • 趋势：较上月提升2.3分 📈
            
            **出勤情况**
            • 本周出勤率：100%
            • 本月出勤率：95%
            • 状态：准时参加所有课程 ✅
            
            **作业完成度**
            • 本周：2/3已完成
            • 待办：CS Assignment（2天后截止）
            • 进度：按计划推进中
            
            **课堂参与**
            • 积极参与讨论
            • 主动向教授提问
            • 参加了3次Study Group
            
            💡 **值得表扬：**
            Zoya 在数据方法课程中表现突出（87分），获得教授书面表扬！
            
            ⚠️ **需要关注：**
            有一份CS作业即将截止，她已经制定了完成计划，目前进度正常。
            """
        ),
        (
            user: "她的出勤率为什么不是100%？",
            ai: """
            📋 **出勤详细分析**
            
            **本月统计（11月1日-7日）**
            • 总课程：20节
            • 实际出勤：19节
            • 出勤率：95%
            
            **缺勤记录：**
            📅 11月3日（周一）
            • 课程：健康数据科学原理 (10:00-12:00)
            • 原因：身体不适（已向教授请假）
            • 补救：已获取课堂笔记，完成了补充阅读
            
            ✅ **积极方面：**
            • Zoya主动联系了教授说明情况
            • 当天下午就借到了同学笔记
            • 已完成该课程的所有作业
            • 教授回复表示理解且无需担心
            
            📧 **教授原话：**
            "Zoya is a diligent student. One absence won't affect her grade. She's doing great in my class."
            
            💚 **健康状况：**
            已恢复正常，之后一周全勤。
            
            需要我发送完整的出勤记录到您的邮箱吗？
            """
        ),
        (
            user: "不用了，她最近有参加什么活动吗？",
            ai: """
            🎯 **Zoya 的社交与课外活动**
            
            **本月参与的活动：**
            
            📚 **学术活动（3次）**
            • Data Science Workshop - 11月2日
              内容：Machine Learning 入门
              收获：认识了5位同专业同学
            
            • Health Research Seminar - 11月5日
              主题：AI在医疗领域的应用
              表现：提问环节积极参与
            
            • Study Group Session - 每周三晚
              持续参加中，已组建固定学习小组
            
            🌏 **社交活动（2次）**
            • International Students Meetup - 11月1日
              认识了来自8个国家的同学
            
            • Chinese Students Association 聚会 - 11月6日
              担任活动志愿者
            
            🏃 **运动健康（1次）**
            • 校园5K跑活动 - 11月4日
              完成时间：32分钟
            
            📅 **即将参加：**
            • Career Fair (11月22日)
            • AI Hackathon (11月25-26日)
              已组队，队友来自 CS 和 Data Science 专业
            
            💡 **平衡度分析：**
            Zoya 在学业和社交活动之间保持了很好的平衡，既专注学习，也积极融入校园生活。建议继续保持！
            
            她的社交能力和团队协作能力都在稳步提升 👍
            """
        ),
        (
            user: "她和同学相处得怎么样？",
            ai: """
            👥 **Zoya 的社交关系分析**
            
            **整体评价：社交能力优秀，融入良好**
            
            ---
            
            🌟 **核心社交圈：**
            
            **学习小组（5人固定团队）**
            • Mei (中国，同专业) - 最好的朋友
            • Sarah (英国，计算机系) - 编程导师角色
            • Arjun (印度，数据科学) - 项目合作伙伴
            • Emma (加拿大，统计学) - 互相帮助
            • Li Wei (中国，健康数据) - 学长，提供经验
            
            📊 **互动频率：**
            • 每周三晚：固定Study Group
            • 每天：课程讨论群活跃
            • 周末：偶尔一起出游或聚餐
            
            ---
            
            🎓 **课堂表现：**
            ✅ 多位教授提到 Zoya 善于团队协作
            ✅ 在小组作业中常担任组织者角色
            ✅ 同学们评价她"可靠"、"友善"
            
            ---
            
            💬 **同学评价（摘自课程反馈）：**
            
            Mei: "Zoya is very organized and always willing to help."
            
            Sarah: "Great team player, brings positive energy to our group."
            
            Dr. Johnson: "Zoya contributes thoughtfully to class discussions and works well with peers."
            
            ---
            
            📈 **社交健康指数：9/10**
            ✅ 有稳定的朋友圈
            ✅ 跨文化交友能力强
            ✅ 保持与家人的沟通
            ✅ 学习社交平衡良好
            
            需要我定期发送她的社交活动总结吗？
            """
        ),
        (
            user: "那她这学期整体目标完成得怎么样？",
            ai: """
            🎯 **Zoya 本学期目标完成情况**
            
            **学期初设定目标（9月）：**
            
            ---
            
            📚 **学业目标：**
            
            ✅ **目标1：平均成绩达到80+**
            • 当前：81.7分 ✓
            • 状态：已达成
            • 趋势：持续上升中 📈
            
            ✅ **目标2：所有课程出勤率95%+**
            • 当前：95% ✓
            • 状态：已达成
            • 仅1次因病请假（已妥善处理）
            
            🔄 **目标3：完成3个独立项目**
            • 已完成：2个
            • 进行中：1个（AI Hackathon）
            • 预计12月完成：✓ 有望达成
            
            ✅ **目标4：掌握Python高级技能**
            • 状态：已达成 ✓
            • 证明：自学了进阶课程
            • 应用：在作业中展现高水平代码
            
            ---
            
            👥 **社交目标：**
            
            ✅ **目标5：建立学习小组**
            • 状态：已完成 ✓
            • 成果：5人固定团队，每周见面
            
            ✅ **目标6：参加至少5个校园活动**
            • 已参加：6个活动 ✓
            • 超额完成
            
            ✅ **目标7：认识20+国际学生**
            • 实际：已认识约25位 ✓
            • 来自：10个不同国家
            
            ---
            
            📊 **总体完成度：85%**
            
            ✅ 已完成：8/10
            🔄 进行中：2/10
            
            ---
            
            🏆 **突出亮点：**
            
            1. **学术表现超预期**
               目标80分，实际81.7分，还在提升中
            
            2. **社交能力强**
               快速融入，建立了稳定的朋友圈
            
            3. **主动学习**
               自学了多个课外技能
            
            4. **时间管理好**
               学习、社交、健康平衡良好
            
            5. **独立性强**
               遇到问题能主动寻求解决方案
            
            ---
            
            🌟 **总结：**
            
            Zoya 这学期的表现**非常优秀**！她不仅达成了大部分学期目标，在学业、社交、个人发展三方面都展现出色的平衡能力。
            
            作为家长，您完全可以放心。Zoya 正在 UCL 健康、积极地成长，她展现出的自律性和独立性令人欣慰。
            
            建议给予她鼓励和肯定，这将是她继续前进的最大动力！💪
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
    
    private func generateSmartResponse(for query: String) -> String {
        let lowercased = query.lowercased()
        
        // 成绩相关
        if lowercased.contains("成绩") || lowercased.contains("分数") || lowercased.contains("grade") {
            return """
            📊 **Zoya 的成绩概况：**
            
            • 总平均分：81.7分
            • 等级：一等学位水平
            • 排名：专业前15%
            
            **各科表现：**
            🟢 数据方法与健康研究：87分（优秀）
            🟡 数据科学与统计：72分（良好）
            🟡 健康数据科学原理：67分（中等）
            
            需要查看详细的成绩分析吗？
            """
        }
        
        // 出勤相关
        if lowercased.contains("出勤") || lowercased.contains("attendance") {
            return """
            📋 **出勤情况：**
            
            • 本月出勤率：95%
            • 总出勤率：95%
            • 缺勤次数：1次（已请假）
            
            ✅ 出勤表现优秀，按时参加所有课程
            
            需要查看详细的出勤记录吗？
            """
        }
        
        // 作业相关
        if lowercased.contains("作业") || lowercased.contains("deadline") || lowercased.contains("assignment") {
            return """
            📝 **作业情况：**
            
            **待完成：**
            • CS Assignment - 2天后截止
            • 当前进度：60%
            
            **已完成：**
            • 数据分析作业 - 90分
            • Python 项目 - 88分
            
            💡 Zoya 已制定完成计划，进度正常
            
            需要我提醒她尽快完成吗？
            """
        }
        
        // 默认回复
        return """
        我理解您的问题: "\(query)"
        
        我可以帮您了解：
        • 📊 学业成绩和排名
        • 📋 出勤情况
        • 📝 作业完成度
        • 🎯 课外活动参与
        • 👥 社交关系
        
        请告诉我您最想了解的是哪一方面？
        """
    }
}

// MARK: - 家长端 AI 助手视图
struct ParentAIAssistantView: View {
    @EnvironmentObject var loc: LocalizationService
    @StateObject private var viewModel = ParentAIAssistantViewModel()
    
    // 精选的演示问题（中文）
    let quickQuestions = [
        ("📊 Zoya 最近的学习状况怎么样？", "learning"),
        ("📋 她的出勤率为什么不是100%？", "attendance"),
        ("🎯 她最近有参加什么活动吗？", "activities"),
        ("👥 她和同学相处得怎么样？", "social"),
        ("🏆 这学期整体目标完成得怎么样？", "goals")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // 优雅的背景
                LinearGradient(
                    colors: [
                        Color(hex: "F8FAFC"),
                        Color(hex: "EEF2FF"),
                        Color(hex: "E0E7FF").opacity(0.5)
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
                                                        Color(hex: "6366F1"),
                                                        Color(hex: "8B5CF6")
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 100, height: 100)
                                            .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 20, x: 0, y: 10)
                                        
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 48))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text(loc.tr("ai_title"))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Text("了解 Zoya 的学习和生活")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.top, 60)
                                
                                // 快速问题卡片
                                VStack(spacing: 16) {
                                    Text("常见问题")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    ForEach(quickQuestions, id: \.0) { question in
                                        ParentQuickQuestionButton(question: question.0) {
                                            viewModel.sendMessage(question.0)
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
                                                .tint(Color(hex: "6366F1"))
                                            
                                            Text("思考中...")
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
                        placeholder: "问我关于 Zoya 的任何问题..."
                    )
                }
            }
            .navigationTitle(loc.tr("ai_title"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 家长端快速问题按钮
struct ParentQuickQuestionButton: View {
    let question: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(Color(hex: "6366F1").opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    // 提取emoji或使用系统图标
                    if let emoji = question.first, emoji.isEmoji {
                        Text(String(emoji))
                            .font(.title2)
                    } else {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color(hex: "6366F1"))
                            .font(.system(size: 20))
                    }
                }
                
                // 问题文本
                Text(question)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
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
                            .stroke(Color(hex: "6366F1").opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
