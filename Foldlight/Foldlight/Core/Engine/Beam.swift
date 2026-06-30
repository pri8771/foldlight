//
//  Beam.swift
//  Foldlight
//
//  Core engine. Light-beam direction, segments and result types returned by the
//  solver for both win detection and UI animation (Technical PRD §3.4).
//

import Foundation

/// A cardinal beam travel direction. Row increases downward.
enum BeamDirection: String, Codable, Sendable, CaseIterable {
    case up
    case down
    case left
    case right

    var rowDelta: Int {
        switch self {
        case .up: return -1
        case .down: return 1
        case .left, .right: return 0
        }
    }

    var columnDelta: Int {
        switch self {
        case .left: return -1
        case .right: return 1
        case .up, .down: return 0
        }
    }

    /// The light-source orientation that emits in this direction.
    var emissionOrientation: Orientation {
        switch self {
        case .up: return .deg0
        case .right: return .deg90
        case .down: return .deg180
        case .left: return .deg270
        }
    }

    /// The direction a light source with the given orientation emits.
    init(emitting orientation: Orientation) {
        switch orientation {
        case .deg0: self = .up
        case .deg90: self = .right
        case .deg180: self = .down
        case .deg270: self = .left
        }
    }

    /// The direction after reflecting off a mirror of the given orientation.
    /// Forward-slash `/` swaps up↔right and down↔left; back-slash `\` swaps
    /// up↔left and down↔right. Either way the beam turns 90°.
    func reflected(off orientation: Orientation) -> BeamDirection {
        if orientation.isForwardSlashMirror {
            switch self {
            case .up: return .right
            case .right: return .up
            case .down: return .left
            case .left: return .down
            }
        } else {
            switch self {
            case .up: return .left
            case .left: return .up
            case .down: return .right
            case .right: return .down
            }
        }
    }
}

/// One straight segment of the beam between two adjacent cells.
struct BeamSegment: Equatable, Sendable {
    let from: BoardCoordinate
    let to: BoardCoordinate
    let direction: BeamDirection
}

/// Why the beam stopped.
enum BeamTermination: String, Equatable, Sendable {
    case reachedGoal
    case blocked
    case exitedBoard
    case loopGuard
    case noSource
}

/// The full result of tracing the beam.
struct BeamResult: Equatable, Sendable {
    let segments: [BeamSegment]
    let reachedGoal: Bool
    let termination: BeamTermination

    /// The coordinates the beam passes through, in order (origin first).
    var visitedCoordinates: [BoardCoordinate] {
        guard let first = segments.first else { return [] }
        return [first.from] + segments.map(\.to)
    }
}
