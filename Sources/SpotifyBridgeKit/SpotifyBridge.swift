import Foundation
import AppKit
import ScriptingBridge

/// Protocol defining operations for communicating with Spotify on macOS
public protocol SpotifyBridgeProtocol: Sendable {
    var bundleIdentifier: String { get }
    var isSpotifyRunning: Bool { get }
    func fetchPlaybackState() -> SpotifyPlaybackState
    func playPause() -> Bool
    func nextTrack() -> Bool
    func previousTrack() -> Bool
    func pause() -> Bool
    func play() -> Bool
}

/// Primary bridge communicating with local Spotify macOS application via ScriptingBridge & AppleScript fallback
public final class SpotifyBridge: SpotifyBridgeProtocol, @unchecked Sendable {
    public static let shared = SpotifyBridge()

    public let bundleIdentifier = "com.spotify.client"

    public init() {}

    /// Checks whether the Spotify desktop application process is currently active.
    public var isSpotifyRunning: Bool {
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
        return runningApps.contains { !$0.isTerminated }
    }

    /// Fetches the latest playback state from Spotify.
    public func fetchPlaybackState() -> SpotifyPlaybackState {
        guard isSpotifyRunning else {
            let state = SpotifyPlaybackState.notRunning
            SharedDataManager.shared.saveState(state)
            return state
        }

        // Attempt ScriptingBridge extraction first
        if let state = fetchStateViaScriptingBridge() {
            // If ScriptingBridge reported active/paused playback but couldn't resolve track metadata,
            // attempt AppleScript fallback to retrieve track details
            if (state.isPlaying || state.status == .paused) && (state.track == nil || !state.hasActiveTrack) {
                if let asState = fetchStateViaAppleScript(), asState.track != nil && asState.hasActiveTrack {
                    SharedDataManager.shared.saveState(asState)
                    return asState
                }
            }
            SharedDataManager.shared.saveState(state)
            return state
        }

        // Fallback to AppleScript extraction
        if let state = fetchStateViaAppleScript() {
            SharedDataManager.shared.saveState(state)
            return state
        }

        // If live extraction failed but Spotify is running, check if SharedDataManager has an unexpired valid active track
        if let cachedState = SharedDataManager.shared.loadState(),
           cachedState.isSpotifyRunning && cachedState.hasActiveTrack && cachedState.isFresh(within: 45.0) {
            return cachedState
        }

        // Fallback to idle if running but unable to extract track (do not overwrite valid cache)
        let fallbackState = SpotifyPlaybackState.stopped
        return fallbackState
    }

    /// Toggles play / pause state in Spotify.
    @discardableResult
    public func playPause() -> Bool {
        guard isSpotifyRunning else {
            return launchSpotify()
        }

        if let sbApp = getScriptingBridgeApp(asynchronous: true) {
            sbApp.playpause?()
            if let sb = sbApp as? SBApplication, sb.lastError() == nil {
                return true
            }
        }

        return executeAppleScriptCommand("tell application id \"\(bundleIdentifier)\" to playpause")
    }

    /// Skips to the next track in Spotify.
    @discardableResult
    public func nextTrack() -> Bool {
        guard isSpotifyRunning else { return false }

        if let sbApp = getScriptingBridgeApp(asynchronous: true) {
            sbApp.nextTrack?()
            if let sb = sbApp as? SBApplication, sb.lastError() == nil {
                return true
            }
        }

        return executeAppleScriptCommand("tell application id \"\(bundleIdentifier)\" to next track")
    }

    /// Returns to the previous track in Spotify.
    @discardableResult
    public func previousTrack() -> Bool {
        guard isSpotifyRunning else { return false }

        if let sbApp = getScriptingBridgeApp(asynchronous: true) {
            sbApp.previousTrack?()
            if let sb = sbApp as? SBApplication, sb.lastError() == nil {
                return true
            }
        }

        return executeAppleScriptCommand("tell application id \"\(bundleIdentifier)\" to previous track")
    }

    /// Pauses playback in Spotify.
    @discardableResult
    public func pause() -> Bool {
        guard isSpotifyRunning else { return false }

        if let sbApp = getScriptingBridgeApp(asynchronous: true) {
            sbApp.pause?()
            if let sb = sbApp as? SBApplication, sb.lastError() == nil {
                return true
            }
        }

        return executeAppleScriptCommand("tell application id \"\(bundleIdentifier)\" to pause")
    }

    /// Resumes playback in Spotify.
    @discardableResult
    public func play() -> Bool {
        guard isSpotifyRunning else { return launchSpotify() }

        if let sbApp = getScriptingBridgeApp(asynchronous: true) {
            sbApp.play?()
            if let sb = sbApp as? SBApplication, sb.lastError() == nil {
                return true
            }
        }

        return executeAppleScriptCommand("tell application id \"\(bundleIdentifier)\" to play")
    }

    // MARK: - Private Helpers

    private func getScriptingBridgeApp(asynchronous: Bool = false) -> SpotifyApplicationProtocol? {
        guard let sbApp = SBApplication(bundleIdentifier: bundleIdentifier) else {
            return nil
        }
        sbApp.timeout = 2
        sbApp.sendMode = asynchronous ? AESendMode(kAENoReply) : AESendMode(kAEWaitReply)
        return sbApp as SpotifyApplicationProtocol
    }

    private func launchSpotify() -> Bool {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            let config = NSWorkspace.OpenConfiguration()
            config.activates = true
            NSWorkspace.shared.openApplication(at: url, configuration: config, completionHandler: nil)
            return true
        }

        if let schemeUrl = URL(string: "spotify:") {
            if NSWorkspace.shared.open(schemeUrl) {
                return true
            }
        }

        return executeAppleScriptCommand("tell application id \"\(bundleIdentifier)\" to activate")
    }

    private func fetchStateViaScriptingBridge() -> SpotifyPlaybackState? {
        guard let sbApp = getScriptingBridgeApp(asynchronous: false) else {
            return nil
        }

        let rawState = sbApp.playerState
        if let sb = sbApp as? SBApplication, sb.lastError() != nil {
            return nil
        }

        guard let rawState = rawState else {
            return nil
        }

        let status: PlaybackStatus
        switch rawState {
        case 1, 0x6b505350: // playing
            status = .playing
        case 2, 0x6b505370: // paused
            status = .paused
        case 0, 0x6b505353: // stopped
            status = .stopped
        default:
            status = .stopped
        }

        var trackMetadata: TrackMetadata? = nil

        if let track = sbApp.currentTrack {
            let title = track.name ?? ""
            let artist = track.artist ?? ""
            let album = track.album ?? ""
            let artworkUrl = track.artworkUrl
            let trackId = track.id ?? ""

            // Spotify duration in seconds or milliseconds
            var durationInSeconds: Double = 0.0
            if let rawDuration = track.duration {
                let durationVal = Double(rawDuration)
                durationInSeconds = durationVal > 10000 ? durationVal / 1000.0 : durationVal
            }

            let positionInSeconds = sbApp.playerPosition ?? 0.0

            if !title.isEmpty || !artist.isEmpty {
                trackMetadata = TrackMetadata(
                    id: trackId,
                    title: title,
                    artist: artist,
                    album: album,
                    artworkUrl: artworkUrl,
                    duration: durationInSeconds,
                    position: positionInSeconds
                )
            }
        }

        let volume = sbApp.soundVolume ?? 100
        let isRepeating = sbApp.repeating ?? false
        let isShuffling = sbApp.shuffling ?? false

        return SpotifyPlaybackState(
            status: status,
            track: trackMetadata,
            volume: volume,
            isRepeating: isRepeating,
            isShuffling: isShuffling,
            lastUpdated: Date()
        )
    }

    private func fetchStateViaAppleScript() -> SpotifyPlaybackState? {
        let scriptSource = """
        with timeout of 2 seconds
            if application id "\(bundleIdentifier)" is running then
                tell application id "\(bundleIdentifier)"
                    set pState to player state as string
                    set pPos to player position
                    set pVol to sound volume
                    set pRep to repeating
                    set pShuf to shuffling
                    set trkName to ""
                    set trkArtist to ""
                    set trkAlbum to ""
                    set trkArt to ""
                    set trkDur to 0
                    set trkId to ""
                    try
                        set trkName to name of current track
                        set trkArtist to artist of current track
                        set trkAlbum to album of current track
                        set trkArt to artwork url of current track
                        set trkDur to duration of current track
                        set trkId to id of current track
                    end try
                    return pState & "|||" & trkName & "|||" & trkArtist & "|||" & trkAlbum & "|||" & trkArt & "|||" & trkDur & "|||" & pPos & "|||" & pVol & "|||" & pRep & "|||" & pShuf & "|||" & trkId
                end tell
            else
                return "notRunning"
            end if
        end timeout
        """

        guard let appleScript = NSAppleScript(source: scriptSource) else { return nil }
        var errorInfo: NSDictionary?
        let descriptor: NSAppleEventDescriptor?
        if Thread.isMainThread {
            descriptor = appleScript.executeAndReturnError(&errorInfo)
        } else {
            descriptor = DispatchQueue.main.sync {
                appleScript.executeAndReturnError(&errorInfo)
            }
        }

        guard errorInfo == nil, let output = descriptor?.stringValue else {
            return nil
        }

        if output == "notRunning" {
            return .notRunning
        }

        let parts = output.components(separatedBy: "|||")
        guard parts.count >= 10 else { return nil }

        let stateString = parts[0].lowercased()
        let status: PlaybackStatus
        if stateString.contains("play") {
            status = .playing
        } else if stateString.contains("pause") {
            status = .paused
        } else {
            status = .stopped
        }

        let title = parts[1]
        let artist = parts[2]
        let album = parts[3]
        let artworkUrl = parts[4].isEmpty ? nil : parts[4]
        let rawDuration = Double(parts[5]) ?? 0.0
        let duration = rawDuration > 10000 ? rawDuration / 1000.0 : rawDuration
        let position = Double(parts[6]) ?? 0.0
        let volume = Int(parts[7]) ?? 100
        let isRepeating = parts[8].lowercased() == "true"
        let isShuffling = parts[9].lowercased() == "true"
        let trackId = parts.count > 10 ? parts[10] : ""

        var trackMetadata: TrackMetadata? = nil
        if !title.isEmpty || !artist.isEmpty {
            trackMetadata = TrackMetadata(
                id: trackId,
                title: title,
                artist: artist,
                album: album,
                artworkUrl: artworkUrl,
                duration: duration,
                position: position
            )
        }

        return SpotifyPlaybackState(
            status: status,
            track: trackMetadata,
            volume: volume,
            isRepeating: isRepeating,
            isShuffling: isShuffling,
            lastUpdated: Date()
        )
    }

    @discardableResult
    private func executeAppleScriptCommand(_ source: String) -> Bool {
        let wrappedSource = """
        with timeout of 2 seconds
            \(source)
        end timeout
        """
        guard let appleScript = NSAppleScript(source: wrappedSource) else { return false }
        if Thread.isMainThread {
            var errorInfo: NSDictionary?
            appleScript.executeAndReturnError(&errorInfo)
            return errorInfo == nil
        } else {
            return DispatchQueue.main.sync {
                var errorInfo: NSDictionary?
                appleScript.executeAndReturnError(&errorInfo)
                return errorInfo == nil
            }
        }
    }
}
