//
//  SettingsView.swift
//  Foldlight
//
//  Settings screen. Toggles for haptics, sound, music and accessibility. Each
//  change is persisted immediately via the view model.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section("Feedback") {
                Toggle("Haptics", isOn: binding(\.hapticsEnabled))
                Toggle("Sound Effects", isOn: binding(\.soundEffectsEnabled))
                Toggle("Music", isOn: binding(\.musicEnabled))
            }

            Section("Accessibility") {
                Toggle("Reduce Motion", isOn: binding(\.reduceMotion))
                Toggle("Color-Blind Assist", isOn: binding(\.colorBlindAssist))
            }

            Section("About") {
                LabeledContent("Version", value: viewModel.appVersion)
                LabeledContent("Game", value: "Foldlight")
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            LinearGradient(
                colors: [FoldlightColor.backgroundElevated, FoldlightColor.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle(AppRoute.settings.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(environment: environment)
            viewModel.onAppear()
        }
    }

    /// A binding that writes through to the view model and persists on change.
    private func binding(_ keyPath: WritableKeyPath<GameSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { viewModel.settings[keyPath: keyPath] },
            set: { newValue in
                viewModel.settings[keyPath: keyPath] = newValue
                viewModel.commit()
            }
        )
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(AppEnvironment.live())
    .environmentObject(AppRouter())
}
