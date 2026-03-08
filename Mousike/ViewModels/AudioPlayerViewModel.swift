import AVFoundation
import Combine
import SwiftUI

enum RepeatMode {
    case off, all, one
}

@MainActor
final class AudioPlayerViewModel: ObservableObject {

    // MARK: - Playback State
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.75
    @Published var isSeeking = false

    // MARK: - Playlist
    @Published var playlist: [Track] = []
    @Published var currentTrackIndex: Int? = nil
    @Published var isShuffled = false
    @Published var repeatMode: RepeatMode = .off

    // MARK: - Spectrum
    @Published var spectrumData: [Float] = Array(repeating: 0, count: 32)

    // MARK: - Display
    @Published var scrollingTitle = ""
    @Published var bitrateText = ""
    @Published var sampleRateText = ""

    var currentTrack: Track? {
        guard let index = currentTrackIndex, playlist.indices.contains(index) else { return nil }
        return playlist[index]
    }

    // MARK: - Private
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private let spectrumAnalyzer = SpectrumAnalyzer()
    private var titleScrollOffset = 0
    private var titleScrollTimer: Timer?
    private var shuffledIndices: [Int] = []
    private var shufflePosition = 0

    init() {
        startDisplayTimer()
    }

    // MARK: - File Import

    func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [
            .audio, .mp3, .wav, .aiff
        ]

        if panel.runModal() == .OK {
            addFiles(urls: panel.urls)
        }
    }

    func addFiles(urls: [URL]) {
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { continue }
            defer { url.stopAccessingSecurityScopedResource() }

            let asset = AVURLAsset(url: url)
            let durationSeconds = CMTimeGetSeconds(asset.duration)

            var title: String? = nil
            var artist: String? = nil

            // Try to extract metadata
            for item in asset.commonMetadata {
                if item.commonKey == .commonKeyTitle {
                    title = item.stringValue
                }
                if item.commonKey == .commonKeyArtist {
                    artist = item.stringValue
                }
            }

            let track = Track(
                url: url,
                title: title,
                artist: artist,
                duration: durationSeconds.isFinite ? durationSeconds : 0
            )
            playlist.append(track)
        }

        if currentTrackIndex == nil && !playlist.isEmpty {
            currentTrackIndex = 0
        }

        rebuildShuffleOrder()
    }

    // MARK: - Playback Controls

    func play() {
        guard let track = currentTrack else {
            if !playlist.isEmpty {
                currentTrackIndex = 0
                play()
            }
            return
        }

        if audioPlayer?.url == track.url {
            audioPlayer?.play()
            isPlaying = true
            return
        }

        loadAndPlay(track: track)
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentTime = 0
        isPlaying = false
    }

    func next() {
        guard !playlist.isEmpty else { return }

        if repeatMode == .one {
            audioPlayer?.currentTime = 0
            currentTime = 0
            if !isPlaying { play() }
            return
        }

        if isShuffled {
            shufflePosition += 1
            if shufflePosition >= shuffledIndices.count {
                if repeatMode == .all {
                    rebuildShuffleOrder()
                    shufflePosition = 0
                } else {
                    stop()
                    return
                }
            }
            currentTrackIndex = shuffledIndices[shufflePosition]
        } else {
            guard let current = currentTrackIndex else { return }
            let nextIndex = current + 1
            if nextIndex >= playlist.count {
                if repeatMode == .all {
                    currentTrackIndex = 0
                } else {
                    stop()
                    return
                }
            } else {
                currentTrackIndex = nextIndex
            }
        }

        loadAndPlay(track: currentTrack!)
    }

    func previous() {
        guard !playlist.isEmpty else { return }

        // If more than 3 seconds in, restart current track
        if currentTime > 3 {
            audioPlayer?.currentTime = 0
            currentTime = 0
            return
        }

        if isShuffled {
            shufflePosition = max(0, shufflePosition - 1)
            currentTrackIndex = shuffledIndices[shufflePosition]
        } else {
            guard let current = currentTrackIndex else { return }
            currentTrackIndex = max(0, current - 1)
        }

        loadAndPlay(track: currentTrack!)
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }

    func setVolume(_ vol: Float) {
        volume = vol
        audioPlayer?.volume = vol
    }

    func toggleShuffle() {
        isShuffled.toggle()
        if isShuffled {
            rebuildShuffleOrder()
        }
    }

    func cycleRepeatMode() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }

    // MARK: - Playlist Management

    func selectTrack(at index: Int) {
        guard playlist.indices.contains(index) else { return }
        currentTrackIndex = index
        loadAndPlay(track: playlist[index])
    }

    func removeTrack(at index: Int) {
        guard playlist.indices.contains(index) else { return }

        let wasPlaying = isPlaying && currentTrackIndex == index
        if wasPlaying { stop() }

        playlist.remove(at: index)

        if let current = currentTrackIndex {
            if index < current {
                currentTrackIndex = current - 1
            } else if index == current {
                if playlist.isEmpty {
                    currentTrackIndex = nil
                } else {
                    currentTrackIndex = min(current, playlist.count - 1)
                }
            }
        }

        rebuildShuffleOrder()
    }

    func clearPlaylist() {
        stop()
        playlist.removeAll()
        currentTrackIndex = nil
        shuffledIndices.removeAll()
    }

    func moveTrack(from source: IndexSet, to destination: Int) {
        let currentTrackId = currentTrack?.id
        playlist.move(fromOffsets: source, toOffset: destination)
        if let id = currentTrackId {
            currentTrackIndex = playlist.firstIndex(where: { $0.id == id })
        }
        rebuildShuffleOrder()
    }

    // MARK: - Private Helpers

    private func rebuildShuffleOrder() {
        shuffledIndices = Array(playlist.indices).shuffled()
        if let current = currentTrackIndex,
           let pos = shuffledIndices.firstIndex(of: current) {
            shuffledIndices.swapAt(0, pos)
            shufflePosition = 0
        } else {
            shufflePosition = 0
        }
    }

    private func loadAndPlay(track: Track) {
        do {
            _ = track.url.startAccessingSecurityScopedResource()
            audioPlayer = try AVAudioPlayer(contentsOf: track.url)
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            duration = audioPlayer?.duration ?? 0
            isPlaying = true
            updateTrackInfo(track: track)
        } catch {
            print("Failed to load track: \(error.localizedDescription)")
            isPlaying = false
        }
    }

    private func updateTrackInfo(track: Track) {
        scrollingTitle = "\(track.artist) - \(track.title)  ***  "
        titleScrollOffset = 0

        let asset = AVURLAsset(url: track.url)
        if let formatDesc = asset.tracks(withMediaType: .audio).first?.formatDescriptions.first {
            let desc = formatDesc as! CMAudioFormatDescription
            let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(desc)?.pointee
            if let asbd = asbd {
                sampleRateText = "\(Int(asbd.mSampleRate / 1000))kHz"
            }
        }
        bitrateText = "CBR"
    }

    private func startDisplayTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateDisplay()
            }
        }

        titleScrollTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.scrollTitle()
            }
        }
    }

    private func updateDisplay() {
        if let player = audioPlayer, isPlaying {
            if !isSeeking {
                currentTime = player.currentTime
            }

            // Check if track ended
            if player.currentTime >= player.duration - 0.1 && !player.isPlaying {
                next()
            }
        }

        // Update spectrum (simulated since AVAudioPlayer doesn't expose raw buffers easily)
        if isPlaying {
            for i in 0..<spectrumData.count {
                let base = Float.random(in: 0.1...0.8)
                spectrumData[i] = spectrumData[i] * 0.7 + base * 0.3
            }
        } else {
            spectrumData = spectrumAnalyzer.generateIdle()
        }
    }

    private func scrollTitle() {
        guard !scrollingTitle.isEmpty else { return }
        titleScrollOffset += 1
        if titleScrollOffset >= scrollingTitle.count {
            titleScrollOffset = 0
        }
    }

    var displayTitle: String {
        guard !scrollingTitle.isEmpty else { return "MOUSIKE" }
        let chars = Array(scrollingTitle)
        let len = min(30, chars.count)
        var result = ""
        for i in 0..<len {
            let idx = (titleScrollOffset + i) % chars.count
            result.append(chars[idx])
        }
        return result
    }
}
