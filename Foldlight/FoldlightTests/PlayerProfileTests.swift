//
//  PlayerProfileTests.swift
//  FoldlightTests
//
//  Tests for the player progression value type.
//

import XCTest
@testable import Foldlight

final class PlayerProfileTests: XCTestCase {
    func testNewProfileDefaults() {
        let profile = PlayerProfile.new
        XCTAssertEqual(profile.schemaVersion, PlayerProfile.currentSchemaVersion)
        XCTAssertEqual(profile.lightFragments, 0)
        XCTAssertEqual(profile.totalLevelsCompleted, 0)
        XCTAssertEqual(profile.currentBiome, .crystalCave)
        XCTAssertEqual(profile.unlockedBiomes, [.crystalCave])
        XCTAssertNil(profile.lastDailyCompletedDay)
    }

    func testStartingBiomeIsUnlockedOnly() {
        let profile = PlayerProfile.new
        XCTAssertTrue(profile.isUnlocked(.crystalCave))
        XCTAssertFalse(profile.isUnlocked(.glassForest))
    }

    func testCodableRoundTrip() throws {
        var profile = PlayerProfile.new
        profile.lightFragments = 120
        profile.dailyPuzzleStreak = 5
        profile.lastDailyCompletedDay = "2026-06-28"
        profile.unlockedBiomes = [.crystalCave, .glassForest, .starMap]

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(profile)
        let decoded = try decoder.decode(PlayerProfile.self, from: data)

        XCTAssertEqual(decoded, profile)
    }
}
