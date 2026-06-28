//
//  TileType.swift
//  Foldlight
//
//  Core engine. The kinds of tile that can occupy a board cell (Technical PRD
//  §3.1) plus the result tiles produced by combinations (§3.3). Each type
//  declares how the light beam interacts with it.
//

import Foundation

/// How the light beam behaves when it enters a cell of a given tile type.
enum BeamBehavior: Sendable, Equatable {
    /// The light source — beam origin.
    case source
    /// The goal crystal — beam terminates here as a win.
    case goal
    /// A mirror — beam reflects 90° based on the tile's orientation.
    case reflect
    /// A conductor (path-like) — beam passes straight through.
    case conduct
    /// Opaque — beam is blocked and stops.
    case block
}

/// Every tile type known to the engine.
enum TileType: String, Codable, Sendable, CaseIterable {
    // Base types (Technical PRD §3.1)
    case empty
    case lightSource
    case goalCrystal
    case path
    case mirror
    case blocker
    case seed
    case water
    case fire
    case ice
    case key
    case lock
    case shadow
    case monster
    case cage

    // Result types produced by tile combinations (Technical PRD §3.3)
    case steam            // fire + ice  → steam cloud (blocks the beam)
    case bridge           // seed + water → plant bridge (conducts the beam)
    case openGate         // key + lock  → opened gate (conducts the beam)
    case capturedMonster  // monster + cage → captured monster (passable)

    /// How the beam interacts with this tile.
    var beamBehavior: BeamBehavior {
        switch self {
        case .lightSource:
            return .source
        case .goalCrystal:
            return .goal
        case .mirror:
            return .reflect
        case .path, .bridge, .openGate, .capturedMonster:
            return .conduct
        case .empty, .blocker, .steam, .seed, .water, .fire, .ice,
             .key, .lock, .shadow, .monster, .cage:
            return .block
        }
    }
}
