import Foundation
import os.log

/// Analytics event tracking stub
/// Replace with Firebase Analytics / Amplitude when ready
enum AnalyticsEvent: String {
    case sessionStart = "session_start"
    case tutorialStart = "tutorial_start"
    case tutorialComplete = "tutorial_complete"
    case tutorialSkip = "tutorial_skip"
    case levelStart = "level_start"
    case levelComplete = "level_complete"
    case levelFail = "level_fail"
    case cardPlay = "card_play"
    case cardDiscard = "card_discard"
    case jokerUse = "joker_use"
    case shopVisit = "shop_visit"
    case shopPurchase = "shop_purchase"
    case iapInitiated = "iap_initiated"
    case iapCompleted = "iap_completed"
    case iapFailed = "iap_failed"
    case iapRestored = "iap_restored"
    case achievementUnlocked = "achievement_unlocked"
    case paywallShown = "paywall_shown"
    case paywallConverted = "paywall_converted"
    case paywallDismissed = "paywall_dismissed"
}

/// 轻量级 Analytics 引擎 — os_log + UserDefaults 持久化
/// MVP 阶段零依赖；上线后可对接 Firebase/Amplitude
@MainActor final class Analytics {
    static let shared = Analytics()

    private let logger = Logger(subsystem: "com.hongzeng.doudizhu", category: "analytics")
    private let sessionCountKey = "analytics_session_count"
    private let eventsKey = "analytics_events"

    let sessionID = UUID().uuidString

    private var events: [(event: String, params: [String: String], timestamp: Date)] = []

    private init() {
        incrementSessionCount()
    }

    // MARK: - Track

    func track(_ event: AnalyticsEvent, params: [String: String] = [:]) {
        let entry = (event: event.rawValue, params: params, timestamp: Date())
        events.append(entry)

        let paramStr = params.isEmpty ? "" : " " + params.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
        logger.info("📊 \(event.rawValue)\(paramStr)")

        persistEventCount(event)
    }

    func track(_ event: AnalyticsEvent, level: Int) {
        track(event, params: ["level": "\(level)"])
    }

    func track(_ event: AnalyticsEvent, joker: String) {
        track(event, params: ["joker": joker])
    }

    // MARK: - Metrics

    func eventCount(for event: AnalyticsEvent) -> Int {
        events.filter { $0.event == event.rawValue }.count
    }

    var totalSessions: Int {
        UserDefaults.standard.integer(forKey: sessionCountKey)
    }

    func totalEventCount(for event: AnalyticsEvent) -> Int {
        let counts = UserDefaults.standard.dictionary(forKey: eventsKey) as? [String: Int] ?? [:]
        return counts[event.rawValue] ?? 0
    }

    var funnelSummary: String {
        let s = totalSessions
        let tc = totalEventCount(for: .tutorialComplete)
        let ls = totalEventCount(for: .levelStart)
        let lc = totalEventCount(for: .levelComplete)
        let ii = totalEventCount(for: .iapInitiated)
        let ic = totalEventCount(for: .iapCompleted)
        return "Sessions:\(s) Tut✓:\(tc) Lvl:\(ls)→\(lc) IAP:\(ii)→\(ic)"
    }

    // MARK: - Private

    private func incrementSessionCount() {
        let c = UserDefaults.standard.integer(forKey: sessionCountKey)
        UserDefaults.standard.set(c + 1, forKey: sessionCountKey)
        track(.sessionStart)
    }

    private func persistEventCount(_ event: AnalyticsEvent) {
        var counts = UserDefaults.standard.dictionary(forKey: eventsKey) as? [String: Int] ?? [:]
        counts[event.rawValue] = (counts[event.rawValue] ?? 0) + 1
        UserDefaults.standard.set(counts, forKey: eventsKey)
    }
}
