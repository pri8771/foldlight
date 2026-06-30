//
//  PreferencesStoreTests.swift
//  FoldlightTests
//
//  Tests for UserDefaults-backed preferences and settings persistence.
//

import XCTest
@testable import Foldlight

final class PreferencesStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: PreferencesStore!

    override func setUpWithError() throws {
        suiteName = "FoldlightTests-\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        store = PreferencesStore(defaults: defaults)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testLaunchCountStartsAtZeroAndIncrements() {
        XCTAssertEqual(store.launchCount, 0)
        XCTAssertEqual(store.recordLaunch(), 1)
        XCTAssertEqual(store.recordLaunch(), 2)
        XCTAssertEqual(store.launchCount, 2)
    }

    func testFirstLaunchFlagPersists() {
        XCTAssertFalse(store.hasCompletedFirstLaunch)
        store.hasCompletedFirstLaunch = true
        XCTAssertTrue(store.hasCompletedFirstLaunch)
    }

    func testDefaultSettingsWhenNoneStored() {
        XCTAssertEqual(store.loadSettings(), .default)
    }

    func testSettingsRoundTrip() {
        var settings = GameSettings.default
        settings.hapticsEnabled = false
        settings.musicEnabled = false
        settings.colorBlindAssist = true

        store.save(settings)
        XCTAssertEqual(store.loadSettings(), settings)
    }
}
