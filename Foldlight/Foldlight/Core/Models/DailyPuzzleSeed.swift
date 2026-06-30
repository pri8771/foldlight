//
//  DailyPuzzleSeed.swift
//  Foldlight
//
//  Deterministic daily-puzzle seeding (Technical PRD §4.3): the same calendar
//  day always produces the same seed, with no server required. The actual
//  generator that consumes the seed arrives in a later phase; this foundation
//  provides the stable, unit-testable seed derivation it will build on.
//

import Foundation

/// Derives a deterministic seed and day-key for the daily puzzle.
enum DailyPuzzleSeed {
    /// A stable `yyyy-MM-dd` key for the given date in the given calendar.
    ///
    /// Uses a fixed POSIX locale and the calendar's time zone so the key is
    /// reproducible regardless of user locale formatting preferences.
    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    /// A deterministic 64-bit seed for the given date.
    ///
    /// Derived purely from the day key via a stable FNV-1a hash so it is
    /// reproducible across launches and devices (Swift's `Hasher` is salted per
    /// process and must not be used for persistent seeds).
    static func seed(for date: Date, calendar: Calendar = .current) -> UInt64 {
        fnv1a(dayKey(for: date, calendar: calendar))
    }

    /// Stable FNV-1a 64-bit hash of a string. Independent of `Hasher` salting.
    static func fnv1a(_ string: String) -> UInt64 {
        let offsetBasis: UInt64 = 0xcbf29ce484222325
        let prime: UInt64 = 0x00000100000001B3
        var hash = offsetBasis
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* prime
        }
        return hash
    }
}
