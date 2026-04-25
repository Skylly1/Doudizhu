import Foundation

// MARK: - 特殊事件系统

/// 楼层间随机触发的特殊事件，增加每局变化性和叙事感
struct SpecialEvent: Identifiable {
    let id = UUID()
    let type: SpecialEventType
    let title: String
    let description: String
    let icon: String
    let choices: [EventChoice]
}

struct EventChoice: Identifiable {
    let id = UUID()
    let label: String
    let description: String
    let icon: String
    let effect: EventEffect
}

enum EventEffect {
    case gainGold(Int)
    case loseGold(Int)
    case gainRandomJoker
    case buyRandomJoker(cost: Int)  // 花费金币获得Joker
    case gainRandomBuff
    case healPlays(Int)        // 恢复出牌次数
    case upgradeRandomJoker    // 现有Joker效果翻倍（标记用）
    case skipNextShop          // 跳过下一个商店
    case nothing               // 无事发生
}

enum SpecialEventType: String {
    case mysteriousMerchant = "mysterious_merchant"
    case ancientChest = "ancient_chest"
    case wanderingMonk = "wandering_monk"
    case crossroads = "crossroads"
    case fortuneTeller = "fortune_teller"
    case blacksmith = "blacksmith"
    case banditAmbush = "bandit_ambush"
    case sacredSpring = "sacred_spring"
}

// MARK: - Event Generator

@MainActor
enum SpecialEventGenerator {

    /// 过关后 20% 概率触发（商店层和Boss层不触发）
    static func maybeGenerate(floor: Int, gold: Int) -> SpecialEvent? {
        guard Int.random(in: 0..<5) == 0 else { return nil }
        let pool = allEvents(gold: gold)
        return pool.randomElement()
    }

    private static func allEvents(gold: Int) -> [SpecialEvent] {
        [
            mysteriousMerchant(gold: gold),
            ancientChest(),
            wanderingMonk(),
            crossroads(),
            fortuneTeller(),
            blacksmith(),
            banditAmbush(gold: gold),
            sacredSpring(),
        ]
    }

    // MARK: - Event Definitions

    private static func mysteriousMerchant(gold: Int) -> SpecialEvent {
        SpecialEvent(
            type: .mysteriousMerchant,
            title: L10n.isEnglish ? "Mysterious Merchant" : "神秘商人",
            description: L10n.isEnglish
                ? "A hooded figure appears with rare wares..."
                : "一位蒙面人带来了珍稀货物……",
            icon: "person.fill.questionmark",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Buy (-80 gold)" : "购买 (-80金币)",
                    description: L10n.isEnglish ? "Get a random Joker" : "获得随机规则牌",
                    icon: "dollarsign.circle.fill",
                    effect: gold >= 80 ? .buyRandomJoker(cost: 80) : .nothing
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Chat" : "聊聊",
                    description: L10n.isEnglish ? "Get a free Buff" : "免费获得一个增益",
                    icon: "bubble.left.fill",
                    effect: .gainRandomBuff
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Leave" : "离开",
                    description: L10n.isEnglish ? "Nothing happens" : "无事发生",
                    icon: "figure.walk",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func ancientChest() -> SpecialEvent {
        SpecialEvent(
            type: .ancientChest,
            title: L10n.isEnglish ? "Ancient Chest" : "远古宝箱",
            description: L10n.isEnglish
                ? "A dusty chest sits in the corner. Do you dare open it?"
                : "角落里有一个布满灰尘的宝箱，你敢打开吗？",
            icon: "shippingbox.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Open!" : "打开！",
                    description: L10n.isEnglish ? "50% gold, 50% trap" : "50%金币，50%陷阱",
                    icon: "lock.open.fill",
                    effect: Bool.random() ? .gainGold(60) : .loseGold(30)
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Leave it" : "算了",
                    description: L10n.isEnglish ? "Safety first" : "安全第一",
                    icon: "figure.walk",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func wanderingMonk() -> SpecialEvent {
        SpecialEvent(
            type: .wanderingMonk,
            title: L10n.isEnglish ? "Wandering Monk" : "云游僧人",
            description: L10n.isEnglish
                ? "An old monk offers you wisdom..."
                : "一位老僧人愿意传授你智慧……",
            icon: "figure.mind.and.body",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Accept teaching" : "接受指点",
                    description: L10n.isEnglish ? "Get a Buff" : "获得一个增益",
                    icon: "sparkles",
                    effect: .gainRandomBuff
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Donate 30 gold" : "供奉30金币",
                    description: L10n.isEnglish ? "+1 play next floor" : "下层多1次出牌",
                    icon: "heart.fill",
                    effect: .healPlays(1)
                ),
            ]
        )
    }

    private static func crossroads() -> SpecialEvent {
        SpecialEvent(
            type: .crossroads,
            title: L10n.isEnglish ? "Crossroads" : "十字路口",
            description: L10n.isEnglish
                ? "Two paths diverge. Which do you choose?"
                : "两条路分岔，你选哪一条？",
            icon: "arrow.triangle.branch",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Left: Riches" : "左：财富之路",
                    description: L10n.isEnglish ? "+40 gold" : "+40金币",
                    icon: "dollarsign.circle",
                    effect: .gainGold(40)
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Right: Power" : "右：力量之路",
                    description: L10n.isEnglish ? "Get a random Buff" : "获得随机增益",
                    icon: "bolt.fill",
                    effect: .gainRandomBuff
                ),
            ]
        )
    }

    private static func fortuneTeller() -> SpecialEvent {
        SpecialEvent(
            type: .fortuneTeller,
            title: L10n.isEnglish ? "Fortune Teller" : "算命先生",
            description: L10n.isEnglish
                ? "\"I see great things in your future... for a price.\""
                : ""我看你骨骼惊奇，只需一点小费……"",
            icon: "eye.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Pay 50 gold" : "付50金币",
                    description: L10n.isEnglish ? "Upgrade a Joker" : "升级一张规则牌",
                    icon: "arrow.up.circle.fill",
                    effect: .upgradeRandomJoker
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Decline" : "拒绝",
                    description: L10n.isEnglish ? "Keep your gold" : "保留金币",
                    icon: "hand.raised.fill",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func blacksmith() -> SpecialEvent {
        SpecialEvent(
            type: .blacksmith,
            title: L10n.isEnglish ? "Blacksmith" : "铁匠铺",
            description: L10n.isEnglish
                ? "A smithy offers to forge something useful."
                : "铁匠愿意为你打造装备。",
            icon: "hammer.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Forge (-60 gold)" : "锻造 (-60金币)",
                    description: L10n.isEnglish ? "Get random Joker" : "获得随机规则牌",
                    icon: "flame.fill",
                    effect: .buyRandomJoker(cost: 60)
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Just warm up" : "烤烤火",
                    description: L10n.isEnglish ? "+20 gold" : "+20金币",
                    icon: "fireplace.fill",
                    effect: .gainGold(20)
                ),
            ]
        )
    }

    private static func banditAmbush(gold: Int) -> SpecialEvent {
        let loss = min(50, gold / 3)
        return SpecialEvent(
            type: .banditAmbush,
            title: L10n.isEnglish ? "Bandit Ambush!" : "强盗伏击！",
            description: L10n.isEnglish
                ? "Bandits block your path! Fight or pay?"
                : "路遇山贼拦路！战还是破财消灾？",
            icon: "exclamationmark.triangle.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Fight" : "迎战",
                    description: L10n.isEnglish ? "50% win: +50g / lose: -\(loss)g" : "50%赢+50金 / 输-\(loss)金",
                    icon: "figure.fencing",
                    effect: Bool.random() ? .gainGold(50) : .loseGold(loss)
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Pay toll (-\(loss))" : "交买路钱 (-\(loss))",
                    description: L10n.isEnglish ? "Safe passage" : "安全通过",
                    icon: "banknote.fill",
                    effect: .loseGold(loss)
                ),
            ]
        )
    }

    private static func sacredSpring() -> SpecialEvent {
        SpecialEvent(
            type: .sacredSpring,
            title: L10n.isEnglish ? "Sacred Spring" : "灵泉",
            description: L10n.isEnglish
                ? "Crystal-clear water flows from the rock. You feel refreshed."
                : "清澈的泉水从岩石中涌出，你感到精力充沛。",
            icon: "drop.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Drink deeply" : "痛饮",
                    description: L10n.isEnglish ? "+2 plays next floor" : "下层多2次出牌",
                    icon: "cup.and.saucer.fill",
                    effect: .healPlays(2)
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Fill flask" : "装满水壶",
                    description: L10n.isEnglish ? "Get a Buff" : "获得增益",
                    icon: "flask.fill",
                    effect: .gainRandomBuff
                ),
            ]
        )
    }
}
