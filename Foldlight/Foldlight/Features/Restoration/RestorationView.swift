//
//  RestorationView.swift
//  Foldlight
//
//  World Restoration / meta-progression entry point. Shows the 10 biomes and
//  their unlock state, and the player's Light Fragment balance.
//

import SwiftUI

struct RestorationView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = RestorationViewModel()

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: FoldlightSpacing.md)]

    var body: some View {
        ScreenScaffold {
            ScrollView {
                VStack(alignment: .leading, spacing: FoldlightSpacing.lg) {
                    HStack {
                        Label("\(environment.profile.lightFragments) Fragments", systemImage: "sparkle")
                            .font(FoldlightTypography.headline())
                            .foregroundStyle(FoldlightColor.fragment)
                        Spacer()
                        Text("\(viewModel.unlockedCount)/\(BiomeID.allCases.count) restored")
                            .font(FoldlightTypography.caption())
                            .foregroundStyle(FoldlightColor.textSecondary)
                    }

                    LazyVGrid(columns: columns, spacing: FoldlightSpacing.md) {
                        ForEach(viewModel.biomeStatuses) { status in
                            BiomeCell(status: status)
                        }
                    }

                    InfoBanner(
                        systemImage: "globe.americas",
                        message: "Spend Light Fragments earned from puzzles to rebuild islands, light constellations, and return creatures. Restoration spending arrives in Phase 5."
                    )
                }
                .padding(FoldlightSpacing.lg)
            }
        }
        .navigationTitle(AppRoute.restoration.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(environment: environment)
            viewModel.onAppear()
        }
    }
}

private struct BiomeCell: View {
    let status: RestorationViewModel.BiomeStatus

    var body: some View {
        VStack(spacing: FoldlightSpacing.sm) {
            Image(systemName: status.isUnlocked ? status.biome.systemImage : "lock.fill")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(status.isUnlocked ? FoldlightColor.primary : FoldlightColor.textSecondary)
            Text(status.biome.displayName)
                .font(FoldlightTypography.caption())
                .foregroundStyle(FoldlightColor.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: FoldlightRadius.md)
                .stroke(FoldlightColor.border, lineWidth: 1)
        )
        .opacity(status.isUnlocked ? 1 : 0.55)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(status.biome.displayName), \(status.isUnlocked ? "unlocked" : "locked")")
    }
}

#Preview {
    NavigationStack {
        RestorationView()
    }
    .environmentObject(AppEnvironment.live())
    .environmentObject(AppRouter())
}
