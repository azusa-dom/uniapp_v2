import SwiftUI

/// Shared chat bubble used by both student and parent AI assistants.
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 24) }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(message.text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(message.isUser ? Color(hex: "6366F1") : Color.white)
                            .shadow(color: Color.black.opacity(message.isUser ? 0 : 0.05), radius: 6, x: 0, y: 2)
                    )
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser { Spacer(minLength: 24) }
        }
        .padding(.horizontal, 4)
        .transition(.move(edge: message.isUser ? .trailing : .leading).combined(with: .opacity))
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
