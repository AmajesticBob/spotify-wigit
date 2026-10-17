import Foundation
import AppKit
import ApplicationServices

/// Status of macOS AppleEvents Automation Permission for Spotify
public enum AutomationPermissionStatus: String, Codable, Sendable {
    case authorized = "Authorized"
    case denied = "Denied"
    case notDetermined = "Not Determined"
    case spotifyNotRunning = "Spotify Not Running"
    case unknown = "Unknown"
}

/// Helper for managing and diagnosing macOS automation permissions for Spotify
public final class SystemPermissionManager: @unchecked Sendable {
    public static let shared = SystemPermissionManager()

    public let targetBundleIdentifier = "com.spotify.client"

    public init() {}

    /// Checks the current automation permission status for Spotify.
    public func checkPermissionStatus() -> AutomationPermissionStatus {
        guard let runningApp = NSRunningApplication.runningApplications(withBundleIdentifier: targetBundleIdentifier).first(where: { !$0.isTerminated }) else {
            return .spotifyNotRunning
        }

        var pid = runningApp.processIdentifier
        var targetDesc = AEDesc()
        let createStatus = AECreateDesc(typeKernelProcessID, &pid, MemoryLayout<pid_t>.size, &targetDesc)
        guard createStatus == noErr else {
            return .unknown
        }
        defer { AEDisposeDesc(&targetDesc) }

        // Test without prompting
        let status = AEDeterminePermissionToAutomateTarget(&targetDesc, typeWildCard, typeWildCard, false)
        switch status {
        case noErr:
            return .authorized
        case -1743: // errAEEventNotPermitted / not permitted
            return .denied
        case -1744, -600: // errAENotAuthorized or procNotFound
            return .notDetermined
        default:
            return status < 0 ? .denied : .unknown
        }
    }

    /// Requests automation permission by triggering a prompt if not yet determined.
    @discardableResult
    public func promptForPermissionIfNeeded() -> Bool {
        guard let runningApp = NSRunningApplication.runningApplications(withBundleIdentifier: targetBundleIdentifier).first(where: { !$0.isTerminated }) else {
            return false
        }

        var pid = runningApp.processIdentifier
        var targetDesc = AEDesc()
        let createStatus = AECreateDesc(typeKernelProcessID, &pid, MemoryLayout<pid_t>.size, &targetDesc)
        guard createStatus == noErr else {
            return false
        }
        defer { AEDisposeDesc(&targetDesc) }

        let status = AEDeterminePermissionToAutomateTarget(&targetDesc, typeWildCard, typeWildCard, true)
        return status == noErr
    }
}
