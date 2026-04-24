import Foundation

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

final class Analytics {
    nonisolated(unsafe) static let shared = Analytics()

    private var events: [(event: String, params: [String: String], timestamp: Date)] = []

    func track(_ event: AnalyticsEvent, params: [String: String] = [:]) {
        let entry = (event: event.rawValue, params: params, timestamp: Date())
        events.append(entry)
        #if DEBUG
        print("[Analytics] \(event.rawValue) \(params)")
        #endif

        // TODO: Replace with actual analytics SDK
        // Firebase.Analytics.logEvent(event.rawValue, parameters: params)
    }

    func track(_ event: AnalyticsEvent, level: Int) {
        track(event, params: ["level": "\(level)"])
    }

    func track(_ event: AnalyticsEvent, joker: String) {
        track(event, params: ["joker": joker])
    }

    /// Get event count for internal metrics
    func eventCount(for event: AnalyticsEvent) -> Int {
        events.filter { $0.event == event.rawValue }.count
    }
}
