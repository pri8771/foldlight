//
//  PuzzleState.swift
//  Foldlight
//
//  Core engine. The live, mutable play state for a puzzle: the current board,
//  the applied-fold history (for deterministic replay), and a bounded undo
//  stack of board snapshots (Technical PRD §3.5: max 20 states).
//
//  A value type so the presentation layer can hold and diff it safely.
//

import Foundation

/// Mutable state of a puzzle being played.
struct PuzzleState: Sendable, Equatable {
    /// Maximum number of undo snapshots retained (Technical PRD §3.5).
    static let maxHistory = 20

    let puzzle: Puzzle
    private(set) var board: Board
    private(set) var appliedFolds: [Fold]
    private var history: [Board]
    private(set) var didWinByCombination: Bool

    init(puzzle: Puzzle) {
        self.puzzle = puzzle
        self.board = puzzle.initialBoard
        self.appliedFolds = []
        self.history = []
        self.didWinByCombination = false
    }

    // MARK: - Queries

    /// Number of folds applied so far.
    var moveCount: Int { appliedFolds.count }

    /// Whether an undo is available.
    var canUndo: Bool { !history.isEmpty }

    /// Whether a fold would be legal on the current board.
    func isLegal(_ fold: Fold) -> Bool {
        FoldEngine.isLegal(fold, on: board)
    }

    /// The current beam trace.
    func beam() -> BeamResult {
        BeamSolver.solve(board)
    }

    /// Whether the puzzle is solved — either the beam reaches the goal or a fold
    /// directly overlapped the light source onto the goal crystal.
    var isSolved: Bool {
        didWinByCombination || beam().reachedGoal
    }

    /// A full evaluation snapshot.
    func result() -> PuzzleResult {
        let beam = self.beam()
        return PuzzleResult(
            isSolved: didWinByCombination || beam.reachedGoal,
            beam: beam,
            moveCount: moveCount
        )
    }

    // MARK: - Mutation

    /// Apply a fold. Returns `false` (and changes nothing) if the fold is
    /// illegal on the current board.
    @discardableResult
    mutating func apply(_ fold: Fold) -> Bool {
        guard let outcome = FoldEngine.apply(fold, to: board) else { return false }
        history.append(board)
        if history.count > Self.maxHistory {
            history.removeFirst(history.count - Self.maxHistory)
        }
        board = outcome.board
        appliedFolds.append(fold)
        if outcome.didWin {
            didWinByCombination = true
        }
        return true
    }

    /// Undo the most recent fold. Returns `false` if there is nothing to undo.
    @discardableResult
    mutating func undo() -> Bool {
        guard let previous = history.popLast() else { return false }
        board = previous
        if !appliedFolds.isEmpty {
            appliedFolds.removeLast()
        }
        didWinByCombination = recomputeCombinationWin()
        return true
    }

    /// Reset to the initial board, clearing history.
    mutating func reset() {
        board = puzzle.initialBoard
        appliedFolds.removeAll()
        history.removeAll()
        didWinByCombination = false
    }

    /// Recompute whether any still-applied fold produced a winning combination
    /// (used after an undo). Replays from the initial board.
    private func recomputeCombinationWin() -> Bool {
        var current = puzzle.initialBoard
        for fold in appliedFolds {
            guard let outcome = FoldEngine.apply(fold, to: current) else { continue }
            if outcome.didWin { return true }
            current = outcome.board
        }
        return false
    }
}
