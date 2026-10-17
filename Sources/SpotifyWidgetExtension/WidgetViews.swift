import SwiftUI
import WidgetKit

// MARK: - Spotify Brand Colors
extension Color {
    public static let spotifyGreen = Color(red: 30.0 / 255.0, green: 215.0 / 255.0, blue: 96.0 / 255.0)
    public static let spotifyDark = Color(red: 18.0 / 255.0, green: 18.0 / 255.0, blue: 18.0 / 255.0)
    public static let spotifyCard = Color(red: 28.0 / 255.0, green: 28.0 / 255.0, blue: 30.0 / 255.0)
    public static let spotifySecondary = Color(red: 179.0 / 255.0, green: 179.0 / 255.0, blue: 179.0 / 255.0)
}

// MARK: - Album Artwork Image View
public struct AlbumArtworkView: View {
    public let artworkData: Data?
    public let cornerRadius: CGFloat

    public init(artworkData: Data?, cornerRadius: CGFloat = 8) {
        self.artworkData = artworkData
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        Group {
            if let data = artworkData, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(LinearGradient(
                            colors: [Color.spotifyCard, Color.black.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    Image(systemName: "music.note")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.spotifyGreen)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - System Small Widget View
public struct SmallWidgetView: View {
    public let state: SpotifyPlaybackState
    public let artworkData: Data?

    public init(state: SpotifyPlaybackState, artworkData: Data?) {
        self.state = state
        self.artworkData = artworkData
    }

    public var body: some View {
        if state.isSpotifyRunning && state.hasActiveTrack, let track = state.track {
            trackContentView(track: track)
        } else {
            FallbackWidgetView(state: state, isSmall: true)
        }
    }

    @ViewBuilder
    private func trackContentView(track: TrackMetadata) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Artwork & Status Header
            HStack {
                AlbumArtworkView(artworkData: artworkData, cornerRadius: 6)
                    .frame(width: 48, height: 48)

                Spacer()

                // Playing indicator dot
                Circle()
                    .fill(state.isPlaying ? Color.spotifyGreen : Color.spotifySecondary)
                    .frame(width: 8, height: 8)
            }

            Spacer(minLength: 0)

            // Title and Artist
            VStack(alignment: .leading, spacing: 2) {
                Text(track.displayTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(track.displayArtist)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.spotifySecondary)
                    .lineLimit(1)
            }

            // Compact Controls Row
            HStack(spacing: 12) {
                Button(intent: PreviousTrackIntent()) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Previous Track")

                Button(intent: TogglePlayPauseIntent()) {
                    ZStack {
                        Circle()
                            .fill(Color.spotifyGreen)
                            .frame(width: 28, height: 28)
                        Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.black)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(state.isPlaying ? "Pause" : "Play")

                Button(intent: NextTrackIntent()) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Next Track")

                Spacer()
            }
            .padding(.top, 2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.spotifyDark)
    }
}

// MARK: - System Medium Widget View
public struct MediumWidgetView: View {
    public let state: SpotifyPlaybackState
    public let artworkData: Data?

    public init(state: SpotifyPlaybackState, artworkData: Data?) {
        self.state = state
        self.artworkData = artworkData
    }

    public var body: some View {
        if state.isSpotifyRunning && state.hasActiveTrack, let track = state.track {
            activeTrackView(track: track)
        } else {
            FallbackWidgetView(state: state, isSmall: false)
        }
    }

    @ViewBuilder
    private func activeTrackView(track: TrackMetadata) -> some View {
        HStack(spacing: 14) {
            // Album Artwork
            AlbumArtworkView(artworkData: artworkData, cornerRadius: 10)
                .frame(width: 104, height: 104)
                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)

            // Track Details & Controls
            VStack(alignment: .leading, spacing: 5) {
                // Status Badge & Duration
                HStack(spacing: 6) {
                    Circle()
                        .fill(state.isPlaying ? Color.spotifyGreen : Color.spotifySecondary)
                        .frame(width: 6, height: 6)

                    Text(state.isPlaying ? "NOW PLAYING" : "PAUSED")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(state.isPlaying ? Color.spotifyGreen : Color.spotifySecondary)
                        .tracking(0.8)

                    Spacer()

                    if track.duration > 0 {
                        Text("\(track.formattedPosition) / \(track.formattedDuration)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.spotifySecondary)
                    }
                }

                // Track Title
                Text(track.displayTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                // Artist & Album
                Text("\(track.displayArtist) • \(track.displayAlbum)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.spotifySecondary)
                    .lineLimit(1)

                // Progress Bar
                if track.duration > 0 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 3)

                            Capsule()
                                .fill(Color.spotifyGreen)
                                .frame(width: max(geo.size.width * CGFloat(track.progress), 3), height: 3)
                        }
                    }
                    .frame(height: 3)
                    .padding(.vertical, 2)
                } else {
                    Spacer().frame(height: 2)
                }

                // Playback Controls Row
                HStack(spacing: 20) {
                    Button(intent: PreviousTrackIntent()) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Previous Track")

                    Button(intent: TogglePlayPauseIntent()) {
                        ZStack {
                            Circle()
                                .fill(Color.spotifyGreen)
                                .frame(width: 32, height: 32)
                            Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.black)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(state.isPlaying ? "Pause" : "Play")

                    Button(intent: NextTrackIntent()) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Next Track")

                    Spacer()

                    // Spotify Brand Indicator
                    Image(systemName: "waveform")
                        .font(.system(size: 12))
                        .foregroundStyle(state.isPlaying ? Color.spotifyGreen : Color.spotifySecondary.opacity(0.5))
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.spotifyDark)
    }
}

// MARK: - Fallback Widget View (Idle / Not Running)
public struct FallbackWidgetView: View {
    public let state: SpotifyPlaybackState
    public let isSmall: Bool

    public init(state: SpotifyPlaybackState, isSmall: Bool) {
        self.state = state
        self.isSmall = isSmall
    }

    public var body: some View {
        let isClosed = !state.isSpotifyRunning

        if isSmall {
            VStack(spacing: 8) {
                Image(systemName: isClosed ? "music.note.house.fill" : "pause.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(isClosed ? Color.spotifySecondary : Color.spotifyGreen)

                Text(isClosed ? "Spotify Closed" : "Spotify Idle")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)

                Text(isClosed ? "Open Spotify" : "No track playing")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.spotifySecondary)
                    .multilineTextAlignment(.center)

                Button(intent: TogglePlayPauseIntent()) {
                    Image(systemName: isClosed ? "arrow.up.forward.app.fill" : "play.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.spotifyGreen)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isClosed ? "Open Spotify" : "Resume Playback")
                .padding(.top, 2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.spotifyDark)
        } else {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.spotifyCard)
                        .frame(width: 80, height: 80)
                    Image(systemName: isClosed ? "antenna.radiowaves.left.and.right.slash" : "music.quarternote.3")
                        .font(.system(size: 30))
                        .foregroundStyle(isClosed ? Color.spotifySecondary : Color.spotifyGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(isClosed ? "Spotify is Closed" : "Spotify is Idle")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    Text(isClosed
                         ? "Launch Spotify desktop app to view currently playing media and controls."
                         : "Start playback in Spotify or click play to resume.")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.spotifySecondary)
                        .lineLimit(2)

                    Button(intent: TogglePlayPauseIntent()) {
                        Label(isClosed ? "Open Spotify" : "Resume Playback", systemImage: isClosed ? "arrow.up.forward.app.fill" : "play.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.spotifyGreen)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isClosed ? "Open Spotify" : "Resume Playback")
                    .padding(.top, 4)
                }

                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.spotifyDark)
        }
    }
}
