//
//  DailyPuzzleSeedTests.swift
//  FoldlightTests
//
//  Tests that the daily-puzzle seed is deterministic per calendar day.
//

import XCTest
@testable import Foldlight

final class DailyPuzzleSeedTests: XCTestCase {
    private var utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        // Force interpretation in UTC to match the test calendar.
        return utc.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }

    func testDayKeyFormat() {
        let key = DailyPuzzleSeed.dayKey(for: date(2026, 6, 28), calendar: utc)
        XCTAssertEqual(key, "2026-06-28")
    }

    func testSeedIsDeterministicForSameDay() {
        let morning = date(2026, 6, 28)
        let later = utc.date(byAdding: .hour, value: 6, to: morning) ?? morning
        XCTAssertEqual(
            DailyPuzzleSeed.seed(for: morning, calendar: utc),
            DailyPuzzleSeed.seed(for: later, calendar: utc)
        )
    }

    func testSeedDiffersAcrossDays() {
        XCTAssertNotEqual(
            DailyPuzzleSeed.seed(for: date(2026, 6, 28), calendar: utc),
            DailyPuzzleSeed.seed(for: date(2026, 6, 29), calendar: utc)
        )
    }

    func testFNV1aIsStableAndKnown() {
        // Reference FNV-1a 64-bit hash of the empty string is the offset basis.
        XCTAssertEqual(DailyPuzzleSeed.fnv1a(""), 0xcbf29ce484222325)
    }
}
