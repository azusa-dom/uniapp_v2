import SwiftUI
import Combine

// MARK: - Design (内嵌简版设计变量，避免外部依赖)
private enum DS {
    enum Color {
        static let primary = Color(hex: "6366F1")
        static let secondary = Color(hex: "8B5CF6")
        static let success = Color(hex: "10B981")
        static let warning = Color(hex: "F59E0B")
        static let danger = Color(hex: "EF4444")
        static let surface = Color.white.opacity(0.96)
        static let bgTop = Color(hex: "F8FAFC")
        static let bgMid = Color(hex: "EEF2FF")
        static let bgBot = Color(hex: "E0E7FF").opacity(0.3)
    }
    enum Radius { static let m: CGFloat = 14; static let l: CGFloat = 18 }
    enum Shadow { static let soft = Color.black.opacity(0.08) }
}

extension LinearGradient {
    static var appBackground: LinearGradient {
        .init(colors: [DS.Color.bgTop, DS.Color.bgMid, DS.Color.bgBot], startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - 角色 & 凭证
enum UserRole: String, CaseIterable, Identifiable {
    case student = "学生"
    case parent = "家长"

    var id: String { rawValue }
}

struct Credentials: Equatable {
    var email: String = ""
    var password: String = ""
    var role: UserRole = .student
}

// MARK: - Auth Service（可替换为你的后端）
protocol AuthProviding {
    func authenticate(_ cred: Credentials) async throws -> AuthToken
    func signInWithApple(role: UserRole) async throws -> AuthToken
    func signInWithGoogle(role: UserRole) async throws -> AuthToken
    var storedEmail: String? { get }
    func storeEmail(_ email: String?)
}

struct AuthToken {
    let userId: String
    let role: UserRole
}

@MainActor
final class MockAuthService: AuthProviding {
    private let storageKey = "login.saved.email"

    var storedEmail: String? { UserDefaults.standard.string(forKey: storageKey) }

    func storeEmail(_ email: String?) {
        if let email = email, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
    }

    func authenticate(_ cred: Credentials) async throws -> AuthToken {
        try await Task.sleep(nanoseconds: 600_000_000)
        let demo = [
            UserRole.student: "student@demo.edu",
            UserRole.parent: "parent@demo.edu"
        ]
        guard cred.password == "password123" else { throw AuthError.invalidPassword }
        guard cred.email.lowercased() == demo[cred.role] else { throw AuthError.accountNotFound }
        return AuthToken(userId: UUID().uuidString, role: cred.role)
    }

    func signInWithApple(role: UserRole) async throws -> AuthToken {
        try await Task.sleep(nanoseconds: 400_000_000)
        return AuthToken(userId: "apple.\(UUID().uuidString)", role: role)
    }

    func signInWithGoogle(role: UserRole) async throws -> AuthToken {
        try await Task.sleep(nanoseconds: 400_000_000)
        return AuthToken(userId: "google.\(UUID().uuidString)", role: role)
    }

    enum AuthError: LocalizedError {
        case invalidPassword, accountNotFound, network

        var errorDescription: String? {
            switch self {
            case .invalidPassword:
                return "密码不正确。"
            case .accountNotFound:
                return "未找到该账号/角色组合。"
            case .network:
                return "网络异常，请稍后重试。"
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var role: UserRole = .student
    @Published var showPassword: Bool = false
    @Published var rememberMe: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isValid: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let auth: AuthProviding

    init(auth: AuthProviding = MockAuthService()) {
        self.auth = auth
        if let saved = auth.storedEmail { self.email = saved }
        Publishers.CombineLatest($email, $password)
            .map { [weak self] email, pwd in
                self?.validateEmail(email) == true && pwd.count >= 8
            }
            .receive(on: RunLoop.main)
            .assign(to: &$isValid)
    }

    func signIn(onSuccess: @escaping (AuthToken) -> Void) {
        errorMessage = nil
        guard isValid else {
            errorMessage = "请输入有效邮箱与至少 8 位密码。"
            return
        }
        isLoading = true
        Task {
            do {
                let token = try await auth.authenticate(.init(email: email, password: password, role: role))
                if rememberMe { auth.storeEmail(email) } else { auth.storeEmail(nil) }
                isLoading = false
                onSuccess(token)
            } catch {
                isLoading = false
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "登录失败，请重试。"
            }
        }
    }

    func signInWithApple(onSuccess: @escaping (AuthToken) -> Void) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let token = try await auth.signInWithApple(role: role)
                if rememberMe { auth.storeEmail(email) }
                isLoading = false
                onSuccess(token)
            } catch {
                isLoading = false
                errorMessage = "Apple 登录失败，请稍后重试。"
            }
        }
    }

    func signInWithGoogle(onSuccess: @escaping (AuthToken) -> Void) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let token = try await auth.signInWithGoogle(role: role)
                if rememberMe { auth.storeEmail(email) }
                isLoading = false
                onSuccess(token)
            } catch {
                isLoading = false
                errorMessage = "Google 登录失败，请稍后重试。"
            }
        }
    }

    func toggleRole(_ newRole: UserRole) {
        role = newRole
        password = ""
    }

    private func validateEmail(_ email: String) -> Bool {
        let pat = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return email.range(of: pat, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

// MARK: - UI
struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    var onAuthenticated: (AuthToken) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(DS.Color.surface)
                                    .frame(width: 76, height: 76)
                                    .shadow(color: DS.Shadow.soft, radius: 12, x: 0, y: 6)
                                Image(systemName: "graduationcap.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(DS.Color.primary)
                            }
                            Text("UCL 学业与健康")
                                .font(.system(size: 24, weight: .bold))
                            Text("请登录以继续")
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)

                        HStack(spacing: 10) {
                            RoleChip(role: .student, selected: vm.role) { vm.toggleRole(.student) }
                            RoleChip(role: .parent, selected: vm.role) { vm.toggleRole(.parent) }
                        }
                        .padding(.top, 6)

                        VStack(spacing: 14) {
                            LabeledField(label: "邮箱", systemImage: "envelope.fill") {
                                TextField("student@demo.edu / parent@demo.edu", text: $vm.email)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .textContentType(.username)
                                    .submitLabel(.next)
                                    .accessibilityLabel("邮箱")
                            }

                            LabeledField(label: "密码", systemImage: "lock.fill") {
                                HStack {
                                    Group {
                                        if vm.showPassword {
                                            TextField("至少 8 位字符（示例：password123）", text: $vm.password)
                                        } else {
                                            SecureField("至少 8 位字符（示例：password123）", text: $vm.password)
                                        }
                                    }
                                    .textContentType(.password)
                                    .submitLabel(.go)

                                    Button {
                                        vm.showPassword.toggle()
                                    } label: {
                                        Image(systemName: vm.showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .accessibilityLabel(vm.showPassword ? "隐藏密码" : "显示密码")
                                }
                            }

                            HStack {
                                Toggle("记住我", isOn: $vm.rememberMe)
                                Spacer()
                                Button("忘记密码？") {
                                    // TODO: 跳转到找回密码（占位）
                                }
                                .font(.footnote)
                                .foregroundColor(DS.Color.primary)
                                .accessibilityHint("跳转到找回密码")
                            }
                            .padding(.horizontal, 4)
                            .padding(.top, 4)
                        }
                        .padding(.horizontal)

                        if let msg = vm.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(DS.Color.warning)
                                Text(msg)
                                    .foregroundColor(.secondary)
                            }
                            .font(.footnote)
                            .padding(.horizontal)
                        }

                        Button(action: { vm.signIn(onSuccess: onAuthenticated) }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("登录")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(vm.isValid ? LinearGradient(colors: [DS.Color.primary, DS.Color.secondary], startPoint: .leading, endPoint: .trailing) : Color.gray.opacity(0.2))
                            .foregroundColor(vm.isValid ? .white : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.l))
                            .shadow(color: vm.isValid ? DS.Color.primary.opacity(0.25) : .clear, radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(.plain)
                        .disabled(!vm.isValid || vm.isLoading)
                        .padding(.horizontal)

                        VStack(spacing: 12) {
                            HStack {
                                Rectangle().fill(Color.gray.opacity(0.25)).frame(height: 1)
                                Text("或").foregroundColor(.secondary).font(.footnote)
                                Rectangle().fill(Color.gray.opacity(0.25)).frame(height: 1)
                            }.padding(.horizontal)

                            HStack(spacing: 12) {
                                OAuthButton(title: "使用 Apple 登录", system: "apple.logo", bg: .black) {
                                    vm.signInWithApple(onSuccess: onAuthenticated)
                                }
                                OAuthButton(title: "使用 Google 登录", system: "g.circle.fill", bg: Color(hex: "FEE2E2")) {
                                    vm.signInWithGoogle(onSuccess: onAuthenticated)
                                }
                            }
                            .padding(.horizontal)
                        }

                        Text("登录即表示同意我们的《服务条款》和《隐私政策》")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 6)
                            .padding(.bottom, 24)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                if vm.isLoading {
                    Color.black.opacity(0.05).ignoresSafeArea()
                    ProgressView("正在登录…")
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 12).fill(DS.Color.surface))
                        .shadow(color: DS.Shadow.soft, radius: 10, x: 0, y: 6)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 子组件
private struct RoleChip: View {
    let role: UserRole
    let selected: UserRole
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: role == .student ? "person.fill" : "figure.2.and.child.holdinghands")
                Text(role.rawValue).fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundColor(selected == role ? .white : DS.Color.primary)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(selected == role ? DS.Color.primary : DS.Color.primary.opacity(0.12))
            .clipShape(Capsule())
            .shadow(color: selected == role ? DS.Color.primary.opacity(0.25) : .clear, radius: 8, x: 0, y: 2)
            .accessibilityLabel(Text("身份：\(role.rawValue)"))
            .accessibilityAddTraits(selected == role ? .isSelected : [])
        }
        .buttonStyle(.plain)
    }
}

private struct LabeledField<Content: View>: View {
    let label: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: systemImage).foregroundColor(DS.Color.secondary)
                Text(label).font(.footnote).foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)

            HStack {
                content
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: DS.Radius.m).fill(DS.Color.surface))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.m).stroke(Color.black.opacity(0.05)))
            .shadow(color: DS.Shadow.soft, radius: 10, x: 0, y: 4)
        }
    }
}

private struct OAuthButton: View {
    let title: String
    let system: String
    let bg: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: system)
                Text(title).fontWeight(.semibold)
            }
            .foregroundColor(system == "apple.logo" ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(system == "apple.logo" ? Color.black : bg)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.m))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 集成示例
struct LoginCoordinator: View {
    @State private var token: AuthToken? = nil

    var body: some View {
        Group {
            if let t = token {
                if t.role == .student {
                    StudentHomePlaceholder(onLogout: { token = nil })
                } else {
                    ParentHomePlaceholder(onLogout: { token = nil })
                }
            } else {
                LoginView { tok in token = tok }
            }
        }
    }
}

private struct StudentHomePlaceholder: View {
    let onLogout: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("学生端").font(.title).bold()
                Text("登录成功！").foregroundColor(.secondary)
                Button("退出登录", action: onLogout)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(DS.Color.primary))
                    .foregroundColor(.white)
            }
        }
    }
}

private struct ParentHomePlaceholder: View {
    let onLogout: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("家长端").font(.title).bold()
                Text("登录成功！").foregroundColor(.secondary)
                Button("退出登录", action: onLogout)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(DS.Color.secondary))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - 预览
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginCoordinator()
            .preferredColorScheme(.light)
    }
}


