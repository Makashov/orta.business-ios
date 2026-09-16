//
//  BuildConfig.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import Foundation

/// Reads values out of the bundled Debug.xcconfig/Release.xcconfig.
///
/// Xcode's `GENERATE_INFOPLIST_FILE` only auto-maps a fixed set of Apple-known
/// `INFOPLIST_KEY_*` settings into the generated Info.plist — a custom key like
/// `API_BASE_URL` is silently dropped (verified: it never appears in the built
/// Info.plist even though `-showBuildSettings` resolves it correctly). Both
/// xcconfig files are already bundled as app resources, so this reads the value
/// straight from the one matching the active build configuration instead.
enum BuildConfig {
    static var apiBaseHost: String {
        value(for: "API_BASE_URL") ?? "localhost:8080"
    }

    private static func value(for key: String) -> String? {
        guard
            let url = Bundle.main.url(forResource: xcconfigResourceName, withExtension: "xcconfig"),
            let contents = try? String(contentsOf: url, encoding: .utf8)
        else {
            return nil
        }

        for line in contents.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix(key) else { continue }
            let parts = trimmed.split(separator: "=", maxSplits: 1)
            guard parts.count == 2, parts[0].trimmingCharacters(in: .whitespaces) == key else { continue }
            return parts[1].trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    #if DEBUG
    private static let xcconfigResourceName = "Debug"
    #else
    private static let xcconfigResourceName = "Release"
    #endif
}
