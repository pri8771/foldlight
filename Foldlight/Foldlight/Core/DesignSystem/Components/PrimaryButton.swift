//
//  PrimaryButton.swift
//  Foldlight
//
//  Shared primary call-to-action button used across the app shell.
//

import SwiftUI

/// A prominent, full-width call-to-action button styled with design tokens.
struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: FoldlightSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(FoldlightTypography.headline())
            .foregroundStyle(FoldlightColor.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, FoldlightSpacing.md)
            .background(FoldlightColor.primary, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScreenScaffold {
        PrimaryButton("Play", systemImage: "play.fill") {}
            .padding()
    }
}
