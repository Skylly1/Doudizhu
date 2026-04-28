import StoreKit

@MainActor
enum ReviewManager {
    private static let winCountKey = "review_win_count"
    private static let hasRequestedKey = "review_has_requested"
    private static let paidReviewRequestedKey = "review_paid_requested"
    private static let purchaseReviewRequestedKey = "review_purchase_requested"
    private static let lastReviewDateKey = "review_last_request_date"
    private static let previousBestScoreKey = "review_previous_best_score"
    private static let achievementReviewRequestedKey = "review_achievement_requested"

    /// 单例式访问（方便 View 中调用）
    static let shared = ReviewManagerProxy()

    // MARK: - Rate Limiting

    /// No more than 1 review request per 7 days
    private static func canRequestReview() -> Bool {
        guard let last = UserDefaults.standard.object(forKey: lastReviewDateKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(last) >= 7 * 24 * 3600
    }

    // MARK: - Floor Win Trigger

    static func recordFloorWin() {
        let count = UserDefaults.standard.integer(forKey: winCountKey) + 1
        UserDefaults.standard.set(count, forKey: winCountKey)

        // 免费用户：第3次过关后请求评价（仅一次）
        if count == 3 && !UserDefaults.standard.bool(forKey: hasRequestedKey) {
            requestReview()
            UserDefaults.standard.set(true, forKey: hasRequestedKey)
            return
        }

        // 付费用户：第8次过关后再请求一次（购买后的正向时刻）
        if count == 8
            && PurchaseManager.shared.isFullVersion
            && !UserDefaults.standard.bool(forKey: paidReviewRequestedKey) {
            requestReview()
            UserDefaults.standard.set(true, forKey: paidReviewRequestedKey)
        }
    }

    // MARK: - High Score Trigger

    /// Call when the player sets a new personal best score.
    /// Triggers review if the score beats previous best by 30%+ and player has 3+ runs.
    static func recordHighScore(score: Int) {
        let previousBest = UserDefaults.standard.integer(forKey: previousBestScoreKey)
        defer { UserDefaults.standard.set(score, forKey: previousBestScoreKey) }

        guard previousBest > 0 else { return }
        guard score >= Int(Double(previousBest) * 1.3) else { return }
        guard PlayerStats.shared.totalRuns >= 3 else { return }
        guard canRequestReview() else { return }

        requestReview()
    }

    // MARK: - Achievement Unlock Trigger

    /// Call when the player unlocks any achievement.
    /// Triggers review once the player has 5+ total unlocked achievements.
    static func recordAchievementUnlocked() {
        guard !UserDefaults.standard.bool(forKey: achievementReviewRequestedKey) else { return }
        guard AchievementTracker.shared.unlockedIds.count >= 5 else { return }
        guard canRequestReview() else { return }

        requestReview()
        UserDefaults.standard.set(true, forKey: achievementReviewRequestedKey)
    }

    // MARK: - Core

    fileprivate static func requestReview() {
        UserDefaults.standard.set(Date(), forKey: lastReviewDateKey)
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

/// 购买成功页等 View 可调用的评价入口
@MainActor
struct ReviewManagerProxy {
    func requestReviewNow() {
        guard !UserDefaults.standard.bool(forKey: "review_purchase_requested") else { return }
        UserDefaults.standard.set(true, forKey: "review_purchase_requested")
        ReviewManager.requestReview()
    }
}
