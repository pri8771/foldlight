//
//  PlayView.swift
//  Foldlight
//
//  Puzzle play screen. Foundation placeholder wired into navigation; the
//  playable board is implemented in later phases (see PlayViewModel).
//

import SwiftUI

struct PlayView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = PlayViewModel()

    var body: some View {
        ScreenScaffold {
            VStack(spacing: FoldlightSpacing.lg) {
                Spacer()

                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(FoldlightColor.primary)
                    .accessibilityHidden(true)

                Text("Folding Board")
                    .font(FoldlightTypography.title())
                    .foregroundStyle(FoldlightColor.textPrimary)

                InfoBanner(systemImage: "wrench.and.screwdriver", message: viewModel.statusMessage)
                    .padding(.horizontal, FoldlightSpacing.lg)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(AppRoute.play.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(environment: environment)
            viewModel.onAppear()
        }
    }
}

#Preview {
    NavigationStack {
        PlayView()
    }
    .environmentObject(AppEnvironment.live())
    .environmentObject(AppRouter())
}
