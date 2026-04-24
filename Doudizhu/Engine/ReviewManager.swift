import StoreKit

@MainActor
enum ReviewManager {
    private static let winCountKey = "review_win_count"
    private static let hasRequestedKey = "review_has_requested"

    static func recordFloorWin() {
        let count = UserDefaults.standard.integer(forKey: winCountKey) + 1
        UserDefaults.standard.set(count, forKey: winCountKey)

        // Request review after 3rd win, only once
        if count == 3 && !UserDefaults.standard.bool(forKey: hasRequestedKey) {
            requestReview()
        }
    }

    private static func requestReview() {
        UserDefaults.standard.set(true, forKey: hasRequestedKey)
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
