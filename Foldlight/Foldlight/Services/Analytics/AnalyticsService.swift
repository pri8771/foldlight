//
//  AnalyticsService.swift
//  Foldlight
//
//  Local-only analytics/event logging (Technical PRD §13: "No third-party SDKs.
//  Events written to local JSON log (debug builds only)."). This foundation
//  provides a safe, isolated implementation that buffers events in memory and
//  prints them in DEBUG. A later phase can flush the buffer to a JSON log file.
//

import Foundation

/// A single analytics event with an optional string-keyed metadata payload.
struct AnalyticsEvent: Sendable, Equatable {
    let name: String
    let parameters: [String: String]

    init(_ name: String, parameters: [String: String] = [:]) {
        self.name = name
        self.parameters = parameters
    }

    // Common foundation-phase events.
    static let appLaunched = AnalyticsEvent("app_launched")
    static func screenViewed(_ screen: String) -> AnalyticsEvent {
        AnalyticsEvent("screen_viewed", parameters: ["screen": screen])
    }
}

/// Records analytics events locally. No network calls (Technical PRD §1.2, §13).
protocol AnalyticsTracking: Sendable {
    func track(_ event: AnalyticsEvent) async
    func recentEvents() async -> [AnalyticsEvent]
}

/// In-memory, local-only analytics tracker. Actor-isolated for thread safety.
actor AnalyticsService: AnalyticsTracking {
    private var buffer: [AnalyticsEvent] = []
    private let maxBuffered: Int

    init(maxBuffered: Int = 500) {
        self.maxBuffered = maxBuffered
    }

    func track(_ event: AnalyticsEvent) async {
        buffer.append(event)
        if buffer.count > maxBuffered {
            buffer.removeFirst(buffer.count - maxBuffered)
        }
        #if DEBUG
        print("[Analytics] \(event.name) \(event.parameters)")
        #endif
    }

    /// Snapshot of buffered events (most recent last). Useful for tests/debug.
    func recentEvents() async -> [AnalyticsEvent] {
        buffer
    }
}
