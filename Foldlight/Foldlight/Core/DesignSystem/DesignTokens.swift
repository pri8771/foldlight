//
//  DesignTokens.swift
//  Foldlight
//
//  Centralized design tokens (colors, spacing, radius, typography) so the
//  entire app shell shares one visual language. Per the Technical PRD the game
//  should feel "modern & premium, cozy & magical" with a "soft glowing night
//  palette". These tokens are the single source of truth for that look.
//
//  No view should hard-code colors or magic numbers; pull them from here.
//

import SwiftUI

/// Namespaced color palette for Foldlight's night/stained-glass aesthetic.
///
/// Colors are defined programmatically (sRGB) so the foundation has zero
/// asset dependencies. Biome-specific skins introduced in later phases can
/// override these via a `Theme` value.
enum FoldlightColor {
    /// Deep night background.
    static let background = Color(red: 0.05, green: 0.06, blue: 0.12)
    /// Slightly lifted background used for the gradient base.
    static let backgroundElevated = Color(red: 0.09, green: 0.10, blue: 0.20)
    /// Card / surface fill.
    static let surface = Color(red: 0.13, green: 0.15, blue: 0.27)
    /// Hairline borders and dividers.
    static let border = Color(red: 0.27, green: 0.30, blue: 0.46)
    /// Primary brand glow (warm light).
    static let primary = Color(red: 0.56, green: 0.81, blue: 0.96)
    /// Secondary accent (magical violet).
    static let accent = Color(red: 0.71, green: 0.55, blue: 0.96)
    /// Success / goal-reached highlight.
    static let success = Color(red: 0.45, green: 0.86, blue: 0.62)
    /// Warning / invalid action highlight.
    static let warning = Color(red: 0.96, green: 0.72, blue: 0.40)
    /// Primary text on dark surfaces.
    static let textPrimary = Color(red: 0.95, green: 0.96, blue: 1.0)
    /// Muted secondary text.
    static let textSecondary = Color(red: 0.66, green: 0.70, blue: 0.84)
    /// Light Fragment currency tint.
    static let fragment = Color(red: 0.98, green: 0.85, blue: 0.45)
}

/// Consistent spacing scale (4-pt base grid).
enum FoldlightSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

/// Corner radius scale.
enum FoldlightRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 22
    static let pill: CGFloat = 999
}

/// Typography helpers. Uses Dynamic Type-friendly system fonts (rounded design)
/// so text scales with the user's accessibility settings (Technical PRD §9).
enum FoldlightTypography {
    static func largeTitle() -> Font { .system(.largeTitle, design: .rounded).weight(.bold) }
    static func title() -> Font { .system(.title2, design: .rounded).weight(.semibold) }
    static func headline() -> Font { .system(.headline, design: .rounded) }
    static func body() -> Font { .system(.body, design: .rounded) }
    static func caption() -> Font { .system(.caption, design: .rounded) }
    static func numeric() -> Font { .system(.title3, design: .rounded).weight(.bold).monospacedDigit() }
}
