//
//  Tile.swift
//  Foldlight
//
//  Core engine. A single tile value. Tiles are identified positionally by the
//  board (no UUID at the engine layer), which keeps fold replay deterministic
//  and board equality content-based. A stable render identity for animations is
//  layered on top in the SpriteKit phase.
//

import Foundation

/// A board tile: its kind, rotation, and reveal state.
struct Tile: Equatable, Codable, Sendable {
    var type: TileType
    var orientation: Orientation
    var isRevealed: Bool

    init(type: TileType, orientation: Orientation = .deg0, isRevealed: Bool = true) {
        self.type = type
        self.orientation = orientation
        self.isRevealed = isRevealed
    }
}

extension Tile {
    static var path: Tile { Tile(type: .path) }
    static var goal: Tile { Tile(type: .goalCrystal) }

    /// A light source emitting toward `direction`.
    static func light(facing direction: BeamDirection) -> Tile {
        Tile(type: .lightSource, orientation: direction.emissionOrientation)
    }

    /// A mirror reflecting as `/` (forward slash) or `\` (back slash).
    static func mirror(_ orientation: Orientation) -> Tile {
        Tile(type: .mirror, orientation: orientation)
    }
}
