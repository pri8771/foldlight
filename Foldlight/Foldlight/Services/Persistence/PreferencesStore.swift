//
//  PreferencesStore.swift
//  Foldlight
//
//  Lightweight UserDefaults-backed store for small, frequently-read scalar
//  preferences and launch metadata (Technical PRD §6.2). Game settings are
//  encoded as a single JSON blob so the schema can evolve without juggling many
//  individual keys.
//

import Foundation

/// Typed wrapper over `UserDefaults` for simple preferences.
///
/// `UserDefaults` is thread-safe, so this type is marked `@unchecked Sendable`.
final class PreferencesStore: @unchecked Sendable {
    private enum Key {
        static let launchCount = "foldlight.launchCount"
        static let hasCompletedFirstLaunch = "foldlight.hasCompletedFirstLaunch"
        static let gameSettings = "foldlight.gameSettings"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Launch metadata

    /// Number of times the app has launched.
    var launchCount: Int {
        get { defaults.integer(forKey: Key.launchCount) }
        set { defaults.set(newValue, forKey: Key.launchCount) }
    }

    /// Whether first-launch onboarding has completed (drives future tutorial).
    var hasCompletedFirstLaunch: Bool {
        get { defaults.bool(forKey: Key.hasCompletedFirstLaunch) }
        set { defaults.set(newValue, forKey: Key.hasCompletedFirstLaunch) }
    }

    /// Increment and persist the launch counter, returning the new value.
    @discardableResult
    func recordLaunch() -> Int {
        let next = launchCount + 1
        launchCount = next
        return next
    }

    // MARK: - Game settings

    /// Load persisted settings, falling back to defaults when unset or corrupt.
    func loadSettings() -> GameSettings {
        guard
            let data = defaults.data(forKey: Key.gameSettings),
            let settings = try? decoder.decode(GameSettings.self, from: data)
        else {
            return .default
        }
        return settings
    }

    /// Persist settings. Silently ignores encoding failure (non-critical path)
    /// but never crashes.
    func save(_ settings: GameSettings) {
        guard let data = try? encoder.encode(settings) else { return }
        defaults.set(data, forKey: Key.gameSettings)
    }
}
