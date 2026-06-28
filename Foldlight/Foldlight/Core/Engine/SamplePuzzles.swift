//
//  SamplePuzzles.swift
//  Foldlight
//
//  Core engine. Hardcoded, hand-verified puzzles used by the play-screen demo
//  and by unit tests to prove a puzzle can be solved purely through engine
//  calls. These are interim fixtures; the procedural generator (Phase 4)
//  replaces them as the source of real levels.
//

import Foundation

/// A small library of hardcoded puzzles with known solutions.
enum SamplePuzzles {
    /// A 2×3 puzzle solvable with a single fold.
    ///
    /// ```
    /// L . G        (row 0)   L = light source emitting right
    /// . P .        (row 1)   P = path, G = goal crystal
    /// ```
    /// Folding the bottom row up onto the top row drops the path between the
    /// light and the goal, completing the beam.
    static var firstFold: Puzzle {
        let board = Board(tiles: [
            [Tile.light(facing: .right), nil, Tile.goal],
            [nil, Tile.path, nil]
        ])
        return Puzzle(id: "sample.firstFold", title: "First Light", initialBoard: board, parFolds: 1)
    }

    /// The fold sequence that solves ``firstFold``.
    static let firstFoldSolution: [Fold] = [
        Fold(direction: .bottomOntoTop, position: 0)
    ]
}
