//
//  InfoBanner.swift
//  Foldlight
//
//  A small informational banner used by foundation screens to communicate that
//  the interactive gameplay for an area arrives in a later implementation phase.
//  Keeps placeholder messaging consistent and clearly labeled.
//

import SwiftUI

struct InfoBanner: View {
    let systemImage: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: FoldlightSpacing.sm) {
            Image(systemName: systemImage)
                .foregroundStyle(FoldlightColor.primary)
            Text(message)
                .font(FoldlightTypography.caption())
                .foregroundStyle(FoldlightColor.textSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(FoldlightSpacing.md)
        .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: FoldlightRadius.md)
                .stroke(FoldlightColor.border, lineWidth: 1)
        )
    }
}

#Preview {
    ScreenScaffold {
        InfoBanner(systemImage: "wrench.and.screwdriver", message: "Interactive board arrives in a later phase.")
            .padding()
    }
}
