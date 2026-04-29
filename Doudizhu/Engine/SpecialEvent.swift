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
            title: L10n.localized("神秘商人", en: "Mysterious Merchant", ja: "謎の商人", ko: "신비한 상인", fr: "Marchand Mystérieux", de: "Mysteriöser Händler", es: "Mercader Misterioso", pt: "Mercador Misterioso"),
            description: L10n.localized("一位蒙面人带来了珍稀货物……", en: "A hooded figure appears with rare wares...", ja: "覆面の人物が珍しい品を持って現れた…", ko: "복면인이 진귀한 물건을 가져왔다…", fr: "Un personnage masqué arrive avec des marchandises rares…", de: "Eine maskierte Gestalt bringt seltene Waren…", es: "Un personaje enmascarado trae mercancías raras…", pt: "Um personagem mascarado traz mercadorias raras…"),
            icon: "person.fill.questionmark",
            choices: [
                EventChoice(
                    label: L10n.localized("购买 (-80金币)", en: "Buy (-80 gold)", ja: "購入 (-80G)", ko: "구매 (-80골드)", fr: "Acheter (-80 or)", de: "Kaufen (-80 Gold)", es: "Comprar (-80 oro)", pt: "Comprar (-80 ouro)"),
                    description: L10n.localized("获得随机规则牌", en: "Get a random Joker", ja: "ランダムルールカード獲得", ko: "랜덤 규칙카드 획득", fr: "Obtenir un Joker aléatoire", de: "Zufälligen Joker erhalten", es: "Obtener Joker aleatorio", pt: "Obter Joker aleatório"),
                    icon: "dollarsign.circle.fill",
                    effect: gold >= 80 ? .buyRandomJoker(cost: 80) : .nothing
                ),
                EventChoice(
                    label: L10n.localized("聊聊", en: "Chat", ja: "雑談", ko: "대화", fr: "Discuter", de: "Plaudern", es: "Charlar", pt: "Conversar"),
                    description: L10n.localized("免费获得一个增益", en: "Get a free Buff", ja: "無料でバフ獲得", ko: "무료 버프 획득", fr: "Obtenir un Buff gratuit", de: "Gratis-Buff erhalten", es: "Obtener Buff gratis", pt: "Obter Buff grátis"),
                    icon: "bubble.left.fill",
                    effect: .gainRandomBuff
                ),
                EventChoice(
                    label: L10n.localized("离开", en: "Leave", ja: "立ち去る", ko: "떠나기", fr: "Partir", de: "Gehen", es: "Irse", pt: "Ir embora"),
                    description: L10n.localized("无事发生", en: "Nothing happens", ja: "何も起きない", ko: "아무 일 없음", fr: "Rien ne se passe", de: "Nichts passiert", es: "No pasa nada", pt: "Nada acontece"),
                    icon: "figure.walk",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func ancientChest() -> SpecialEvent {
        SpecialEvent(
            type: .ancientChest,
            title: L10n.localized("远古宝箱", en: "Ancient Chest", ja: "古代の宝箱", ko: "고대 보물상자", fr: "Coffre Ancien", de: "Alte Truhe", es: "Cofre Antiguo", pt: "Baú Antigo"),
            description: L10n.localized("角落里有一个布满灰尘的宝箱，你敢打开吗？", en: "A dusty chest sits in the corner. Do you dare open it?", ja: "角に埃をかぶった宝箱がある。開ける勇気はあるか？", ko: "구석에 먼지 쌓인 보물상자가 있다. 열어볼 용기가 있나?", fr: "Un coffre poussiéreux dans le coin. Osez-vous l'ouvrir ?", de: "Eine staubige Truhe in der Ecke. Wagst du es?", es: "Un cofre polvoriento en la esquina. ¿Te atreves?", pt: "Um baú empoeirado no canto. Ousas abri-lo?"),
            icon: "shippingbox.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("打开！", en: "Open!", ja: "開ける！", ko: "열기!", fr: "Ouvrir !", de: "Öffnen!", es: "¡Abrir!", pt: "Abrir!"),
                    description: L10n.localized("50%金币，50%陷阱", en: "50% gold, 50% trap", ja: "50%金貨、50%罠", ko: "50% 골드, 50% 함정", fr: "50% or, 50% piège", de: "50% Gold, 50% Falle", es: "50% oro, 50% trampa", pt: "50% ouro, 50% armadilha"),
                    icon: "lock.open.fill",
                    effect: Bool.random() ? .gainGold(60) : .loseGold(30)
                ),
                EventChoice(
                    label: L10n.localized("算了", en: "Leave it", ja: "やめる", ko: "그만두기", fr: "Laisser", de: "Lassen", es: "Dejarlo", pt: "Deixar"),
                    description: L10n.localized("安全第一", en: "Safety first", ja: "安全第一", ko: "안전 제일", fr: "La sécurité d'abord", de: "Sicherheit zuerst", es: "La seguridad primero", pt: "Segurança primeiro"),
                    icon: "figure.walk",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func wanderingMonk() -> SpecialEvent {
        SpecialEvent(
            type: .wanderingMonk,
            title: L10n.localized("云游僧人", en: "Wandering Monk"),
            description: L10n.localized("一位老僧人愿意传授你智慧……", en: "An old monk offers you wisdom..."),
            icon: "figure.mind.and.body",
            choices: [
                EventChoice(
                    label: L10n.localized("接受指点", en: "Accept teaching"),
                    description: L10n.localized("获得一个增益", en: "Get a Buff"),
                    icon: "sparkles",
                    effect: .gainRandomBuff
                ),
                EventChoice(
                    label: L10n.localized("供奉30金币", en: "Donate 30 gold"),
                    description: L10n.localized("-30金币，下层多1次出牌", en: "-30 gold, +1 play next floor"),
                    icon: "heart.fill",
                    effect: .healPlays(1, goldCost: 30)
                ),
            ]
        )
    }

    private static func crossroads() -> SpecialEvent {
        SpecialEvent(
            type: .crossroads,
            title: L10n.localized("十字路口", en: "Crossroads"),
            description: L10n.localized("两条路分岔，你选哪一条？", en: "Two paths diverge. Which do you choose?"),
            icon: "arrow.triangle.branch",
            choices: [
                EventChoice(
                    label: L10n.localized("左：财富之路", en: "Left: Riches"),
                    description: L10n.localized("+40金币", en: "+40 gold"),
                    icon: "dollarsign.circle",
                    effect: .gainGold(40)
                ),
                EventChoice(
                    label: L10n.localized("右：力量之路", en: "Right: Power"),
                    description: L10n.localized("获得随机增益", en: "Get a random Buff"),
                    icon: "bolt.fill",
                    effect: .gainRandomBuff
                ),
            ]
        )
    }

    private static func fortuneTeller() -> SpecialEvent {
        SpecialEvent(
            type: .fortuneTeller,
            title: L10n.localized("算命先生", en: "Fortune Teller"),
            description: L10n.localized("\u{201C}我看你骨骼惊奇，只需一点小费\u{2026}\u{2026}\u{201D}", en: "\"I see great things in your future... for a price.\""),
            icon: "eye.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("付50金币", en: "Pay 50 gold"),
                    description: L10n.localized("升级一张规则牌", en: "Upgrade a Joker"),
                    icon: "arrow.up.circle.fill",
                    effect: .upgradeRandomJoker(goldCost: 50)
                ),
                EventChoice(
                    label: L10n.localized("拒绝", en: "Decline"),
                    description: L10n.localized("保留金币", en: "Keep your gold"),
                    icon: "hand.raised.fill",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func blacksmith() -> SpecialEvent {
        SpecialEvent(
            type: .blacksmith,
            title: L10n.localized("铁匠铺", en: "Blacksmith"),
            description: L10n.localized("铁匠愿意为你打造装备。", en: "A smithy offers to forge something useful."),
            icon: "hammer.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("锻造 (-60金币)", en: "Forge (-60 gold)"),
                    description: L10n.localized("获得随机规则牌", en: "Get random Joker", ja: "ランダムルールカード獲得", ko: "랜덤 규칙카드 획득", fr: "Obtenir un Joker aléatoire", de: "Zufälligen Joker erhalten", es: "Obtener Joker aleatorio", pt: "Obter Joker aleatório"),
                    icon: "flame.fill",
                    effect: .buyRandomJoker(cost: 60)
                ),
                EventChoice(
                    label: L10n.localized("烤烤火", en: "Just warm up"),
                    description: L10n.localized("+20金币", en: "+20 gold"),
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
            title: L10n.localized("强盗伏击！", en: "Bandit Ambush!"),
            description: L10n.localized("路遇山贼拦路！战还是破财消灾？", en: "Bandits block your path! Fight or pay?"),
            icon: "exclamationmark.triangle.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("迎战", en: "Fight"),
                    description: L10n.localized("50%赢+50金 / 输-\(loss)金", en: "50% win: +50g / lose: -\(loss)g"),
                    icon: "figure.fencing",
                    effect: Bool.random() ? .gainGold(50) : .loseGold(loss)
                ),
                EventChoice(
                    label: L10n.localized("交买路钱 (-\(loss))", en: "Pay toll (-\(loss))"),
                    description: L10n.localized("安全通过", en: "Safe passage"),
                    icon: "banknote.fill",
                    effect: .loseGold(loss)
                ),
            ]
        )
    }

    private static func sacredSpring() -> SpecialEvent {
        SpecialEvent(
            type: .sacredSpring,
            title: L10n.localized("灵泉", en: "Sacred Spring"),
            description: L10n.localized("清澈的泉水从岩石中涌出，你感到精力充沛。", en: "Crystal-clear water flows from the rock. You feel refreshed."),
            icon: "drop.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("痛饮", en: "Drink deeply"),
                    description: L10n.localized("下层多2次出牌", en: "+2 plays next floor"),
                    icon: "cup.and.saucer.fill",
                    effect: .healPlays(2)
                ),
                EventChoice(
                    label: L10n.localized("装满水壶", en: "Fill flask"),
                    description: L10n.localized("获得增益", en: "Get a Buff"),
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
            title: L10n.localized("赌坊", en: "Gambling Den"),
            description: L10n.localized("热闹的赌坊传来骰子声，你手痒了吗？", en: "A lively gambling house beckons. Feeling lucky?"),
            icon: "dice.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("豪赌 (-50金币)", en: "Bet big (-50 gold)"),
                    description: L10n.localized("50%赢+100金 / 输掉赌注", en: "50% win +100g / lose all bet"),
                    icon: "flame.fill",
                    effect: gold >= 50
                        ? (Bool.random() ? .gainGold(100) : .loseGold(50))
                        : .nothing
                ),
                EventChoice(
                    label: L10n.localized("小赌 (-20金币)", en: "Bet small (-20 gold)"),
                    description: L10n.localized("50%赢+40金 / 输掉赌注", en: "50% win +40g / lose bet"),
                    icon: "dollarsign.circle",
                    effect: gold >= 20
                        ? (Bool.random() ? .gainGold(40) : .loseGold(20))
                        : .nothing
                ),
                EventChoice(
                    label: L10n.localized("只看不赌", en: "Watch only"),
                    description: L10n.localized("无事发生", en: "Nothing happens", ja: "何も起きない", ko: "아무 일 없음", fr: "Rien ne se passe", de: "Nichts passiert", es: "No pasa nada", pt: "Nada acontece"),
                    icon: "eye.fill",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func apothecary(gold: Int) -> SpecialEvent {
        SpecialEvent(
            type: .apothecary,
            title: L10n.localized("药铺", en: "Apothecary"),
            description: L10n.localized("药架上摆满了奇珍异草，老药师笑脸相迎。", en: "Shelves of exotic herbs and tonics. The apothecary smiles warmly."),
            icon: "leaf.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("买补药 (-40金币)", en: "Tonic (-40 gold)"),
                    description: L10n.localized("下层多2次出牌", en: "+2 plays next floor"),
                    icon: "cross.vial.fill",
                    effect: gold >= 40 ? .healPlays(2, goldCost: 40) : .nothing
                ),
                EventChoice(
                    label: L10n.localized("买凉茶 (-15金币)", en: "Cheap tea (-15 gold)"),
                    description: L10n.localized("下层多1次出牌", en: "+1 play next floor"),
                    icon: "cup.and.saucer.fill",
                    effect: gold >= 15 ? .healPlays(1, goldCost: 15) : .nothing
                ),
                EventChoice(
                    label: L10n.localized("随便看看", en: "Just browsing"),
                    description: L10n.localized("无事发生", en: "Nothing happens", ja: "何も起きない", ko: "아무 일 없음", fr: "Rien ne se passe", de: "Nichts passiert", es: "No pasa nada", pt: "Nada acontece"),
                    icon: "figure.walk",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func windfall() -> SpecialEvent {
        let amount = [30, 50, 80].randomElement() ?? 50
        return SpecialEvent(
            type: .windfall,
            title: L10n.localized("天降横财", en: "Windfall"),
            description: L10n.localized("一阵狂风吹来一个绸缎钱袋，落在你脚边！", en: "A gust of wind blows a silk pouch to your feet!"),
            icon: "wind",
            choices: [
                EventChoice(
                    label: L10n.localized("收下 (+\(amount)金)", en: "Keep it (+\(amount)g)"),
                    description: L10n.localized("天予不取，反受其咎", en: "Finders keepers"),
                    icon: "banknote.fill",
                    effect: .gainGold(amount)
                ),
                EventChoice(
                    label: L10n.localized("积德行善", en: "Share the luck"),
                    description: L10n.localized("获得一个增益", en: "Get a Buff instead"),
                    icon: "hands.sparkles.fill",
                    effect: .gainRandomBuff
                ),
            ]
        )
    }

    private static func tombRaid(gold: Int) -> SpecialEvent {
        SpecialEvent(
            type: .tombRaid,
            title: L10n.localized("古墓探险", en: "Ancient Tomb"),
            description: L10n.localized("你发现了一座被遗忘的古墓的入口，危险与宝藏并存……", en: "You discover the entrance to a forgotten tomb. Danger and treasure await..."),
            icon: "building.columns.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("深入探索", en: "Venture deep"),
                    description: L10n.localized("40%获规则牌 / 60%失去40金", en: "40% Joker / 60% lose 40g"),
                    icon: "flashlight.on.fill",
                    effect: Int.random(in: 0..<5) < 2
                        ? .gainRandomJoker
                        : .loseGold(min(40, gold))
                ),
                EventChoice(
                    label: L10n.localized("搜刮入口", en: "Loot entrance"),
                    description: L10n.localized("+25金币（安全）", en: "+25 gold (safe)"),
                    icon: "hand.point.down.fill",
                    effect: .gainGold(25)
                ),
                EventChoice(
                    label: L10n.localized("转身离开", en: "Walk away"),
                    description: L10n.localized("无事发生", en: "Nothing happens", ja: "何も起きない", ko: "아무 일 없음", fr: "Rien ne se passe", de: "Nichts passiert", es: "No pasa nada", pt: "Nada acontece"),
                    icon: "figure.walk",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func teaHouseIntel() -> SpecialEvent {
        SpecialEvent(
            type: .teaHouseIntel,
            title: L10n.localized("茶馆情报", en: "Tea House"),
            description: L10n.localized("茶馆里南来北往的旅客交换着消息，细心聆听或许有用……", en: "Travelers share rumors over fragrant tea. Useful information, if you listen..."),
            icon: "bubble.left.and.bubble.right.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("打听消息", en: "Gather intel"),
                    description: L10n.localized("跳过下一个商店（省钱）", en: "Skip next shop (save gold)"),
                    icon: "ear.fill",
                    effect: .skipNextShop
                ),
                EventChoice(
                    label: L10n.localized("交流江湖事", en: "Share stories"),
                    description: L10n.localized("获得一个增益", en: "Get a Buff"),
                    icon: "text.bubble.fill",
                    effect: .gainRandomBuff
                ),
                EventChoice(
                    label: L10n.localized("品茶休憩", en: "Enjoy the tea"),
                    description: L10n.localized("下层多1次出牌", en: "+1 play next floor"),
                    icon: "cup.and.saucer.fill",
                    effect: .healPlays(1)
                ),
            ]
        )
    }

    private static func escortAgency(gold: Int) -> SpecialEvent {
        SpecialEvent(
            type: .escortAgency,
            title: L10n.localized("镖局", en: "Escort Agency"),
            description: L10n.localized("镖头拍着胸脯：要保镖还是要货，开个价！", en: "The escort chief offers protection and rare goods—for the right price."),
            icon: "shield.lefthalf.filled",
            choices: [
                EventChoice(
                    label: L10n.localized("买镖货 (-70金币)", en: "Buy goods (-70 gold)"),
                    description: L10n.localized("获得一张规则牌", en: "Get a Joker"),
                    icon: "shippingbox.fill",
                    effect: gold >= 70 ? .buyRandomJoker(cost: 70) : .nothing
                ),
                EventChoice(
                    label: L10n.localized("雇镖师 (-30金币)", en: "Hire escort (-30 gold)"),
                    description: L10n.localized("获得一个增益", en: "Get a Buff"),
                    icon: "person.badge.shield.checkmark.fill",
                    effect: gold >= 30 ? .gainRandomBuff : .nothing
                ),
                EventChoice(
                    label: L10n.localized("路过而已", en: "Pass by"),
                    description: L10n.localized("无事发生", en: "Nothing happens", ja: "何も起きない", ko: "아무 일 없음", fr: "Rien ne se passe", de: "Nichts passiert", es: "No pasa nada", pt: "Nada acontece"),
                    icon: "figure.walk",
                    effect: .nothing
                ),
            ]
        )
    }

    private static func injuredHero(gold: Int) -> SpecialEvent {
        SpecialEvent(
            type: .injuredHero,
            title: L10n.localized("落难侠客", en: "Injured Hero"),
            description: L10n.localized("路边一位受伤的侠客向你求助……", en: "A wounded warrior lies by the road. They beg for aid..."),
            icon: "figure.fall",
            choices: [
                EventChoice(
                    label: L10n.localized("赠金相助 (-40金)", en: "Give gold (-40)"),
                    description: L10n.localized("侠客感恩，赠你规则牌", en: "Gratitude: free Joker"),
                    icon: "heart.fill",
                    effect: gold >= 40 ? .gainRandomJoker : .nothing
                ),
                EventChoice(
                    label: L10n.localized("分享草药", en: "Share medicine"),
                    description: L10n.localized("侠客传授一招（+增益）", en: "They teach you a trick (+Buff)"),
                    icon: "cross.case.fill",
                    effect: .gainRandomBuff
                ),
                EventChoice(
                    label: L10n.localized("视而不见", en: "Ignore"),
                    description: L10n.localized("因果报应……-20金币", en: "Bad karma... -20 gold"),
                    icon: "figure.walk",
                    effect: .loseGold(min(20, gold))
                ),
            ]
        )
    }

    private static func celestialLibrary() -> SpecialEvent {
        SpecialEvent(
            type: .celestialLibrary,
            title: L10n.localized("天机阁", en: "Celestial Library"),
            description: L10n.localized("隐秘的天机阁中藏有上古秘籍，天道奥秘尽在其中。", en: "A hidden pavilion of ancient scrolls. Knowledge of the heavens awaits."),
            icon: "book.closed.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("研读秘籍", en: "Study scrolls"),
                    description: L10n.localized("升级一张规则牌", en: "Upgrade a Joker"),
                    icon: "scroll.fill",
                    effect: .upgradeRandomJoker()
                ),
                EventChoice(
                    label: L10n.localized("闭关参悟", en: "Meditate"),
                    description: L10n.localized("获得一个增益", en: "Get a Buff"),
                    icon: "sparkles",
                    effect: .gainRandomBuff
                ),
            ]
        )
    }

    private static func wanderingMusician() -> SpecialEvent {
        SpecialEvent(
            type: .wanderingMusician,
            title: L10n.localized("流浪琴师", en: "Wandering Musician"),
            description: L10n.localized("悠扬的琴声随风飘来，琴师愿为你奏一曲。", en: "Haunting melodies drift through the air. The musician offers to play for you."),
            icon: "music.note",
            choices: [
                EventChoice(
                    label: L10n.localized("聆听一曲", en: "Listen"),
                    description: L10n.localized("下层多2次出牌", en: "+2 plays next floor"),
                    icon: "ear.fill",
                    effect: .healPlays(2)
                ),
                EventChoice(
                    label: L10n.localized("合奏一番", en: "Jam together"),
                    description: L10n.localized("获得一个增益", en: "Get a Buff"),
                    icon: "music.quarternote.3",
                    effect: .gainRandomBuff
                ),
                EventChoice(
                    label: L10n.localized("打赏铜板", en: "Toss a coin"),
                    description: L10n.localized("-10金币，+1出牌（琴声鼓舞！）", en: "-10 gold, +1 play (inspired!)"),
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
            title: L10n.localized("雷暴来袭！", en: "Thunderstorm!"),
            description: L10n.localized("乌云密布，电闪雷鸣，你必须赶紧行动！", en: "Dark clouds gather and lightning splits the sky. You must act fast!"),
            icon: "cloud.bolt.fill",
            choices: [
                EventChoice(
                    label: L10n.localized("冒雨前行", en: "Brave the storm"),
                    description: L10n.localized("50%找到庇护+增益 / 被雷劈-\(loss)金", en: "50% find shelter +Buff / get struck -\(loss)g"),
                    icon: "bolt.fill",
                    effect: Bool.random() ? .gainRandomBuff : .loseGold(loss)
                ),
                EventChoice(
                    label: L10n.localized("寻找避难所 (-\(loss)金币)", en: "Take cover (-\(loss) gold)"),
                    description: L10n.localized("安全等待风暴过去", en: "Wait it out safely"),
                    icon: "house.fill",
                    effect: .loseGold(loss)
                ),
            ]
        )
    }
}
