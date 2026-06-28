//
//  AppRouterTests.swift
//  FoldlightTests
//
//  Tests for navigation stack behavior.
//

import XCTest
@testable import Foldlight

@MainActor
final class AppRouterTests: XCTestCase {
    func testStartsAtRoot() {
        let router = AppRouter()
        XCTAssertTrue(router.path.isEmpty)
    }

    func testPushAppendsRoute() {
        let router = AppRouter()
        router.push(.daily)
        router.push(.settings)
        XCTAssertEqual(router.path, [.daily, .settings])
    }

    func testPopRemovesLast() {
        let router = AppRouter()
        router.push(.play)
        router.push(.infinite)
        router.pop()
        XCTAssertEqual(router.path, [.play])
    }

    func testPopOnEmptyIsSafe() {
        let router = AppRouter()
        router.pop()
        XCTAssertTrue(router.path.isEmpty)
    }

    func testPopToRootClearsStack() {
        let router = AppRouter()
        router.push(.play)
        router.push(.daily)
        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
    }

    func testAllRoutesHaveTitles() {
        for route in AppRoute.allCases {
            XCTAssertFalse(route.title.isEmpty)
            XCTAssertFalse(route.systemImage.isEmpty)
        }
    }
}
