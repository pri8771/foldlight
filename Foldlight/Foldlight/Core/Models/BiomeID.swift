//
//  BiomeID.swift
//  Foldlight
//
//  The 10 biome themes that structure world progression and the restoration
//  meta-game (Technical PRD §4.4). Defined here as a stable, ordered identifier
//  so persistence and UI can reference biomes without string typos.
//

import Foundation

/// One of Foldlight's 10 visual/world biomes, in unlock order.
enum BiomeID: String, Codable, CaseIterable, Sendable, Identifiable {
    case crystalCave
    case glassForest
    case starMap
    case shadowRealm
    case moonGarden
    case fireFjord
    case ancientLibrary
    case voidArchive
    case sunkenAtoll
    case luminousDesert

    var id: String { rawValue }

    /// The first biome a new player starts in.
    static var starting: BiomeID { .crystalCave }

    /// User-facing display name.
    var displayName: String {
        switch self {
        case .crystalCave: return "Crystal Cave"
        case .glassForest: return "Glass Forest"
        case .starMap: return "Star Map"
        case .shadowRealm: return "Shadow Realm"
        case .moonGarden: return "Moon Garden"
        case .fireFjord: return "Fire Fjord"
        case .ancientLibrary: return "Ancient Library"
        case .voidArchive: return "Void Archive"
        case .sunkenAtoll: return "Sunken Atoll"
        case .luminousDesert: return "Luminous Desert"
        }
    }

    /// SF Symbol used as a placeholder biome glyph until art is produced.
    var systemImage: String {
        switch self {
        case .crystalCave: return "diamond.fill"
        case .glassForest: return "tree.fill"
        case .starMap: return "sparkles"
        case .shadowRealm: return "moon.fill"
        case .moonGarden: return "leaf.fill"
        case .fireFjord: return "flame.fill"
        case .ancientLibrary: return "books.vertical.fill"
        case .voidArchive: return "circle.hexagongrid.fill"
        case .sunkenAtoll: return "water.waves"
        case .luminousDesert: return "sun.max.fill"
        }
    }
}
