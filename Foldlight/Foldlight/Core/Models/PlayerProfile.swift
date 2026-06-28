//
//  PlayerProfile.swift
//  Foldlight
//
//  The persisted player progression record for the MVP foundation. Mirrors the
//  PlayerProgress fields described in Technical PRD §5.1, but modeled as a plain
//  Codable value type so it can be saved with the file-based SaveService
//  (SwiftData migration is deferred to a later phase per the Phase 1 prompt).
//

import Foundation

/// Durable player progression state.
///
/// A pure `Codable` value type — no UIKit/SwiftUI/SwiftData dependency — so the
/// domain stays testable and persistence-agnostic.
struct PlayerProfile: Codable, Equatable, Sendable {
    /// Schema version for forward-compatible, versioned save migrations.
    var schemaVersion: Int
    var totalLevelsCompleted: Int
    var totalStarsEarned: Int
    var lightFragments: Int
    var currentBiome: BiomeID
    var unlockedBiomes: Set<BiomeID>
    var dailyPuzzleStreak: Int
    var lastDailyCompletedDay: String?
    var totalPlayTimeSeconds: TimeInterval

    /// Current schema version. Increment when fields change to drive migration.
    static let currentSchemaVersion = 1

    /// A fresh profile for a brand-new player.
    static var new: PlayerProfile {
        PlayerProfile(
            schemaVersion: currentSchemaVersion,
            totalLevelsCompleted: 0,
            totalStarsEarned: 0,
            lightFragments: 0,
            currentBiome: .starting,
            unlockedBiomes: [.starting],
            dailyPuzzleStreak: 0,
            lastDailyCompletedDay: nil,
            totalPlayTimeSeconds: 0
        )
    }

    /// Whether a biome is available to the player.
    func isUnlocked(_ biome: BiomeID) -> Bool {
        unlockedBiomes.contains(biome)
    }
}
