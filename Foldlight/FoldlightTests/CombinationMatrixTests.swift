//
//  CombinationMatrixTests.swift
//  FoldlightTests
//
//  The documented tile-combination rules, including symmetry (A+B == B+A).
//

import XCTest
@testable import Foldlight

final class CombinationMatrixTests: XCTestCase {
    private func assertRule(
        _ a: TileType,
        _ b: TileType,
        equals expected: CombinationResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(CombinationMatrix.result(a, b), expected, file: file, line: line)
        XCTAssertEqual(CombinationMatrix.result(b, a), expected, "rule must be symmetric", file: file, line: line)
    }

    func testAllDocumentedRules() {
        assertRule(.lightSource, .goalCrystal, equals: .win)
        assertRule(.path, .path, equals: .connectedPath)
        assertRule(.lightSource, .mirror, equals: .reflectedBeam)
        assertRule(.lightSource, .shadow, equals: .revealedPath)
        assertRule(.key, .lock, equals: .openedGate)
        assertRule(.seed, .water, equals: .grownBridge)
        assertRule(.fire, .ice, equals: .steamBlocker)
        assertRule(.monster, .cage, equals: .capturedMonster)
    }

    func testResultingTileTypes() {
        XCTAssertNil(CombinationResult.win.resultingType)
        XCTAssertEqual(CombinationResult.connectedPath.resultingType, .path)
        XCTAssertEqual(CombinationResult.openedGate.resultingType, .openGate)
        XCTAssertEqual(CombinationResult.grownBridge.resultingType, .bridge)
        XCTAssertEqual(CombinationResult.steamBlocker.resultingType, .steam)
        XCTAssertEqual(CombinationResult.capturedMonster.resultingType, .capturedMonster)
    }

    func testUnrelatedTilesDoNotCombine() {
        XCTAssertNil(CombinationMatrix.result(.path, .mirror))
        XCTAssertNil(CombinationMatrix.result(.blocker, .seed))
        XCTAssertNil(CombinationMatrix.result(.water, .fire))
    }
}
