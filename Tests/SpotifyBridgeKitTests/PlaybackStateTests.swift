import XCTest
@testable import SpotifyBridgeKit

final class PlaybackStateTests: XCTestCase {
    func testPlaybackStatusDisplayNames() {
        XCTAssertEqual(PlaybackStatus.playing.displayName, "Playing")
        XCTAssertEqual(PlaybackStatus.paused.displayName, "Paused")
        XCTAssertEqual(PlaybackStatus.stopped.displayName, "Stopped")
        XCTAssertEqual(PlaybackStatus.notRunning.displayName, "Not Running")
    }

    func testTrackMetadataTimeFormatting() {
        XCTAssertEqual(TrackMetadata.formatTime(0), "0:00")
        XCTAssertEqual(TrackMetadata.formatTime(59), "0:59")
        XCTAssertEqual(TrackMetadata.formatTime(60), "1:00")
        XCTAssertEqual(TrackMetadata.formatTime(125), "2:05")
        XCTAssertEqual(TrackMetadata.formatTime(3600), "60:00")
        XCTAssertEqual(TrackMetadata.formatTime(-10), "0:00")
        XCTAssertEqual(TrackMetadata.formatTime(Double.nan), "0:00")
        XCTAssertEqual(TrackMetadata.formatTime(Double.infinity), "0:00")
    }

    func testTrackMetadataProgress() {
        let track = TrackMetadata(
            title: "Test",
            artist: "Artist",
            album: "Album",
            duration: 200,
            position: 50
        )
        XCTAssertEqual(track.progress, 0.25, accuracy: 0.001)

        let zeroDuration = TrackMetadata(title: "T", artist: "A", album: "Al", duration: 0, position: 10)
        XCTAssertEqual(zeroDuration.progress, 0.0)

        let overflowPosition = TrackMetadata(title: "T", artist: "A", album: "Al", duration: 100, position: 150)
        XCTAssertEqual(overflowPosition.progress, 1.0)
    }

    func testTrackMetadataFallbacks() {
        let emptyTrack = TrackMetadata(title: "   ", artist: "", album: "\n")
        XCTAssertEqual(emptyTrack.displayTitle, "Unknown Title")
        XCTAssertEqual(emptyTrack.displayArtist, "Unknown Artist")
        XCTAssertEqual(emptyTrack.displayAlbum, "Unknown Album")

        let validTrack = TrackMetadata(title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera")
        XCTAssertEqual(validTrack.displayTitle, "Bohemian Rhapsody")
        XCTAssertEqual(validTrack.displayArtist, "Queen")
        XCTAssertEqual(validTrack.displayAlbum, "A Night at the Opera")
    }

    func testPlaybackStateJSONRoundTrip() throws {
        let original = SpotifyPlaybackState(
            status: .playing,
            track: TrackMetadata(
                id: "spotify:track:4cOdK2wGLETKBW3PvgPWqT",
                title: "Never Gonna Give You Up",
                artist: "Rick Astley",
                album: "Whenever You Need Somebody",
                artworkUrl: "https://example.com/art.jpg",
                duration: 213.5,
                position: 45.2
            ),
            volume: 85,
            isRepeating: true,
            isShuffling: false,
            lastUpdated: Date()
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(SpotifyPlaybackState.self, from: data)

        XCTAssertEqual(decoded.status, original.status)
        XCTAssertEqual(decoded.track?.id, original.track?.id)
        XCTAssertEqual(decoded.track?.title, original.track?.title)
        XCTAssertEqual(decoded.track?.artist, original.track?.artist)
        XCTAssertEqual(decoded.track?.album, original.track?.album)
        XCTAssertEqual(decoded.track?.duration, original.track?.duration)
        XCTAssertEqual(decoded.volume, original.volume)
        XCTAssertEqual(decoded.isRepeating, original.isRepeating)
        XCTAssertEqual(decoded.isShuffling, original.isShuffling)
    }

    func testPresets() {
        let notRunning = SpotifyPlaybackState.notRunning
        XCTAssertEqual(notRunning.status, .notRunning)
        XCTAssertFalse(notRunning.isPlaying)
        XCTAssertFalse(notRunning.isSpotifyRunning)
        XCTAssertFalse(notRunning.hasActiveTrack)

        let stopped = SpotifyPlaybackState.stopped
        XCTAssertEqual(stopped.status, .stopped)
        XCTAssertFalse(stopped.isPlaying)
        XCTAssertTrue(stopped.isSpotifyRunning)
        XCTAssertFalse(stopped.hasActiveTrack)

        let preview = SpotifyPlaybackState.previewMock
        XCTAssertEqual(preview.status, .playing)
        XCTAssertTrue(preview.isPlaying)
        XCTAssertTrue(preview.isSpotifyRunning)
        XCTAssertTrue(preview.hasActiveTrack)
        XCTAssertNotNil(preview.track)
    }
}
