//
//  TileNode.swift
//  Foldlight
//
//  A single rendered board tile: a rounded color panel plus a glyph, with three
//  visual states (idle / lit-by-beam / emphasized). Pure rendering — it holds no
//  game rules.
//

import SpriteKit

final class TileNode: SKNode {
    /// Visual state of a tile.
    enum DisplayState {
        case idle
        case lit          // on the active light beam
        case emphasized   // e.g. just transformed by a combination
    }

    private let panel: SKShapeNode
    private let label: SKLabelNode

    init(tile: Tile, size: CGFloat) {
        let inset = size * 0.92
        panel = SKShapeNode(rectOf: CGSize(width: inset, height: inset), cornerRadius: size * 0.18)
        label = SKLabelNode(text: GameTheme.glyph(for: tile))
        super.init()

        panel.fillColor = GameTheme.fill(for: tile.type)
        panel.strokeColor = GameTheme.grid
        panel.lineWidth = 1
        addChild(panel)

        label.fontName = "AvenirNext-Bold"
        label.fontSize = size * 0.46
        label.fontColor = GameTheme.glyphColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)

        setState(.idle)
    }

    required init?(coder aDecoder: NSCoder) {
        // Tiles are created programmatically, never decoded.
        return nil
    }

    func setState(_ state: DisplayState) {
        switch state {
        case .idle:
            panel.strokeColor = GameTheme.grid
            panel.lineWidth = 1
            panel.glowWidth = 0
        case .lit:
            panel.strokeColor = GameTheme.beam
            panel.lineWidth = 3
            panel.glowWidth = 6
        case .emphasized:
            panel.strokeColor = GameTheme.destinationOutline
            panel.lineWidth = 3
            panel.glowWidth = 0
        }
    }

    /// A short pulse used to draw attention to a transformed tile.
    func pulse() {
        run(.sequence([
            .scale(to: 1.15, duration: 0.12),
            .scale(to: 1.0, duration: 0.12)
        ]))
    }
}
