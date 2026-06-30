//
//  AppRouter.swift
//  Foldlight
//
//  Owns the navigation stack path for the app shell. Keeping navigation state
//  in one observable object (rather than scattered @State) makes deep links,
//  programmatic navigation, and unit testing straightforward.
//

import Foundation
import Combine

/// Observable navigation coordinator backing the root `NavigationStack`.
@MainActor
final class AppRouter: ObservableObject {
    /// The stack of pushed routes. Home is the implicit root (empty path).
    @Published var path: [AppRoute] = []

    /// Push a destination onto the stack.
    func push(_ route: AppRoute) {
        path.append(route)
    }

    /// Pop back to the Home root.
    func popToRoot() {
        path.removeAll()
    }

    /// Pop a single level, if possible.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
