//
//  FileSaveServiceTests.swift
//  FoldlightTests
//
//  Round-trip tests for the real file-backed persistence service.
//

import XCTest
@testable import Foldlight

final class FileSaveServiceTests: XCTestCase {
    private var tempDirectory: URL!
    private var service: FileSaveService!

    override func setUpWithError() throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("FoldlightTests-\(UUID().uuidString)", isDirectory: true)
        service = FileSaveService(directory: tempDirectory)
    }

    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: tempDirectory.path) {
            try FileManager.default.removeItem(at: tempDirectory)
        }
    }

    func testSaveThenLoadRoundTrips() async throws {
        var profile = PlayerProfile.new
        profile.lightFragments = 42
        profile.totalLevelsCompleted = 7
        profile.unlockedBiomes = [.crystalCave, .glassForest]

        try await service.save(profile, for: .playerProfile)
        let loaded = try await service.load(PlayerProfile.self, for: .playerProfile)

        XCTAssertEqual(loaded, profile)
    }

    func testLoadMissingReturnsNil() async throws {
        let loaded = try await service.load(PlayerProfile.self, for: .playerProfile)
        XCTAssertNil(loaded)
    }

    func testExistsReflectsState() async throws {
        let before = await service.exists(for: .playerProfile)
        XCTAssertFalse(before)

        try await service.save(PlayerProfile.new, for: .playerProfile)
        let after = await service.exists(for: .playerProfile)
        XCTAssertTrue(after)
    }

    func testDeleteRemovesDocument() async throws {
        try await service.save(PlayerProfile.new, for: .playerProfile)
        try await service.delete(for: .playerProfile)

        let exists = await service.exists(for: .playerProfile)
        XCTAssertFalse(exists)
    }

    func testDeleteMissingDoesNotThrow() async throws {
        try await service.delete(for: .playerProfile)
    }

    func testSaveOverwritesPreviousValue() async throws {
        var first = PlayerProfile.new
        first.lightFragments = 1
        try await service.save(first, for: .playerProfile)

        var second = PlayerProfile.new
        second.lightFragments = 999
        try await service.save(second, for: .playerProfile)

        let loaded = try await service.load(PlayerProfile.self, for: .playerProfile)
        XCTAssertEqual(loaded?.lightFragments, 999)
    }
}
