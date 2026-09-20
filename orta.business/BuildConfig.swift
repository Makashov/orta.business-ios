//
//  BuildConfig.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import Foundation

/// Reads values out of the bundled Debug.xcconfig/Release.xcconfig, following
/// `#include`/`#include?` directives the same way Xcode itself resolves them
/// (later assignments — including ones pulled in via an include — override
/// earlier ones for the same key).
///
/// Xcode's `GENERATE_INFOPLIST_FILE` only auto-maps a fixed set of Apple-known
/// `INFOPLIST_KEY_*` settings into the generated Info.plist — a custom key like
/// `API_BASE_URL` is silently dropped (verified: it never appears in the built
/// Info.plist even though `-showBuildSettings` resolves it correctly). All
/// three xcconfig files are already bundled as app resources, so this reads
/// the value straight from disk instead.
enum BuildConfig {
    static var apiBaseHost: String {
        value(for: "API_BASE_URL", in: xcconfigResourceName, visited: []) ?? "localhost:8080"
    }

    /// The tenant-scoped API base, e.g. "test" + "localhost:8080" -> http://test.localhost:8080/api.
    static func apiBaseURL(tenant: String) -> URL? {
        let scheme = apiBaseHost.contains(":") ? "http" : "https"
        return URL(string: "\(scheme)://\(tenant).\(apiBaseHost)/api")
    }

    /// - Parameter visited: resource names already opened on this call stack, to guard against `#include` cycles.
    private static func value(for key: String, in resourceName: String, visited: Set<String>) -> String? {
        guard
            !visited.contains(resourceName),
            let url = Bundle.main.url(forResource: resourceName, withExtension: "xcconfig"),
            let contents = try? String(contentsOf: url, encoding: .utf8)
        else {
            return nil
        }
        let visited = visited.union([resourceName])

        var result: String?
        for rawLine in contents.split(separator: "\n", omittingEmptySubsequences: false) {
            // xcconfig comments run from "//" to the end of the line, including on
            // otherwise-valid assignment lines (e.g. a URL value like "https://…").
            let line = rawLine.components(separatedBy: "//")[0].trimmingCharacters(in: .whitespaces)

            if line.hasPrefix("#include"), let includedName = includedResourceName(from: line) {
                if let includedValue = value(for: key, in: includedName, visited: visited) {
                    result = includedValue
                }
                continue
            }

            guard line.hasPrefix(key) else { continue }
            let parts = line.split(separator: "=", maxSplits: 1)
            guard parts.count == 2, parts[0].trimmingCharacters(in: .whitespaces) == key else { continue }
            result = parts[1].trimmingCharacters(in: .whitespaces)
        }
        return result
    }

    /// Extracts "Foo" from `#include "Foo.xcconfig"` / `#include? "Foo.xcconfig"`.
    private static func includedResourceName(from line: String) -> String? {
        guard
            let firstQuote = line.firstIndex(of: "\""),
            let lastQuote = line.lastIndex(of: "\""),
            firstQuote != lastQuote
        else {
            return nil
        }
        let filename = line[line.index(after: firstQuote)..<lastQuote]
        return String(filename).replacingOccurrences(of: ".xcconfig", with: "")
    }

    #if DEBUG
    private static let xcconfigResourceName = "Debug"
    #else
    private static let xcconfigResourceName = "Release"
    #endif
}
