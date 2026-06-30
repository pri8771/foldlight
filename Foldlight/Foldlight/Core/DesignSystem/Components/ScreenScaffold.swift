//
//  ScreenScaffold.swift
//  Foldlight
//
//  A reusable screen container that applies the shared Foldlight background
//  gradient and standard padding. Every feature screen wraps its content in
//  this so the visual language stays consistent without repetition.
//

import SwiftUI

/// Shared screen background + layout scaffold.
struct ScreenScaffold<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [FoldlightColor.backgroundElevated, FoldlightColor.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
        }
    }
}

#Preview {
    ScreenScaffold {
        Text("Foldlight")
            .font(FoldlightTypography.largeTitle())
            .foregroundStyle(FoldlightColor.textPrimary)
    }
}
