//
//  BeamSolverTests.swift
//  FoldlightTests
//
//  Light-beam tracing: reaching the goal, being blocked, mirror reflection,
//  edge exit, missing source, and the loop-guard safety bound.
//

import XCTest
@testable import Foldlight

final class BeamSolverTests: XCTestCase {
    private func coordinate(_ row: Int, _ column: Int) -> BoardCoordinate {
        BoardCoordinate(row: row, column: column)
    }

    func testBeamReachesGoalStraight() {
        let board = Board(tiles: [[Tile.light(facing: .right), Tile.path, Tile.goal]])
        let result = BeamSolver.solve(board)
        XCTAssertTrue(result.reachedGoal)
        XCTAssertEqual(result.termination, .reachedGoal)
    }

    func testBeamBlockedByGap() {
        let board = Board(tiles: [[Tile.light(facing: .right), nil, Tile.goal]])
        let result = BeamSolver.solve(board)
        XCTAssertFalse(result.reachedGoal)
        XCTAssertEqual(result.termination, .blocked)
    }

    func testBeamBlockedByBlocker() {
        let board = Board(tiles: [[Tile.light(facing: .right), Tile(type: .blocker), Tile.goal]])
        let result = BeamSolver.solve(board)
        XCTAssertFalse(result.reachedGoal)
        XCTAssertEqual(result.termination, .blocked)
    }

    func testBeamExitsBoard() {
        let board = Board(tiles: [[Tile.light(facing: .right), Tile.path]])
        let result = BeamSolver.solve(board)
        XCTAssertFalse(result.reachedGoal)
        XCTAssertEqual(result.termination, .exitedBoard)
    }

    func testMirrorReflectsToGoal() {
        // light → '\' mirror turns the beam downward into the goal.
        let board = Board(tiles: [
            [Tile.light(facing: .right), Tile.mirror(.deg90)],
            [nil, Tile.goal]
        ])
        let result = BeamSolver.solve(board)
        XCTAssertTrue(result.reachedGoal)
        XCTAssertEqual(result.termination, .reachedGoal)
    }

    func testForwardSlashMirrorReflectsUp() {
        // light → '/' mirror turns a rightward beam upward (off-board here).
        let board = Board(tiles: [
            [nil, Tile.goal],
            [Tile.light(facing: .right), Tile.mirror(.deg0)]
        ])
        let result = BeamSolver.solve(board)
        XCTAssertTrue(result.reachedGoal)
    }

    func testNoSourceTerminates() {
        let board = Board(tiles: [[Tile.path, Tile.goal]])
        let result = BeamSolver.solve(board)
        XCTAssertFalse(result.reachedGoal)
        XCTAssertEqual(result.termination, .noSource)
    }

    func testSolverAlwaysTerminatesWithinStepBound() {
        // A four-mirror ring fed by a light source: whatever happens, the solver
        // must return promptly and never exceed the loop-guard step cap.
        let board = Board(tiles: [
            [Tile.light(facing: .right), Tile.mirror(.deg90), Tile.mirror(.deg0)],
            [nil, Tile.mirror(.deg0), Tile.mirror(.deg90)]
        ])
        let result = BeamSolver.solve(board)
        XCTAssertLessThanOrEqual(result.segments.count, BeamSolver.maxSteps)
    }
}
