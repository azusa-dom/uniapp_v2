//
//  StudentSettingsView.swift
//  uniapp
//
//  学生设置界面：支持更换头像和编辑个人信息
//  优化版本 - 跨平台兼容
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct StudentSettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAvatarPicker = false
    @State private var showingImagePicker = false
    #if canImport(UIKit)
    @State private var selectedImage: UIImage?
    #endif
    
    // 个人信息编辑状态
    @State private var editedName: String = ""
    @State private var editedEmail: String = ""
    @State private var editedStudentId: String = ""
    @State private var editedProgram: String = ""
    @State private var editedYear: String = ""
    @State private var editedPhone: String = ""
    @State private var editedBio: String = ""
    
    @State private var showingSaveAlert = false
    @State private var hasUnsavedChanges = false
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.backgroundGradient.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        avatarSection
                        personalInfoSection
                        academicInfoSection
                        contactSection
                        aboutSection
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("设置")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if hasUnsavedChanges {
                            showingSaveAlert = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveChanges()
                    } label: {
                        Text("保存")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(hasUnsavedChanges ? Color(hex: "6366F1") : .secondary)
                    }
                    .disabled(!hasUnsavedChanges)
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if hasUnsavedChanges {
                            showingSaveAlert = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveChanges()
                    } label: {
                        Text("保存")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(hasUnsavedChanges ? Color(hex: "6366F1") : .secondary)
                    }
                    .disabled(!hasUnsavedChanges)
                }
                #endif
            }
            .alert("未保存的更改", isPresented: $showingSaveAlert) {
                Button("放弃更改", role: .destructive) {
                    dismiss()
                }
                Button("继续编辑", role: .cancel) {}
                Button("保存") {
                    saveChanges()
                    dismiss()
                }
            } message: {
                Text("您有未保存的更改，是否要保存？")
            }
            .sheet(isPresented: $showingAvatarPicker) {
                AvatarPickerView(selectedIcon: $appState.avatarIcon)
                    .environmentObject(loc)
            }
            #if canImport(UIKit)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            #endif
            .onAppear {
                loadCurrentData()
            }
            .onChange(of: editedName) { _, _ in checkForChanges() }
            .onChange(of: editedEmail) { _, _ in checkForChanges() }
            .onChange(of: editedStudentId) { _, _ in checkForChanges() }
            .onChange(of: editedProgram) { _, _ in checkForChanges() }
            .onChange(of: editedYear) { _, _ in checkForChanges() }
            .onChange(of: editedPhone) { _, _ in checkForChanges() }
            .onChange(of: editedBio) { _, _ in checkForChanges() }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
    
    // MARK: - 头像区域（美化版）
    private var avatarSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text("头像设置")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 24) {
                // 当前头像显示 - 增强版
                ZStack {
                    // 外圈光晕
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "6366F1").opacity(0.3),
                                    Color(hex: "8B5CF6").opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 130, height: 130)
                        .shadow(color: Color(hex: "6366F1").opacity(0.4), radius: 20, x: 0, y: 8)
                    
                    #if canImport(UIKit)
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 130, height: 130)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: appState.avatarIcon)
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    #else
                    Image(systemName: appState.avatarIcon)
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundColor(.white)
                    #endif
                    
                    // 编辑按钮 - 美化版
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                showingAvatarPicker = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 42, height: 42)
                                        .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 8, x: 0, y: 4)
                                    
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "pencil")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .frame(width: 130, height: 130)
                }
                .padding(.vertical, 10)
                
                // 头像选择按钮 - 美化版
                HStack(spacing: 14) {
                    Button {
                        showingAvatarPicker = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                            Text("选择图标")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color(hex: "6366F1").opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    
                    #if canImport(UIKit)
                    Button {
                        showingImagePicker = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.fill.on.rectangle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("相册")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "6366F1"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "6366F1").opacity(0.3), lineWidth: 2)
                                )
                        )
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    #endif
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
        }
    }
    
    // MARK: - 个人信息区域
    private var personalInfoSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "person.text.rectangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "10B981"))
                
                Text("个人信息")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                SettingsTextField(
                    icon: "person.fill",
                    title: "姓名",
                    placeholder: "请输入姓名",
                    text: $editedName
                )
                
                SettingsTextField(
                    icon: "envelope.fill",
                    title: "邮箱",
                    placeholder: "请输入邮箱",
                    text: $editedEmail
                )
                
                SettingsTextField(
                    icon: "number",
                    title: "学号",
                    placeholder: "请输入学号",
                    text: $editedStudentId
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
            )
        }
    }
    
    // MARK: - 学业信息区域
    private var academicInfoSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "graduationcap.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "F59E0B"))
                
                Text("学业信息")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                SettingsTextField(
                    icon: "graduationcap.fill",
                    title: "专业",
                    placeholder: "请输入专业",
                    text: $editedProgram
                )
                
                SettingsTextField(
                    icon: "calendar",
                    title: "年级",
                    placeholder: "例如：Year 1",
                    text: $editedYear
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
            )
        }
    }
    
    // MARK: - 联系方式区域
    private var contactSection: some View {
        VStack(spacing: 18) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "EF4444").opacity(0.12))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "EF4444"))
                }
                
                Text("联系方式")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "10B981"))
            }
            
            VStack(spacing: 16) {
                SettingsTextField(
                    icon: "phone.fill",
                    title: "手机号",
                    placeholder: "请输入手机号",
                    text: $editedPhone
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
            )
        }
    }
    
    // MARK: - 个人简介区域（美化版）
    private var aboutSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "8B5CF6").opacity(0.12))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "text.quote")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "8B5CF6"))
                }
                
                Text("个人简介")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "character.cursor.ibeam")
                        .font(.system(size: 11))
                        .foregroundColor(editedBio.count > 180 ? Color(hex: "EF4444") : .secondary)
                    
                    Text("\(editedBio.count)/200")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(editedBio.count > 180 ? Color(hex: "EF4444") : .secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill((editedBio.count > 180 ? Color(hex: "EF4444") : Color.gray).opacity(0.1))
                )
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topLeading) {
                    if editedBio.isEmpty {
                        Text("介绍一下你自己吧...")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                    }
                    
                    TextEditor(text: $editedBio)
                        .font(.system(size: 15))
                        .frame(height: 120)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(editedBio.isEmpty ? Color.gray.opacity(0.2) : Color(hex: "8B5CF6").opacity(0.3), lineWidth: 1.5)
                        )
                )
                .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
            )
        }
    }
    
    // MARK: - 辅助方法
    private func loadCurrentData() {
        editedName = appState.studentName
        editedEmail = appState.studentEmail
        editedStudentId = appState.studentId
        editedProgram = appState.studentProgram
        editedYear = appState.studentYear
        editedPhone = appState.studentPhone
        editedBio = appState.studentBio
    }
    
    private func checkForChanges() {
        hasUnsavedChanges = 
            editedName != appState.studentName ||
            editedEmail != appState.studentEmail ||
            editedStudentId != appState.studentId ||
            editedProgram != appState.studentProgram ||
            editedYear != appState.studentYear ||
            editedPhone != appState.studentPhone ||
            editedBio != appState.studentBio
    }
    
    private func saveChanges() {
        appState.studentName = editedName
        appState.studentEmail = editedEmail
        appState.studentId = editedStudentId
        appState.studentProgram = editedProgram
        appState.studentYear = editedYear
        appState.studentPhone = editedPhone
        appState.studentBio = editedBio
        
        hasUnsavedChanges = false
        
        // 显示保存成功提示
        withAnimation {
            // 可以添加一个保存成功的提示
        }
    }
}

// MARK: - 设置文本框组件（美化版）
struct SettingsTextField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "6366F1").opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(text.isEmpty ? Color.gray.opacity(0.2) : Color(hex: "6366F1").opacity(0.3), lineWidth: 1.5)
                        )
                )
                .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
        }
    }
}

#if canImport(UIKit)
// MARK: - 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif

// MARK: - 预览
struct StudentSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        StudentSettingsView()
            .environmentObject(AppState())
            .environmentObject(LocalizationService())
    }
}
