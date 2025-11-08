import SwiftUI

// MARK: - GP 预约主视图
struct AppointmentBookingView: View {
    @StateObject private var healthData = HealthDataManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep = 1
    @State private var selectedDepartment: Department?
    @State private var selectedDoctor: Doctor?
    @State private var selectedDate: Date = Date()
    @State private var selectedTimeSlot: AppointmentTimeSlot?
    @State private var patientName = ""
    @State private var patientPhone = ""
    @State private var symptoms = ""
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [
                        Color(hex: "F8FAFC"),
                        Color(hex: "EEF2FF"),
                        Color(hex: "E0E7FF").opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 进度指示器
                    StepIndicator(currentStep: currentStep)
                        .padding()
                        .background(Color.white.opacity(0.9))
                    
                    // 内容区域
                    ScrollView {
                        VStack(spacing: 20) {
                            switch currentStep {
                            case 1:
                                DoctorSelectionStep(
                                    selectedDepartment: $selectedDepartment,
                                    selectedDoctor: $selectedDoctor
                                )
                            case 2:
                                TimeSelectionStep(
                                    selectedDate: $selectedDate,
                                    selectedTimeSlot: $selectedTimeSlot,
                                    doctor: selectedDoctor
                                )
                            case 3:
                                InformationStep(
                                    patientName: $patientName,
                                    patientPhone: $patientPhone,
                                    symptoms: $symptoms
                                )
                            case 4:
                                ConfirmationStep(
                                    doctor: selectedDoctor,
                                    date: selectedDate,
                                    timeSlot: selectedTimeSlot,
                                    patientName: patientName,
                                    symptoms: symptoms
                                )
                            default:
                                EmptyView()
                            }
                        }
                        .padding()
                    }
                    
                    // 底部按钮
                    BottomButtons(
                        currentStep: $currentStep,
                        canProceed: canProceedToNextStep(),
                        onBack: handleBack,
                        onNext: handleNext,
                        onConfirm: handleConfirm
                    )
                    .background(Color.white.opacity(0.95))
                }
            }
            .navigationTitle("预约面诊")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .alert("预约成功", isPresented: $showConfirmation) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("您的预约已成功提交！\n预约时间：\(formatDateTime())")
        }
    }
    
    private func canProceedToNextStep() -> Bool {
        switch currentStep {
        case 1:
            return selectedDoctor != nil
        case 2:
            return selectedTimeSlot != nil
        case 3:
            return !patientName.isEmpty && !patientPhone.isEmpty && !symptoms.isEmpty
        case 4:
            return true
        default:
            return false
        }
    }
    
    private func handleBack() {
        withAnimation {
            currentStep -= 1
        }
    }
    
    private func handleNext() {
        withAnimation {
            currentStep += 1
        }
    }
    
    private func handleConfirm() {
        // 创建新预约
        guard let doctor = selectedDoctor, let timeSlot = selectedTimeSlot else { return }
        
        let appointment = MedicalAppointment(
            appointmentNumber: "UCL-\(Date().timeIntervalSince1970)",
            doctor: doctor,
            date: selectedDate,
            timeSlot: timeSlot.time,
            location: "\(selectedDepartment?.name ?? "全科")诊室",
            appointmentType: .newSymptom,
            reason: [symptoms],
            description: symptoms,
            needsTranslation: false,
            attachments: [],
            emergencyContact: EmergencyContact(name: patientName, phone: patientPhone, relationship: "本人"),
            status: .scheduled,
            remindersSent: []
        )
        
        healthData.appointments.append(appointment)
        showConfirmation = true
    }
    
    private func formatDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let dateString = dateFormatter.string(from: selectedDate)
        return "\(dateString) \(selectedTimeSlot?.time ?? "")"
    }
}

// MARK: - 进度指示器
struct StepIndicator: View {
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...4, id: \.self) { step in
                HStack(spacing: 0) {
                    // 圆圈
                    ZStack {
                        Circle()
                            .fill(step <= currentStep ? Color(hex: "6366F1") : Color.gray.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        if step < currentStep {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(step)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(step == currentStep ? .white : .gray)
                        }
                    }
                    
                    // 连接线
                    if step < 4 {
                        Rectangle()
                            .fill(step < currentStep ? Color(hex: "6366F1") : Color.gray.opacity(0.2))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - 步骤1：选择医生
struct DoctorSelectionStep: View {
    @StateObject private var healthData = HealthDataManager.shared
    @Binding var selectedDepartment: Department?
    @Binding var selectedDoctor: Doctor?
    
    let departments = Department.allDepartments
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("选择科室")
                .font(.system(size: 20, weight: .bold))
            
            // 科室选择
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(departments) { dept in
                        DepartmentCard(
                            department: dept,
                            isSelected: selectedDepartment?.id == dept.id
                        )
                        .onTapGesture {
                            selectedDepartment = dept
                            selectedDoctor = nil
                        }
                    }
                }
            }
            
            Text("选择医生")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 10)
            
            // 医生列表
            if let department = selectedDepartment {
                VStack(spacing: 12) {
                    ForEach(healthData.doctors.filter { $0.department == department.name }) { doctor in
                        DoctorCard(
                            doctor: doctor,
                            isSelected: selectedDoctor?.id == doctor.id
                        )
                        .onTapGesture {
                            selectedDoctor = doctor
                        }
                    }
                }
            } else {
                Text("请先选择科室")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
    }
}

// MARK: - 科室卡片
struct DepartmentCard: View {
    let department: Department
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color(hex: department.color) : Color(hex: department.color).opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: department.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color(hex: department.color))
            }
            
            Text(department.name)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? Color(hex: department.color) : .primary)
        }
        .frame(width: 90)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color(hex: department.color).opacity(0.1) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(hex: department.color) : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - 医生卡片
struct DoctorCard: View {
    let doctor: Doctor
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // 医生头像
            ZStack {
                Circle()
                    .fill(Color(hex: "6366F1").opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Text(String(doctor.name.prefix(1)))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(hex: "6366F1"))
            }
            
            // 医生信息
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(doctor.name)
                        .font(.system(size: 17, weight: .semibold))
                    
                    Text(doctor.title)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "F59E0B"))
                        .clipShape(Capsule())
                }
                
                Text(doctor.specialization)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 15) {
                    Label("\(doctor.experience)年", systemImage: "cross.case")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if doctor.available {
                        Label("可预约", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "10B981"))
                    }
                }
            }
            
            Spacer()
            
            // 选中指示器
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "6366F1"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color(hex: "6366F1").opacity(0.05) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(hex: "6366F1") : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
    }
}

// MARK: - 步骤2：选择时间
struct TimeSelectionStep: View {
    @Binding var selectedDate: Date
    @Binding var selectedTimeSlot: AppointmentTimeSlot?
    let doctor: Doctor?
    
    @State private var availableSlots: [AppointmentTimeSlot] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("选择日期")
                .font(.system(size: 20, weight: .bold))
            
            // 日期选择器
            DatePicker(
                "预约日期",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(Color(hex: "6366F1"))
            .background(Color.white)
            .cornerRadius(12)
            .onChange(of: selectedDate) { _, _ in
                loadAvailableSlots()
            }
            
            Text("选择时间段")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 10)
            
            // 时间段选择
            if availableSlots.isEmpty {
                Text("当日无可用时间段")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(availableSlots) { slot in
                        TimeSlotCard(
                            slot: slot,
                            isSelected: selectedTimeSlot?.id == slot.id
                        )
                        .onTapGesture {
                            selectedTimeSlot = slot
                        }
                    }
                }
            }
        }
        .onAppear {
            loadAvailableSlots()
        }
    }
    
    private func loadAvailableSlots() {
        // 生成当日可用时间段
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(selectedDate)
        let currentHour = calendar.component(.hour, from: Date())
        
        availableSlots = [
            AppointmentTimeSlot(time: "09:00", isAvailable: !isToday || currentHour < 9, isRecommended: false),
            AppointmentTimeSlot(time: "09:30", isAvailable: !isToday || currentHour < 9, isRecommended: false),
            AppointmentTimeSlot(time: "10:00", isAvailable: !isToday || currentHour < 10, isRecommended: true),
            AppointmentTimeSlot(time: "10:30", isAvailable: !isToday || currentHour < 10, isRecommended: false),
            AppointmentTimeSlot(time: "11:00", isAvailable: !isToday || currentHour < 11, isRecommended: false),
            AppointmentTimeSlot(time: "14:00", isAvailable: !isToday || currentHour < 14, isRecommended: false),
            AppointmentTimeSlot(time: "14:30", isAvailable: !isToday || currentHour < 14, isRecommended: true),
            AppointmentTimeSlot(time: "15:00", isAvailable: !isToday || currentHour < 15, isRecommended: false),
            AppointmentTimeSlot(time: "15:30", isAvailable: !isToday || currentHour < 15, isRecommended: false),
            AppointmentTimeSlot(time: "16:00", isAvailable: !isToday || currentHour < 16, isRecommended: false),
            AppointmentTimeSlot(time: "16:30", isAvailable: !isToday || currentHour < 16, isRecommended: false)
        ].filter { $0.isAvailable }
    }
}

// MARK: - 时间段卡片
struct TimeSlotCard: View {
    let slot: AppointmentTimeSlot
    let isSelected: Bool
    
    var body: some View {
        Text(slot.time)
            .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color(hex: "6366F1") : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - 步骤3：填写信息
struct InformationStep: View {
    @Binding var patientName: String
    @Binding var patientPhone: String
    @Binding var symptoms: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("填写就诊信息")
                .font(.system(size: 20, weight: .bold))
            
            VStack(spacing: 16) {
                // 患者姓名
                VStack(alignment: .leading, spacing: 8) {
                    Text("患者姓名")
                        .font(.system(size: 15, weight: .medium))
                    
                    TextField("请输入患者姓名", text: $patientName)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                
                // 联系电话
                VStack(alignment: .leading, spacing: 8) {
                    Text("联系电话")
                        .font(.system(size: 15, weight: .medium))
                    
                    TextField("请输入联系电话", text: $patientPhone)
                        .keyboardType(.phonePad)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                
                // 症状描述
                VStack(alignment: .leading, spacing: 8) {
                    Text("症状描述")
                        .font(.system(size: 15, weight: .medium))
                    
                    TextEditor(text: $symptoms)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    
                    if symptoms.isEmpty {
                        Text("请详细描述您的症状")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.top, -110)
                            .padding(.leading, 12)
                    }
                }
            }
        }
    }
}

// MARK: - 步骤4：确认预约
struct ConfirmationStep: View {
    let doctor: Doctor?
    let date: Date
    let timeSlot: AppointmentTimeSlot?
    let patientName: String
    let symptoms: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("确认预约信息")
                .font(.system(size: 20, weight: .bold))
            
            VStack(spacing: 16) {
                // 医生信息
                ConfirmationRow(
                    icon: "stethoscope",
                    title: "医生",
                    content: doctor?.name ?? "",
                    subtitle: doctor?.title ?? ""
                )
                
                // 时间信息
                ConfirmationRow(
                    icon: "calendar",
                    title: "日期",
                    content: formatDate(date),
                    subtitle: timeSlot?.time ?? ""
                )
                
                // 患者信息
                ConfirmationRow(
                    icon: "person.fill",
                    title: "患者",
                    content: patientName,
                    subtitle: nil
                )
                
                // 症状描述
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "6366F1").opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "text.alignleft")
                                .foregroundColor(Color(hex: "6366F1"))
                        }
                        
                        Text("症状描述")
                            .font(.system(size: 15, weight: .medium))
                        
                        Spacer()
                    }
                    
                    Text(symptoms)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
            }
            
            // 温馨提示
            VStack(alignment: .leading, spacing: 10) {
                Text("温馨提示")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "F59E0B"))
                
                VStack(alignment: .leading, spacing: 6) {
                    BulletPoint(text: "请提前15分钟到达诊室")
                    BulletPoint(text: "携带相关病历和检查报告")
                    BulletPoint(text: "如需取消请提前1天联系")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "FEF3C7"))
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - 确认信息行
struct ConfirmationRow: View {
    let icon: String
    let title: String
    let content: String
    let subtitle: String?
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "6366F1").opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "6366F1"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Text(content)
                    .font(.system(size: 16, weight: .medium))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
}

// MARK: - 提示项
struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "F59E0B"))
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 底部按钮
struct BottomButtons: View {
    @Binding var currentStep: Int
    let canProceed: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if currentStep > 1 {
                Button(action: onBack) {
                    Text("上一步")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "6366F1"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "6366F1"), lineWidth: 1.5)
                        )
                }
            }
            
            Button(action: currentStep == 4 ? onConfirm : onNext) {
                Text(currentStep == 4 ? "确认预约" : "下一步")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceed ? Color(hex: "6366F1") : Color.gray.opacity(0.3))
                    .cornerRadius(12)
            }
            .disabled(!canProceed)
        }
        .padding()
    }
}

// MARK: - 数据模型
struct Department: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    
    static let allDepartments = [
        Department(name: "全科", icon: "heart.text.square", color: "6366F1"),
        Department(name: "骨科", icon: "figure.walk", color: "10B981"),
        Department(name: "内科", icon: "cross.case", color: "F59E0B"),
        Department(name: "皮肤科", icon: "hand.raised", color: "EC4899"),
        Department(name: "眼科", icon: "eye", color: "8B5CF6")
    ]
}

// 预约专用时间段（避免与 HealthModels 中的 TimeSlot 冲突）
struct AppointmentTimeSlot: Identifiable {
    let id = UUID()
    let time: String
    let isAvailable: Bool
    let isRecommended: Bool
}

#Preview {
    AppointmentBookingView()
}
