//
//  RootView.swift
//  Foldlight
//
//  Hosts the root NavigationStack and maps AppRoute values to feature screens.
//  Home is the stack root; every other area is a pushed destination. This is the
//  single place navigation destinations are resolved.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .tint(FoldlightColor.primary)
    }

    /// Resolve a route to its feature screen.
    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .play:
            PlayView()
        case .daily:
            DailyView()
        case .infinite:
            InfiniteView()
        case .restoration:
            RestorationView()
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppEnvironment.live())
        .environmentObject(AppRouter())
}
