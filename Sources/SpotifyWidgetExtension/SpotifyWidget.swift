import WidgetKit
import SwiftUI

// MARK: - Widget Timeline Entry
public struct SpotifyWidgetEntry: TimelineEntry {
    public let date: Date
    public let state: SpotifyPlaybackState
    public let artworkData: Data?

    public init(date: Date, state: SpotifyPlaybackState, artworkData: Data?) {
        self.date = date
        self.state = state
        self.artworkData = artworkData
    }
}

// MARK: - Timeline Provider
public struct SpotifyTimelineProvider: TimelineProvider {
    public typealias Entry = SpotifyWidgetEntry

    public init() {}

    public func placeholder(in context: Context) -> SpotifyWidgetEntry {
        SpotifyWidgetEntry(
            date: Date(),
            state: SpotifyPlaybackState.previewMock,
            artworkData: nil
        )
    }

    public func getSnapshot(in context: Context, completion: @escaping (SpotifyWidgetEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
            return
        }

        let state = fetchCurrentState()
        if let cached = loadArtwork(for: state) {
            let entry = SpotifyWidgetEntry(date: Date(), state: state, artworkData: cached)
            completion(entry)
            return
        }

        if let artworkUrl = state.track?.artworkUrl, !artworkUrl.isEmpty {
            Task {
                let fetchedData = await SharedDataManager.shared.fetchAndCacheArtwork(from: artworkUrl)
                let entry = SpotifyWidgetEntry(date: Date(), state: state, artworkData: fetchedData)
                completion(entry)
            }
        } else {
            let entry = SpotifyWidgetEntry(date: Date(), state: state, artworkData: nil)
            completion(entry)
        }
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<SpotifyWidgetEntry>) -> Void) {
        let state = fetchCurrentState()
        let refreshInterval: TimeInterval = state.isPlaying ? 5 : 15
        let nextUpdate = Calendar.current.date(byAdding: .second, value: Int(refreshInterval), to: Date()) ?? Date().addingTimeInterval(refreshInterval)

        if let cached = loadArtwork(for: state) {
            let entry = SpotifyWidgetEntry(date: Date(), state: state, artworkData: cached)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
            return
        }

        if let artworkUrl = state.track?.artworkUrl, !artworkUrl.isEmpty {
            Task {
                let fetchedData = await SharedDataManager.shared.fetchAndCacheArtwork(from: artworkUrl)
                let entry = SpotifyWidgetEntry(date: Date(), state: state, artworkData: fetchedData)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        } else {
            let entry = SpotifyWidgetEntry(date: Date(), state: state, artworkData: nil)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchCurrentState() -> SpotifyPlaybackState {
        // If Spotify is not running, return notRunning immediately
        guard SpotifyBridge.shared.isSpotifyRunning else {
            return .notRunning
        }

        // Try direct bridge extraction
        let state = SpotifyBridge.shared.fetchPlaybackState()
        if state.hasActiveTrack {
            return state
        }

        // If direct bridge did not yield an active track (e.g. sandboxed extension restriction),
        // check if SharedDataManager has an unexpired active track saved by the companion app
        if let sharedState = SharedDataManager.shared.loadState(),
           sharedState.isSpotifyRunning && sharedState.hasActiveTrack && sharedState.isFresh(within: 45.0) {
            return sharedState
        }

        return state
    }

    private func loadArtwork(for state: SpotifyPlaybackState) -> Data? {
        guard let track = state.track, let urlString = track.artworkUrl, !urlString.isEmpty else {
            return nil
        }
        return SharedDataManager.shared.loadCachedArtwork(forKey: urlString)
    }
}

// MARK: - Entry View
public struct SpotifyWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    public let entry: SpotifyWidgetEntry

    public init(entry: SpotifyWidgetEntry) {
        self.entry = entry
    }

    public var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(state: entry.state, artworkData: entry.artworkData)
        case .systemMedium:
            MediumWidgetView(state: entry.state, artworkData: entry.artworkData)
        default:
            MediumWidgetView(state: entry.state, artworkData: entry.artworkData)
        }
    }
}

// MARK: - Widget Declaration
public struct SpotifyWidget: Widget {
    public let kind: String = "SpotifyWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpotifyTimelineProvider()) { entry in
            SpotifyWidgetEntryView(entry: entry)
                .containerBackground(Color.spotifyDark, for: .widget)
        }
        .configurationDisplayName("Spotify Media")
        .description("View currently playing track details and control playback.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}
