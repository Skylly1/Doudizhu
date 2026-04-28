import Foundation
import UIKit
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif
import os.log

/// Analytics event tracking — 核心转化漏斗 + 行为数据
/// Replace with Firebase Analytics / Amplitude when ready
enum AnalyticsEvent: String {
    // 生命周期
    case sessionStart = "session_start"
    case appFirstOpen = "app_first_open"

    // 教程
    case tutorialStart = "tutorial_start"
    case tutorialComplete = "tutorial_complete"
    case tutorialSkip = "tutorial_skip"

    // 引导系统
    case shopFirstVisit = "shop_first_visit"
    case firstJokerPurchase = "first_joker_purchase"
    case guideOpened = "guide_opened"
    case stuckHintShown = "stuck_hint_shown"

    // 核心循环
    case runStart = "run_start"
    case runComplete = "run_complete"
    case runAbandon = "run_abandon"
    case floorStart = "floor_start"
    case levelStart = "level_start"
    case levelComplete = "level_complete"
    case levelFail = "level_fail"

    // 出牌行为
    case cardPlay = "card_play"
    case cardDiscard = "card_discard"
    case comboAchieved = "combo_achieved"

    // 系统交互
    case jokerUse = "joker_use"
    case bossEncounter = "boss_encounter"
    case shopVisit = "shop_visit"
    case shopPurchase = "shop_purchase"
    case dailyChallengeStart = "daily_challenge_start"

    // 转化漏斗（直接影响营收）
    case iapInitiated = "iap_initiated"
    case iapCompleted = "iap_completed"
    case iapFailed = "iap_failed"
    case iapRestored = "iap_restored"
    case iapPending = "iap_pending"
    case iapRevoked = "iap_revoked"
    case paywallShown = "paywall_shown"
    case paywallConverted = "paywall_converted"
    case paywallDismissed = "paywall_dismissed"
    case paywallFreePeek = "paywall_free_peek"

    // 成就 & 留存
    case achievementUnlocked = "achievement_unlocked"

    // 漏斗补全事件
    case paywallScrollDepth = "paywall_scroll_depth"       // 付费墙滚动深度(%)
    case paywallButtonVisible = "paywall_button_visible"    // 购买按钮首次进入可视区
    case paywallScrolledToPurchase = "paywall_scrolled_to_purchase" // 用户滚动到购买按钮区域
    case purchaseSuccessCTA = "purchase_success_cta"        // 购买成功页CTA点击(share/review)
    case retentionD1 = "retention_d1"                       // D1留存
    case retentionD7 = "retention_d7"                       // D7留存
    case shareApp = "share_app"                             // 分享应用
    case retentionD30 = "retention_d30"                     // D30留存

    // 留存追踪
    case appReturnVisit = "app_return_visit"
    // 每日挑战完整追踪
    case dailyChallengeComplete = "daily_challenge_complete"
    case dailyChallengeFail = "daily_challenge_fail"
}

/// 轻量级 Analytics 引擎 — os_log + UserDefaults + Firebase Analytics 双通道
/// Firebase 已集成：canImport(FirebaseAnalytics) 自动转发所有事件
// REVENUE-TODO: [P2] 加入 A/B 测试框架（Firebase Remote Config），测试付费墙文案/时机/价格
// REVENUE-TODO: [P2] 计算并上报 ARPU = 总收入 / DAU，LTV = ARPU × 平均生命周期天数
@MainActor final class Analytics {
    static let shared = Analytics()

    private let logger = Logger(subsystem: "com.hongzeng.doudizhu", category: "analytics")
    private let sessionCountKey = "analytics_session_count"
    private let eventsKey = "analytics_events"

    let sessionID = UUID().uuidString

    private var events: [(event: String, params: [String: String], timestamp: Date)] = []

    // PERF-06: In-memory cache to avoid disk I/O on every event
    private var eventCounts: [String: Int] = [:]
    private var unflushedCount = 0

    private init() {
        eventCounts = UserDefaults.standard.dictionary(forKey: eventsKey) as? [String: Int] ?? [:]
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.flushEventCounts() }
        }
        incrementSessionCount()
        trackReturnVisit()
    }

    // MARK: - Track

    func track(_ event: AnalyticsEvent, params: [String: String] = [:]) {
        let entry = (event: event.rawValue, params: params, timestamp: Date())
        events.append(entry)

        let paramStr = params.isEmpty ? "" : " " + params.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
        logger.info("📊 \(event.rawValue)\(paramStr)")

        persistEventCount(event)

        // Firebase 转发
        #if canImport(FirebaseAnalytics)
        FirebaseAnalytics.Analytics.logEvent(event.rawValue, parameters: params.isEmpty ? nil : params)
        #endif
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
        return eventCounts[event.rawValue] ?? 0
    }

    var funnelSummary: String {
        let s = totalSessions
        let tc = totalEventCount(for: .tutorialComplete)
        let rs = totalEventCount(for: .runStart)
        let rc = totalEventCount(for: .runComplete)
        let pw = totalEventCount(for: .paywallShown)
        let pc = totalEventCount(for: .paywallConverted)
        let ii = totalEventCount(for: .iapInitiated)
        let ic = totalEventCount(for: .iapCompleted)
        return "Sessions:\(s) Tut✓:\(tc) Run:\(rs)→\(rc) Paywall:\(pw)→\(pc) IAP:\(ii)→\(ic)"
    }

    /// 付费墙转化率 — 核心营收指标
    var paywallConversionRate: Double {
        let shown = totalEventCount(for: .paywallShown)
        guard shown > 0 else { return 0 }
        return Double(totalEventCount(for: .paywallConverted)) / Double(shown)
    }

    /// 试玩→购买转化率
    var trialToPurchaseRate: Double {
        let runs = totalEventCount(for: .runStart)
        guard runs > 0 else { return 0 }
        return Double(totalEventCount(for: .iapCompleted)) / Double(runs)
    }

    // MARK: - Private

    private func incrementSessionCount() {
        let c = UserDefaults.standard.integer(forKey: sessionCountKey)
        UserDefaults.standard.set(c + 1, forKey: sessionCountKey)
        track(.sessionStart)
    }

    private func persistEventCount(_ event: AnalyticsEvent) {
        eventCounts[event.rawValue] = (eventCounts[event.rawValue] ?? 0) + 1
        unflushedCount += 1
        if unflushedCount >= 10 {
            flushEventCounts()
        }
    }

    func flushEventCounts() {
        guard unflushedCount > 0 else { return }
        UserDefaults.standard.set(eventCounts, forKey: eventsKey)
        unflushedCount = 0
    }

    /// 追踪回访间隔（D1/D7/D30 留存的本地近似）
    private func trackReturnVisit() {
        let lastVisitKey = "analytics_last_visit"
        let firstVisitKey = "analytics_first_visit"
        let now = Date()
        if UserDefaults.standard.object(forKey: firstVisitKey) == nil {
            UserDefaults.standard.set(now, forKey: firstVisitKey)
            // 同时记录安装日期供社交证明使用
            UserDefaults.standard.set(now, forKey: "has_opened_before_date")
            track(.appFirstOpen)
        }
        if let lastVisit = UserDefaults.standard.object(forKey: lastVisitKey) as? Date {
            let daysSince = Calendar.current.dateComponents([.day], from: lastVisit, to: now).day ?? 0
            if daysSince >= 1 {
                track(.appReturnVisit, params: ["days_since_last": "\(daysSince)"])
            }
        }
        UserDefaults.standard.set(now, forKey: lastVisitKey)

        // 留存里程碑（每个里程碑只触发一次）
        if let firstVisit = UserDefaults.standard.object(forKey: firstVisitKey) as? Date {
            let daysSinceInstall = Calendar.current.dateComponents([.day], from: firstVisit, to: now).day ?? 0
            let retentionKey = "retention_milestone_"
            for (day, event) in [(1, AnalyticsEvent.retentionD1), (7, .retentionD7), (30, .retentionD30)] {
                if daysSinceInstall >= day && !UserDefaults.standard.bool(forKey: retentionKey + "\(day)") {
                    UserDefaults.standard.set(true, forKey: retentionKey + "\(day)")
                    track(event, params: ["days_since_install": "\(daysSinceInstall)"])
                }
            }
        }
    }
}
