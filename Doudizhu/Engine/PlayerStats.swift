import Foundation

/// Persistent player statistics
@MainActor class PlayerStats: ObservableObject {
    static let shared = PlayerStats()

    @Published var totalRuns: Int
    @Published var totalWins: Int
    @Published var totalFloors: Int
    @Published var totalCardsPlayed: Int
    @Published var highestCombo: Int
    @Published var highestSingleScore: Int
    @Published var totalGoldEarned: Int
    @Published var highestFloor: Int
    @Published var favoriteBuild: String
    @Published var totalPlayTime: TimeInterval  // seconds

    private let defaults = UserDefaults.standard

    init() {
        totalRuns = defaults.integer(forKey: "stats_totalRuns")
        totalWins = defaults.integer(forKey: "stats_totalWins")
        totalFloors = defaults.integer(forKey: "stats_totalFloors")
        totalCardsPlayed = defaults.integer(forKey: "stats_totalCardsPlayed")
        highestCombo = defaults.integer(forKey: "stats_highestCombo")
        highestSingleScore = defaults.integer(forKey: "stats_highestSingleScore")
        totalGoldEarned = defaults.integer(forKey: "stats_totalGoldEarned")
        highestFloor = defaults.integer(forKey: "stats_highestFloor")
        favoriteBuild = defaults.string(forKey: "stats_favoriteBuild") ?? ""
        totalPlayTime = defaults.double(forKey: "stats_totalPlayTime")
    }

    func recordRun(won: Bool, floorsCleared: Int, cardsPlayed: Int, goldEarned: Int, build: String) {
        totalRuns += 1
        if won { totalWins += 1 }
        totalFloors += floorsCleared
        totalCardsPlayed += cardsPlayed
        totalGoldEarned += goldEarned
        favoriteBuild = build
        save()
    }

    func recordCombo(_ combo: Int) {
        if combo > highestCombo {
            highestCombo = combo
            save()
        }
    }

    func recordHighestFloor(_ floor: Int) {
        if floor > highestFloor {
            highestFloor = floor
            save()
        }
    }

    func recordSingleScore(_ score: Int) {
        if score > highestSingleScore {
            highestSingleScore = score
            save()
        }
    }

    func addPlayTime(_ seconds: TimeInterval) {
        totalPlayTime += seconds
        save()
    }

    func recordBuildUsage(_ buildId: String) {
        let key = "stats_buildCount_\(buildId)"
        let count = defaults.integer(forKey: key) + 1
        defaults.set(count, forKey: key)
        // Determine the most-used build as favorite
        var bestBuild = buildId
        var bestCount = count
        for build in StarterBuild.allBuilds {
            let c = defaults.integer(forKey: "stats_buildCount_\(build.id)")
            if c > bestCount {
                bestCount = c
                bestBuild = build.id
            }
        }
        favoriteBuild = bestBuild
        save()
    }

    var winRate: Double {
        totalRuns > 0 ? Double(totalWins) / Double(totalRuns) : 0
    }

    var formattedPlayTime: String {
        let hours = Int(totalPlayTime) / 3600
        let minutes = (Int(totalPlayTime) % 3600) / 60
        if hours > 0 {
            return L10n.isEnglish ? "\(hours)h \(minutes)m" : "\(hours)小时\(minutes)分"
        }
        return L10n.isEnglish ? "\(minutes)m" : "\(minutes)分钟"
    }

    func save() {
        defaults.set(totalRuns, forKey: "stats_totalRuns")
        defaults.set(totalWins, forKey: "stats_totalWins")
        defaults.set(totalFloors, forKey: "stats_totalFloors")
        defaults.set(totalCardsPlayed, forKey: "stats_totalCardsPlayed")
        defaults.set(highestCombo, forKey: "stats_highestCombo")
        defaults.set(highestSingleScore, forKey: "stats_highestSingleScore")
        defaults.set(totalGoldEarned, forKey: "stats_totalGoldEarned")
        defaults.set(highestFloor, forKey: "stats_highestFloor")
        defaults.set(favoriteBuild, forKey: "stats_favoriteBuild")
        defaults.set(totalPlayTime, forKey: "stats_totalPlayTime")
    }
}
