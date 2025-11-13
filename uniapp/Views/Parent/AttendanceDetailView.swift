//
//  AttendanceDetailView.swift
//  uniapp
//
//  Production-ready: attendance summary + per-course bars
//

import SwiftUI

struct AttendanceDetailView: View {
    // ✅ 修复：
    // 这里的 `ATTStats` 现在会正确使用
    // `共享数据模型.swift` 中定义的 `ATTStats`。
    let stats: ATTStats

    // ✅ 修复：
    // `stats` 的默认值 `.sample` 现在来自 `共享数据模型.swift`
    init(stats: ATTStats = .sample) { self.stats = stats }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.appBackground.ignoresSafeArea()
                VStack(spacing: 16) {
                    Card {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("出勤总览").font(.headline)
                            HStack(spacing: 12) {
                                ATTTile(title: "出勤", value: "\(stats.present)%", color: .green, icon: "checkmark.circle.fill")
                                ATTTile(title: "迟到", value: "\(stats.late)%",   color: .orange, icon: "clock.fill")
                                ATTTile(title: "缺勤", value: "\(stats.absent)%", color: .red,   icon: "xmark.circle.fill")
                            }
                        }
                    }.padding(.horizontal)

                    Card {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("课程维度").font(.headline)
                            ForEach(stats.courses) { c in
                                HStack {
                                    Text(c.name).frame(width: 120, alignment: .leading)
                                    ATTBar(value: Double(c.present), color: .green)
                                    ATTBar(value: Double(c.late),    color: .orange)
                                    ATTBar(value: Double(c.absent),  color: .red)
                                }
                            }
                            Text("绿色=出勤，橙色=迟到，红色=缺勤").font(.caption).foregroundColor(.secondary)
                        }
                    }.padding(.horizontal)

                    Spacer(minLength: 8)
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("出勤详情")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Local Models & UI

// ✅ 最重要修改：
// 移除了这里定义的 `ATTStats` 结构体。
// 它与 `共享数据模型.swift` 中的定义重复，会导致编译错误。

private struct ATTTile: View {
    let title:String; let value:String; let color:Color; let icon:String
    var body: some View {
        VStack(spacing: 8) {
            ZStack { Circle().fill(color.opacity(0.18)).frame(width: 48, height: 48); Image(systemName: icon).foregroundColor(color) }
            Text(value).font(.system(size: 22, weight: .bold))
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.95)))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

private struct ATTBar: View {
    let value: Double; let color: Color
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.15))
                RoundedRectangle(cornerRadius: 4).fill(color)
                    .frame(width: geo.size.width * CGFloat(max(0,min(100,value))/100))
            }
        }.frame(height: 10)
    }
}

private struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ c: ()->Content) { content = c() }
    var body: some View {
        content
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.95)))
            .shadow(color:.black.opacity(0.06), radius:10, x:0, y:4)
    }
}
