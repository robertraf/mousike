import SwiftUI

struct Theme: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let background: Color
    let backgroundSecondary: Color
    let foreground: Color
    let accent: Color
    let accentSecondary: Color
    let textPrimary: Color
    let textSecondary: Color
    let visualizerColor: Color
    let visualizerColorSecondary: Color
    let borderColor: Color
    let buttonColor: Color
    let sliderTrackColor: Color
    let sliderThumbColor: Color
    let playlistBackground: Color
    let playlistSelectedRow: Color
    let playlistText: Color
    let playlistPlayingText: Color
    let titleBarGradientStart: Color
    let titleBarGradientEnd: Color
    let displayBackground: Color
    let displayText: Color

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Built-in Themes

extension Theme {

    /// Classic Winamp dark theme
    static let classic = Theme(
        id: "classic",
        name: "Classic",
        background: Color(hex: "232323"),
        backgroundSecondary: Color(hex: "1A1A1A"),
        foreground: Color(hex: "2D2D2D"),
        accent: Color(hex: "00C85A"),
        accentSecondary: Color(hex: "FFD700"),
        textPrimary: Color(hex: "00FF00"),
        textSecondary: Color(hex: "8A8A8A"),
        visualizerColor: Color(hex: "00FF00"),
        visualizerColorSecondary: Color(hex: "FFFF00"),
        borderColor: Color(hex: "3A3A3A"),
        buttonColor: Color(hex: "B8B8B8"),
        sliderTrackColor: Color(hex: "0A0A0A"),
        sliderThumbColor: Color(hex: "C0C0C0"),
        playlistBackground: Color(hex: "0A0A14"),
        playlistSelectedRow: Color(hex: "0000C6"),
        playlistText: Color(hex: "00FF00"),
        playlistPlayingText: Color(hex: "FFFFFF"),
        titleBarGradientStart: Color(hex: "0000C6"),
        titleBarGradientEnd: Color(hex: "000070"),
        displayBackground: Color(hex: "0A0A14"),
        displayText: Color(hex: "00FF00")
    )

    /// Modern dark theme
    static let midnight = Theme(
        id: "midnight",
        name: "Midnight",
        background: Color(hex: "1C1C2E"),
        backgroundSecondary: Color(hex: "16162A"),
        foreground: Color(hex: "252540"),
        accent: Color(hex: "7C5CFC"),
        accentSecondary: Color(hex: "FF6B9D"),
        textPrimary: Color(hex: "E0E0FF"),
        textSecondary: Color(hex: "8888AA"),
        visualizerColor: Color(hex: "7C5CFC"),
        visualizerColorSecondary: Color(hex: "FF6B9D"),
        borderColor: Color(hex: "3A3A5C"),
        buttonColor: Color(hex: "CCCCEE"),
        sliderTrackColor: Color(hex: "0E0E1A"),
        sliderThumbColor: Color(hex: "7C5CFC"),
        playlistBackground: Color(hex: "12122A"),
        playlistSelectedRow: Color(hex: "7C5CFC").opacity(0.3),
        playlistText: Color(hex: "C0C0E0"),
        playlistPlayingText: Color(hex: "FF6B9D"),
        titleBarGradientStart: Color(hex: "7C5CFC"),
        titleBarGradientEnd: Color(hex: "4B3CA8"),
        displayBackground: Color(hex: "0E0E20"),
        displayText: Color(hex: "7C5CFC")
    )

    /// Retrowave / Synthwave theme
    static let retrowave = Theme(
        id: "retrowave",
        name: "Retrowave",
        background: Color(hex: "2B1055"),
        backgroundSecondary: Color(hex: "1A0A3E"),
        foreground: Color(hex: "3D1A6E"),
        accent: Color(hex: "FF2975"),
        accentSecondary: Color(hex: "00D4FF"),
        textPrimary: Color(hex: "FF71CE"),
        textSecondary: Color(hex: "B967FF"),
        visualizerColor: Color(hex: "FF2975"),
        visualizerColorSecondary: Color(hex: "00D4FF"),
        borderColor: Color(hex: "5C2D91"),
        buttonColor: Color(hex: "FF71CE"),
        sliderTrackColor: Color(hex: "150833"),
        sliderThumbColor: Color(hex: "FF2975"),
        playlistBackground: Color(hex: "150833"),
        playlistSelectedRow: Color(hex: "FF2975").opacity(0.3),
        playlistText: Color(hex: "01CDFE"),
        playlistPlayingText: Color(hex: "FF71CE"),
        titleBarGradientStart: Color(hex: "FF2975"),
        titleBarGradientEnd: Color(hex: "7B2D8E"),
        displayBackground: Color(hex: "0D0221"),
        displayText: Color(hex: "01CDFE")
    )

    /// Amber terminal theme
    static let amber = Theme(
        id: "amber",
        name: "Amber Terminal",
        background: Color(hex: "1A1400"),
        backgroundSecondary: Color(hex: "120E00"),
        foreground: Color(hex: "2A2000"),
        accent: Color(hex: "FFB000"),
        accentSecondary: Color(hex: "FF8C00"),
        textPrimary: Color(hex: "FFB000"),
        textSecondary: Color(hex: "8B6914"),
        visualizerColor: Color(hex: "FFB000"),
        visualizerColorSecondary: Color(hex: "FF8C00"),
        borderColor: Color(hex: "3D2E00"),
        buttonColor: Color(hex: "FFB000"),
        sliderTrackColor: Color(hex: "0D0A00"),
        sliderThumbColor: Color(hex: "FFB000"),
        playlistBackground: Color(hex: "0D0A00"),
        playlistSelectedRow: Color(hex: "FFB000").opacity(0.2),
        playlistText: Color(hex: "FFB000"),
        playlistPlayingText: Color(hex: "FFDD00"),
        titleBarGradientStart: Color(hex: "FFB000"),
        titleBarGradientEnd: Color(hex: "8B6914"),
        displayBackground: Color(hex: "0D0A00"),
        displayText: Color(hex: "FFB000")
    )

    /// Ocean blue theme
    static let ocean = Theme(
        id: "ocean",
        name: "Ocean",
        background: Color(hex: "0A1628"),
        backgroundSecondary: Color(hex: "061020"),
        foreground: Color(hex: "122240"),
        accent: Color(hex: "00B4D8"),
        accentSecondary: Color(hex: "48CAE4"),
        textPrimary: Color(hex: "CAF0F8"),
        textSecondary: Color(hex: "5A8AA0"),
        visualizerColor: Color(hex: "00B4D8"),
        visualizerColorSecondary: Color(hex: "48CAE4"),
        borderColor: Color(hex: "1A3050"),
        buttonColor: Color(hex: "90E0EF"),
        sliderTrackColor: Color(hex: "050C18"),
        sliderThumbColor: Color(hex: "00B4D8"),
        playlistBackground: Color(hex: "050C18"),
        playlistSelectedRow: Color(hex: "00B4D8").opacity(0.2),
        playlistText: Color(hex: "90E0EF"),
        playlistPlayingText: Color(hex: "CAF0F8"),
        titleBarGradientStart: Color(hex: "0077B6"),
        titleBarGradientEnd: Color(hex: "023E8A"),
        displayBackground: Color(hex: "03071E"),
        displayText: Color(hex: "00B4D8")
    )

    static let allThemes: [Theme] = [.classic, .midnight, .retrowave, .amber, .ocean]
}

// MARK: - Color hex initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
