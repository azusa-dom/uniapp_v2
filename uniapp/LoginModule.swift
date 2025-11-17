import SwiftUI
import Combine


// MARK: - Design (内嵌简版设计变量，避免外部依赖)
private enum DS {
    enum Palette {
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

// MARK: - 角色 & 凭证
// ✅ UserRole 现在定义在 AppState.swift 中

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

    // 🔴【修改】错误信息现在使用本地化键
    enum AuthError: LocalizedError {
        case invalidPassword, accountNotFound, network

        var errorDescription: String? {
            switch self {
            case .invalidPassword:
                return String(localized: "error.invalidPassword")
            case .accountNotFound:
                return String(localized: "error.accountNotFound")
            case .network:
                return String(localized: "error.network")
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
            // 🔴【修改】使用本地化键
            errorMessage = String(localized: "error.invalidCredentials")
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
                // 🔴【修改】使用本地化键
                errorMessage = (error as? LocalizedError)?.errorDescription ?? String(localized: "error.genericLoginFailed")
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
                // 🔴【修改】使用本地化键
                errorMessage = String(localized: "error.appleFailed")
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
                // 🔴【修改】使用本地化键
                errorMessage = String(localized: "error.googleFailed")
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
    @EnvironmentObject var loc: LocalizationService
    var onAuthenticated: (AuthToken) -> Void
    @State private var animateHero = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        headerSection
                        languageSwitcher // 🟢【新增】语言切换器
                        loginCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 36)
                }

                if vm.isLoading { loadingOverlay }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    animateHero = true
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var backgroundLayer: some View {
        LinearGradient(
            colors: [Color(hex: "EEF2FF"), Color(hex: "FDF2F8"), Color.white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            ZStack {
                Circle()
                    .fill(Color(hex: "A5B4FC").opacity(0.35))
                    .blur(radius: animateHero ? 110 : 80)
                    .frame(width: animateHero ? 320 : 260, height: animateHero ? 320 : 260)
                    .offset(x: -140, y: -220)
                Circle()
                    .fill(Color(hex: "FBCFE8").opacity(0.35))
                    .blur(radius: animateHero ? 140 : 90)
                    .frame(width: animateHero ? 360 : 280, height: animateHero ? 360 : 280)
                    .offset(x: 160, y: -180)
                Circle()
                    .fill(Color(hex: "C7D2FE").opacity(0.35))
                    .blur(radius: animateHero ? 120 : 60)
                    .frame(width: animateHero ? 300 : 220, height: animateHero ? 300 : 220)
                    .offset(x: 130, y: 280)
            }
        )
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("UniApp") // App 名称通常保持不变
                .font(.system(size: 34, weight: .bold))
            Text(loc.tr("app.tagline"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
    }
    
    // 语言切换器视图（使用 LocalizationService ）
    private var languageSwitcher: some View {
        Picker("language.select", selection: $loc.language) {
            ForEach(LocalizationService.Language.allCases) { lang in
                Text(lang.rawValue).tag(lang)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
    }

    private var loginCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(loc.tr("login.title"))
                    .font(.system(size: 22, weight: .semibold))
                Text(loc.tr("login.subtitle"))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            RoleSegmentedControl(selection: vm.role) { role in
                vm.toggleRole(role)
            }

            VStack(spacing: 16) {
                emailInput
                passwordInput
            }

            HStack {
                Toggle(loc.tr("login.rememberMe"), isOn: $vm.rememberMe)
                    .toggleStyle(SwitchToggleStyle(tint: DS.Palette.primary))
                Spacer()
                Button {
                    // TODO: Forgot password flow
                } label: {
                    Text(loc.tr("login.forgotPassword"))
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.plain)
                .foregroundColor(DS.Palette.primary)
            }

            if let msg = vm.errorMessage {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(DS.Palette.warning)
                    Text(msg) // msg 已经从 ViewModel 本地化了
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }

            VStack(spacing: 14) {
                Button {
                    vm.signIn(onSuccess: onAuthenticated)
                } label: {
                    HStack {
                        Spacer()
                        Text(loc.tr("login.button.signIn"))
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right.circle.fill")
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: vm.role == .student
                                ? [Color(hex: "6366F1"), Color(hex: "8B5CF6")]
                                : [Color(hex: "F472B6"), Color(hex: "EC4899")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: DS.Palette.primary.opacity(vm.role == .student ? 0.35 : 0.15), radius: 14, x: 0, y: 10)
                }
                .disabled(!vm.isValid)
                .opacity(vm.isValid ? 1 : 0.6)

                HStack {
                    Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 1)
                    Text(loc.tr("login.divider.orContinue"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 1)
                }

                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        SocialLoginButton(title: loc.tr("login.button.apple"), systemName: "apple.logo", background: .black, foreground: .white) {
                            vm.signInWithApple(onSuccess: onAuthenticated)
                        }
                        SocialLoginButton(title: loc.tr("login.button.google"), systemName: "g.circle.fill", background: Color.white, foreground: .primary) {
                            vm.signInWithGoogle(onSuccess: onAuthenticated)
                        }
                    }

                    HStack(spacing: 12) {
                        QuickDemoChip(title: loc.tr("login.demo.student"), icon: "graduationcap.fill", tint: Color(hex: "6366F1")) {
                            fillDemo(for: .student)
                        }
                        QuickDemoChip(title: loc.tr("login.demo.parent"), icon: "heart.fill", tint: Color(hex: "EC4899")) {
                            fillDemo(for: .parent)
                        }
                    }
                }
            }

            Text(loc.tr("login.terms"))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 30, x: 0, y: 20)
    }

    // 抽离子视图，降低类型推断复杂度
    private var emailInput: some View {
        let emailLabel: String = (vm.role == .student)
            ? loc.tr("input.student.email")
            : loc.tr("input.parent.account")
        let emailPlaceholder: String = (vm.role == .student)
            ? loc.tr("placeholder.student.email")
            : loc.tr("placeholder.parent.email")
        return GlassInput(label: emailLabel, icon: "person.crop.circle.fill") {
            TextField(emailPlaceholder, text: $vm.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
                .textContentType(.username)
                .submitLabel(.next)
        }
    }

    private var passwordInput: some View {
        GlassInput(label: loc.tr("input.password"), icon: "lock.fill") {
            HStack(spacing: 12) {
                if vm.showPassword {
                    TextField(loc.tr("placeholder.password"), text: $vm.password)
                        .textContentType(.password)
                        .submitLabel(.go)
                } else {
                    SecureField(loc.tr("placeholder.password"), text: $vm.password)
                        .textContentType(.password)
                        .submitLabel(.go)
                }

                Button { vm.showPassword.toggle() } label: {
                    Image(systemName: vm.showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(vm.showPassword ? loc.tr("a11y.hidePassword") : loc.tr("a11y.showPassword"))
            }
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.05).ignoresSafeArea()
            // 🔴【修改】使用本地化键
            ProgressView(loc.tr("login.loading"))
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        }
    }

    private func fillDemo(for role: UserRole) {
        vm.toggleRole(role)
        vm.email = role == .student ? "student@demo.edu" : "parent@demo.edu"
        vm.password = "password123"
        vm.errorMessage = nil
    }
}

// MARK: - 子组件
private struct RoleSegmentedControl: View {
    @EnvironmentObject var loc: LocalizationService
    let selection: UserRole
    let onSelect: (UserRole) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(UserRole.allCases, id: \.self) { role in
                Button {
                    onSelect(role)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: role == .student ? "graduationcap.fill" : "person.2.fill")
                        let textKey = role == .student ? "role.student" : "role.parent"
                        Text(loc.tr(textKey))
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(selection == role ? .white : .secondary)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            if selection == role {
                                LinearGradient(
                                    colors: role == .student
                                        ? [Color(hex: "6366F1"), Color(hex: "8B5CF6")]
                                        : [Color(hex: "F472B6"), Color(hex: "EC4899")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            } else {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white.opacity(0.6))
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
                .shadow(color: selection == role ? Color.black.opacity(0.15) : .clear, radius: 10, x: 0, y: 6)
            }
        }
        .padding(6)
        .background(Color.white.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct GlassInput<Content: View>: View {
    let label: String
    let icon: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label) // 这里的 label 已经被本地化了
                .font(.footnote)
                .foregroundColor(.secondary)
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "6366F1"))
                content
                    .foregroundColor(.primary)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white.opacity(0.9)))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

private struct SocialLoginButton: View {
    let title: String
    let systemName: String
    let background: Color
    let foreground: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                Text(title) // 这里的 title 已经被本地化了
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(background.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: background == .black ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct QuickDemoChip: View {
    let title: String
    let icon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title).font(.footnote.weight(.semibold)) // 这里的 title 已经被本地化了
            }
            .foregroundColor(tint)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(tint.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}


// MARK: - 集成示例
struct LoginCoordinator: View {
    // 全局本地化服务
    @StateObject private var loc = LocalizationService()
    
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
        // 注入 LocalizationService 供界面使用
        .environmentObject(loc)
    }
}

private struct StudentHomePlaceholder: View {
    let onLogout: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 🔴【修改】使用本地化键
                Text("home.student.title").font(.title).bold()
                Text("home.success").foregroundColor(.secondary)
                Button("home.logout", action: onLogout) // Button 标题会自动本地化
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(DS.Palette.primary))
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
                // 🔴【修改】使用本地化键
                Text("home.parent.title").font(.title).bold()
                Text("home.success").foregroundColor(.secondary)
                Button("home.logout", action: onLogout) // Button 标题会自动本地化
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(DS.Palette.secondary))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - 预览
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // 预览 LoginCoordinator 会自动包含 languageSettings
        LoginCoordinator()
            .preferredColorScheme(.light)
        
        // 你也可以单独预览英文或中文
        LoginCoordinator()
            .environment(\.locale, .init(identifier: "en"))
            .previewDisplayName("English Preview")
        
        LoginCoordinator()
            .environment(\.locale, .init(identifier: "zh-Hans"))
            .previewDisplayName("Chinese Preview")
    }
}
