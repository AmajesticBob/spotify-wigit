import Foundation
import SwiftUI
import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
public final class HostAppViewModel: ObservableObject {
    @Published public var state: SpotifyPlaybackState = .stopped
    @Published public var artworkData: Data? = nil
    @Published public var permissionStatus: AutomationPermissionStatus = .notDetermined
    @Published public var isRunning: Bool = false
    @Published public var lastNotificationTime: Date? = nil
    @Published public var showingReloadFeedback: Bool = false

    private var timer: AnyCancellable?
    private var notificationObserver: Any?
    private var inFlightArtworkUrl: String?
    private var lastLoadedArtworkUrl: String?

    public init() {
        setupObservers()
        refresh()
    }

    deinit {
        if let observer = notificationObserver {
            DistributedNotificationCenter.default().removeObserver(observer)
        }
    }

    public func setupObservers() {
        // Observe Spotify distributed playback notifications
        notificationObserver = DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.spotify.client.PlaybackState"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.lastNotificationTime = Date()
            self?.refresh()
        }

        // Lightweight periodic refresh timer
        timer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refresh()
            }
    }

    public func refresh() {
        let wasRunning = isRunning
        let oldState = self.state
        isRunning = SpotifyBridge.shared.isSpotifyRunning
        permissionStatus = SystemPermissionManager.shared.checkPermissionStatus()

        let newState = SpotifyBridge.shared.fetchPlaybackState()
        self.state = newState

        let trackChanged = (oldState.track?.id != newState.track?.id && !(oldState.track?.id ?? "").isEmpty) ||
                           (oldState.track?.title != newState.track?.title) ||
                           (oldState.track?.artist != newState.track?.artist)

        if wasRunning != isRunning || oldState.status != newState.status || trackChanged {
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }

        // Check and load artwork with in-flight deduplication
        if let track = newState.track, let urlString = track.artworkUrl, !urlString.isEmpty {
            if lastLoadedArtworkUrl == urlString && self.artworkData != nil {
                // Already loaded and active
            } else if inFlightArtworkUrl == urlString {
                // Fetch already in progress
            } else if let cached = SharedDataManager.shared.loadCachedArtwork(forKey: urlString) {
                self.artworkData = cached
                self.lastLoadedArtworkUrl = urlString
            } else {
                inFlightArtworkUrl = urlString
                Task { [weak self] in
                    let data = await SharedDataManager.shared.fetchAndCacheArtwork(from: urlString)
                    await MainActor.run {
                        self?.inFlightArtworkUrl = nil
                        self?.lastLoadedArtworkUrl = urlString
                        self?.artworkData = data
                        #if canImport(WidgetKit)
                        WidgetCenter.shared.reloadAllTimelines()
                        #endif
                    }
                }
            }
        } else {
            self.artworkData = nil
            self.lastLoadedArtworkUrl = nil
            self.inFlightArtworkUrl = nil
        }
    }

    public func togglePlayPause() {
        SpotifyBridge.shared.playPause()
        triggerWidgetReload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.refresh()
        }
    }

    public func nextTrack() {
        SpotifyBridge.shared.nextTrack()
        triggerWidgetReload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.refresh()
        }
    }

    public func previousTrack() {
        SpotifyBridge.shared.previousTrack()
        triggerWidgetReload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.refresh()
        }
    }

    public func requestPermissions() {
        SystemPermissionManager.shared.promptForPermissionIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refresh()
        }
    }

    public func triggerWidgetReload() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
        showingReloadFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showingReloadFeedback = false
        }
    }
}
