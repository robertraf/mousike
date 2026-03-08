import SwiftUI

@main
struct MousikeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 320, height: 500)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandMenu("Playback") {
                Button("Play/Pause") {
                    NotificationCenter.default.post(name: .togglePlayPause, object: nil)
                }
                .keyboardShortcut(" ", modifiers: [])

                Button("Stop") {
                    NotificationCenter.default.post(name: .stopPlayback, object: nil)
                }
                .keyboardShortcut(".", modifiers: .command)

                Divider()

                Button("Next Track") {
                    NotificationCenter.default.post(name: .nextTrack, object: nil)
                }
                .keyboardShortcut(.rightArrow, modifiers: .command)

                Button("Previous Track") {
                    NotificationCenter.default.post(name: .previousTrack, object: nil)
                }
                .keyboardShortcut(.leftArrow, modifiers: .command)
            }

            CommandMenu("File") {
                Button("Open Files...") {
                    NotificationCenter.default.post(name: .openFiles, object: nil)
                }
                .keyboardShortcut("o", modifiers: .command)
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let togglePlayPause = Notification.Name("togglePlayPause")
    static let stopPlayback = Notification.Name("stopPlayback")
    static let nextTrack = Notification.Name("nextTrack")
    static let previousTrack = Notification.Name("previousTrack")
    static let openFiles = Notification.Name("openFiles")
}
