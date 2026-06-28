//
//  PlayView.swift
//  Foldlight
//
//  Puzzle play screen. Phase 2 renders a lightweight SwiftUI board that reflects
//  the live engine state and lets the player drive the sample puzzle to a solved
//  state (fold / undo / reset). The polished SpriteKit board with free fold
//  gestures and animations replaces this grid in Phase 3.
//

import SwiftUI

struct PlayView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = PlayViewModel()

    var body: some View {
        ScreenScaffold {
            ScrollView {
                VStack(spacing: FoldlightSpacing.lg) {
                    boardGrid

                    Text(viewModel.statusText)
                        .font(FoldlightTypography.body())
                        .foregroundStyle(viewModel.isSolved ? FoldlightColor.success : FoldlightColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    controls

                    InfoBanner(
                        systemImage: "hand.draw",
                        message: "Phase 2 wires in the deterministic fold engine and beam solver. Phase 3 replaces this grid with the SpriteKit board and free fold gestures."
                    )
                }
                .padding(FoldlightSpacing.lg)
            }
        }
        .navigationTitle(AppRoute.play.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(environment: environment)
            viewModel.onAppear()
        }
    }

    private var boardGrid: some View {
        let board = viewModel.board
        let beam = viewModel.beamCoordinates
        return VStack(spacing: FoldlightSpacing.xs) {
            ForEach(0..<board.height, id: \.self) { row in
                HStack(spacing: FoldlightSpacing.xs) {
                    ForEach(0..<board.width, id: \.self) { column in
                        let coordinate = BoardCoordinate(row: row, column: column)
                        TileCellView(
                            type: board.effectiveType(at: coordinate),
                            isOnBeam: beam.contains(coordinate)
                        )
                    }
                }
            }
        }
        .padding(FoldlightSpacing.md)
        .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: FoldlightRadius.md)
                .stroke(FoldlightColor.border, lineWidth: 1)
        )
    }

    private var controls: some View {
        VStack(spacing: FoldlightSpacing.sm) {
            PrimaryButton(
                viewModel.isSolved ? "Solved" : "Fold to Connect the Light",
                systemImage: viewModel.isSolved ? "checkmark.circle.fill" : "arrow.uturn.down"
            ) {
                viewModel.applyHintFold()
            }
            .disabled(viewModel.nextHintFold == nil)
            .opacity(viewModel.nextHintFold == nil ? 0.5 : 1)

            HStack(spacing: FoldlightSpacing.md) {
                Button {
                    viewModel.undo()
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                        .frame(maxWidth: .infinity)
                }
                .disabled(!viewModel.canUndo)

                Button {
                    viewModel.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
            }
            .font(FoldlightTypography.headline())
            .foregroundStyle(FoldlightColor.primary)
        }
    }
}

/// One board cell rendered with a tile glyph and optional beam highlight.
private struct TileCellView: View {
    let type: TileType
    let isOnBeam: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: FoldlightRadius.sm)
            .fill(FoldlightColor.background)
            .frame(width: 48, height: 48)
            .overlay(
                Image(systemName: type.glyph)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(type.glyphTint)
            )
            .overlay(
                RoundedRectangle(cornerRadius: FoldlightRadius.sm)
                    .stroke(isOnBeam ? FoldlightColor.fragment : FoldlightColor.border,
                            lineWidth: isOnBeam ? 2 : 1)
            )
            .accessibilityLabel(type.accessibilityName)
    }
}

private extension TileType {
    /// SF Symbol used to represent the tile in the Phase 2 grid.
    var glyph: String {
        switch self {
        case .empty: return "circle.dotted"
        case .lightSource: return "sun.max.fill"
        case .goalCrystal: return "diamond.fill"
        case .path, .bridge, .openGate, .capturedMonster: return "square.fill"
        case .mirror: return "line.diagonal"
        case .blocker, .steam: return "xmark.square.fill"
        case .seed: return "leaf.fill"
        case .water: return "drop.fill"
        case .fire: return "flame.fill"
        case .ice: return "snowflake"
        case .key: return "key.fill"
        case .lock: return "lock.fill"
        case .shadow: return "moon.fill"
        case .monster: return "ant.fill"
        case .cage: return "square.grid.3x3.square"
        }
    }

    var glyphTint: Color {
        switch self {
        case .lightSource: return FoldlightColor.fragment
        case .goalCrystal: return FoldlightColor.success
        case .path, .bridge, .openGate, .capturedMonster: return FoldlightColor.primary.opacity(0.7)
        case .mirror: return FoldlightColor.accent
        case .empty: return FoldlightColor.border
        default: return FoldlightColor.textSecondary
        }
    }

    var accessibilityName: String {
        switch self {
        case .empty: return "empty"
        case .lightSource: return "light source"
        case .goalCrystal: return "goal crystal"
        default: return rawValue
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
