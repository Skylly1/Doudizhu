import StoreKit

@MainActor
enum ReviewManager {
    // REVENUE-TODO: [P2] smart-timing：检测玩家是否刚打出高分/解锁成就后请求，转化率更高
    private static let winCountKey = "review_win_count"
    private static let hasRequestedKey = "review_has_requested"
    private static let paidReviewRequestedKey = "review_paid_requested"
    private static let purchaseReviewRequestedKey = "review_purchase_requested"

    /// 单例式访问（方便 View 中调用）
    static let shared = ReviewManagerProxy()

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

    fileprivate static func requestReview() {
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
