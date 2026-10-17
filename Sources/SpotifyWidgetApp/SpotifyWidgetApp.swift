import SwiftUI

@main
struct SpotifyWidgetApp: App {
    var body: some Scene {
        WindowGroup("Widgit - Spotify Desktop & Widget") {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 820, height: 660)
    }
}
