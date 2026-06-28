//
//  BoardCoordinate.swift
//  Foldlight
//
//  Core engine — pure Swift, no UIKit/SwiftUI/SpriteKit. A grid position on the
//  puzzle board expressed as (row, column), origin top-left.
//

import Foundation

/// An integer (row, column) position on the board.
struct BoardCoordinate: Hashable, Codable, Sendable {
    var row: Int
    var column: Int

    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    /// The neighbouring coordinate one step in the given beam direction.
    func offset(_ direction: BeamDirection) -> BoardCoordinate {
        BoardCoordinate(row: row + direction.rowDelta, column: column + direction.columnDelta)
    }
}
