//
//  Orientation.swift
//  Foldlight
//
//  Core engine. Discrete tile orientation (0/90/180/270°) per Technical PRD §3.1.
//  Used for the light source's emission direction and a mirror's reflective axis.
//

import Foundation

/// A tile's rotation in 90° increments.
enum Orientation: Int, Codable, Sendable, CaseIterable {
    case deg0 = 0
    case deg90 = 90
    case deg180 = 180
    case deg270 = 270

    /// Rotate clockwise by 90°.
    func rotatedClockwise() -> Orientation {
        switch self {
        case .deg0: return .deg90
        case .deg90: return .deg180
        case .deg180: return .deg270
        case .deg270: return .deg0
        }
    }

    /// A mirror at this orientation behaves as a forward-slash `/` (deg0/deg180)
    /// or a back-slash `\` (deg90/deg270) reflector.
    var isForwardSlashMirror: Bool {
        self == .deg0 || self == .deg180
    }
}
