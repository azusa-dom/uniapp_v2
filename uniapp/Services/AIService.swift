//
//  AIService.swift
//  uniapp
//
//  Created by AI Assistant
//

import Foundation

final class AIService {
    static let shared = AIService()

    private let apiKey = Config.deepSeekAPIKey
    private let baseURL = URL(string: "https://api.deepseek.com/v1/chat/completions")!
    private init() {}

    /// 将当前会话发送到 DeepSeek，返回模型回复
    func sendConversation(_ messages: [ChatMessage]) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }

        guard messages.last?.isUser == true else {
            throw AIError.invalidConversation
        }

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let systemPrompt = """
        You are UniApp's bilingual study assistant for UCL students. Respond in polished Simplified Chinese, stay concise, and focus on actionable guidance for classes, assignments, health and campus life.
        """

        var payloadMessages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]

        let historySlice = Array(messages.suffix(8))
        for message in historySlice {
            payloadMessages.append([
                "role": message.isUser ? "user" : "assistant",
                "content": message.text
            ])
        }

        let payload: [String: Any] = [
            "model": "deepseek-chat",
            "messages": payloadMessages,
            "temperature": 0.7,
            "max_tokens": 800,
            "stream": false
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        return try parseResponse(data)
    }

    private func parseResponse(_ data: Data) throws -> String {
        do {
            let response = try JSONDecoder().decode(DeepSeekResponse.self, from: data)
            guard let content = response.choices.first?.message.content else {
                throw AIError.parseError
            }
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            throw AIError.parseError
        }
    }
}

// MARK: - Response DTO
private struct DeepSeekResponse: Decodable {
    struct Choice: Decodable {
        let message: ResponseMessage
    }

    struct ResponseMessage: Decodable {
        let content: String
    }

    let choices: [Choice]
}

// MARK: - Error Types
enum AIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case parseError
    case networkError(Error)
    case missingAPIKey
    case invalidConversation

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 API 地址"
        case .invalidResponse:
            return "无效的服务器响应"
        case .apiError(let statusCode, let message):
            return "AI 服务错误 (\(statusCode)): \(message)"
        case .parseError:
            return "无法解析 AI 响应，请稍后再试"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .missingAPIKey:
            return "未配置 DeepSeek API Key"
        case .invalidConversation:
            return "当前对话无效，缺少用户输入"
        }
    }
}
