import SwiftUI
import Combine

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: Theme
    @Published var availableThemes: [Theme]

    private let selectedThemeKey = "selectedThemeId"

    private init() {
        let themes = Theme.allThemes
        self.availableThemes = themes

        let savedId = UserDefaults.standard.string(forKey: selectedThemeKey) ?? "classic"
        self.currentTheme = themes.first(where: { $0.id == savedId }) ?? .classic
    }

    func selectTheme(_ theme: Theme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.id, forKey: selectedThemeKey)
    }

    func addCustomTheme(_ theme: Theme) {
        availableThemes.append(theme)
    }
}
