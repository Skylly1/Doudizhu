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

    /// 3 种预设流派
    static let allBuilds: [StarterBuild] = [
        StarterBuild(
            id: "balanced",
            name: "稳扎稳打",
            icon: "🛡️",
            description: "均衡开局，适合新手。起始多 50 金币，无特殊牌。",
            startingJoker: nil,
            startingBuff: nil,
            goldAdjustment: 50
        ),
        StarterBuild(
            id: "explosive",
            name: "炸弹狂人",
            icon: "💣",
            description: "炸弹路线。起始携带「火烧连营」（炸弹×2）和「火药桶」。",
            startingJoker: Joker.allJokers.first { $0.effect == .explosiveBonus },
            startingBuff: Buff.allBuffs.first { $0.type == .bombBonus },
            goldAdjustment: -30
        ),
        StarterBuild(
            id: "combo",
            name: "连环套",
            icon: "🔥",
            description: "连击路线。起始携带「连环计」（连击翻倍）和「一鸣惊人」。",
            startingJoker: Joker.allJokers.first { $0.effect == .doubleComboRate },
            startingBuff: nil,
            goldAdjustment: 0
        ),
    ]
}
