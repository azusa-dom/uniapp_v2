import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

enum DesignSystem {
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(hex: "F8FAFC"),
            Color(hex: "EEF2FF"),
            Color(hex: "E0E7FF").opacity(0.3)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

func gradeColor(for score: Int) -> Color {
    switch score {
    case 70...:
        return Color(hex: "10B981")
    case 60..<70:
        return Color(hex: "F59E0B")
    default:
        return Color(hex: "EF4444")
    }
}

func degreeClassification(for average: Double) -> String {
    if average >= 70 { return "一等学位（First）" }
    if average >= 60 { return "二等一（Upper Second）" }
    if average >= 50 { return "二等二（Lower Second）" }
    return "三等/及格"
}

func degreeLevel(for average: Double) -> String {
    degreeClassification(for: average)
}
