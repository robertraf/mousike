import SwiftUI

struct ThemePickerView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Title
            HStack {
                Text("THEMES")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                Button("×") { dismiss() }
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [
                        themeManager.currentTheme.titleBarGradientStart,
                        themeManager.currentTheme.titleBarGradientEnd
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            // Theme grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(themeManager.availableThemes) { theme in
                        themeCard(theme)
                    }
                }
                .padding(12)
            }
            .background(themeManager.currentTheme.background)
        }
        .frame(width: 340, height: 400)
    }

    private func themeCard(_ theme: Theme) -> some View {
        let isSelected = themeManager.currentTheme.id == theme.id

        return Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                themeManager.selectTheme(theme)
            }
        } label: {
            VStack(spacing: 0) {
                // Mini preview
                VStack(spacing: 2) {
                    // Mini title bar
                    HStack {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(.white.opacity(0.8))
                            .frame(width: 30, height: 4)
                        Spacer()
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        LinearGradient(
                            colors: [theme.titleBarGradientStart, theme.titleBarGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                    // Mini display
                    HStack(spacing: 4) {
                        // Mini visualizer bars
                        HStack(spacing: 1) {
                            ForEach(0..<8, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 0.5)
                                    .fill(theme.visualizerColor)
                                    .frame(width: 3, height: CGFloat.random(in: 4...18))
                            }
                        }
                        .frame(height: 20)

                        Spacer()

                        Text("01:23")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.displayText)
                    }
                    .padding(4)
                    .background(theme.displayBackground)

                    // Mini controls
                    HStack(spacing: 2) {
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(theme.buttonColor)
                                .frame(width: 14, height: 8)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)

                    // Mini playlist
                    VStack(spacing: 1) {
                        ForEach(0..<3, id: \.self) { i in
                            HStack {
                                RoundedRectangle(cornerRadius: 0.5)
                                    .fill(i == 0 ? theme.playlistPlayingText : theme.playlistText)
                                    .frame(height: 3)
                                Spacer()
                            }
                            .padding(.horizontal, 6)
                            .background(i == 0 ? theme.playlistSelectedRow : theme.playlistBackground)
                        }
                    }
                }
                .background(theme.background)
                .clipShape(RoundedRectangle(cornerRadius: 4))

                // Theme name
                Text(theme.name)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(
                        isSelected
                            ? themeManager.currentTheme.accent
                            : themeManager.currentTheme.textSecondary
                    )
                    .padding(.top, 6)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(themeManager.currentTheme.foreground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        isSelected ? themeManager.currentTheme.accent : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
