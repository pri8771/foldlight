//
//  InfiniteViewModel.swift
//  Foldlight
//
//  Presentation state for Infinite Mode. Lets the player choose a difficulty
//  tier; the chosen tier feeds the procedural generator in a later phase. Holds
//  selection state, so it is a genuine @StateObject view model.
//

import Foundation

@MainActor
final class InfiniteViewModel: ObservableObject {
    private var environment: AppEnvironment?

    /// Currently selected difficulty tier.
    @Published var selectedDifficulty: Difficulty = .easy

    /// All selectable difficulty tiers.
    let difficulties = Difficulty.allCases

    /// Reward range label for the selected tier, e.g. "5–10 Fragments".
    var rewardText: String {
        let range = selectedDifficulty.fragmentReward
        return "\(range.lowerBound)–\(range.upperBound) Fragments"
    }

    func configure(environment: AppEnvironment) {
        guard self.environment == nil else { return }
        self.environment = environment
    }

    func select(_ difficulty: Difficulty) {
        selectedDifficulty = difficulty
        environment?.haptics.play(.selection)
    }

    func onAppear() {
        guard let analytics = environment?.analytics else { return }
        Task { await analytics.track(.screenViewed("infinite")) }
    }
}
