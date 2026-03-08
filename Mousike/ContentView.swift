import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var player = AudioPlayerViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showThemePicker = false
    @State private var isDropTargeted = false

    private var theme: Theme { themeManager.currentTheme }

    var body: some View {
        VStack(spacing: 0) {
            PlayerView(player: player, themeManager: themeManager)

            // Divider
            Rectangle()
                .fill(theme.borderColor)
                .frame(height: 2)

            PlaylistView(player: player, themeManager: themeManager)
        }
        .frame(width: 320, minHeight: 450)
        .background(theme.background)
        .overlay(dropOverlay)
        .onDrop(of: [.audio, .fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showThemePicker.toggle()
                } label: {
                    Image(systemName: "paintpalette")
                        .foregroundColor(theme.accent)
                }
                .help("Change Theme")
            }
        }
        .sheet(isPresented: $showThemePicker) {
            ThemePickerView(themeManager: themeManager)
        }
    }

    // MARK: - Drop Overlay

    @ViewBuilder
    private var dropOverlay: some View {
        if isDropTargeted {
            ZStack {
                theme.background.opacity(0.85)

                VStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 36))
                        .foregroundColor(theme.accent)

                    Text("Drop audio files here")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(theme.accent)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(theme.accent, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .padding(4)
            )
        }
    }

    // MARK: - Drop Handler

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        var urls: [URL] = []

        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                let _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url {
                        DispatchQueue.main.async {
                            player.addFiles(urls: [url])
                        }
                    }
                }
            }
        }

        return true
    }
}

// MARK: - Keyboard Shortcuts

extension ContentView {
    var keyboardShortcuts: some View {
        self
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    switch event.keyCode {
                    case 49: // Space
                        player.togglePlayPause()
                        return nil
                    default:
                        return event
                    }
                }
            }
    }
}
