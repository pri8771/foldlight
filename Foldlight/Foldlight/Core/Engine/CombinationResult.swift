//
//  CombinationResult.swift
//  Foldlight
//
//  Core engine. The documented tile-overlap combination rules (Technical PRD
//  §3.3 and FOLDLIGHT-PROMPT-002). All rules are symmetric (A+B == B+A).
//

import Foundation

/// The outcome of two tiles overlapping in one cell after a fold.
enum CombinationResult: String, Equatable, Sendable, Codable, CaseIterable {
    /// light source + goal crystal → puzzle won.
    case win
    /// path + path → a connected (repaired) path.
    case connectedPath
    /// light source + mirror → reflected beam (mirror retained).
    case reflectedBeam
    /// light source + shadow → revealed (hidden) path.
    case revealedPath
    /// key + lock → opened gate.
    case openedGate
    /// seed + water → grown plant bridge.
    case grownBridge
    /// fire + ice → steam blocker.
    case steamBlocker
    /// monster + cage → captured monster.
    case capturedMonster

    /// Whether this combination immediately wins the puzzle.
    var isWin: Bool { self == .win }

    /// The tile type the merged cell becomes, or `nil` when no tile change
    /// occurs (the winning overlap retains the existing tile).
    var resultingType: TileType? {
        switch self {
        case .win: return nil
        case .connectedPath: return .path
        case .reflectedBeam: return .mirror
        case .revealedPath: return .path
        case .openedGate: return .openGate
        case .grownBridge: return .bridge
        case .steamBlocker: return .steam
        case .capturedMonster: return .capturedMonster
        }
    }
}

/// The symmetric matrix that resolves overlapping tile types.
enum CombinationMatrix {
    /// The combination for an unordered pair of tile types, or `nil` if none.
    static func result(_ a: TileType, _ b: TileType) -> CombinationResult? {
        func pair(_ x: TileType, _ y: TileType) -> Bool {
            (a == x && b == y) || (a == y && b == x)
        }

        if pair(.lightSource, .goalCrystal) { return .win }
        if pair(.path, .path) { return .connectedPath }
        if pair(.lightSource, .mirror) { return .reflectedBeam }
        if pair(.lightSource, .shadow) { return .revealedPath }
        if pair(.key, .lock) { return .openedGate }
        if pair(.seed, .water) { return .grownBridge }
        if pair(.fire, .ice) { return .steamBlocker }
        if pair(.monster, .cage) { return .capturedMonster }
        return nil
    }
}
