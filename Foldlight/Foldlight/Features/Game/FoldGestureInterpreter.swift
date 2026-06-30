//
//  FoldGestureInterpreter.swift
//  Foldlight
//
//  Translates a drag gesture into a candidate fold. This is pure input mapping
//  (Foundation + CoreGraphics only — no SpriteKit/SwiftUI), so it is unit
//  testable and keeps the gesture→fold logic out of the rendering layer. The
//  engine still decides legality and applies the fold; this only proposes one.
//

import Foundation
import CoreGraphics

/// A drag gesture expressed in grid-relative terms.
struct FoldGesture: Equatable {
    /// The cell the drag started on (the grabbed flap edge).
    let startCell: BoardCoordinate
    /// Horizontal drag amount; positive = rightward.
    let dx: CGFloat
    /// Vertical drag amount in screen space; positive = downward.
    let dyDown: CGFloat
}

/// Maps a ``FoldGesture`` to the fold the player intends.
enum FoldGestureInterpreter {
    /// The candidate fold for a gesture, or `nil` if the drag is too small or
    /// the board is too thin to fold along the dragged axis.
    ///
    /// The grabbed cell becomes the edge of the folding flap and the drag
    /// direction chooses which region folds:
    /// - drag down → top region folds down; drag up → bottom folds up
    /// - drag right → left region folds right; drag left → right folds left
    static func fold(
        for gesture: FoldGesture,
        boardWidth: Int,
        boardHeight: Int,
        minimumMagnitude: CGFloat
    ) -> Fold? {
        let magnitude = hypot(gesture.dx, gesture.dyDown)
        guard magnitude >= minimumMagnitude else { return nil }

        if abs(gesture.dx) >= abs(gesture.dyDown) {
            guard boardWidth >= 2 else { return nil }
            if gesture.dx > 0 {
                return Fold(direction: .leftOntoRight,
                            position: clamp(gesture.startCell.column, 0, boardWidth - 2))
            } else {
                return Fold(direction: .rightOntoLeft,
                            position: clamp(gesture.startCell.column - 1, 0, boardWidth - 2))
            }
        } else {
            guard boardHeight >= 2 else { return nil }
            if gesture.dyDown > 0 {
                return Fold(direction: .topOntoBottom,
                            position: clamp(gesture.startCell.row, 0, boardHeight - 2))
            } else {
                return Fold(direction: .bottomOntoTop,
                            position: clamp(gesture.startCell.row - 1, 0, boardHeight - 2))
            }
        }
    }

    private static func clamp(_ value: Int, _ lower: Int, _ upper: Int) -> Int {
        min(max(value, lower), upper)
    }
}
