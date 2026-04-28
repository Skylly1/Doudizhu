import GameKit

@MainActor
final class GameCenterManager: ObservableObject {
    static let shared = GameCenterManager()

    @Published var isAuthenticated = false

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                if let error {
                    CrashReporter.shared.log("GameCenter auth failed: \(error.localizedDescription)", level: .info)
                }
                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                if GKLocalPlayer.local.isAuthenticated {
                    #if DEBUG
                    print("[GameCenter] Authenticated: \(GKLocalPlayer.local.displayName)")
                    #endif
                }
            }
        }
    }

    // Leaderboard: Total score across all runs
    func reportScore(_ score: Int) {
        guard isAuthenticated else { return }
        Task {
            do {
                try await GKLeaderboard.submitScore(
                    score,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: ["com.hongzeng.doudizhu.highscore"]
                )
            } catch {
                CrashReporter.shared.log("GameCenter score submit failed: \(error.localizedDescription)", level: .warning)
            }
        }
    }

    // Achievement reporting bridge
    func reportAchievement(id: String, percent: Double = 100.0) {
        guard isAuthenticated else { return }
        Task {
            let achievement = GKAchievement(identifier: "com.hongzeng.doudizhu.\(id)")
            achievement.percentComplete = percent
            achievement.showsCompletionBanner = true
            do {
                try await GKAchievement.report([achievement])
            } catch {
                CrashReporter.shared.log("GameCenter achievement report failed: \(error.localizedDescription)", level: .warning)
            }
        }
    }
}
