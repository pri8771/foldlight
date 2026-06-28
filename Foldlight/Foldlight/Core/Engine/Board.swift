//
//  Board.swift
//  Foldlight
//
//  Core engine. A rectangular grid of cells, stored as a value type so board
//  snapshots are cheap and safe for undo history (Technical PRD §3.5).
//

import Foundation

/// A rectangular puzzle board of `height` rows × `width` columns.
struct Board: Equatable, Codable, Sendable {
    let width: Int
    let height: Int
    /// Row-major grid: `cells[row][column]`.
    private(set) var cells: [[Cell]]

    /// Designated initializer. The grid is normalized to exactly
    /// `height × width`, padding or truncating defensively (never crashes).
    init(width: Int, height: Int, cells: [[Cell]]) {
        let safeWidth = max(0, width)
        let safeHeight = max(0, height)
        var normalized: [[Cell]] = []
        normalized.reserveCapacity(safeHeight)
        for row in 0..<safeHeight {
            var rowCells = row < cells.count ? cells[row] : []
            if rowCells.count < safeWidth {
                rowCells.append(contentsOf: Array(repeating: .empty, count: safeWidth - rowCells.count))
            } else if rowCells.count > safeWidth {
                rowCells = Array(rowCells.prefix(safeWidth))
            }
            normalized.append(rowCells)
        }
        self.width = safeWidth
        self.height = safeHeight
        self.cells = normalized
    }

    /// An all-empty board.
    init(width: Int, height: Int) {
        self.init(
            width: width,
            height: height,
            cells: Array(repeating: Array(repeating: Cell.empty, count: max(0, width)), count: max(0, height))
        )
    }

    // MARK: - Bounds & lookup

    /// Whether a coordinate is inside the board.
    func contains(_ coordinate: BoardCoordinate) -> Bool {
        coordinate.row >= 0 && coordinate.row < height &&
        coordinate.column >= 0 && coordinate.column < width
    }

    /// The cell at a coordinate, or `.empty` when out of bounds.
    func cell(at coordinate: BoardCoordinate) -> Cell {
        guard contains(coordinate) else { return .empty }
        return cells[coordinate.row][coordinate.column]
    }

    /// The effective tile type at a coordinate (`.empty` when out of bounds).
    func effectiveType(at coordinate: BoardCoordinate) -> TileType {
        cell(at: coordinate).effectiveType
    }

    /// The topmost tile at a coordinate, if any.
    func tile(at coordinate: BoardCoordinate) -> Tile? {
        cell(at: coordinate).top
    }

    /// All coordinates, row-major.
    var coordinates: [BoardCoordinate] {
        var result: [BoardCoordinate] = []
        result.reserveCapacity(width * height)
        for row in 0..<height {
            for column in 0..<width {
                result.append(BoardCoordinate(row: row, column: column))
            }
        }
        return result
    }

    /// The first coordinate (row-major) whose effective tile is `type`.
    func coordinate(ofFirst type: TileType) -> BoardCoordinate? {
        for row in 0..<height {
            for column in 0..<width {
                if cells[row][column].effectiveType == type {
                    return BoardCoordinate(row: row, column: column)
                }
            }
        }
        return nil
    }

    // MARK: - Placement

    /// Replace the cell at a coordinate (no-op if out of bounds).
    mutating func setCell(_ cell: Cell, at coordinate: BoardCoordinate) {
        guard contains(coordinate) else { return }
        cells[coordinate.row][coordinate.column] = cell
    }

    /// Add a tile as a new top layer at a coordinate (no-op if out of bounds).
    mutating func place(_ tile: Tile, at coordinate: BoardCoordinate) {
        guard contains(coordinate) else { return }
        cells[coordinate.row][coordinate.column].layers.append(tile)
    }
}

extension Board {
    /// Build a board from a grid of optional tiles; `nil` means an empty cell.
    /// Rows are top-to-bottom, columns left-to-right.
    init(tiles: [[Tile?]]) {
        let height = tiles.count
        let width = tiles.map(\.count).max() ?? 0
        var cells = Array(repeating: Array(repeating: Cell.empty, count: width), count: height)
        for row in 0..<height {
            for column in 0..<tiles[row].count {
                if let tile = tiles[row][column] {
                    cells[row][column] = Cell(tile)
                }
            }
        }
        self.init(width: width, height: height, cells: cells)
    }
}
