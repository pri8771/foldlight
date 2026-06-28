//
//  FoldlightApp.swift
//  Foldlight
//
//  Application entry point. Constructs the composition root (AppEnvironment)
//  and the navigation router, injects them into the SwiftUI environment, and
//  bootstraps persisted state on launch.
//

import SwiftUI

@main
struct FoldlightApp: App {
    @StateObject private var environment = AppEnvironment.live()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(environment)
                .environmentObject(router)
                .task {
                    await environment.bootstrap()
                }
                .preferredColorScheme(.dark)
        }
    }
}
