//
//  FileSaveService.swift
//  Foldlight
//
//  Real (non-stub) implementation of `SaveService` backed by JSON documents in
//  the app's Application Support directory. Writes are atomic and use file
//  protection so partially-written or corrupt saves are avoided
//  (Technical PRD §6, §12). Implemented as an actor for thread-safe access.
//

import Foundation

/// File-backed, Codable JSON persistence. Each `SaveKey` maps to one `.json`
/// document inside a dedicated subdirectory of Application Support.
actor FileSaveService: SaveService {
    private let directory: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// - Parameter directory: Root directory for save documents. Defaults to
    ///   `Application Support/Foldlight/Saves`. Tests inject a temp directory.
    init(directory: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        if let directory {
            self.directory = directory
        } else {
            let base = (try? fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )) ?? fileManager.temporaryDirectory
            self.directory = base
                .appendingPathComponent("Foldlight", isDirectory: true)
                .appendingPathComponent("Saves", isDirectory: true)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func save<Value: Encodable & Sendable>(_ value: Value, for key: SaveKey) async throws {
        try ensureDirectoryExists()
        let data: Data
        do {
            data = try encoder.encode(value)
        } catch {
            throw SaveError.encodingFailed
        }
        do {
            try data.write(to: url(for: key), options: [.atomic, .completeFileProtection])
        } catch {
            throw SaveError.writeFailed
        }
    }

    func load<Value: Decodable & Sendable>(_ type: Value.Type, for key: SaveKey) async throws -> Value? {
        let fileURL = url(for: key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw SaveError.readFailed
        }
        do {
            return try decoder.decode(Value.self, from: data)
        } catch {
            throw SaveError.decodingFailed
        }
    }

    func delete(for key: SaveKey) async throws {
        let fileURL = url(for: key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            throw SaveError.writeFailed
        }
    }

    func exists(for key: SaveKey) async -> Bool {
        fileManager.fileExists(atPath: url(for: key).path)
    }

    // MARK: - Helpers

    private func ensureDirectoryExists() throws {
        guard !fileManager.fileExists(atPath: directory.path) else { return }
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            throw SaveError.writeFailed
        }
    }

    private func url(for key: SaveKey) -> URL {
        directory.appendingPathComponent(key.name).appendingPathExtension("json")
    }
}
