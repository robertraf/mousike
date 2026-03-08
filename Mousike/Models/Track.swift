import Foundation

struct Track: Identifiable, Equatable, Hashable {
    let id: UUID
    let url: URL
    let title: String
    let artist: String
    let duration: TimeInterval

    init(url: URL, title: String? = nil, artist: String? = nil, duration: TimeInterval = 0) {
        self.id = UUID()
        self.url = url
        self.title = title ?? url.deletingPathExtension().lastPathComponent
        self.artist = artist ?? "Unknown Artist"
        self.duration = duration
    }
}
