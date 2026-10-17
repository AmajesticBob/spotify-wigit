import Foundation
import ScriptingBridge

/// Objective-C player state enum corresponding to Spotify's AppleScript definition ('ePlS')
@objc public enum SpotifyPlayerStateEnum: NSInteger {
    case stopped = 0x6b505353 // 'kPSS'
    case playing = 0x6b505350 // 'kPSP'
    case paused  = 0x6b505370 // 'kPSp'
}

/// ScriptingBridge protocol for a Spotify Track object ('spTr')
@objc public protocol SpotifyTrackProtocol {
    @objc optional var name: String { get }
    @objc optional var artist: String { get }
    @objc optional var album: String { get }
    @objc optional var artworkUrl: String { get }
    @objc optional var duration: Int { get }
    @objc optional var id: String { get }
    @objc optional var albumArtist: String { get }
    @objc optional var spotifyUrl: String { get }
}

/// ScriptingBridge protocol for the Spotify Application object ('capp')
@objc public protocol SpotifyApplicationProtocol {
    @objc optional var currentTrack: SpotifyTrackProtocol { get }
    @objc optional var playerState: NSInteger { get }
    @objc optional var playerPosition: Double { get }
    @objc optional var soundVolume: Int { get }
    @objc optional var repeating: Bool { get }
    @objc optional var shuffling: Bool { get }

    @objc optional func playpause()
    @objc optional func pause()
    @objc optional func play()
    @objc optional func nextTrack()
    @objc optional func previousTrack()
}

// Conform SBApplication to SpotifyApplicationProtocol
extension SBApplication: SpotifyApplicationProtocol {}
