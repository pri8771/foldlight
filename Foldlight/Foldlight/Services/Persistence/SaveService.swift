//
//  SaveService.swift
//  Foldlight
//
//  Abstraction over durable, Codable-based local persistence. Defining a
//  protocol keeps call sites testable (swap in a temp-directory instance or a
//  fake) and lets a future phase replace the file backend with SwiftData
//  without touching consumers.
//

import Foundation

/// A namespaced key identifying a single persisted document.
struct SaveKey: Hashable, Sendable {
    /// Filename stem (without extension). Kept filesystem-safe by construction.
    let name: String

    init(_ name: String) {
        self.name = name
    }

    /// The player progression document.
    static let playerProfile = SaveKey("player_profile")
}

/// Errors surfaced by persistence operations. No operation fails silently.
enum SaveError: Error, Equatable {
    case encodingFailed
    case decodingFailed
    case writeFailed
    case readFailed
}

/// Durable load/save of `Codable` values. All work is async and `Sendable`-safe
/// so it can run off the main actor.
protocol SaveService: Sendable {
    /// Persist a value for the given key, overwriting any existing document.
    func save<Value: Encodable & Sendable>(_ value: Value, for key: SaveKey) async throws

    /// Load a value for the given key, or `nil` if nothing is stored.
    func load<Value: Decodable & Sendable>(_ type: Value.Type, for key: SaveKey) async throws -> Value?

    /// Remove the document for the given key. No-op if it does not exist.
    func delete(for key: SaveKey) async throws

    /// Whether a document exists for the given key.
    func exists(for key: SaveKey) async -> Bool
}
