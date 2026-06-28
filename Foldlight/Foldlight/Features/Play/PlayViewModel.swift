//
//  PlayViewModel.swift
//  Foldlight
//
//  Presentation state for the Play screen. Phase 2 wires the core puzzle engine
//  in: this view model drives a real `PuzzleState` for a hardcoded sample puzzle
//  so the folding mechanic and beam solver are demonstrably playable through
//  engine calls — without any SpriteKit. The polished SpriteKit board and free
//  fold gestures arrive in Phase 3; gameplay logic stays in the engine/VM, never
//  in the view.
//

import Foundation

@MainActor
final class PlayViewModel: ObservableObject {
    @Published private(set) var state: PuzzleState

    private var environment: AppEnvironment?
    private let solution: [Fold]

    init(puzzle: Puzzle = SamplePuzzles.firstFold, solution: [Fold] = SamplePuzzles.firstFoldSolution) {
        self.state = PuzzleState(puzzle: puzzle)
        self.solution = solution
    }

    // MARK: Derived display state

    var board: Board { state.board }
    var moveCount: Int { state.moveCount }
    var canUndo: Bool { state.canUndo }
    var isSolved: Bool { state.isSolved }

    /// Coordinates the beam currently travels through, for highlighting.
    var beamCoordinates: Set<BoardCoordinate> {
        Set(state.beam().visitedCoordinates)
    }

    /// The next fold from the known solution, if the puzzle is not yet solved.
    var nextHintFold: Fold? {
        guard !isSolved, state.moveCount < solution.count else { return nil }
        return solution[state.moveCount]
    }

    var statusText: String {
        if isSolved {
            return "Solved — the light reaches the crystal in \(moveCount) fold\(moveCount == 1 ? "" : "s")."
        }
        switch state.beam().termination {
        case .blocked, .exitedBoard:
            return "The beam doesn't reach the goal yet. Fold the board to connect the light."
        case .noSource:
            return "No light source on the board."
        case .loopGuard:
            return "The beam loops — fold to redirect it."
        case .reachedGoal:
            return "Solved!"
        }
    }

    // MARK: Intent

    func configure(environment: AppEnvironment) {
        guard self.environment == nil else { return }
        self.environment = environment
    }

    func onAppear() {
        guard let analytics = environment?.analytics else { return }
        Task { await analytics.track(.screenViewed("play")) }
    }

    /// Apply the next solving fold (the in-app demo affordance for Phase 2).
    func applyHintFold() {
        guard let fold = nextHintFold else { return }
        let applied = state.apply(fold)
        if applied {
            environment?.haptics.play(isSolved ? .success : .lightImpact)
        } else {
            environment?.haptics.play(.warning)
        }
    }

    func undo() {
        if state.undo() {
            environment?.haptics.play(.selection)
        }
    }

    func reset() {
        state.reset()
        environment?.haptics.play(.selection)
    }
}
