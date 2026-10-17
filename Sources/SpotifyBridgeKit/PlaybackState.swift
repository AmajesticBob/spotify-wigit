import Foundation

/// Represents the playback status of Spotify.
public enum PlaybackStatus: String, Codable, CaseIterable, Sendable {
    case playing = "playing"
    case paused = "paused"
    case stopped = "stopped"
    case notRunning = "notRunning"

    public var displayName: String {
        switch self {
        case .playing: return "Playing"
        case .paused: return "Paused"
        case .stopped: return "Stopped"
        case .notRunning: return "Not Running"
        }
    }

    public var systemIconName: String {
        switch self {
        case .playing: return "play.fill"
        case .paused: return "pause.fill"
        case .stopped: return "stop.fill"
        case .notRunning: return "antenna.radiowaves.left.and.right.slash"
        }
    }
}

/// Metadata for the currently playing track in Spotify.
public struct TrackMetadata: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let artist: String
    public let album: String
    public let artworkUrl: String?
    public let duration: Double
    public let position: Double

    public init(
        id: String = "",
        title: String,
        artist: String,
        album: String,
        artworkUrl: String? = nil,
        duration: Double = 0.0,
        position: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.artworkUrl = artworkUrl
        self.duration = duration
        self.position = position
    }

    public var displayTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unknown Title" : title
    }

    public var displayArtist: String {
        artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unknown Artist" : artist
    }

    public var displayAlbum: String {
        album.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unknown Album" : album
    }

    public var formattedDuration: String {
        Self.formatTime(duration)
    }

    public var formattedPosition: String {
        Self.formatTime(position)
    }

    public var progress: Double {
        guard duration > 0 else { return 0.0 }
        return min(max(position / duration, 0.0), 1.0)
    }

    public static func formatTime(_ timeInSeconds: Double) -> String {
        guard !timeInSeconds.isNaN && !timeInSeconds.isInfinite && timeInSeconds >= 0 else {
            return "0:00"
        }
        let totalSeconds = Int(timeInSeconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Complete snapshot of Spotify's current playback state.
public struct SpotifyPlaybackState: Codable, Equatable, Sendable {
    public let status: PlaybackStatus
    public let track: TrackMetadata?
    public let volume: Int
    public let isRepeating: Bool
    public let isShuffling: Bool
    public let lastUpdated: Date

    public init(
        status: PlaybackStatus,
        track: TrackMetadata? = nil,
        volume: Int = 100,
        isRepeating: Bool = false,
        isShuffling: Bool = false,
        lastUpdated: Date = Date()
    ) {
        self.status = status
        self.track = track
        self.volume = volume
        self.isRepeating = isRepeating
        self.isShuffling = isShuffling
        self.lastUpdated = lastUpdated
    }

    public var isPlaying: Bool {
        status == .playing
    }

    public var isSpotifyRunning: Bool {
        status != .notRunning
    }

    public var hasActiveTrack: Bool {
        guard let track = track else { return false }
        return !track.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Checks if this playback state snapshot was updated within the specified duration.
    public func isFresh(within seconds: TimeInterval = 45.0) -> Bool {
        Date().timeIntervalSince(lastUpdated) <= seconds
    }

    // MARK: - Presets
    public static var notRunning: SpotifyPlaybackState {
        SpotifyPlaybackState(status: .notRunning, track: nil, volume: 0)
    }

    public static var stopped: SpotifyPlaybackState {
        SpotifyPlaybackState(status: .stopped, track: nil)
    }

    public static var idle: SpotifyPlaybackState {
        SpotifyPlaybackState(status: .stopped, track: nil)
    }

    public static var previewMock: SpotifyPlaybackState {
        SpotifyPlaybackState(
            status: .playing,
            track: TrackMetadata(
                id: "spotify:track:preview123",
                title: "Blinding Lights",
                artist: "The Weeknd",
                album: "After Hours",
                artworkUrl: "https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36",
                duration: 200.0,
                position: 84.0
            ),
            volume: 75,
            isRepeating: false,
            isShuffling: true,
            lastUpdated: Date()
        )
    }
}
