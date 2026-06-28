//
//  Fold.swift
//  Foldlight
//
//  Core engine. A fold is defined by a crease line that divides the board into
//  two regions; one region (the source) folds onto the other (Technical PRD
//  §3.2). The source region is mirror-transformed across the crease.
//

import Foundation

/// The geometric axis of a fold crease.
enum FoldAxis: Codable, Sendable, Equatable {
    /// A horizontal crease — rows move (top/bottom regions).
    case horizontal
    /// A vertical crease — columns move (left/right regions).
    case vertical
}

/// Which region folds onto which (Technical PRD §3.2).
enum FoldDirection: String, Codable, Sendable, CaseIterable {
    case topOntoBottom
    case bottomOntoTop
    case leftOntoRight
    case rightOntoLeft

    /// The crease axis implied by this direction.
    var axis: FoldAxis {
        switch self {
        case .topOntoBottom, .bottomOntoTop: return .horizontal
        case .leftOntoRight, .rightOntoLeft: return .vertical
        }
    }
}

/// A concrete fold: a direction plus a crease position.
///
/// `position` is the index of the last row/column *before* the crease, so the
/// crease lies between `position` and `position + 1`. A horizontal fold reflects
/// rows across the line `row = position + 0.5`; a vertical fold reflects columns.
struct Fold: Equatable, Codable, Sendable {
    var direction: FoldDirection
    var position: Int

    init(direction: FoldDirection, position: Int) {
        self.direction = direction
        self.position = position
    }
}
