import Foundation
import AppKit
import CryptoKit

/// Manages shared playback state and artwork caching across the host app and widget extension.
public final class SharedDataManager: @unchecked Sendable {
    public static let shared = SharedDataManager()

    public static let appGroupIdentifier = "group.com.widgit.SpotifyWidget"
    private static let stateKey = "spotify_playback_state"

    private let userDefaults: UserDefaults
    private let fileManager = FileManager.default
    private let cacheDirectoryUrl: URL
    private let stateFileUrl: URL
    private let lock = NSLock()
    private var failedArtworkUrls: [String: Date] = [:]

    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        return URLSession(configuration: config)
    }()

    public init() {
        if let groupDefaults = UserDefaults(suiteName: Self.appGroupIdentifier) {
            self.userDefaults = groupDefaults
        } else {
            self.userDefaults = .standard
        }

        // Setup shared directory for fallback and artwork cache
        var resolvedBase: URL?
        let fm = FileManager.default

        func isUsableDirectory(_ dir: URL) -> Bool {
            do {
                try fm.createDirectory(at: dir, withIntermediateDirectories: true)
                let probe = dir.appendingPathComponent(".probe_\(UUID().uuidString)")
                try "probe".write(to: probe, atomically: true, encoding: .utf8)
                try? fm.removeItem(at: probe)
                return true
            } catch {
                return false
            }
        }

        if let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier),
           isUsableDirectory(groupUrl) {
            resolvedBase = groupUrl
        }

        if resolvedBase == nil {
            if let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let candidate = appSupport.appendingPathComponent("SpotifyWidget", isDirectory: true)
                if isUsableDirectory(candidate) {
                    resolvedBase = candidate
                }
            }
        }

        if resolvedBase == nil {
            if let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
                let candidate = caches.appendingPathComponent("SpotifyWidget", isDirectory: true)
                if isUsableDirectory(candidate) {
                    resolvedBase = candidate
                }
            }
        }

        if resolvedBase == nil {
            let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("SpotifyWidget", isDirectory: true)
            try? fm.createDirectory(at: tempDir, withIntermediateDirectories: true)
            resolvedBase = tempDir
        }

        let baseDir = resolvedBase ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let artworkDir = baseDir.appendingPathComponent("ArtworkCache", isDirectory: true)
        try? fm.createDirectory(at: artworkDir, withIntermediateDirectories: true)
        self.cacheDirectoryUrl = artworkDir
        self.stateFileUrl = baseDir.appendingPathComponent("playback_state.json")
    }

    /// Saves the current playback state to UserDefaults and shared file storage.
    public func saveState(_ state: SpotifyPlaybackState) {
        lock.lock()
        defer { lock.unlock() }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(state)
            userDefaults.set(data, forKey: Self.stateKey)
            try? data.write(to: stateFileUrl, options: .atomic)
        } catch {
            NSLog("[SharedDataManager] Error encoding state: %@", error.localizedDescription)
        }
    }

    /// Loads the most recently saved playback state (picking the freshest between UserDefaults and file storage).
    public func loadState() -> SpotifyPlaybackState? {
        lock.lock()
        defer { lock.unlock() }

        let decoder = JSONDecoder()

        let userDefaultsState: SpotifyPlaybackState? = {
            guard let data = userDefaults.data(forKey: Self.stateKey) else { return nil }
            return try? decoder.decode(SpotifyPlaybackState.self, from: data)
        }()

        let fileState: SpotifyPlaybackState? = {
            guard let fileData = try? Data(contentsOf: stateFileUrl) else { return nil }
            return try? decoder.decode(SpotifyPlaybackState.self, from: fileData)
        }()

        if let uds = userDefaultsState, let fs = fileState {
            return uds.lastUpdated >= fs.lastUpdated ? uds : fs
        }

        return userDefaultsState ?? fileState
    }

    /// Loads cached artwork for a given URL string or track ID.
    public func loadCachedArtwork(forKey key: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        let fileUrl = artworkFileUrl(forKey: key)
        return try? Data(contentsOf: fileUrl)
    }

    /// Caches artwork data for a given URL string or track ID.
    public func cacheArtwork(data: Data, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        let fileUrl = artworkFileUrl(forKey: key)
        do {
            try data.write(to: fileUrl, options: .atomic)
        } catch {
            NSLog("[SharedDataManager] Artwork write error to %@: %@", fileUrl.path, error.localizedDescription)
        }
    }

    /// Asynchronously fetches artwork from a URL and caches it.
    public func fetchAndCacheArtwork(from urlString: String) async -> Data? {
        guard !urlString.isEmpty else { return nil }

        // Check disk cache first
        if let cached = loadCachedArtwork(forKey: urlString) {
            return cached
        }

        // Check failed URL cooldown (60 seconds)
        if isArtworkUrlCoolingDown(urlString) {
            return nil
        }

        guard let url = URL(string: urlString) else {
            recordFailedArtworkUrl(urlString)
            return nil
        }

        do {
            let (data, response) = try await urlSession.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                recordFailedArtworkUrl(urlString)
                return nil
            }
            clearFailedArtworkUrl(urlString)
            cacheArtwork(data: data, forKey: urlString)
            return data
        } catch {
            recordFailedArtworkUrl(urlString)
            return nil
        }
    }

    private func isArtworkUrlCoolingDown(_ url: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if let failedDate = failedArtworkUrls[url], Date().timeIntervalSince(failedDate) < 60.0 {
            return true
        }
        return false
    }

    private func recordFailedArtworkUrl(_ url: String) {
        lock.lock()
        defer { lock.unlock() }
        failedArtworkUrls[url] = Date()
    }

    private func clearFailedArtworkUrl(_ url: String) {
        lock.lock()
        defer { lock.unlock() }
        failedArtworkUrls.removeValue(forKey: url)
    }

    private func artworkFileUrl(forKey key: String) -> URL {
        let hash = SHA256.hash(data: Data(key.utf8))
        let hexString = hash.map { String(format: "%02x", $0) }.joined()
        return cacheDirectoryUrl.appendingPathComponent("\(hexString).img")
    }
}
