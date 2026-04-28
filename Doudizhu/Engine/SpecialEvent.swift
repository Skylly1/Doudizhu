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
    case healPlays(Int, goldCost: Int = 0)  // 恢复出牌次数，可选金币消耗
    case upgradeRandomJoker(goldCost: Int = 0)    // 现有Joker效果翻倍，可选金币消耗
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
    case gamblingDen = "gambling_den"
    case apothecary = "apothecary"
    case windfall = "windfall"
    case tombRaid = "tomb_raid"
    case teaHouseIntel = "tea_house_intel"
    case escortAgency = "escort_agency"
    case injuredHero = "injured_hero"
    case celestialLibrary = "celestial_library"
    case wanderingMusician = "wandering_musician"
    case thunderstorm = "thunderstorm"
}

// MARK: - Event Generator

@MainActor
enum SpecialEventGenerator {

    /// 过关后 30% 概率触发（商店层和Boss层不触发）
    static func maybeGenerate(floor: Int, gold: Int) -> SpecialEvent? {
        guard Int.random(in: 0..<10) < 3 else { return nil }
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
            gamblingDen(gold: gold),
            apothecary(gold: gold),
            windfall(),
            tombRaid(gold: gold),
            teaHouseIntel(),
            escortAgency(gold: gold),
            injuredHero(gold: gold),
            celestialLibrary(),
            wanderingMusician(),
            thunderstorm(gold: gold),
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
                    description: L10n.isEnglish ? "-30 gold, +1 play next floor" : "-30金币，下层多1次出牌",
                    icon: "heart.fill",
                    effect: .healPlays(1, goldCost: 30)
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
                : "\u{201C}我看你骨骼惊奇，只需一点小费\u{2026}\u{2026}\u{201D}",
            icon: "eye.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Pay 50 gold" : "付50金币",
                    description: L10n.isEnglish ? "Upgrade a Joker" : "升级一张规则牌",
                    icon: "arrow.up.circle.fill",
                    effect: .upgradeRandomJoker(goldCost: 50)
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

    // MARK: - New Event Definitions

    private static func gamblingDen(gold: Int) -> SpecialEvent {
        SpecialEvent(
            type: .gamblingDen,
            title: L10n.isEnglish ? "Gambling Den" : "赌坊",
            description: L10n.isEnglish
                ? "A lively gambling house beckons. Feeling lucky?"
                : "热闹的赌坊传来骰子声，你手痒了吗？",
            icon: "dice.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Bet big (-50 gold)" : "豪赌 (-50金币)",
                    description: L10n.isEnglish ? "50% win +100g / lose all bet" : "50%赢+100金 / 输掉赌注",
                    icon: "flame.fill",
                    effect: gold >= 50
                        ? (Bool.random() ? .gainGold(100) : .loseGold(50))
                        : .nothing
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Bet small (-20 gold)" : "小赌 (-20金币)",
                    description: L10n.isEnglish ? "50% win +40g / lose bet" : "50%赢+40金 / 输掉赌注",
                    icon: "dollarsign.circle",
                    effect: gold >= 20
                        ? (Bool.random() ? .gainGold(40) : .loseGold(20))
                        : .nothing
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Watch only" : "只看不赌",
                    description: L10n.isEnglish ? "Nothing happens" : "无事发生",
                    icon: "eye.fill",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func apothecary(gold: Int) -> SpecialEvent {
        SpecialEvent(
            type: .apothecary,
            title: L10n.isEnglish ? "Apothecary" : "药铺",
            description: L10n.isEnglish
                ? "Shelves of exotic herbs and tonics. The apothecary smiles warmly."
                : "药架上摆满了奇珍异草，老药师笑脸相迎。",
            icon: "leaf.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Tonic (-40 gold)" : "买补药 (-40金币)",
                    description: L10n.isEnglish ? "+2 plays next floor" : "下层多2次出牌",
                    icon: "cross.vial.fill",
                    effect: gold >= 40 ? .healPlays(2, goldCost: 40) : .nothing
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Cheap tea (-15 gold)" : "买凉茶 (-15金币)",
                    description: L10n.isEnglish ? "+1 play next floor" : "下层多1次出牌",
                    icon: "cup.and.saucer.fill",
                    effect: gold >= 15 ? .healPlays(1, goldCost: 15) : .nothing
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Just browsing" : "随便看看",
                    description: L10n.isEnglish ? "Nothing happens" : "无事发生",
                    icon: "figure.walk",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func windfall() -> SpecialEvent {
        let amount = [30, 50, 80].randomElement()!
        return SpecialEvent(
            type: .windfall,
            title: L10n.isEnglish ? "Windfall" : "天降横财",
            description: L10n.isEnglish
                ? "A gust of wind blows a silk pouch to your feet!"
                : "一阵狂风吹来一个绸缎钱袋，落在你脚边！",
            icon: "wind",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Keep it (+\(amount)g)" : "收下 (+\(amount)金)",
                    description: L10n.isEnglish ? "Finders keepers" : "天予不取，反受其咎",
                    icon: "banknote.fill",
                    effect: .gainGold(amount)
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Share the luck" : "积德行善",
                    description: L10n.isEnglish ? "Get a Buff instead" : "获得一个增益",
                    icon: "hands.sparkles.fill",
                    effect: .gainRandomBuff
                ),
            ]
        )
    }

    private static func tombRaid(gold: Int) -> SpecialEvent {
        SpecialEvent(
            type: .tombRaid,
            title: L10n.isEnglish ? "Ancient Tomb" : "古墓探险",
            description: L10n.isEnglish
                ? "You discover the entrance to a forgotten tomb. Danger and treasure await..."
                : "你发现了一座被遗忘的古墓的入口，危险与宝藏并存……",
            icon: "building.columns.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Venture deep" : "深入探索",
                    description: L10n.isEnglish ? "40% Joker / 60% lose 40g" : "40%获规则牌 / 60%失去40金",
                    icon: "flashlight.on.fill",
                    effect: Int.random(in: 0..<5) < 2
                        ? .gainRandomJoker
                        : .loseGold(min(40, gold))
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Loot entrance" : "搜刮入口",
                    description: L10n.isEnglish ? "+25 gold (safe)" : "+25金币（安全）",
                    icon: "hand.point.down.fill",
                    effect: .gainGold(25)
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Walk away" : "转身离开",
                    description: L10n.isEnglish ? "Nothing happens" : "无事发生",
                    icon: "figure.walk",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func teaHouseIntel() -> SpecialEvent {
        SpecialEvent(
            type: .teaHouseIntel,
            title: L10n.isEnglish ? "Tea House" : "茶馆情报",
            description: L10n.isEnglish
                ? "Travelers share rumors over fragrant tea. Useful information, if you listen..."
                : "茶馆里南来北往的旅客交换着消息，细心聆听或许有用……",
            icon: "bubble.left.and.bubble.right.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Gather intel" : "打听消息",
                    description: L10n.isEnglish ? "Skip next shop (save gold)" : "跳过下一个商店（省钱）",
                    icon: "ear.fill",
                    effect: .skipNextShop
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Share stories" : "交流江湖事",
                    description: L10n.isEnglish ? "Get a Buff" : "获得一个增益",
                    icon: "text.bubble.fill",
                    effect: .gainRandomBuff
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Enjoy the tea" : "品茶休憩",
                    description: L10n.isEnglish ? "+1 play next floor" : "下层多1次出牌",
                    icon: "cup.and.saucer.fill",
                    effect: .healPlays(1)
                ),
            ]
        )
    }

    private static func escortAgency(gold: Int) -> SpecialEvent {
        SpecialEvent(
            type: .escortAgency,
            title: L10n.isEnglish ? "Escort Agency" : "镖局",
            description: L10n.isEnglish
                ? "The escort chief offers protection and rare goods—for the right price."
                : "镖头拍着胸脯：要保镖还是要货，开个价！",
            icon: "shield.lefthalf.filled",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Buy goods (-70 gold)" : "买镖货 (-70金币)",
                    description: L10n.isEnglish ? "Get a Joker" : "获得一张规则牌",
                    icon: "shippingbox.fill",
                    effect: gold >= 70 ? .buyRandomJoker(cost: 70) : .nothing
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Hire escort (-30 gold)" : "雇镖师 (-30金币)",
                    description: L10n.isEnglish ? "Get a Buff" : "获得一个增益",
                    icon: "person.badge.shield.checkmark.fill",
                    effect: gold >= 30 ? .gainRandomBuff : .nothing
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Pass by" : "路过而已",
                    description: L10n.isEnglish ? "Nothing happens" : "无事发生",
                    icon: "figure.walk",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func injuredHero(gold: Int) -> SpecialEvent {
        SpecialEvent(
            type: .injuredHero,
            title: L10n.isEnglish ? "Injured Hero" : "落难侠客",
            description: L10n.isEnglish
                ? "A wounded warrior lies by the road. They beg for aid..."
                : "路边一位受伤的侠客向你求助……",
            icon: "figure.fall",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Give gold (-40)" : "赠金相助 (-40金)",
                    description: L10n.isEnglish ? "Gratitude: free Joker" : "侠客感恩，赠你规则牌",
                    icon: "heart.fill",
                    effect: gold >= 40 ? .gainRandomJoker : .nothing
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Share medicine" : "分享草药",
                    description: L10n.isEnglish ? "They teach you a trick (+Buff)" : "侠客传授一招（+增益）",
                    icon: "cross.case.fill",
                    effect: .gainRandomBuff
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Ignore" : "视而不见",
                    description: L10n.isEnglish ? "Bad karma... -20 gold" : "因果报应……-20金币",
                    icon: "figure.walk",
                    effect: .loseGold(min(20, gold))
                ),
            ]
        )
    }

    private static func celestialLibrary() -> SpecialEvent {
        SpecialEvent(
            type: .celestialLibrary,
            title: L10n.isEnglish ? "Celestial Library" : "天机阁",
            description: L10n.isEnglish
                ? "A hidden pavilion of ancient scrolls. Knowledge of the heavens awaits."
                : "隐秘的天机阁中藏有上古秘籍，天道奥秘尽在其中。",
            icon: "book.closed.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Study scrolls" : "研读秘籍",
                    description: L10n.isEnglish ? "Upgrade a Joker" : "升级一张规则牌",
                    icon: "scroll.fill",
                    effect: .upgradeRandomJoker()
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Meditate" : "闭关参悟",
                    description: L10n.isEnglish ? "Get a Buff" : "获得一个增益",
                    icon: "sparkles",
                    effect: .gainRandomBuff
                ),
            ]
        )
    }

    private static func wanderingMusician() -> SpecialEvent {
        SpecialEvent(
            type: .wanderingMusician,
            title: L10n.isEnglish ? "Wandering Musician" : "流浪琴师",
            description: L10n.isEnglish
                ? "Haunting melodies drift through the air. The musician offers to play for you."
                : "悠扬的琴声随风飘来，琴师愿为你奏一曲。",
            icon: "music.note",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Listen" : "聆听一曲",
                    description: L10n.isEnglish ? "+2 plays next floor" : "下层多2次出牌",
                    icon: "ear.fill",
                    effect: .healPlays(2)
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Jam together" : "合奏一番",
                    description: L10n.isEnglish ? "Get a Buff" : "获得一个增益",
                    icon: "music.quarternote.3",
                    effect: .gainRandomBuff
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Toss a coin" : "打赏铜板",
                    description: L10n.isEnglish ? "-10 gold, +1 play (inspired!)" : "-10金币，+1出牌（琴声鼓舞！）",
                    icon: "dollarsign.circle.fill",
                    effect: .healPlays(1, goldCost: 10)
                ),
            ]
        )
    }

    private static func thunderstorm(gold: Int) -> SpecialEvent {
        let loss = min(30, gold / 3)
        return SpecialEvent(
            type: .thunderstorm,
            title: L10n.isEnglish ? "Thunderstorm!" : "雷暴来袭！",
            description: L10n.isEnglish
                ? "Dark clouds gather and lightning splits the sky. You must act fast!"
                : "乌云密布，电闪雷鸣，你必须赶紧行动！",
            icon: "cloud.bolt.fill",
            choices: [
                EventChoice(
                    label: L10n.isEnglish ? "Brave the storm" : "冒雨前行",
                    description: L10n.isEnglish ? "50% find shelter +Buff / get struck -\(loss)g" : "50%找到庇护+增益 / 被雷劈-\(loss)金",
                    icon: "bolt.fill",
                    effect: Bool.random() ? .gainRandomBuff : .loseGold(loss)
                ),
                EventChoice(
                    label: L10n.isEnglish ? "Take cover (-\(loss) gold)" : "寻找避难所 (-\(loss)金币)",
                    description: L10n.isEnglish ? "Wait it out safely" : "安全等待风暴过去",
                    icon: "house.fill",
                    effect: .loseGold(loss)
                ),
            ]
        )
    }
}
