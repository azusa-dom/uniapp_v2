import SwiftUI

/// Shared chat bubble used by both student and parent AI assistants.
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            if !message.isUser {
                avatarView
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // 渲染 Markdown 格式的消息
                if message.isUser {
                    // 用户消息：简单文本显示
                    Text(message.text)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                } else {
                    // AI 消息：使用 Markdown 渲染
                    MarkdownText(message.text)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(
                            LinearGradient(
                                colors: [Color.white, Color.white],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                }
                
                Text(timeString(message.timestamp))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if message.isUser {
                avatarView
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 4)
        .transition(.move(edge: message.isUser ? .trailing : .leading).combined(with: .opacity))
    }
    
    private var avatarView: some View {
        Circle()
            .fill(
                message.isUser ?
                Color(hex: "6366F1") :
                Color(hex: "F59E0B")
            )
            .frame(width: 36, height: 36)
            .overlay(
                Image(systemName: message.isUser ? "person.fill" : "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            )
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

/// Input bar with text field and send button.
struct ChatInputBar: View {
    @Binding var text: String
    var placeholder: String = "请输入内容"
    var isProcessing = false
    var onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(1...4)
                .textFieldStyle(.roundedBorder)
                .disabled(isProcessing)
            
            Button(action: onSend) {
                Image(systemName: isProcessing ? "hourglass" : "paperplane.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(isSendDisabled ? Color.gray.opacity(0.4) : Color(hex: "6366F1"))
                    )
            }
            .disabled(isSendDisabled)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 0)
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var isSendDisabled: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing
    }
}

// MARK: - Markdown 文本渲染组件
struct MarkdownText: View {
    let content: String
    
    init(_ content: String) {
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(parseMarkdown(), id: \.id) { element in
                element.view
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func parseMarkdown() -> [MarkdownElement] {
        var elements: [MarkdownElement] = []
        let lines = content.components(separatedBy: .newlines)
        
        var listItems: [String] = []
        var currentLevel = 0
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // 处理标题（**标题**）
            if trimmed.hasPrefix("**") && trimmed.hasSuffix("**") && trimmed.count > 4 {
                // 先处理积累的列表
                if !listItems.isEmpty {
                    elements.append(.list(items: listItems, level: currentLevel))
                    listItems.removeAll()
                }
                
                let title = trimmed
                    .replacingOccurrences(of: "**", with: "")
                    .trimmingCharacters(in: .whitespaces)
                elements.append(.heading(title))
            }
            // 处理列表项（- 或 • 开头）
            else if trimmed.hasPrefix("-") || trimmed.hasPrefix("•") {
                let item = trimmed
                    .replacingOccurrences(of: "^[-•]\\s*", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
                if !item.isEmpty {
                    listItems.append(item)
                }
                currentLevel = line.hasPrefix("  ") || line.hasPrefix("\t") ? 1 : 0
            }
            // 处理编号列表（1. 开头）
            else if let match = trimmed.range(of: "^\\d+\\.\\s", options: .regularExpression) {
                if !listItems.isEmpty {
                    elements.append(.list(items: listItems, level: currentLevel))
                    listItems.removeAll()
                }
                
                let item = String(trimmed[match.upperBound...]).trimmingCharacters(in: .whitespaces)
                if !item.isEmpty {
                    elements.append(.numberedItem(item))
                }
            }
            // 空行
            else if trimmed.isEmpty {
                if !listItems.isEmpty {
                    elements.append(.list(items: listItems, level: currentLevel))
                    listItems.removeAll()
                }
                // 不添加空行元素，保持紧凑
            }
            // 普通文本
            else {
                if !listItems.isEmpty {
                    elements.append(.list(items: listItems, level: currentLevel))
                    listItems.removeAll()
                }
                
                // 处理行内加粗（**text**）
                let processedLine = processInlineMarkdown(trimmed)
                elements.append(.text(processedLine, id: MarkdownElement.nextTextId()))
            }
        }
        
        // 处理最后的列表
        if !listItems.isEmpty {
            elements.append(.list(items: listItems, level: currentLevel))
        }
        
        return elements
    }
    
    // 处理行内 Markdown（如 **粗体**）
    private func processInlineMarkdown(_ text: String) -> AttributedString {
        var result = AttributedString()
        let pattern = "\\*\\*(.+?)\\*\\*"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            var lastIndex = 0
            
            for match in matches {
                if match.numberOfRanges >= 2 {
                    let fullRange = match.range(at: 0)
                    let contentRange = match.range(at: 1)
                    
                    // 添加匹配前的普通文本
                    if fullRange.location > lastIndex {
                        let beforeRange = NSRange(location: lastIndex, length: fullRange.location - lastIndex)
                        let beforeText = nsString.substring(with: beforeRange)
                        result.append(AttributedString(beforeText))
                    }
                    
                    // 添加粗体文本
                    let content = nsString.substring(with: contentRange)
                    var boldText = AttributedString(content)
                    boldText.font = .system(size: 15, weight: .semibold)
                    result.append(boldText)
                    
                    lastIndex = fullRange.location + fullRange.length
                }
            }
            
            // 添加剩余的文本
            if lastIndex < nsString.length {
                let remainingRange = NSRange(location: lastIndex, length: nsString.length - lastIndex)
                let remainingText = nsString.substring(with: remainingRange)
                result.append(AttributedString(remainingText))
            }
        } else {
            // 如果正则表达式失败，返回原始文本
            result = AttributedString(text)
        }
        
        return result
    }
}

// MARK: - Markdown 元素枚举
enum MarkdownElement: Identifiable {
    case heading(String)
    case text(AttributedString, id: String)
    case list(items: [String], level: Int)
    case numberedItem(String)
    
    var id: String {
        switch self {
        case .heading(let text): return "h_\(text)"
        case .text(_, let id): return id
        case .list(let items, _): return "l_\(items.joined())"
        case .numberedItem(let text): return "n_\(text)"
        }
    }
    
    private static var textIdCounter = 0
    static func nextTextId() -> String {
        textIdCounter += 1
        return "t_\(textIdCounter)"
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .heading(let text):
            Text(text)
                .font(.system(size: 16, weight: .bold))
                .padding(.top, 8)
                .padding(.bottom, 4)
            
        case .text(let attributedText, _):
            Text(attributedText)
                .font(.system(size: 15))
                .fixedSize(horizontal: false, vertical: true)
            
        case .list(let items, let level):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        Text(item)
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.leading, CGFloat(level * 16))
                }
            }
            
        case .numberedItem(let text):
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                Text(text)
                    .font(.system(size: 15))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

