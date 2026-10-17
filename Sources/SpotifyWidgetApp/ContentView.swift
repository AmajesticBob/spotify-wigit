import SwiftUI

public struct ContentView: View {
    @StateObject private var viewModel = HostAppViewModel()

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Bar
                headerView

                // Main Content Grid
                HStack(alignment: .top, spacing: 20) {
                    // Left Column: Player & Controls
                    VStack(alignment: .leading, spacing: 16) {
                        playerCardView
                        permissionsCardView
                    }
                    .frame(minWidth: 320, maxWidth: 380)

                    // Right Column: Widget Previews & Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        widgetPreviewsCardView
                        instructionsCardView
                    }
                    .frame(minWidth: 360, maxWidth: .infinity)
                }
            }
            .padding(24)
        }
        .frame(minWidth: 760, minHeight: 620)
        .background(Color(red: 20/255, green: 20/255, blue: 22/255))
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 30/255, green: 215/255, blue: 96/255))
                        .frame(width: 36, height: 36)
                    Image(systemName: "music.note")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Widgit")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Spotify macOS Desktop & Notification Center Widget")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.gray)
                }
            }

            Spacer()

            // Status Badge
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(statusText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
        }
    }

    // MARK: - Player Card
    private var playerCardView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Now Playing")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)

            if viewModel.state.hasActiveTrack, let track = viewModel.state.track {
                // Artwork & Metadata
                VStack(spacing: 12) {
                    Group {
                        if let data = viewModel.artworkData, let img = NSImage(data: data) {
                            Image(nsImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                                Image(systemName: "music.note")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color(red: 30/255, green: 215/255, blue: 96/255))
                            }
                        }
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )

                    VStack(spacing: 4) {
                        Text(track.displayTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(track.displayArtist)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.gray)
                            .lineLimit(1)

                        Text(track.displayAlbum)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.gray.opacity(0.8))
                            .lineLimit(1)
                    }

                    // Progress bar
                    if track.duration > 0 {
                        VStack(spacing: 4) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 4)
                                    Capsule()
                                        .fill(Color(red: 30/255, green: 215/255, blue: 96/255))
                                        .frame(width: max(geo.size.width * CGFloat(track.progress), 4), height: 4)
                                }
                            }
                            .frame(height: 4)

                            HStack {
                                Text(track.formattedPosition)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.gray)
                                Spacer()
                                Text(track.formattedDuration)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }

                    // Media Control Buttons
                    HStack(spacing: 24) {
                        Button(action: { viewModel.previousTrack() }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)

                        Button(action: { viewModel.togglePlayPause() }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 30/255, green: 215/255, blue: 96/255))
                                    .frame(width: 44, height: 44)
                                Image(systemName: viewModel.state.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                        }
                        .buttonStyle(.plain)

                        Button(action: { viewModel.nextTrack() }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                }
            } else {
                // Fallback UI when paused / no track / not running
                VStack(spacing: 12) {
                    Image(systemName: viewModel.isRunning ? "music.note" : "antenna.radiowaves.left.and.right.slash")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.gray)

                    Text(viewModel.isRunning ? "Spotify is Idle" : "Spotify is Closed")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    Text(viewModel.isRunning
                         ? "No media currently playing in Spotify. Click play to resume playback."
                         : "Launch Spotify to display currently playing track and artwork.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)

                    Button(action: { viewModel.togglePlayPause() }) {
                        Label(viewModel.isRunning ? "Play" : "Launch Spotify", systemImage: "play.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(red: 30/255, green: 215/255, blue: 96/255))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Permissions Card
    private var permissionsCardView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("macOS System Automation")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)

            HStack {
                Text("Automation Permission:")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gray)
                Spacer()
                Text(viewModel.permissionStatus.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(permissionStatusColor)
            }

            Text("Controls Spotify via ScriptingBridge and AppleScript without requiring web API tokens or internet login.")
                .font(.system(size: 11))
                .foregroundStyle(Color.gray.opacity(0.8))

            Button(action: { viewModel.requestPermissions() }) {
                Label("Test / Request Permission", systemImage: "lock.shield")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Widget Previews Card
    private var widgetPreviewsCardView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Widget Live Previews")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Button(action: {
                    viewModel.triggerWidgetReload()
                }) {
                    Label(viewModel.showingReloadFeedback ? "Reloaded!" : "Reload Widgets", systemImage: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(viewModel.showingReloadFeedback ? Color(red: 30/255, green: 215/255, blue: 96/255) : .white)
                }
                .buttonStyle(.plain)
            }

            // Medium Widget Preview Card
            VStack(alignment: .leading, spacing: 6) {
                Text("Medium Widget (Notification Center & Desktop)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.gray)

                MediumPreviewContainer(state: viewModel.state, artworkData: viewModel.artworkData)
                    .frame(height: 132)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            }

            // Small Widget Preview Card
            VStack(alignment: .leading, spacing: 6) {
                Text("Small Widget (Desktop & Dock)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.gray)

                SmallPreviewContainer(state: viewModel.state, artworkData: viewModel.artworkData)
                    .frame(width: 148, height: 148)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Instructions Card
    private var instructionsCardView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Adding Widget to macOS")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 6) {
                instructionRow(number: "1", title: "Desktop Widget", description: "Right-click any empty area on your Desktop and select 'Edit Widgets…'.")
                instructionRow(number: "2", title: "Notification Center", description: "Click the Date / Time in the menu bar, scroll down, and click 'Edit Widgets…'.")
                instructionRow(number: "3", title: "Select Widgit", description: "Find 'Widgit' or 'Spotify Widget' in the widget gallery and drag Small or Medium to your preferred spot.")
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func instructionRow(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 20, height: 20)
                Text(number)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                Text(description)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.gray)
            }
        }
    }

    private var statusColor: Color {
        guard viewModel.isRunning else { return .red }
        switch viewModel.state.status {
        case .playing: return Color(red: 30/255, green: 215/255, blue: 96/255)
        case .paused: return .yellow
        case .stopped: return .gray
        case .notRunning: return .red
        }
    }

    private var statusText: String {
        guard viewModel.isRunning else { return "Spotify Closed" }
        return "Spotify \(viewModel.state.status.displayName)"
    }

    private var permissionStatusColor: Color {
        switch viewModel.permissionStatus {
        case .authorized: return Color(red: 30/255, green: 215/255, blue: 96/255)
        case .denied: return .red
        case .notDetermined: return .orange
        case .spotifyNotRunning: return .gray
        case .unknown: return .gray
        }
    }
}

// MARK: - Medium Preview Container
struct MediumPreviewContainer: View {
    let state: SpotifyPlaybackState
    let artworkData: Data?

    var body: some View {
        let isClosed = !state.isSpotifyRunning
        let hasTrack = state.hasActiveTrack

        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255)

            if !isClosed && hasTrack, let track = state.track {
                HStack(spacing: 14) {
                    Group {
                        if let data = artworkData, let nsImg = NSImage(data: data) {
                            Image(nsImage: nsImg)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.06))
                                Image(systemName: "music.note")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color(red: 30/255, green: 215/255, blue: 96/255))
                            }
                        }
                    }
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(state.isPlaying ? Color(red: 30/255, green: 215/255, blue: 96/255) : Color.gray)
                                .frame(width: 6, height: 6)

                            Text(state.isPlaying ? "NOW PLAYING" : "PAUSED")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(state.isPlaying ? Color(red: 30/255, green: 215/255, blue: 96/255) : Color.gray)

                            Spacer()

                            Text("\(track.formattedPosition) / \(track.formattedDuration)")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.gray)
                        }

                        Text(track.displayTitle)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text("\(track.displayArtist) • \(track.displayAlbum)")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.gray)
                            .lineLimit(1)

                        HStack(spacing: 16) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.85))

                            ZStack {
                                Circle()
                                    .fill(Color(red: 30/255, green: 215/255, blue: 96/255))
                                    .frame(width: 28, height: 28)
                                Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.black)
                            }

                            Image(systemName: "forward.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.85))

                            Spacer()
                        }
                    }
                }
                .padding(14)
            } else {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 80, height: 80)
                        Image(systemName: isClosed ? "antenna.radiowaves.left.and.right.slash" : "music.quarternote.3")
                            .font(.system(size: 28))
                            .foregroundStyle(isClosed ? Color.gray : Color(red: 30/255, green: 215/255, blue: 96/255))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(isClosed ? "Spotify is Closed" : "Spotify is Idle")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)

                        Text(isClosed ? "Launch Spotify desktop app to view currently playing media." : "No active track playing.")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.gray)
                    }

                    Spacer()
                }
                .padding(14)
            }
        }
    }
}

// MARK: - Small Preview Container
struct SmallPreviewContainer: View {
    let state: SpotifyPlaybackState
    let artworkData: Data?

    var body: some View {
        let isClosed = !state.isSpotifyRunning
        let hasTrack = state.hasActiveTrack

        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255)

            if !isClosed && hasTrack, let track = state.track {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Group {
                            if let data = artworkData, let nsImg = NSImage(data: data) {
                                Image(nsImage: nsImg)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.06))
                                    Image(systemName: "music.note")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color(red: 30/255, green: 215/255, blue: 96/255))
                                }
                            }
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        Spacer()

                        Circle()
                            .fill(state.isPlaying ? Color(red: 30/255, green: 215/255, blue: 96/255) : Color.gray)
                            .frame(width: 6, height: 6)
                    }

                    Spacer(minLength: 0)

                    Text(track.displayTitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(track.displayArtist)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.gray)
                        .lineLimit(1)

                    HStack(spacing: 10) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.85))

                        ZStack {
                            Circle()
                                .fill(Color(red: 30/255, green: 215/255, blue: 96/255))
                                .frame(width: 24, height: 24)
                            Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                        }

                        Image(systemName: "forward.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .padding(10)
            } else {
                VStack(spacing: 6) {
                    Image(systemName: isClosed ? "music.note.house.fill" : "pause.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(isClosed ? Color.gray : Color(red: 30/255, green: 215/255, blue: 96/255))

                    Text(isClosed ? "Spotify Closed" : "Spotify Idle")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)

                    Text(isClosed ? "Open Spotify" : "No track playing")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.gray)
                }
                .padding(10)
            }
        }
    }
}
