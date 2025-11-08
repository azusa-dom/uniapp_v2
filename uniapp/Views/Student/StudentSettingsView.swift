//
//  StudentSettingsView.swift
//  uniapp
//
//  学生设置界面：支持更换头像和编辑个人信息
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
    }
    
    // MARK: - 头像区域
    private var avatarSection: some View {
        VStack(spacing: 16) {
            Text("头像设置")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 20) {
                // 当前头像显示
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 15, x: 0, y: 5)
                    
                    #if canImport(UIKit)
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: appState.avatarIcon)
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    #else
                    Image(systemName: appState.avatarIcon)
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(.white)
                    #endif
                    
                    // 编辑按钮
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                // 选择更换方式
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "6366F1"))
                                }
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .frame(width: 120, height: 120)
                }
                
                // 头像选择按钮
                HStack(spacing: 12) {
                    Button {
                        showingAvatarPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "paintbrush.pointed.fill")
                                .font(.system(size: 16))
                            Text("选择图标")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "6366F1"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button {
                        showingImagePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 16))
                            Text("相册上传")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "6366F1"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "6366F1").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - 个人信息区域
    private var personalInfoSection: some View {
        VStack(spacing: 16) {
            Text("个人信息")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
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
                    text: $editedEmail,
                    keyboardType: .emailAddress
                )
                
                SettingsTextField(
                    icon: "number",
                    title: "学号",
                    placeholder: "请输入学号",
                    text: $editedStudentId
                )
            }
            .padding(16)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - 学业信息区域
    private var academicInfoSection: some View {
        VStack(spacing: 16) {
            Text("学业信息")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
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
            .padding(16)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - 联系方式区域
    private var contactSection: some View {
        VStack(spacing: 16) {
            Text("联系方式")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                #if canImport(UIKit)
                SettingsTextField(
                    icon: "phone.fill",
                    title: "手机号",
                    placeholder: "请输入手机号",
                    text: $editedPhone,
                    keyboardType: .phonePad
                )
                #else
                SettingsTextField(
                    icon: "phone.fill",
                    title: "手机号",
                    placeholder: "请输入手机号",
                    text: $editedPhone
                )
                #endif
            }
            .padding(16)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - 个人简介区域
    private var aboutSection: some View {
        VStack(spacing: 16) {
            Text("个人简介")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6366F1"))
                    
                    Text("简介")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                TextEditor(text: $editedBio)
                    .font(.system(size: 15))
                    .frame(height: 100)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(16)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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

// MARK: - 设置文本框组件
struct SettingsTextField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    #if canImport(UIKit)
    var keyboardType: UIKeyboardType = .default
    #endif
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            #if canImport(UIKit)
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .keyboardType(keyboardType)
            #else
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            #endif
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
