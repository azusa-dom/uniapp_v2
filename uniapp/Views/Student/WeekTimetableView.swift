//
//  WeekTimetableView.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI

// MARK: - 周视图课程表
struct WeekTimetableView: View {
    @StateObject private var viewModel = TimetableViewModel()
    @EnvironmentObject var loc: LocalizationService
    @State private var selectedWeek: Date = Date()
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
    private let timeSlots = Array(8...20).map { hour in
        DateComponents(hour: hour, minute: 0)
    }
    
    private let weekdays = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    
    private var weekStart: Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedWeek)) ?? selectedWeek
    }
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekStart)
        }
    }
    
    private func eventsForDay(_ date: Date) -> [TimetableEvent] {
        let calendar = Calendar.current
        return viewModel.weekEvents.filter { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 周选择器
            weekSelector
            
            // 时间表
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        // 背景网格
                        gridBackground
                        
                        // 课程块
                        courseBlocks
                        
                        // 当前时间线
                        currentTimeLine
                    }
                    .frame(width: CGFloat(weekDates.count) * 100 + 60, height: CGFloat(timeSlots.count) * 60)
                }
            }
        }
    }
    
    // MARK: - 周选择器
    private var weekSelector: some View {
        HStack {
            Button {
                withAnimation {
                    selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedWeek) ?? selectedWeek
                    viewModel.selectedDate = selectedWeek
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "6366F1"))
            }
            
            Spacer()
            
            Text(weekRangeText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button {
                withAnimation {
                    selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedWeek) ?? selectedWeek
                    viewModel.selectedDate = selectedWeek
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "6366F1"))
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
    
    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        if let start = weekDates.first, let end = weekDates.last {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
        return ""
    }
    
    // MARK: - 网格背景
    private var gridBackground: some View {
        VStack(spacing: 0) {
            // 时间轴 + 星期标题行
            HStack(spacing: 0) {
                // 时间轴列（60px宽）
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(timeSlots, id: \.hour) { slot in
                        Text("\(slot.hour ?? 0):00")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .frame(width: 60, height: 60, alignment: .topTrailing)
                            .padding(.trailing, 4)
                    }
                }
                
                // 星期列
                ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                    VStack(spacing: 0) {
                        // 星期标题
                        VStack(spacing: 4) {
                            Text(weekdays[index])
                                .font(.system(size: 12, weight: .semibold))
                            Text(dayNumber(date))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isToday(date) ? Color(hex: "6366F1") : .primary)
                        }
                        .frame(width: 100, height: 40)
                        .background(isToday(date) ? Color(hex: "6366F1").opacity(0.1) : Color.clear)
                        
                        // 时间槽
                        ForEach(timeSlots, id: \.hour) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.05))
                                .frame(width: 100, height: 60)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 1),
                                    alignment: .bottom
                                )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 课程块
    private var courseBlocks: some View {
        GeometryReader { geometry in
            ForEach(weekDates, id: \.self) { date in
                let dayIndex = weekDates.firstIndex(of: date) ?? 0
                let events = eventsForDay(date)
                
                ForEach(events) { event in
                    CourseBlockView(event: event, dayIndex: dayIndex, timeSlots: timeSlots)
                }
            }
        }
    }
    
    // MARK: - 当前时间线
    private var currentTimeLine: some View {
        GeometryReader { geometry in
            let calendar = Calendar.current
            let now = Date()
            if calendar.isDate(now, equalTo: selectedWeek, toGranularity: .weekOfYear) {
                let hour = calendar.component(.hour, from: now)
                let minute = calendar.component(.minute, from: now)
                let timePosition = CGFloat(hour - 8) * 60 + CGFloat(minute) / 60 * 60
                
                Rectangle()
                    .fill(Color(hex: "EF4444"))
                    .frame(width: CGFloat(weekDates.count) * 100 + 60, height: 2)
                    .offset(y: timePosition)
            }
        }
    }
    
    // MARK: - 辅助方法
    private func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - 课程块视图
struct CourseBlockView: View {
    @EnvironmentObject var loc: LocalizationService
    let event: TimetableEvent
    let dayIndex: Int
    let timeSlots: [DateComponents]
    
    private var isChinese: Bool {
        loc.language == .chinese
    }
    
    private var startPosition: CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: event.startTime)
        let minute = calendar.component(.minute, from: event.startTime)
        return CGFloat(hour - 8) * 60 + CGFloat(minute) / 60 * 60
    }
    
    private var height: CGFloat {
        let calendar = Calendar.current
        let duration = event.endTime.timeIntervalSince(event.startTime)
        return CGFloat(duration / 3600) * 60
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.localizedTitle(isChinese: isChinese))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(event.localizedType(isChinese: isChinese))
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.9))
            
            Text(event.localizedLocation(isChinese: isChinese))
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
        .padding(6)
        .frame(width: 96, height: max(height, 40), alignment: .topLeading)
        .background(Color(hex: event.color))
        .cornerRadius(6)
        .offset(x: CGFloat(dayIndex) * 100 + 60, y: startPosition)
    }
}

