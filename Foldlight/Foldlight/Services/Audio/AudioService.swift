//
//  AudioService.swift
//  Foldlight
//
//  STUB SERVICE — intentionally a safe placeholder for the Phase 1 foundation.
//
//  The Technical PRD calls for ASMR-quality fold sounds and background music
//  (§ Design Philosophy, E010 asset production). No audio assets exist yet, so
//  this service configures the audio session correctly and exposes the API the
//  game will call, but routing real samples is deferred to a later phase.
//
//  The stub is clearly isolated behind the `AudioPlaying` protocol and never
//  performs unsafe work: calls are no-ops (optionally logged) when disabled or
//  when no asset is wired up.
//

import Foundation
#if canImport(AVFoundation)
import AVFoundation
#endif

/// Semantic sound effects the game can request.
enum SoundEffect: String, Sendable {
    case fold
    case invalidFold
    case combine
    case win
    case tap
}

/// Plays sound effects and background music, gated by user preference.
@MainActor
protocol AudioPlaying: AnyObject {
    var soundEffectsEnabled: Bool { get set }
    var musicEnabled: Bool { get set }
    func prepare()
    func play(_ effect: SoundEffect)
    func startMusic()
    func stopMusic()
}

/// Default audio service. Configures `AVAudioSession` and provides the call
/// surface the game uses. Effect playback is a documented stub until assets
/// are produced (E010).
@MainActor
final class AudioService: AudioPlaying {
    var soundEffectsEnabled: Bool
    var musicEnabled: Bool

    private var isPrepared = false

    init(soundEffectsEnabled: Bool = true, musicEnabled: Bool = true) {
        self.soundEffectsEnabled = soundEffectsEnabled
        self.musicEnabled = musicEnabled
    }

    /// Configure the audio session. Uses `.ambient` so the game mixes with other
    /// audio and respects the silent switch (Bug Tracker RISK-010 mitigation).
    func prepare() {
        guard !isPrepared else { return }
        isPrepared = true
        #if canImport(AVFoundation) && !os(macOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        #endif
    }

    func play(_ effect: SoundEffect) {
        guard soundEffectsEnabled else { return }
        // STUB: no audio assets bundled yet. Sound routing lands with E010.
    }

    func startMusic() {
        guard musicEnabled else { return }
        // STUB: background music tracks land with E010.
    }

    func stopMusic() {
        // STUB: no-op until music playback is implemented.
    }
}
