//
//  GameSettings.swift
//  Foldlight
//
//  User-adjustable preferences. Persisted via UserDefaults (PreferencesStore)
//  since these are small, frequently-read scalar values (Technical PRD §6.2).
//

import Foundation

/// User-facing settings for feel and accessibility.
struct GameSettings: Codable, Equatable, Sendable {
    var hapticsEnabled: Bool
    var soundEffectsEnabled: Bool
    var musicEnabled: Bool
    var reduceMotion: Bool
    var colorBlindAssist: Bool

    /// Sensible production defaults for a first launch.
    static var `default`: GameSettings {
        GameSettings(
            hapticsEnabled: true,
            soundEffectsEnabled: true,
            musicEnabled: true,
            reduceMotion: false,
            colorBlindAssist: false
        )
    }
}
