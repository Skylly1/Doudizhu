import Foundation

/// 起始流派 — 开局选择，影响初始 Joker、Buff、金币
struct StarterBuild: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let startingJoker: Joker?
    let startingBuff: Buff?
    let goldAdjustment: Int   // 相对于基础 150 金币的调整

    /// 9 种预设流派
    static let allBuilds: [StarterBuild] = [
        StarterBuild(
            id: "balanced",
            name: L10n.buildBalanced,
            icon: "🛡️",
            description: L10n.buildBalancedDesc,
            startingJoker: nil,
            startingBuff: nil,
            goldAdjustment: 50
        ),
        StarterBuild(
            id: "explosive",
            name: L10n.buildExplosive,
            icon: "💣",
            description: L10n.buildExplosiveDesc,
            startingJoker: Joker.allJokers.first { $0.effect == .explosiveBonus },
            startingBuff: Buff.allBuffs.first { $0.type == .bombBonus },
            goldAdjustment: -30
        ),
        StarterBuild(
            id: "combo",
            name: L10n.buildCombo,
            icon: "🔥",
            description: L10n.buildComboDesc,
            startingJoker: Joker.allJokers.first { $0.effect == .doubleComboRate },
            startingBuff: nil,
            goldAdjustment: 0
        ),
        StarterBuild(
            id: "precision",
            name: L10n.buildPrecision,
            icon: "🎯",
            description: L10n.buildPrecisionDesc,
            startingJoker: Joker.allJokers.first { $0.effect == .miniHandBonus },
            startingBuff: nil,
            goldAdjustment: 20
        ),
        StarterBuild(
            id: "greed",
            name: L10n.buildGreed,
            icon: "💰",
            description: L10n.buildGreedDesc,
            startingJoker: Joker.allJokers.first { $0.effect == .goldRush },
            startingBuff: Buff.allBuffs.first { $0.type == .globalMultiplier },
            goldAdjustment: -50
        ),
        StarterBuild(
            id: "allIn",
            name: L10n.buildAllIn,
            icon: "⚡",
            description: L10n.buildAllInDesc,
            startingJoker: Joker.allJokers.first { $0.effect == .lastStandBonus },
            startingBuff: nil,
            goldAdjustment: -50
        ),
        StarterBuild(
            id: "straightMaster",
            name: L10n.buildStraightMaster,
            icon: "🌊",
            description: L10n.buildStraightMasterDesc,
            startingJoker: Joker.allJokers.first { $0.effect == .sequenceBonus },
            startingBuff: Buff.allBuffs.first { $0.type == .straightBonus },
            goldAdjustment: 0
        ),
        StarterBuild(
            id: "defensive",
            name: L10n.buildDefensive,
            icon: "🛡️",
            description: L10n.buildDefensiveDesc,
            startingJoker: Joker.allJokers.first { $0.effect == .extraDiscards },
            startingBuff: Buff.allBuffs.first { $0.type == .globalMultiplier },
            goldAdjustment: 50
        ),
        StarterBuild(
            id: "gambler",
            name: L10n.buildGambler,
            icon: "🎰",
            description: L10n.buildGamblerDesc,
            startingJoker: Joker.allJokers.first { $0.effect == .gambler },
            startingBuff: nil,
            goldAdjustment: -20
        ),
    ]
}
