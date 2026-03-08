import SwiftUI

struct PlayerView: View {
    @ObservedObject var player: AudioPlayerViewModel
    @ObservedObject var themeManager: ThemeManager

    private var theme: Theme { themeManager.currentTheme }

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            displayPanel
            controlsPanel
        }
        .background(theme.background)
    }

    // MARK: - Title Bar

    private var titleBar: some View {
        HStack {
            Text("MOUSIKE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: 6) {
                titleBarButton("−") { /* minimize */ }
                titleBarButton("□") { /* maximize */ }
                titleBarButton("×") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [theme.titleBarGradientStart, theme.titleBarGradientEnd],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    private func titleBarButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 14, height: 14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Display Panel (LCD-style)

    private var displayPanel: some View {
        HStack(spacing: 0) {
            // Left: Visualizer
            VisualizerView(spectrumData: player.spectrumData, theme: theme)
                .frame(width: 80, height: 42)
                .padding(4)

            // Center: Track info + time
            VStack(alignment: .leading, spacing: 2) {
                // Scrolling title
                Text(player.displayTitle)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.displayText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    // Time display
                    Text(formatTime(player.currentTime))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(theme.displayText)

                    Spacer()

                    // Bitrate / Sample rate
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(player.bitrateText)
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(theme.displayText.opacity(0.7))
                        Text(player.sampleRateText)
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(theme.displayText.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .background(theme.displayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .padding(.horizontal, 6)
        .padding(.top, 4)
    }

    // MARK: - Controls

    private var controlsPanel: some View {
        VStack(spacing: 6) {
            // Seek bar
            seekBar

            HStack(spacing: 0) {
                // Transport controls
                transportControls

                Spacer()

                // Volume
                volumeControl
            }
            .padding(.horizontal, 8)

            // Bottom row: shuffle, repeat, EQ, theme
            HStack(spacing: 8) {
                toggleButton("SHF", isActive: player.isShuffled) {
                    player.toggleShuffle()
                }
                toggleButton(repeatLabel, isActive: player.repeatMode != .off) {
                    player.cycleRepeatMode()
                }

                Spacer()

                toggleButton("ADD", isActive: false) {
                    player.openFilePicker()
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
        }
        .padding(.top, 6)
    }

    private var seekBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.sliderTrackColor)
                    .frame(height: 6)

                // Progress
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.accent)
                    .frame(width: seekBarWidth(in: geo.size.width), height: 6)

                // Thumb
                Circle()
                    .fill(theme.sliderThumbColor)
                    .frame(width: 12, height: 12)
                    .offset(x: seekBarWidth(in: geo.size.width) - 6)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        player.isSeeking = true
                        let ratio = max(0, min(1, value.location.x / geo.size.width))
                        player.currentTime = ratio * player.duration
                    }
                    .onEnded { value in
                        let ratio = max(0, min(1, value.location.x / geo.size.width))
                        player.seek(to: ratio * player.duration)
                        player.isSeeking = false
                    }
            )
        }
        .frame(height: 14)
        .padding(.horizontal, 8)
    }

    private func seekBarWidth(in totalWidth: CGFloat) -> CGFloat {
        guard player.duration > 0 else { return 0 }
        return CGFloat(player.currentTime / player.duration) * totalWidth
    }

    private var transportControls: some View {
        HStack(spacing: 2) {
            transportButton(systemName: "backward.end.fill") { player.previous() }
            transportButton(systemName: player.isPlaying ? "pause.fill" : "play.fill") {
                player.togglePlayPause()
            }
            transportButton(systemName: "stop.fill") { player.stop() }
            transportButton(systemName: "forward.end.fill") { player.next() }
        }
    }

    private func transportButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12))
                .foregroundColor(theme.buttonColor)
                .frame(width: 28, height: 22)
                .background(theme.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        .buttonStyle(.plain)
    }

    private var volumeControl: some View {
        HStack(spacing: 4) {
            Image(systemName: "speaker.fill")
                .font(.system(size: 8))
                .foregroundColor(theme.textSecondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.sliderTrackColor)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.accent)
                        .frame(width: CGFloat(player.volume) * geo.size.width, height: 4)

                    Circle()
                        .fill(theme.sliderThumbColor)
                        .frame(width: 10, height: 10)
                        .offset(x: CGFloat(player.volume) * geo.size.width - 5)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let ratio = Float(max(0, min(1, value.location.x / geo.size.width)))
                            player.setVolume(ratio)
                        }
                )
            }
            .frame(width: 70, height: 12)

            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 8))
                .foregroundColor(theme.textSecondary)
        }
    }

    private func toggleButton(_ label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(isActive ? theme.accent : theme.textSecondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isActive ? theme.accent.opacity(0.15) : theme.foreground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(isActive ? theme.accent.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var repeatLabel: String {
        switch player.repeatMode {
        case .off: return "REP"
        case .all: return "RPT"
        case .one: return "RP1"
        }
    }

    // MARK: - Helpers

    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && time >= 0 else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
