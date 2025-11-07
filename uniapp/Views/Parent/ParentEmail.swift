//
//  ParentEmail.swift
//  uniapp
//

import SwiftUI

struct ParentEmailView: View {
    @EnvironmentObject var loc: LocalizationService
    @State private var selectedFilter = "全部"
    
    let categories = ["全部", "紧急", "学术", "活动"]
    
    var parentEmails: [EmailPreview] {
        mockEmails.map { email in
            var parentTitle = email.title
            var parentExcerpt = email.excerpt
            
            if email.category == "Academic" {
                parentTitle = "学业进展报告：" + email.title
                parentExcerpt = "您的孩子在" + email.excerpt
            } else if email.category == "Urgent" {
                parentTitle = "重要通知：" + email.title
            }
            
            return EmailPreview(
                title: parentTitle,
                sender: email.sender,
                excerpt: parentExcerpt,
                date: email.date,
                category: email.category,
                isRead: email.isRead
            )
        }
    }
    
    var filteredEmails: [EmailPreview] {
        let categoryMap: [String: String] = [
            "全部": "All",
            "紧急": "Urgent",
            "学术": "Academic",
            "活动": "Events"
        ]
        let englishFilter = categoryMap[selectedFilter] ?? "All"
        if englishFilter == "All" { return parentEmails }
        return parentEmails.filter { $0.category == englishFilter }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    EmailStatsView(emails: parentEmails)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedFilter = cat
                                    }
                                }) {
                                    Text(cat)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(
                                            selectedFilter == cat
                                                ? Color(hex: "8B5CF6")
                                                : Color.gray.opacity(0.15)
                                        )
                                        .foregroundColor(selectedFilter == cat ? .white : .primary)
                                        .cornerRadius(12)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredEmails) { email in
                                NavigationLink(destination: EmailDetailView(email: email)) {
                                    EmailRow(email: email)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("邮件")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ParentEmailView_Previews: PreviewProvider {
    static var previews: some View {
        ParentEmailView()
            .environmentObject(LocalizationService())
    }
}
