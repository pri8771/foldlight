//
//  Difficulty.swift
//  Foldlight
//
//  Difficulty tiers and their associated Light Fragment reward ranges.
//  Values are sourced from the planning docs (economy figures in the prompt
//  log / progression PRD) and centralized here so later phases (generator,
//  rewards) read from one place rather than duplicating magic numbers.
//

import Foundation

/// Puzzle difficulty tier.
enum Difficulty: String, Codable, CaseIterable, Sendable, Identifiable {
    case easy
    case medium
    case hard
    case expert

    var id: String { rawValue }

    /// User-facing label.
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }

    /// Inclusive Light Fragment reward range for solving a puzzle of this tier.
    /// (Easy 5–10, Medium 15–25, Hard 35–50, Expert 75–100.)
    var fragmentReward: ClosedRange<Int> {
        switch self {
        case .easy: return 5...10
        case .medium: return 15...25
        case .hard: return 35...50
        case .expert: return 75...100
        }
    }

    /// Number of folds that characterizes this tier (used by the generator in
    /// a later phase). Easy ≤3, Medium 4–6, Hard 7–9, Expert 10+.
    var foldRange: ClosedRange<Int> {
        switch self {
        case .easy: return 1...3
        case .medium: return 4...6
        case .hard: return 7...9
        case .expert: return 10...14
        }
    }
}
