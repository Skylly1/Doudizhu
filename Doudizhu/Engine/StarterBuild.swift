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

    /// 6 种预设流派
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
        StarterBuild(
            id: "precision",
            name: "精打细算",
            icon: "🎯",
            description: "小牌精准路线。携带「精打细算」+ 额外换牌。",
            startingJoker: Joker.allJokers.first { $0.effect == .miniHandBonus },
            startingBuff: nil,
            goldAdjustment: 20
        ),
        StarterBuild(
            id: "greed",
            name: "贪婪商人",
            icon: "💰",
            description: "经济路线。携带「点石成金」，但初始金币减少。",
            startingJoker: Joker.allJokers.first { $0.effect == .goldRush },
            startingBuff: Buff.allBuffs.first { $0.type == .globalMultiplier },
            goldAdjustment: -50
        ),
        StarterBuild(
            id: "allIn",
            name: "背水一战",
            icon: "⚡",
            description: "高风险高回报。「破釜沉舟」+「一鸣惊人」，但只有 80 金币。",
            startingJoker: Joker.allJokers.first { $0.effect == .lastStandBonus },
            startingBuff: nil,
            goldAdjustment: -70
        ),
        StarterBuild(
            id: "straightMaster",
            name: "顺子专家",
            icon: "🌊",
            description: "顺子路线。携带「顺势而为」（顺子×2）+ 顺风车 Buff，180金币。",
            startingJoker: Joker.allJokers.first { $0.effect == .sequenceBonus },
            startingBuff: Buff.allBuffs.first { $0.type == .straightBonus },
            goldAdjustment: 30
        ),
        StarterBuild(
            id: "defensive",
            name: "防御大师",
            icon: "🛡️",
            description: "防守反击。携带「暗度陈仓」（换牌+2），200金币，稳中求胜。",
            startingJoker: Joker.allJokers.first { $0.effect == .extraDiscards },
            startingBuff: Buff.allBuffs.first { $0.type == .globalMultiplier },
            goldAdjustment: 50
        ),
        StarterBuild(
            id: "gambler",
            name: "赌徒",
            icon: "🎰",
            description: "命运由天。携带「赌徒之心」（随机±30%），100金币，搏一搏单车变摩托。",
            startingJoker: Joker.allJokers.first { $0.effect == .gambler },
            startingBuff: nil,
            goldAdjustment: -50
        ),
    ]
}
