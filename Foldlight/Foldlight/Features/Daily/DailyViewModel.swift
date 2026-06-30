//
//  DailyViewModel.swift
//  Foldlight
//
//  Presentation logic for the Daily Puzzle screen. Computes the deterministic
//  day key and seed for today (Technical PRD §4.3) and reflects whether today's
//  daily has already been completed. The actual generated puzzle is produced in
//  the generator phase; this foundation owns the stable seeding the UI shows.
//

import Foundation

@MainActor
final class DailyViewModel: ObservableObject {
    private var environment: AppEnvironment?
    private let now: Date
    private let calendar: Calendar

    /// - Parameters allow tests to inject a fixed date/calendar.
    init(now: Date = Date(), calendar: Calendar = .current) {
        self.now = now
        self.calendar = calendar
    }

    /// Stable `yyyy-MM-dd` key for today.
    var dayKey: String {
        DailyPuzzleSeed.dayKey(for: now, calendar: calendar)
    }

    /// Deterministic seed for today's puzzle.
    var seed: UInt64 {
        DailyPuzzleSeed.seed(for: now, calendar: calendar)
    }

    /// Whether the player has already completed today's daily puzzle.
    var isCompletedToday: Bool {
        environment?.profile.lastDailyCompletedDay == dayKey
    }

    /// Current daily streak.
    var streak: Int {
        environment?.profile.dailyPuzzleStreak ?? 0
    }

    /// A friendly, human-readable date for display.
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: now)
    }

    func configure(environment: AppEnvironment) {
        guard self.environment == nil else { return }
        self.environment = environment
    }

    func onAppear() {
        guard let analytics = environment?.analytics else { return }
        Task { await analytics.track(.screenViewed("daily")) }
    }
}
