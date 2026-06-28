//
//  SettingsViewModel.swift
//  Foldlight
//
//  Editable settings state. Holds a working copy of GameSettings and persists
//  changes through AppEnvironment (which writes to PreferencesStore and applies
//  them to live services). Real, working persistence — not a stub.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    private var environment: AppEnvironment?

    @Published var settings: GameSettings = .default

    func configure(environment: AppEnvironment) {
        guard self.environment == nil else { return }
        self.environment = environment
        settings = environment.settings
    }

    func onAppear() {
        guard let analytics = environment?.analytics else { return }
        Task { await analytics.track(.screenViewed("settings")) }
    }

    /// Persist the current working copy and apply it to live services.
    func commit() {
        guard let environment else { return }
        environment.updateSettings(settings)
        // Give immediate tactile confirmation if haptics remain enabled.
        environment.haptics.play(.selection)
    }

    /// App version string for the about footer.
    var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "0.1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
