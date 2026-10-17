# Widgit: Spotify macOS Desktop & Notification Center Widget

A native macOS application and interactive WidgetKit extension that displays currently playing Spotify media (track title, artist, album, and artwork) and provides interactive playback controls (play/pause, next track, previous track) via local macOS scripting without requiring external web API credentials or Spotify developer tokens.

---

## Features

- **Local Scripting Bridge (R1)**: Seamlessly interfaces with the local Spotify macOS application via AppleScript and ScriptingBridge (`ScriptingBridge.framework`). Queries track metadata (title, artist, album, album art URL, duration, position) and playback state (playing, paused, stopped, not running).
- **Interactive macOS WidgetKit Extension (R2)**: Built using SwiftUI and WidgetKit.
  - Supports standard widget sizes: `systemSmall` (compact artwork, title, artist, play/pause & skip controls) and `systemMedium` (high-res artwork, status badge, title, artist, album, progress bar, timestamps, and full media controls).
  - Uses modern interactive `AppIntent` buttons (`TogglePlayPauseIntent`, `NextTrackIntent`, `PreviousTrackIntent`) that execute media commands in the background without bringing the host app to the foreground.
  - Automatically fetches and caches album artwork locally for instant widget rendering.
  - Provides graceful fallback UI when Spotify is closed, stopped, or no track is actively playing.
- **Companion Host Application (R3)**:
  - Enclosing macOS companion app (`Widgit.app`) embedding the WidgetKit extension (`Contents/PlugIns/SpotifyWidgetExtension.appex`).
  - Real-time Player Card with live metadata, artwork, progress slider, and media control buttons.
  - Live Interactive Widget Previews for both Small and Medium widget layouts.
  - System Automation & Permissions Manager: Diagnostics, status display, and one-click automation permission request (`AEDeterminePermissionToAutomateTarget`).
  - Distributed notification listener (`com.spotify.client.PlaybackState`) and timer-based sync to update shared container state and reload widget timelines (`WidgetCenter.shared.reloadAllTimelines()`).
- **Command-Line Test Harness & Verification Suite**: Standalone CLI tool (`SpotifyHarness`) for querying state, JSON formatting, triggering media actions, and running an automated 16-point test suite.

---

## Project Structure

```
widgit/
├── Package.swift                    # Swift Package Manager manifest
├── SpotifyWidget.xcodeproj/         # Xcode project for building Host App & Extension
│   ├── project.pbxproj
│   └── xcshareddata/xcschemes/SpotifyWidgetApp.xcscheme
├── Sources/
│   ├── SpotifyBridgeKit/            # Core library for Spotify scripting and data models
│   │   ├── PlaybackState.swift      # SpotifyPlaybackState, TrackMetadata, PlaybackStatus
│   │   ├── SpotifyBridge.swift      # ScriptingBridge & AppleScript bridge implementation
│   │   ├── SpotifyScriptingProtocol.swift # SBApplication Objective-C protocols
│   │   ├── SharedDataManager.swift  # App Group & local shared storage & artwork disk cache
│   │   └── SystemPermissionManager.swift # AppleEvents automation permissions
│   ├── SpotifyWidgetApp/            # macOS Companion Host Application
│   │   ├── SpotifyWidgetApp.swift   # App entry point
│   │   ├── ContentView.swift        # Host SwiftUI UI: player card, widget previews, diagnostics
│   │   ├── HostAppViewModel.swift   # Live state model, distributed notifications, timer
│   │   ├── Info.plist               # App Info.plist with NSAppleEventsUsageDescription
│   │   └── SpotifyWidgetApp.entitlements # Automation & scripting-targets entitlements
│   ├── SpotifyWidgetExtension/      # macOS WidgetKit App Extension
│   │   ├── SpotifyWidgetBundle.swift# WidgetBundle entry point
│   │   ├── SpotifyWidget.swift      # Widget definition, timeline provider, timeline entry
│   │   ├── WidgetViews.swift        # SmallWidgetView, MediumWidgetView, FallbackWidgetView
│   │   ├── SpotifyIntents.swift     # TogglePlayPauseIntent, NextTrackIntent, PreviousTrackIntent
│   │   ├── Info.plist               # com.apple.widgetkit-extension definition
│   │   └── SpotifyWidgetExtension.entitlements # Sandbox, network client, automation entitlements
│   └── SpotifyHarness/              # Standalone CLI test tool
│       └── main.swift
├── Tests/
│   └── SpotifyBridgeKitTests/       # Unit tests for models, serialization, and bridge
│       ├── PlaybackStateTests.swift
│       └── SpotifyBridgeTests.swift
└── scripts/
    ├── generate_xcodeproj.py        # Generates Xcode project
    └── verify.sh                    # End-to-end verification script
```

---

## Building and Running

### 1. Opening and Running in Xcode
1. Open `SpotifyWidget.xcodeproj` in Xcode:
   ```bash
   open SpotifyWidget.xcodeproj
   ```
2. In the Xcode scheme selector (top bar), select the **SpotifyWidgetApp** scheme and destination **My Mac**.
3. Under the **Signing & Capabilities** tab of both `SpotifyWidgetApp` and `SpotifyWidgetExtension`:
   - Select your Apple Development Team (or leave as "Sign to Run Locally" for local testing).
4. Click **Run** (or press `Cmd + R`).
   - The companion host application will launch, display the current Spotify status, and register the widget extension with macOS LaunchServices.

### 2. Command-Line Build via `xcodebuild`
To compile the companion app and embedded widget extension from the terminal:
```bash
xcodebuild -project SpotifyWidget.xcodeproj \
           -scheme SpotifyWidgetApp \
           -derivedDataPath .build/DerivedData \
           CODE_SIGNING_ALLOWED=NO \
           build
```
The output application bundle will be located at:
`.build/DerivedData/Build/Products/Debug/Widgit.app`
with the embedded extension at:
`.build/DerivedData/Build/Products/Debug/Widgit.app/Contents/PlugIns/SpotifyWidgetExtension.appex`.

### 3. Running the Verification Suite
Execute the automated end-to-end verification script:
```bash
./scripts/verify.sh
```

---

## Using the CLI Test Harness (`SpotifyHarness`)

The `SpotifyHarness` executable provides command-line interaction with the local Spotify instance:

### Query Playback Status
```bash
swift run --disable-sandbox SpotifyHarness --status
```
Example Output:
```
============================================================
Spotify Desktop & Bridge Status
============================================================
Spotify Process:     RUNNING (Active)
Automation Perm:     Authorized
Playback Status:     Playing [isPlaying: true]
Volume:              75%
Repeat Enabled:      false
Shuffle Enabled:     true
------------------------------------------------------------
Track Information:
  Title:             Blinding Lights
  Artist:            The Weeknd
  Album:             After Hours
  Duration:          3:20 (200.0s)
  Position:          1:24 (84.0s)
  Progress:          42.0%
============================================================
```

### JSON Output
```bash
swift run --disable-sandbox SpotifyHarness --json
```

### Media Controls
```bash
# Toggle play / pause
swift run --disable-sandbox SpotifyHarness --play-pause

# Skip to next track
swift run --disable-sandbox SpotifyHarness --next

# Return to previous track
swift run --disable-sandbox SpotifyHarness --previous
```

### Run Comprehensive Automated Verification
```bash
swift run --disable-sandbox SpotifyHarness --verify
```

---

## Adding the Widget to macOS Desktop & Notification Center

1. Run `Widgit.app` at least once so macOS LaunchServices registers the `SpotifyWidgetExtension`.
2. **On the Desktop**:
   - Right-click any open space on your macOS Desktop and select **Edit Widgets…**.
   - Search for **Widgit** or **Spotify Widget** in the widget gallery.
   - Drag either the **Small** or **Medium** widget onto your Desktop.
3. **In the Notification Center**:
   - Click the date and time in the top-right corner of your menu bar to open Notification Center.
   - Scroll to the bottom and click **Edit Widgets…**.
   - Add the Spotify Widget.
4. When prompted by macOS for Automation permission to control Spotify, click **OK** to authorize local scripting.
# spotify-wigit
# spotify-wigit
