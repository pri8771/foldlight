//
//  MenuCard.swift
//  Foldlight
//
//  A tappable card used on the Home screen to enter each major game area.
//

import SwiftUI

/// A large, tappable navigation card with an icon, title and subtitle.
struct MenuCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: FoldlightSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 48, height: 48)
                    .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: FoldlightRadius.sm))

                VStack(alignment: .leading, spacing: FoldlightSpacing.xxs) {
                    Text(title)
                        .font(FoldlightTypography.headline())
                        .foregroundStyle(FoldlightColor.textPrimary)
                    Text(subtitle)
                        .font(FoldlightTypography.caption())
                        .foregroundStyle(FoldlightColor.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(FoldlightColor.textSecondary)
            }
            .padding(FoldlightSpacing.md)
            .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: FoldlightRadius.md)
                    .stroke(FoldlightColor.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScreenScaffold {
        MenuCard(
            title: "Daily Puzzle",
            subtitle: "A fresh hand-quality puzzle every day",
            systemImage: "calendar",
            tint: FoldlightColor.accent
        ) {}
        .padding()
    }
}
