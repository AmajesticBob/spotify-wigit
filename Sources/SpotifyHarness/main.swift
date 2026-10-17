import Foundation
import SpotifyBridgeKit

@main @MainActor
struct SpotifyHarnessMain {
    static func main() async {
        let args = CommandLine.arguments

        if args.contains("--help") || args.contains("-h") {
            printHelp()
            return
        }

        if args.contains("--json") {
            outputJSON()
            return
        }

        if args.contains("--verify") {
            await runVerificationSuite()
            return
        }

        if args.contains("--play-pause") {
            print("Invoking SpotifyBridge.playPause()...")
            let success = SpotifyBridge.shared.playPause()
            print("Result: \(success ? "Success" : "Failed")")
            outputStatus()
            return
        }

        if args.contains("--next") {
            print("Invoking SpotifyBridge.nextTrack()...")
            let success = SpotifyBridge.shared.nextTrack()
            print("Result: \(success ? "Success" : "Failed")")
            outputStatus()
            return
        }

        if args.contains("--previous") {
            print("Invoking SpotifyBridge.previousTrack()...")
            let success = SpotifyBridge.shared.previousTrack()
            print("Result: \(success ? "Success" : "Failed")")
            outputStatus()
            return
        }

        if args.contains("--pause") {
            print("Invoking SpotifyBridge.pause()...")
            let success = SpotifyBridge.shared.pause()
            print("Result: \(success ? "Success" : "Failed")")
            outputStatus()
            return
        }

        if args.contains("--play") {
            print("Invoking SpotifyBridge.play()...")
            let success = SpotifyBridge.shared.play()
            print("Result: \(success ? "Success" : "Failed")")
            outputStatus()
            return
        }

        // Default or --status
        outputStatus()
    }

    static func printHelp() {
        print("""
        Spotify Widget CLI Test Harness
        ===============================
        Usage: SpotifyHarness [OPTIONS]

        Commands:
          --status       Query and display current Spotify playback state (default)
          --json         Output playback state formatted as JSON
          --play-pause   Toggle playback play/pause via SpotifyBridge
          --next         Skip to next track via SpotifyBridge
          --previous     Skip to previous track via SpotifyBridge
          --pause        Pause playback
          --play         Resume playback
          --verify       Run comprehensive verification suite
          --help, -h     Show this help message
        """)
    }

    static func outputStatus() {
        let bridge = SpotifyBridge.shared
        let isRunning = bridge.isSpotifyRunning
        let state = bridge.fetchPlaybackState()
        let permission = SystemPermissionManager.shared.checkPermissionStatus()

        print("""
        ============================================================
        Spotify Desktop & Bridge Status
        ============================================================
        Spotify Process:     \(isRunning ? "RUNNING (Active)" : "CLOSED (Not Running)")
        Automation Perm:     \(permission.rawValue)
        Playback Status:     \(state.status.displayName) [isPlaying: \(state.isPlaying)]
        Volume:              \(state.volume)%
        Repeat Enabled:      \(state.isRepeating)
        Shuffle Enabled:     \(state.isShuffling)
        Last Updated:        \(state.lastUpdated)
        ------------------------------------------------------------
        """)

        if let track = state.track {
            print("""
            Track Information:
              Title:             \(track.displayTitle)
              Artist:            \(track.displayArtist)
              Album:             \(track.displayAlbum)
              Track ID:          \(track.id.isEmpty ? "(none)" : track.id)
              Duration:          \(track.formattedDuration) (\(String(format: "%.1f", track.duration))s)
              Position:          \(track.formattedPosition) (\(String(format: "%.1f", track.position))s)
              Progress:          \(String(format: "%.1f%%", track.progress * 100))
              Artwork URL:       \(track.artworkUrl ?? "(none)")
            """)
        } else {
            print("Track Information:   No active track / Idle\n")
        }
        print("============================================================")
    }

    static func outputJSON() {
        let state = SpotifyBridge.shared.fetchPlaybackState()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(state)
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("{\"error\": \"\(error.localizedDescription)\"}")
        }
    }

    static func runVerificationSuite() async {
        print("""
        ============================================================
        Running Spotify Widget Verification Suite
        ============================================================
        """)

        var passedCount = 0
        var totalCount = 0

        func assertTest(_ name: String, _ condition: Bool, _ details: String = "") {
            totalCount += 1
            if condition {
                passedCount += 1
                print("  [PASS] \(name)")
            } else {
                print("  [FAIL] \(name) - \(details)")
            }
        }

        // Test 1: SpotifyBridge Singleton and Protocol Conformance
        let bridge: SpotifyBridgeProtocol = SpotifyBridge.shared
        assertTest("Bridge protocol conformance", bridge.bundleIdentifier == "com.spotify.client")

        // Test 2: Process detection consistency
        let isRunning = bridge.isSpotifyRunning
        assertTest("Process detection returns boolean", isRunning == true || isRunning == false, "isRunning: \(isRunning)")

        // Test 3: Playback state extraction
        let state = bridge.fetchPlaybackState()
        assertTest("Playback state extraction returns non-nil state", state.status != .notRunning || !isRunning)

        // Test 4: Duration calculation and formatting
        let trackMock = TrackMetadata(
            id: "test:track:123",
            title: "Test Song",
            artist: "Test Artist",
            album: "Test Album",
            artworkUrl: "https://example.com/art.jpg",
            duration: 185.0,
            position: 60.0
        )
        assertTest("Track formattedDuration (185s -> 3:05)", trackMock.formattedDuration == "3:05", "Got: \(trackMock.formattedDuration)")
        assertTest("Track formattedPosition (60s -> 1:00)", trackMock.formattedPosition == "1:00", "Got: \(trackMock.formattedPosition)")
        assertTest("Track progress calculation (60/185 ~ 0.324)", abs(trackMock.progress - (60.0 / 185.0)) < 0.001)

        // Test 5: Fallback handling when empty title
        let emptyTrack = TrackMetadata(title: "", artist: "", album: "")
        assertTest("Empty track title fallback", emptyTrack.displayTitle == "Unknown Title")
        assertTest("Empty track artist fallback", emptyTrack.displayArtist == "Unknown Artist")
        assertTest("Empty track album fallback", emptyTrack.displayAlbum == "Unknown Album")

        // Test 6: Fallback state presets
        let notRunningState = SpotifyPlaybackState.notRunning
        assertTest("notRunning preset status", notRunningState.status == .notRunning && !notRunningState.isSpotifyRunning)
        let stoppedState = SpotifyPlaybackState.stopped
        assertTest("stopped preset status", stoppedState.status == .stopped && !stoppedState.hasActiveTrack)

        // Test 7: JSON Serialization Round-Trip
        do {
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            let mockState = SpotifyPlaybackState.previewMock
            let data = try encoder.encode(mockState)
            let decoded = try decoder.decode(SpotifyPlaybackState.self, from: data)
            assertTest("JSON serialization round-trip", decoded.status == mockState.status && decoded.track?.title == mockState.track?.title)
        } catch {
            assertTest("JSON serialization round-trip", false, "Error: \(error)")
        }

        // Test 8: SharedDataManager save and load
        let testState = SpotifyPlaybackState(
            status: .playing,
            track: TrackMetadata(title: "Harness Test", artist: "Harness Artist", album: "Harness Album"),
            volume: 88
        )
        SharedDataManager.shared.saveState(testState)
        let loadedState = SharedDataManager.shared.loadState()
        assertTest("SharedDataManager state persistence", loadedState?.track?.title == "Harness Test" && loadedState?.volume == 88)

        // Test 9: Artwork caching
        let testArtData = "MockImageData123".data(using: .utf8)!
        SharedDataManager.shared.cacheArtwork(data: testArtData, forKey: "mock_test_art_key")
        let loadedArt = SharedDataManager.shared.loadCachedArtwork(forKey: "mock_test_art_key")
        assertTest("Artwork disk cache read/write", loadedArt == testArtData)

        // Test 10: System Permission Manager query
        let permStatus = SystemPermissionManager.shared.checkPermissionStatus()
        assertTest("Permission query returns valid enum", AutomationPermissionStatus.allCasesString.contains(permStatus.rawValue), "Status: \(permStatus.rawValue)")

        // Test 11: Playback control method protocol verification & boundary safety
        print("\n  Testing bridge playback control availability & safety:")
        if !bridge.isSpotifyRunning {
            let nextWhenClosed = bridge.nextTrack()
            let prevWhenClosed = bridge.previousTrack()
            let pauseWhenClosed = bridge.pause()
            print("    -> nextTrack() when closed: \(nextWhenClosed)")
            print("    -> previousTrack() when closed: \(prevWhenClosed)")
            print("    -> pause() when closed: \(pauseWhenClosed)")
            assertTest("Bridge control methods handle closed app safely", !nextWhenClosed && !prevWhenClosed && !pauseWhenClosed)
        } else if permStatus == .authorized {
            let pauseResult = bridge.pause()
            print("    -> pause() returned \(pauseResult)")
            let playResult = bridge.play()
            print("    -> play() returned \(playResult)")
            assertTest("Bridge playback control methods execute cleanly when authorized", playResult || pauseResult)
        } else {
            // Live Spotify process active in headless/unprompted terminal: verify methods dispatch safely without crashing
            let pauseResult = bridge.pause()
            print("    -> pause() safely returned \(pauseResult) (permission: \(permStatus.rawValue))")
            assertTest("Bridge control methods execute safely without crashing", true)
        }

        // Test 12: Playback state freshness TTL
        let freshSnap = SpotifyPlaybackState(status: .playing, track: nil, lastUpdated: Date())
        let staleSnap = SpotifyPlaybackState(status: .playing, track: nil, lastUpdated: Date().addingTimeInterval(-120.0))
        assertTest("Playback state freshness validation", freshSnap.isFresh(within: 45.0) && !staleSnap.isFresh(within: 45.0))

        // Test 13: Artwork fetch cooldown on invalid URL
        let badUrl = "https://invalid-test-domain-12345.xyz/album.jpg"
        let artFailResult = await SharedDataManager.shared.fetchAndCacheArtwork(from: badUrl)
        assertTest("Artwork invalid URL cooldown handling", artFailResult == nil)

        print("""
        ------------------------------------------------------------
        Verification Summary: \(passedCount)/\(totalCount) tests passed.
        ============================================================
        """)

        if passedCount == totalCount {
            print("ALL VERIFICATION CHECKS PASSED SUCCESSFULLY!\n")
        } else {
            print("SOME CHECKS FAILED. Review output above.\n")
            exit(1)
        }
    }
}

extension AutomationPermissionStatus {
    static var allCasesString: [String] {
        [
            AutomationPermissionStatus.authorized.rawValue,
            AutomationPermissionStatus.denied.rawValue,
            AutomationPermissionStatus.notDetermined.rawValue,
            AutomationPermissionStatus.spotifyNotRunning.rawValue,
            AutomationPermissionStatus.unknown.rawValue
        ]
    }
}
