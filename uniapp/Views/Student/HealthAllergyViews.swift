//
//  HealthAllergyViews.swift
//  uniapp
//
//  Created by 748 on 12/11/2025.
//

import SwiftUI

// MARK: - 过敏史视图
struct AllergiesManagementView: View {
    @EnvironmentObject var healthManager: HealthManager
    @State private var showingAddAllergy = false
    @State private var selectedAllergy: AllergyRecord?
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // 警告提示
                    warningBanner
                    
                    // 统计信息
                    allergyStats
                    
                    // 过敏列表
                    if healthManager.allergies.isEmpty {
                        emptyState
                    } else {
                        ForEach(healthManager.allergies) { allergy in
                            AllergyCard(allergy: allergy)
                                .environmentObject(healthManager)
                                .onTapGesture {
                                    selectedAllergy = allergy
                                }
                        }
                    }
                }
                .padding()
            }
            
            // 添加按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddAllergy = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "EF4444"))
                            .clipShape(Circle())
                            .shadow(color: Color(hex: "EF4444").opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingAddAllergy) {
            AddAllergyView()
                .environmentObject(healthManager)
        }
        .sheet(item: $selectedAllergy) { allergy in
            AllergyDetailView(allergy: allergy)
                .environmentObject(healthManager)
        }
    }
    
    private var warningBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundColor(Color(hex: "EF4444"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("重要提醒")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("就医时请主动告知医生您的过敏史")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "FEE2E2"))
        .cornerRadius(12)
    }
    
    private var allergyStats: some View {
        HStack(spacing: 12) {
            ForEach(AllergyRecord.AllergyType.allCases, id: \.self) { type in
                let count = healthManager.allergies.filter { $0.allergyType == type }.count
                if count > 0 {
                    VStack(spacing: 8) {
                        Text(type.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .glassCard()
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("暂无过敏记录")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("点击右下角 + 按钮添加过敏史")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - 过敏卡片
struct AllergyCard: View {
    @EnvironmentObject var healthManager: HealthManager
    let allergy: AllergyRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(allergy.severity.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(allergy.allergen)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(allergy.allergyType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(allergy.severity.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(allergy.severity.color)
                    .cornerRadius(8)
            }
            
            if !allergy.symptoms.isEmpty {
                Divider()
                
                FlowLayout(spacing: 8) {
                    ForEach(allergy.symptoms, id: \.self) { symptom in
                        Text(symptom)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
            
            if let discoveredDate = allergy.discoveredDate {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("发现于 \(formatDate(discoveredDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .glassCard()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(allergy.severity.color.opacity(0.3), lineWidth: 2)
        )
        .contextMenu {
            Button(role: .destructive, action: {
                healthManager.deleteAllergy(allergy)
            }) {
                Label("删除", systemImage: "trash")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }
}

// MARK: - 流式布局（用于症状标签）
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - 添加过敏视图
struct AddAllergyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var healthManager: HealthManager
    
    @State private var allergen = ""
    @State private var allergyType: AllergyRecord.AllergyType = .drug
    @State private var severity: AllergyRecord.AllergySeverity = .mild
    @State private var symptoms: [String] = []
    @State private var symptomInput = ""
    @State private var discoveredDate: Date? = Date()
    @State private var hasDiscoveredDate = true
    @State private var notes = ""
    
    let commonSymptoms = ["皮疹", "瘙痒", "红肿", "呼吸困难", "恶心", "呕吐", "腹泻", "头晕", "心悸", "过敏性休克"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("过敏原信息")) {
                    TextField("过敏原名称", text: $allergen)
                    
                    Picker("过敏类型", selection: $allergyType) {
                        ForEach(AllergyRecord.AllergyType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("严重程度", selection: $severity) {
                        ForEach(AllergyRecord.AllergySeverity.allCases, id: \.self) { severity in
                            HStack {
                                Circle()
                                    .fill(severity.color)
                                    .frame(width: 12, height: 12)
                                Text(severity.rawValue)
                            }
                            .tag(severity)
                        }
                    }
                }
                
                Section(header: Text("症状")) {
                    HStack {
                        TextField("添加症状", text: $symptomInput)
                        Button(action: addSymptom) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(hex: "6366F1"))
                        }
                        .disabled(symptomInput.isEmpty)
                    }
                    
                    if !symptoms.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(symptoms, id: \.self) { symptom in
                                HStack(spacing: 4) {
                                    Text(symptom)
                                        .font(.caption)
                                    Button(action: {
                                        symptoms.removeAll { $0 == symptom }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    Text("常见症状")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(commonSymptoms, id: \.self) { symptom in
                            Button(action: {
                                if !symptoms.contains(symptom) {
                                    symptoms.append(symptom)
                                }
                            }) {
                                Text(symptom)
                                    .font(.caption)
                                    .foregroundColor(symptoms.contains(symptom) ? .white : Color(hex: "6366F1"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(symptoms.contains(symptom) ? Color(hex: "6366F1") : Color(hex: "6366F1").opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section(header: Text("发现日期")) {
                    Toggle("记录发现日期", isOn: $hasDiscoveredDate)
                    
                    if hasDiscoveredDate {
                        DatePicker("发现日期", selection: Binding(
                            get: { discoveredDate ?? Date() },
                            set: { discoveredDate = $0 }
                        ), displayedComponents: [.date])
                    }
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Button(action: saveAllergy) {
                    Text("保存")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color(hex: "EF4444"))
                .disabled(allergen.isEmpty)
            }
            .navigationTitle("添加过敏史")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addSymptom() {
        let trimmed = symptomInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !symptoms.contains(trimmed) {
            symptoms.append(trimmed)
            symptomInput = ""
        }
    }
    
    private func saveAllergy() {
        let allergy = AllergyRecord(
            allergen: allergen,
            allergyType: allergyType,
            severity: severity,
            symptoms: symptoms,
            discoveredDate: hasDiscoveredDate ? discoveredDate : nil,
            notes: notes
        )
        
        healthManager.addAllergy(allergy)
        dismiss()
    }
}

// MARK: - 过敏详情视图
struct AllergyDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var healthManager: HealthManager
    
    let allergy: AllergyRecord
    @State private var showingEditView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 警告横幅
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(allergy.severity.color)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(allergy.allergen)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack {
                                Text(allergy.allergyType.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                
                                Text(allergy.severity.rawValue)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(allergy.severity.color)
                                    .cornerRadius(6)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(allergy.severity.color.opacity(0.1))
                    .cornerRadius(16)
                    
                    // 症状
                    if !allergy.symptoms.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("症状")
                                .font(.headline)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(allergy.symptoms, id: \.self) { symptom in
                                    Text(symptom)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .glassCard()
                    }
                    
                    // 详细信息
                    VStack(alignment: .leading, spacing: 16) {
                        Text("详细信息")
                            .font(.headline)
                        
                        if let discoveredDate = allergy.discoveredDate {
                            DetailRow(
                                icon: "calendar",
                                label: "发现日期",
                                value: formatDate(discoveredDate)
                            )
                        }
                        
                        if !allergy.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "note.text")
                                        .foregroundColor(Color(hex: "6366F1"))
                                        .frame(width: 24)
                                    Text("备注")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(allergy.notes)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .padding(.leading, 32)
                            }
                        }
                    }
                    .padding()
                    .glassCard()
                    
                    // 安全提示
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(Color(hex: "3B82F6"))
                            Text("安全提示")
                                .font(.headline)
                        }
                        
                        Text("• 就医时请主动告知医生此过敏史")
                        Text("• 避免接触或使用此过敏原")
                        Text("• 如出现严重过敏反应，请立即就医")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(hex: "DBEAFE"))
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(DesignSystem.backgroundGradient.ignoresSafeArea())
            .navigationTitle("过敏详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEditView = true }) {
                            Label("编辑", systemImage: "pencil")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            healthManager.deleteAllergy(allergy)
                            dismiss()
                        }) {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditAllergyView(allergy: allergy)
                .environmentObject(healthManager)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

struct EditAllergyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var healthManager: HealthManager
    
    let allergy: AllergyRecord
    
    @State private var allergen: String
    @State private var allergyType: AllergyRecord.AllergyType
    @State private var severity: AllergyRecord.AllergySeverity
    @State private var symptoms: [String]
    @State private var symptomInput = ""
    @State private var discoveredDate: Date?
    @State private var hasDiscoveredDate: Bool
    @State private var notes: String
    
    let commonSymptoms = ["皮疹", "瘙痒", "红肿", "呼吸困难", "恶心", "呕吐", "腹泻", "头晕", "心悸", "过敏性休克"]
    
    init(allergy: AllergyRecord) {
        self.allergy = allergy
        _allergen = State(initialValue: allergy.allergen)
        _allergyType = State(initialValue: allergy.allergyType)
        _severity = State(initialValue: allergy.severity)
        _symptoms = State(initialValue: allergy.symptoms)
        _discoveredDate = State(initialValue: allergy.discoveredDate)
        _hasDiscoveredDate = State(initialValue: allergy.discoveredDate != nil)
        _notes = State(initialValue: allergy.notes)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("过敏原信息")) {
                    TextField("过敏原名称", text: $allergen)
                    
                    Picker("过敏类型", selection: $allergyType) {
                        ForEach(AllergyRecord.AllergyType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("严重程度", selection: $severity) {
                        ForEach(AllergyRecord.AllergySeverity.allCases, id: \.self) { severity in
                            HStack {
                                Circle()
                                    .fill(severity.color)
                                    .frame(width: 12, height: 12)
                                Text(severity.rawValue)
                            }
                            .tag(severity)
                        }
                    }
                }
                
                Section(header: Text("症状")) {
                    HStack {
                        TextField("添加症状", text: $symptomInput)
                        Button(action: addSymptom) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(hex: "6366F1"))
                        }
                        .disabled(symptomInput.isEmpty)
                    }
                    
                    if !symptoms.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(symptoms, id: \.self) { symptom in
                                HStack(spacing: 4) {
                                    Text(symptom)
                                        .font(.caption)
                                    Button(action: {
                                        symptoms.removeAll { $0 == symptom }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    Text("常见症状")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(commonSymptoms, id: \.self) { symptom in
                            Button(action: {
                                if !symptoms.contains(symptom) {
                                    symptoms.append(symptom)
                                }
                            }) {
                                Text(symptom)
                                    .font(.caption)
                                    .foregroundColor(symptoms.contains(symptom) ? .white : Color(hex: "6366F1"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(symptoms.contains(symptom) ? Color(hex: "6366F1") : Color(hex: "6366F1").opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section(header: Text("发现日期")) {
                    Toggle("记录发现日期", isOn: $hasDiscoveredDate)
                    
                    if hasDiscoveredDate {
                        DatePicker("发现日期", selection: Binding(
                            get: { discoveredDate ?? Date() },
                            set: { discoveredDate = $0 }
                        ), displayedComponents: [.date])
                    }
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Button(action: saveChanges) {
                    Text("保存修改")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color(hex: "EF4444"))
                .disabled(allergen.isEmpty)
            }
            .navigationTitle("编辑过敏史")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addSymptom() {
        let trimmed = symptomInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !symptoms.contains(trimmed) {
            symptoms.append(trimmed)
            symptomInput = ""
        }
    }
    
    private func saveChanges() {
        let updatedAllergy = AllergyRecord(
            id: allergy.id,
            allergen: allergen,
            allergyType: allergyType,
            severity: severity,
            symptoms: symptoms,
            discoveredDate: hasDiscoveredDate ? discoveredDate : nil,
            notes: notes
        )
        
        healthManager.updateAllergy(updatedAllergy)
        dismiss()
    }
}

