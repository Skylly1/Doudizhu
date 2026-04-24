import GameKit

@MainActor
final class GameCenterManager: ObservableObject {
    static let shared = GameCenterManager()

    @Published var isAuthenticated = false

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                if GKLocalPlayer.local.isAuthenticated {
                    print("[GameCenter] Authenticated: \(GKLocalPlayer.local.displayName)")
                }
            }
        }
    }

    // Leaderboard: Total score across all runs
    func reportScore(_ score: Int) {
        guard isAuthenticated else { return }
        Task {
            try? await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: ["com.hongzeng.doudizhu.highscore"]
            )
        }
    }

    // Achievement reporting bridge
    func reportAchievement(id: String, percent: Double = 100.0) {
        guard isAuthenticated else { return }
        Task {
            let achievement = GKAchievement(identifier: "com.hongzeng.doudizhu.\(id)")
            achievement.percentComplete = percent
            achievement.showsCompletionBanner = true
            try? await GKAchievement.report([achievement])
        }
    }
}
