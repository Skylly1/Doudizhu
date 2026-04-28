import StoreKit

@MainActor
enum ReviewManager {
    // REVENUE-TODO: [P1] 付费用户首次通关后（不仅仅是第8次过关）立即请求评价 — 这是情感最高峰
    // REVENUE-TODO: [P2] 加入 smart-timing：检测玩家是否刚打出高分/解锁成就后请求，转化率更高
    private static let winCountKey = "review_win_count"
    private static let hasRequestedKey = "review_has_requested"
    private static let paidReviewRequestedKey = "review_paid_requested"

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

    private static func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
