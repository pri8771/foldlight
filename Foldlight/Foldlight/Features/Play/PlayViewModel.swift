//
//  PlayViewModel.swift
//  Foldlight
//
//  Presentation state for the Play screen. In this foundation phase the screen
//  is a wired placeholder: the deterministic fold engine (FOLDLIGHT-PROMPT-002)
//  and the SpriteKit board renderer (FOLDLIGHT-PROMPT-003) replace the
//  placeholder body in later phases. The view model already owns the seam those
//  phases plug into, so no gameplay logic lives in the view.
//

import Foundation

@MainActor
final class PlayViewModel: ObservableObject {
    private var environment: AppEnvironment?

    /// Human-readable status describing what this screen will host.
    let statusMessage = "The interactive folding board renders here once the core puzzle engine (Phase 2) and SpriteKit board (Phase 3) land."

    func configure(environment: AppEnvironment) {
        guard self.environment == nil else { return }
        self.environment = environment
    }

    func onAppear() {
        guard let analytics = environment?.analytics else { return }
        Task { await analytics.track(.screenViewed("play")) }
    }
}
