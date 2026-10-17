import XCTest
@testable import SpotifyBridgeKit

final class SpotifyBridgeTests: XCTestCase {
    func testBridgeSingletonAndBundleId() {
        let bridge = SpotifyBridge.shared
        XCTAssertEqual(bridge.bundleIdentifier, "com.spotify.client")
    }

    func testFetchPlaybackStateReturnsValidObject() {
        let bridge = SpotifyBridge.shared
        let state = bridge.fetchPlaybackState()
        // If Spotify is running or not, state must be valid
        if !bridge.isSpotifyRunning {
            XCTAssertEqual(state.status, .notRunning)
        } else {
            XCTAssertNotEqual(state.status, .notRunning)
        }
    }

    func testSharedDataManagerSaveAndLoad() {
        let manager = SharedDataManager.shared
        let testState = SpotifyPlaybackState(
            status: .paused,
            track: TrackMetadata(title: "Unit Test Song", artist: "Unit Test Artist", album: "Unit Test Album"),
            volume: 42
        )

        manager.saveState(testState)
        let loaded = manager.loadState()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.status, .paused)
        XCTAssertEqual(loaded?.track?.title, "Unit Test Song")
        XCTAssertEqual(loaded?.volume, 42)
    }

    func testArtworkCaching() {
        let manager = SharedDataManager.shared
        let testData = "TestArtworkBinaryData".data(using: .utf8)!
        let key = "test_artwork_key_123"

        manager.cacheArtwork(data: testData, forKey: key)
        let loaded = manager.loadCachedArtwork(forKey: key)

        XCTAssertEqual(loaded, testData)
    }

    func testArtworkCachingWithLongUrl() {
        let manager = SharedDataManager.shared
        let testData = "TestArtworkBinaryDataForLongSpotifyCdnUrl".data(using: .utf8)!
        let longUrlKey = "https://i.scdn.co/image/ab67616d0000b2736f7d8c9dcc983839bd746dbc?size=large&format=jpeg"

        manager.cacheArtwork(data: testData, forKey: longUrlKey)
        let loaded = manager.loadCachedArtwork(forKey: longUrlKey)

        XCTAssertEqual(loaded, testData)
    }

    func testSystemPermissionManagerStatus() {
        let manager = SystemPermissionManager.shared
        XCTAssertEqual(manager.targetBundleIdentifier, "com.spotify.client")
        let status = manager.checkPermissionStatus()
        // Must be one of the declared statuses
        let validStatuses: [AutomationPermissionStatus] = [
            .authorized, .denied, .notDetermined, .spotifyNotRunning, .unknown
        ]
        XCTAssertTrue(validStatuses.contains(status))
    }

    func testTrackMetadataWithTrackId() {
        let track = TrackMetadata(
            id: "spotify:track:1xbJNPLSTtIWgGTt3Uu4gl",
            title: "Test Track",
            artist: "Test Artist",
            album: "Test Album",
            artworkUrl: "https://i.scdn.co/image/test",
            duration: 200,
            position: 50
        )
        XCTAssertEqual(track.id, "spotify:track:1xbJNPLSTtIWgGTt3Uu4gl")
        XCTAssertEqual(track.displayTitle, "Test Track")
        XCTAssertEqual(track.displayArtist, "Test Artist")
        XCTAssertEqual(track.displayAlbum, "Test Album")
        XCTAssertEqual(track.formattedDuration, "3:20")
        XCTAssertEqual(track.formattedPosition, "0:50")
        XCTAssertEqual(track.progress, 0.25)
    }

    func testSharedDataManagerPrefersFresherState() {
        let manager = SharedDataManager.shared
        let olderDate = Date().addingTimeInterval(-60)
        let newerDate = Date()

        let olderState = SpotifyPlaybackState(
            status: .playing,
            track: TrackMetadata(title: "Old Song", artist: "Old Artist", album: "Old Album"),
            volume: 50,
            lastUpdated: olderDate
        )

        let newerState = SpotifyPlaybackState(
            status: .playing,
            track: TrackMetadata(title: "New Song", artist: "New Artist", album: "New Album"),
            volume: 90,
            lastUpdated: newerDate
        )

        // Save older first, then newer
        manager.saveState(olderState)
        manager.saveState(newerState)

        let loaded = manager.loadState()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.track?.title, "New Song")
        XCTAssertEqual(loaded?.volume, 90)
    }

    func testPlaybackStateFreshness() {
        let freshState = SpotifyPlaybackState(
            status: .playing,
            track: TrackMetadata(title: "Fresh Track", artist: "Artist", album: "Album"),
            lastUpdated: Date()
        )
        XCTAssertTrue(freshState.isFresh(within: 45.0))

        let staleDate = Date().addingTimeInterval(-100.0)
        let staleState = SpotifyPlaybackState(
            status: .playing,
            track: TrackMetadata(title: "Stale Track", artist: "Artist", album: "Album"),
            lastUpdated: staleDate
        )
        XCTAssertFalse(staleState.isFresh(within: 45.0))
        XCTAssertTrue(staleState.isFresh(within: 150.0))
    }

    func testFailedArtworkUrlCooldown() async {
        let manager = SharedDataManager.shared
        let badUrl = "https://invalid-nonexistent-domain-12345.xyz/image.jpg"

        // First attempt fails due to invalid domain
        let firstResult = await manager.fetchAndCacheArtwork(from: badUrl)
        XCTAssertNil(firstResult)

        // Second attempt immediately hits cooldown without network request
        let secondResult = await manager.fetchAndCacheArtwork(from: badUrl)
        XCTAssertNil(secondResult)
    }

    func testPausedPlaybackStatePreservesTrack() {
        let pausedState = SpotifyPlaybackState(
            status: .paused,
            track: TrackMetadata(
                id: "spotify:track:paused123",
                title: "Paused Song",
                artist: "Paused Artist",
                album: "Paused Album",
                artworkUrl: "https://example.com/art.jpg",
                duration: 210.0,
                position: 105.0
            ),
            volume: 65,
            lastUpdated: Date()
        )

        XCTAssertFalse(pausedState.isPlaying)
        XCTAssertTrue(pausedState.isSpotifyRunning)
        XCTAssertTrue(pausedState.hasActiveTrack)
        XCTAssertEqual(pausedState.status, .paused)
        XCTAssertEqual(pausedState.track?.formattedPosition, "1:45")
        XCTAssertEqual(pausedState.track?.formattedDuration, "3:30")
        XCTAssertEqual(pausedState.track?.progress, 0.5)

        SharedDataManager.shared.saveState(pausedState)
        let loaded = SharedDataManager.shared.loadState()
        XCTAssertEqual(loaded?.status, .paused)
        XCTAssertEqual(loaded?.track?.title, "Paused Song")
    }

    func testBridgeControlsClosedSafety() {
        let bridge = SpotifyBridge.shared
        if !bridge.isSpotifyRunning {
            XCTAssertFalse(bridge.nextTrack())
            XCTAssertFalse(bridge.previousTrack())
            XCTAssertFalse(bridge.pause())
        }
    }
}
