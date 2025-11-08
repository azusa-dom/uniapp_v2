import Foundation

struct APIConfig {
    // MARK: - UCL API Configuration
    
    // UCL API Base URL
    static let baseURL = "https://uclapi.com"
    
    // 你的 API Token
    static let apiToken = "uclapi-57b768cb3e4b8cc-2499552a17ad299-7ae012c12b7f9c3-1b31c15b5866279"
    // MARK: - 兼容旧代码的方法
      static let activitiesLatest = "/timetable/personal"
      static let activitiesRefresh = "/timetable/personal"
      
      static func activitiesLatestURL() -> URL? {
          var components = URLComponents(string: "\(baseURL)\(activitiesLatest)")
          components?.queryItems = [URLQueryItem(name: "token", value: apiToken)]
          return components?.url
      }
      
      static func activitiesRefreshURL() -> URL? {
          var components = URLComponents(string: "\(baseURL)\(activitiesRefresh)")
          components?.queryItems = [URLQueryItem(name: "token", value: apiToken)]
          return components?.url
      }
    // MARK: - API Endpoints
    
    enum Endpoint {
        case timetableByModules(modules: [String])  // 按课程模块查询时间表
        case timetablePersonal                       // 个人时间表
        case rooms                                   // 房间信息
        case roomBookings                            // 房间预订
        case search                                  // 搜索
        
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
            
            // 添加 token 参数
            var queryItems = [URLQueryItem(name: "token", value: APIConfig.apiToken)]
            
            // 添加其他参数
            for (key, value) in parameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            
            components.queryItems = queryItems
            return components.url
        }
    }
    
    // MARK: - Helper Methods
    
    static func createRequest(endpoint: Endpoint, parameters: [String: String] = [:]) -> URLRequest? {
        guard let url = endpoint.url(with: parameters) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        return request
    }
}

// MARK: - Data Models

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

// MARK: - Network Manager

class UCLAPIManager {
    static let shared = UCLAPIManager()
    
    private init() {}
    
    // 获取个人时间表
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
        
        // 展平所有日期的事件
        return timetableResponse.timetable.values.flatMap { $0 }
    }
    
    // 按模块获取时间表
    func fetchTimetableByModules(_ modules: [String]) async throws -> [TimetableEvent] {
        let parameters = [
            "modules": modules.joined(separator: ",")
        ]
        
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

// MARK: - SwiftUI View 使用示例

import SwiftUI

struct TimetableView: View {
    @State private var events: [TimetableEvent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("加载中...")
                } else if let error = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.secondary)
                        Button("重试") {
                            Task {
                                await loadTimetable()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    List(events) { event in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event.moduleName)
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "clock")
                                Text("\(event.startTime) - \(event.endTime)")
                                    .font(.subheadline)
                            }
                            
                            if let location = event.location?.name {
                                HStack {
                                    Image(systemName: "location")
                                    Text(location)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if let sessionType = event.sessionType {
                                Text(sessionType)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("我的课程表")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .task {
                await loadTimetable()
            }
            .refreshable {
                await loadTimetable()
            }
        }
    }
    
    func loadTimetable() async {
        isLoading = true
        errorMessage = nil
        
        do {
            events = try await UCLAPIManager.shared.fetchPersonalTimetable()
        } catch {
            errorMessage = "加载失败: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
