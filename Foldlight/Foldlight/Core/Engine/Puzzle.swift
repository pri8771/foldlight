//
//  Puzzle.swift
//  Foldlight
//
//  Core engine. The serializable definition of a puzzle (its starting board and
//  goal) and the evaluated result of a play session.
//

import Foundation

/// The win condition for a puzzle. Only one goal type exists in the MVP.
enum PuzzleGoal: String, Codable, Sendable, Equatable {
    /// Guide the light beam from the source to the goal crystal.
    case guideLightToGoal
}

/// A self-contained puzzle definition. Codable for save/load and for bundled or
/// generated level storage.
struct Puzzle: Equatable, Codable, Sendable, Identifiable {
    let id: String
    let title: String
    let initialBoard: Board
    let goal: PuzzleGoal
    /// The optimal (par) number of folds, when known — used for star scoring.
    let parFolds: Int?

    init(id: String, title: String, initialBoard: Board, goal: PuzzleGoal = .guideLightToGoal, parFolds: Int? = nil) {
        self.id = id
        self.title = title
        self.initialBoard = initialBoard
        self.goal = goal
        self.parFolds = parFolds
    }
}

/// A snapshot evaluation of a play session.
struct PuzzleResult: Equatable, Sendable {
    let isSolved: Bool
    let beam: BeamResult
    let moveCount: Int
}
