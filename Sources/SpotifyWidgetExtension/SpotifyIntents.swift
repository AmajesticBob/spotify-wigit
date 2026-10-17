import Foundation
import AppIntents
#if canImport(WidgetKit)
import WidgetKit
#endif

/// AppIntent to toggle Play / Pause in Spotify directly from the widget
public struct TogglePlayPauseIntent: AppIntent {
    public static var title: LocalizedStringResource = "Toggle Play/Pause"
    public static var description = IntentDescription("Toggles Spotify playback.")

    public init() {}

    public func perform() async throws -> some IntentResult {
        SpotifyBridge.shared.playPause()

        // Wait briefly for Spotify to update its player state
        try? await Task.sleep(nanoseconds: 180_000_000)

        // Pre-fetch updated state and cache to shared storage
        let state = SpotifyBridge.shared.fetchPlaybackState()

        // Proactively cache artwork so widget renders immediately without placeholder flicker
        if let artUrl = state.track?.artworkUrl, !artUrl.isEmpty {
            _ = await SharedDataManager.shared.fetchAndCacheArtwork(from: artUrl)
        }

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif

        return .result()
    }
}

/// AppIntent to skip to the next track in Spotify directly from the widget
public struct NextTrackIntent: AppIntent {
    public static var title: LocalizedStringResource = "Next Track"
    public static var description = IntentDescription("Skips to the next track in Spotify.")

    public init() {}

    public func perform() async throws -> some IntentResult {
        SpotifyBridge.shared.nextTrack()

        try? await Task.sleep(nanoseconds: 180_000_000)
        let state = SpotifyBridge.shared.fetchPlaybackState()

        if let artUrl = state.track?.artworkUrl, !artUrl.isEmpty {
            _ = await SharedDataManager.shared.fetchAndCacheArtwork(from: artUrl)
        }

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif

        return .result()
    }
}

/// AppIntent to skip to the previous track in Spotify directly from the widget
public struct PreviousTrackIntent: AppIntent {
    public static var title: LocalizedStringResource = "Previous Track"
    public static var description = IntentDescription("Skips to the previous track in Spotify.")

    public init() {}

    public func perform() async throws -> some IntentResult {
        SpotifyBridge.shared.previousTrack()

        try? await Task.sleep(nanoseconds: 180_000_000)
        let state = SpotifyBridge.shared.fetchPlaybackState()

        if let artUrl = state.track?.artworkUrl, !artUrl.isEmpty {
            _ = await SharedDataManager.shared.fetchAndCacheArtwork(from: artUrl)
        }

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif

        return .result()
    }
}
