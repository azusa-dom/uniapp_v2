//
//  StudentSettingsView.swift
//  uniapp
//

import SwiftUI

struct StudentSettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loc: LocalizationService
    @Environment(\.dismiss) private var dismiss

    @State private var showingAvatarPicker = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?

    // 可编辑字段
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
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex:"F8FAFC"), Color(hex:"EEF2FF"), Color(hex:"E0E7FF").opacity(0.4)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

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
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
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
                            .foregroundColor(hasUnsavedChanges ? Color(hex:"6366F1") : .secondary)
                    }
                    .disabled(!hasUnsavedChanges)
                }
            }
            .alert("未保存的更改", isPresented: $showingSaveAlert) {
                Button("放弃更改", role: .destructive) { dismiss() }
                Button("继续编辑", role: .cancel) {}
                Button("保存") { saveChanges(); dismiss() }
            } message: {
                Text("您有未保存的更改，是否要保存？")
            }
            .sheet(isPresented: $showingAvatarPicker) {
                AvatarPickerView(selectedIcon: $appState.avatarIcon)
                    .environmentObject(loc)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onAppear { loadCurrentData() }
            // ✅ iOS 17：onChange 新签名（零参数版），避免弃用警告
            .onChange(of: editedName) { checkForChanges() }
            .onChange(of: editedEmail) { checkForChanges() }
            .onChange(of: editedStudentId) { checkForChanges() }
            .onChange(of: editedProgram) { checkForChanges() }
            .onChange(of: editedYear) { checkForChanges() }
            .onChange(of: editedPhone) { checkForChanges() }
            .onChange(of: editedBio) { checkForChanges() }
        }
    }

    // MARK: - 头像区域
    private var avatarSection: some View {
        VStack(spacing: 16) {
            Text("头像设置").font(.system(size: 18, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex:"6366F1"), Color(hex:"8B5CF6")],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(hex:"6366F1").opacity(0.3), radius: 15, x: 0, y: 5)

                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable().scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: appState.avatarIcon)
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Menu {
                                Button("选择图标") { showingAvatarPicker = true }
                                Button("相册上传") { showingImagePicker = true }
                            } label: {
                                ZStack {
                                    Circle().fill(Color.white).frame(width: 36, height: 36)
                                    Image(systemName: "camera.fill").font(.system(size: 16)).foregroundColor(Color(hex:"6366F1"))
                                }
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .frame(width: 120, height: 120)
                }

                HStack(spacing: 12) {
                    Button {
                        showingAvatarPicker = true
                    } label: {
                        HStack { Image(systemName:"paintbrush.pointed.fill"); Text("选择图标").fontWeight(.semibold) }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Color(hex:"6366F1")).clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button { showingImagePicker = true } label: {
                        HStack { Image(systemName:"photo.fill"); Text("相册上传").fontWeight(.semibold) }
                            .foregroundColor(Color(hex:"6366F1"))
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Color(hex:"6366F1").opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - 个人信息
    private var personalInfoSection: some View {
        VStack(spacing: 16) {
            SectionTitle("个人信息")
            VStack(spacing: 12) {
                SettingsTextField(icon:"person.fill", title:"姓名", placeholder:"请输入姓名", text: $editedName)
                SettingsTextField(icon:"envelope.fill", title:"邮箱", placeholder:"请输入邮箱", text: $editedEmail, keyboardType: .emailAddress)
                SettingsTextField(icon:"number", title:"学号", placeholder:"请输入学号", text: $editedStudentId)
            }
            .padding(16)
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - 学业信息
    private var academicInfoSection: some View {
        VStack(spacing: 16) {
            SectionTitle("学业信息")
            VStack(spacing: 12) {
                SettingsTextField(icon:"graduationcap.fill", title:"专业", placeholder:"请输入专业", text: $editedProgram)
                SettingsTextField(icon:"calendar", title:"年级", placeholder:"例如：Year 1", text: $editedYear)
            }
            .padding(16)
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - 联系方式
    private var contactSection: some View {
        VStack(spacing: 16) {
            SectionTitle("联系方式")
            VStack(spacing: 12) {
                SettingsTextField(icon:"phone.fill", title:"手机号", placeholder:"请输入手机号", text: $editedPhone, keyboardType: .phonePad)
            }
            .padding(16)
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - 简介
    private var aboutSection: some View {
        VStack(spacing: 16) {
            SectionTitle("个人简介")
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName:"doc.text.fill").font(.system(size: 14)).foregroundColor(Color(hex:"6366F1"))
                    Text("简介").font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
                }
                TextEditor(text: $editedBio)
                    .font(.system(size: 15)).frame(height: 100)
                    .padding(8).background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(16)
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - 辅助
    private func loadCurrentData() {
        editedName = appState.studentName
        editedEmail = appState.studentEmail
        editedStudentId = appState.studentId
        editedProgram = appState.studentProgram
        editedYear = appState.studentYear
        editedPhone = appState.studentPhone
        editedBio = appState.studentBio
        hasUnsavedChanges = false
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
    }

    private func SectionTitle(_ t: String) -> some View {
        Text(t).font(.system(size: 18, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 通用输入组件
struct SettingsTextField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(Color(hex:"6366F1"))
                Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
            }
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .keyboardType(keyboardType)
        }
    }
}

// MARK: - 图片选择器（相册）
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let edited = info[.editedImage] as? UIImage { parent.image = edited }
            else if let original = info[.originalImage] as? UIImage { parent.image = original }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}

