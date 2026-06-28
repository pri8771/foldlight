//
//  GameScene.swift
//  Foldlight
//
//  SpriteKit renderer + input for the playable board. The scene renders a given
//  Board and beam, and turns drag gestures into candidate folds via the pure
//  FoldGestureInterpreter. It NEVER applies rules itself: it asks its owner
//  (the GameViewModel) to apply a fold through the engine, and re-renders from
//  the board it is handed back. This preserves strict engine/UI separation.
//

import SpriteKit
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class GameScene: SKScene {
    // MARK: Callbacks to the owning view model (rules live there)

    /// Ask the owner to apply a fold. Returns `true` if it was legal & applied.
    var onFoldProposed: ((Fold) -> Bool)?
    /// Invoked when a gesture produced an illegal/rejected fold.
    var onFoldRejected: (() -> Void)?

    // MARK: Rendered state (set by the view model)

    private var board = Board(width: 0, height: 0)
    private var beam = BeamResult(segments: [], reachedGoal: false, termination: .noSource)

    // MARK: Layers

    private let boardLayer = SKNode()
    private let beamLayer = SKNode()
    private let previewLayer = SKNode()

    // MARK: Layout (recomputed on render)

    private var tileSize: CGFloat = 1
    private var boardOriginX: CGFloat = 0
    private var boardOriginY: CGFloat = 0

    // MARK: Gesture

    private var dragStart: CGPoint?

    // MARK: Lifecycle

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = GameTheme.background
        boardLayer.zPosition = 0
        beamLayer.zPosition = 10
        previewLayer.zPosition = 20
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func didMove(to view: SKView) {
        isUserInteractionEnabled = true
        if boardLayer.parent == nil { addChild(boardLayer) }
        if beamLayer.parent == nil { addChild(beamLayer) }
        if previewLayer.parent == nil { addChild(previewLayer) }
        render()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        render()
    }

    // MARK: Public update

    /// Replace the rendered board and beam, then redraw.
    func update(board: Board, beam: BeamResult) {
        self.board = board
        self.beam = beam
        render()
    }

    // MARK: Rendering

    private func render() {
        guard size.width > 0, size.height > 0, board.width > 0, board.height > 0 else { return }
        computeLayout()
        boardLayer.removeAllChildren()
        beamLayer.removeAllChildren()

        let litCoordinates = Set(beam.visitedCoordinates)
        for coordinate in board.coordinates {
            let cell = board.cell(at: coordinate)
            let node = TileNode(tile: cell.top ?? Tile(type: .empty), size: tileSize)
            node.position = point(for: coordinate)
            if cell.effectiveType != .empty && litCoordinates.contains(coordinate) {
                node.setState(.lit)
            }
            boardLayer.addChild(node)
        }
        drawBeam()
    }

    private func computeLayout() {
        let columns = CGFloat(max(board.width, 1))
        let rows = CGFloat(max(board.height, 1))
        let usableWidth = size.width * 0.9
        let usableHeight = size.height * 0.9
        tileSize = min(usableWidth / columns, usableHeight / rows)
        let boardWidth = tileSize * columns
        let boardHeight = tileSize * rows
        boardOriginX = (size.width - boardWidth) / 2
        boardOriginY = (size.height - boardHeight) / 2
    }

    /// Center point of a cell. Row 0 is at the top (higher y in SpriteKit).
    private func point(for coordinate: BoardCoordinate) -> CGPoint {
        let boardHeight = tileSize * CGFloat(max(board.height, 1))
        let x = boardOriginX + (CGFloat(coordinate.column) + 0.5) * tileSize
        let y = boardOriginY + boardHeight - (CGFloat(coordinate.row) + 0.5) * tileSize
        return CGPoint(x: x, y: y)
    }

    /// The cell under a scene point, or `nil` if outside the board.
    private func cell(at point: CGPoint) -> BoardCoordinate? {
        guard tileSize > 0 else { return nil }
        let boardHeight = tileSize * CGFloat(max(board.height, 1))
        let column = Int((point.x - boardOriginX) / tileSize)
        let row = Int((boardOriginY + boardHeight - point.y) / tileSize)
        guard row >= 0, row < board.height, column >= 0, column < board.width else { return nil }
        return BoardCoordinate(row: row, column: column)
    }

    private func drawBeam() {
        let coordinates = beam.visitedCoordinates
        guard coordinates.count >= 2 else { return }
        let path = CGMutablePath()
        path.move(to: point(for: coordinates[0]))
        for coordinate in coordinates.dropFirst() {
            path.addLine(to: point(for: coordinate))
        }
        let line = SKShapeNode(path: path)
        line.strokeColor = beam.reachedGoal ? GameTheme.win : GameTheme.beam
        line.lineWidth = max(2, tileSize * 0.12)
        line.lineCap = .round
        line.lineJoin = .round
        line.glowWidth = tileSize * 0.08
        beamLayer.addChild(line)
    }

    // MARK: Gesture input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragStart = touches.first?.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let start = dragStart, let current = touches.first?.location(in: self) else { return }
        updatePreview(from: start, to: current)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            dragStart = nil
            previewLayer.removeAllChildren()
        }
        guard let start = dragStart, let end = touches.first?.location(in: self) else { return }
        guard let fold = candidateFold(from: start, to: end) else { return }
        let applied = onFoldProposed?(fold) ?? false
        if !applied {
            onFoldRejected?()
            shake()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragStart = nil
        previewLayer.removeAllChildren()
    }

    private func candidateFold(from start: CGPoint, to end: CGPoint) -> Fold? {
        guard let startCell = cell(at: start) else { return nil }
        let gesture = FoldGesture(
            startCell: startCell,
            dx: end.x - start.x,
            dyDown: start.y - end.y // SpriteKit y is up; screen-down is decreasing y.
        )
        return FoldGestureInterpreter.fold(
            for: gesture,
            boardWidth: board.width,
            boardHeight: board.height,
            minimumMagnitude: tileSize * 0.4
        )
    }

    // MARK: Fold preview

    private func updatePreview(from start: CGPoint, to end: CGPoint) {
        previewLayer.removeAllChildren()
        guard let fold = candidateFold(from: start, to: end) else { return }
        let legal = FoldEngine.isLegal(fold, on: board)
        let panelSize = CGSize(width: tileSize * 0.92, height: tileSize * 0.92)

        for coordinate in board.coordinates where FoldEngine.isSource(coordinate, fold: fold) {
            let source = SKShapeNode(rectOf: panelSize, cornerRadius: tileSize * 0.18)
            source.position = point(for: coordinate)
            source.fillColor = legal ? GameTheme.sourceHighlight : GameTheme.illegalHighlight
            source.strokeColor = .clear
            previewLayer.addChild(source)

            let destination = FoldEngine.reflectedCoordinate(coordinate, fold: fold)
            if board.contains(destination) {
                let outline = SKShapeNode(rectOf: panelSize, cornerRadius: tileSize * 0.18)
                outline.position = point(for: destination)
                outline.fillColor = .clear
                outline.strokeColor = GameTheme.destinationOutline
                outline.lineWidth = 2
                previewLayer.addChild(outline)
            }
        }
    }

    // MARK: Feedback animations

    private func shake() {
        let amount = tileSize * 0.12
        boardLayer.run(.sequence([
            .moveBy(x: -amount, y: 0, duration: 0.04),
            .moveBy(x: amount * 2, y: 0, duration: 0.08),
            .moveBy(x: -amount, y: 0, duration: 0.04)
        ]))
    }

    /// Celebration when the puzzle is solved (light-beam glow + radiating ring).
    func playWinAnimation() {
        guard let goal = board.coordinate(ofFirst: .goalCrystal) else { return }
        let center = point(for: goal)

        let ring = SKShapeNode(circleOfRadius: tileSize * 0.4)
        ring.position = center
        ring.strokeColor = GameTheme.win
        ring.fillColor = .clear
        ring.lineWidth = 3
        ring.glowWidth = tileSize * 0.1
        ring.zPosition = 30
        addChild(ring)
        ring.run(.sequence([
            .group([.scale(to: 6, duration: 0.8), .fadeOut(withDuration: 0.8)]),
            .removeFromParent()
        ]))

        for index in 0..<8 {
            let spark = SKShapeNode(circleOfRadius: max(2, tileSize * 0.06))
            spark.position = center
            spark.fillColor = GameTheme.beam
            spark.strokeColor = .clear
            spark.zPosition = 31
            addChild(spark)
            let angle = (CGFloat(index) / 8) * 2 * .pi
            let distance = tileSize * 2
            let move = SKAction.moveBy(
                x: cos(angle) * distance,
                y: sin(angle) * distance,
                duration: 0.7
            )
            spark.run(.sequence([
                .group([move, .fadeOut(withDuration: 0.7)]),
                .removeFromParent()
            ]))
        }
    }
}
