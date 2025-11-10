import SwiftUI

struct UCLActivitiesView: View {
    @EnvironmentObject var loc: LocalizationService
    @StateObject private var activitiesService = UCLActivitiesService()
    @State private var selectedCategory = "全部"
    @State private var searchText = ""
    @State private var showingFilters = false

    let categories = ["全部", "学术", "文化", "体育", "社团", "讲座", "展览"]

    var filteredActivities: [UCLActivity] {
        let categoryFiltered = selectedCategory == "全部" ?
            activitiesService.activities :
            activitiesService.activities.filter { activity in
                switch selectedCategory {
                case "学术":
                    return activity.type.contains("academic") || activity.type.contains("lecture")
                case "文化":
                    return activity.type.contains("cultural") || activity.type.contains("art")
                case "体育":
                    return activity.type.contains("sport") || activity.type.contains("fitness")
                case "社团":
                    return activity.type.contains("club") || activity.type.contains("society")
                case "讲座":
                    return activity.type.contains("seminar") || activity.type.contains("talk")
                case "展览":
                    return activity.type.contains("exhibition") || activity.type.contains("display")
                default:
                    return true
                }
            }

        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    searchBar
                    if showingFilters {
                        categoryFilterBar
                    }
                    content
                }
            }
            .navigationTitle("UCL 活动")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        activitiesService.refreshActivities()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        activitiesService.refreshActivities()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                }
                #endif
            }
            .onAppear {
                if activitiesService.activities.isEmpty {
                    activitiesService.loadActivities()
                }
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索活动", text: $searchText)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: { showingFilters.toggle() }) {
                Image(systemName: "line.horizontal.3.decrease.circle")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "6366F1"))
            }
            .padding(12)
            .background(Color.white.opacity(0.8))
            .clipShape(Circle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? Color(hex: "6366F1") : Color.gray.opacity(0.2))
                        .foregroundColor(selectedCategory == category ? .white : .primary)
                        .clipShape(Capsule())
                        .onTapGesture {
                            selectedCategory = category
                        }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var content: some View {
        if activitiesService.isLoading {
            VStack {
                ProgressView()
                Text("加载中...")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if filteredActivities.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 64))
                    .foregroundColor(Color(hex: "F59E0B"))
                Text(searchText.isEmpty ? "暂无活动" : "未找到相关活动")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredActivities, id: \.id) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}

struct ActivityCard: View {
    @EnvironmentObject var loc: LocalizationService
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: UCLAPIViewModel
    let activity: UCLActivity
    @State private var isAddedToCalendar = false

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: loc.language == .chinese ? "zh_CN" : "en_US")
        dateFormatter.dateFormat = loc.language == .chinese ? "M月d日" : "MMM d"
        return dateFormatter.string(from: parseActivityDate(activity.date) ?? Date())
    }

    var formattedTime: String {
        if !activity.startTime.isEmpty && !activity.endTime.isEmpty {
            return "\(activity.startTime) - \(activity.endTime)"
        }
        return ""
    }

    private func parseActivityDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.date(from: dateString)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(activity.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Spacer()

                Text(activity.type.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "6366F1"))
                    .clipShape(Capsule())
            }

            if let description = activity.description {
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            HStack(spacing: 16) {
                if !formattedDate.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text(formattedDate)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                if !formattedTime.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text(formattedTime)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                if let location = activity.location {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text(location)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            HStack(spacing: 12) {
                Button(action: {
                    // 查看详情
                }) {
                    Text("查看详情")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "6366F1"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "6366F1").opacity(0.1))
                        .clipShape(Capsule())
                }

                Button(action: {
                    // 使用 UCLAPIViewModel 添加到日历
                    viewModel.addActivityToCalendar(activity)
                    isAddedToCalendar = true
                    
                    // 显示成功提示
                    withAnimation {
                        // 可以添加震动反馈
                        #if os(iOS)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        #endif
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isAddedToCalendar ? "checkmark.circle.fill" : "calendar.badge.plus")
                        Text(isAddedToCalendar ? "已添加" : loc.tr("calendar_add_to_calendar"))
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isAddedToCalendar ? Color(hex: "10B981") : Color(hex: "6366F1"))
                    .clipShape(Capsule())
                }
                .disabled(isAddedToCalendar)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}
