import SwiftUI
import UniformTypeIdentifiers

struct PlaylistView: View {
    @ObservedObject var player: AudioPlayerViewModel
    @ObservedObject var themeManager: ThemeManager

    private var theme: Theme { themeManager.currentTheme }

    var body: some View {
        VStack(spacing: 0) {
            playlistTitleBar
            trackList
            playlistFooter
        }
        .background(theme.backgroundSecondary)
    }

    // MARK: - Title Bar

    private var playlistTitleBar: some View {
        HStack {
            Text("PLAYLIST")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            Text("\(player.playlist.count) tracks")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
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

    // MARK: - Track List

    private var trackList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(player.playlist.enumerated()), id: \.element.id) { index, track in
                    trackRow(track: track, index: index)
                        .id(track.id)
                        .listRowBackground(
                            player.currentTrackIndex == index
                                ? theme.playlistSelectedRow
                                : theme.playlistBackground
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4))
                }
                .onMove { source, destination in
                    player.moveTrack(from: source, to: destination)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(theme.playlistBackground)
            .onChange(of: player.currentTrackIndex) { _, newIndex in
                if let idx = newIndex, player.playlist.indices.contains(idx) {
                    withAnimation {
                        proxy.scrollTo(player.playlist[idx].id, anchor: .center)
                    }
                }
            }
        }
    }

    private func trackRow(track: Track, index: Int) -> some View {
        HStack(spacing: 6) {
            // Track number
            Text("\(index + 1).")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(
                    player.currentTrackIndex == index
                        ? theme.playlistPlayingText
                        : theme.playlistText.opacity(0.5)
                )
                .frame(width: 24, alignment: .trailing)

            // Playing indicator
            if player.currentTrackIndex == index && player.isPlaying {
                Image(systemName: "play.fill")
                    .font(.system(size: 7))
                    .foregroundColor(theme.accent)
            }

            // Title + Artist
            VStack(alignment: .leading, spacing: 0) {
                Text(track.title)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(
                        player.currentTrackIndex == index
                            ? theme.playlistPlayingText
                            : theme.playlistText
                    )
                    .lineLimit(1)

                Text(track.artist)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(theme.playlistText.opacity(0.5))
                    .lineLimit(1)
            }

            Spacer()

            // Duration
            Text(formatDuration(track.duration))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(theme.playlistText.opacity(0.6))

            // Remove button
            Button {
                player.removeTrack(at: index)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 8))
                    .foregroundColor(theme.playlistText.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            player.selectTrack(at: index)
        }
    }

    // MARK: - Footer

    private var playlistFooter: some View {
        HStack(spacing: 8) {
            footerButton("+ ADD") {
                player.openFilePicker()
            }

            footerButton("− CLR") {
                player.clearPlaylist()
            }

            Spacer()

            Text(totalDurationText)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(theme.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(theme.foreground)
    }

    private func footerButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(theme.buttonColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 3).fill(theme.background))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        guard duration.isFinite && duration > 0 else { return "--:--" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var totalDurationText: String {
        let total = player.playlist.reduce(0) { $0 + $1.duration }
        guard total > 0 else { return "" }
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
}
