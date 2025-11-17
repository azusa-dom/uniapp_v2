// APIConfig.swift
// 精简后的配置文件示例（已替换敏感 Token）

import Foundation

struct APIConfig {
    static let baseURL = "https://uclapi.com"
    static let apiToken = "<YOUR_TOKEN_HERE>"

    enum Endpoint {
        case timetableByModules(modules: [String])
        case timetablePersonal
        case rooms
        case roomBookings
        case search

        var path: String {
            switch self {
            case .timetableByModules:
                return "/timetable/bymodule"
            case .timetablePersonal:
                return "/timetable/personal"
            case .rooms:
                return "/roombookings/rooms"
            case .roomBookings:
                return "/roombookings/bookings"
            case .search:
                return "/search/people"
            }
        }

        func url(with parameters: [String: String] = [:]) -> URL? {
            guard var components = URLComponents(string: "\(APIConfig.baseURL)\(path)") else {
                return nil
            }

            var queryItems = [URLQueryItem(name: "token", value: APIConfig.apiToken)]

            parameters.forEach { key, value in
                queryItems.append(URLQueryItem(name: key, value: value))
            }

            components.queryItems = queryItems
            return components.url
        }
    }

    static func createRequest(endpoint: Endpoint, parameters: [String: String] = [:]) -> URLRequest? {
        guard let url = endpoint.url(with: parameters) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        return request
    }
}

// MARK: - Network Manager 示例

final class UCLAPIManager {
    static let shared = UCLAPIManager()

    private init() {}

    func fetchPersonalTimetable() async throws -> [TimetableEvent] {
        guard let request = APIConfig.createRequest(endpoint: .timetablePersonal) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let timetableResponse = try JSONDecoder().decode(TimetableResponse.self, from: data)
        return timetableResponse.timetable.values.flatMap { $0 }
    }

    func fetchTimetableByModules(_ modules: [String]) async throws -> [TimetableEvent] {
        let parameters = ["modules": modules.joined(separator: ",")]

        guard let request = APIConfig.createRequest(
            endpoint: .timetableByModules(modules: modules),
            parameters: parameters
        ) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let timetableResponse = try JSONDecoder().decode(TimetableResponse.self, from: data)
        return timetableResponse.timetable.values.flatMap { $0 }
    }
}

// MARK: - 数据模型示例

struct TimetableEvent: Codable, Identifiable {
    let id = UUID()
    let moduleName: String
    let moduleId: String
    let startTime: String
    let endTime: String
    let location: Location?
    let sessionTitle: String?
    let sessionType: String?
    let contact: String?

    enum CodingKeys: String, CodingKey {
        case moduleName = "module_name"
        case moduleId = "module_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case location
        case sessionTitle = "session_title"
        case sessionType = "session_type"
        case contact
    }
}

struct Location: Codable {
    let name: String?
    let address: String?
    let siteName: String?

    enum CodingKeys: String, CodingKey {
        case name
        case address
        case siteName = "site_name"
    }
}

struct TimetableResponse: Codable {
    let ok: Bool
    let timetable: [String: [TimetableEvent]]
}

