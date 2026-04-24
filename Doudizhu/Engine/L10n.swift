import Foundation

/// 本地化字符串管理器
/// 使用方式：L10n.battleTitle, L10n.play 等
/// 后续可迁移到 String Catalog (.xcstrings) 实现自动翻译
enum L10n {
    /// 当前语言（后续可做设置切换）
    static var isEnglish: Bool {
        Locale.current.language.languageCode?.identifier == "en"
    }

    // MARK: - 通用
    static var appName: String { localized("斗破乾坤", en: "Dou Po Qian Kun") }
    static var appSubtitle: String { localized("Roguelike 斗地主", en: "Roguelike Dou Di Zhu") }
    static var back: String { localized("返回", en: "Back") }
    static var confirm: String { localized("确认", en: "Confirm") }
    static var cancel: String { localized("取消", en: "Cancel") }

    // MARK: - 主菜单
    static var startAdventure: String { localized("开始冒险", en: "Start Adventure") }
    static var cardCollection: String { localized("卡牌收藏", en: "Card Collection") }
    static var settings: String { localized("设置", en: "Settings") }
    static var chooseBuild: String { localized("选择流派", en: "Choose Build") }
    static var buildHint: String { localized("不同流派影响你的起始装备和金币",
                                              en: "Different builds affect your starting gear and gold") }

    // MARK: - 地图
    static var adventurePath: String { localized("冒险之路", en: "Adventure Path") }
    static var mapSubtitle: String { localized("穿越 8 层牌局", en: "Cross 8 floors of card battles") }
    static var depart: String { localized("出发", en: "Depart") }
    static func playsLabel(_ n: Int) -> String { localized("\(n)次出牌", en: "\(n) Plays") }
    static func discardsLabel(_ n: Int) -> String { localized("\(n)次换牌", en: "\(n) Swaps") }

    // MARK: - 战斗
    static var play: String { localized("出牌", en: "Play") }
    static var swap: String { localized("换牌", en: "Swap") }
    static var floor: String { localized("层", en: "Floor") }
    static var combo: String { localized("连击", en: "Combo") }
    static var cleared: String { localized("过关！", en: "Cleared!") }
    static var failed: String { localized("失败", en: "Failed") }
    static var victory: String { localized("通关！", en: "Victory!") }
    static var continueForward: String { localized("继续前进 →", en: "Continue →") }
    static var restart: String { localized("重新开始", en: "Restart") }
    static var backToMenu: String { localized("返回主菜单", en: "Back to Menu") }
    static var targetNotReached: String { localized("未达到目标分数", en: "Target score not reached") }
    static var bossDefeated: String { localized("你击败了恶霸地主！", en: "You defeated the Landlord!") }
    static var playAgain: String { localized("再来一局", en: "Play Again") }
    static var achievementUnlocked: String { localized("成就解锁", en: "Achievement Unlocked") }
    static var invalidPattern: String { localized("无效牌型", en: "Invalid Pattern") }
    static var floorScoreLabel: String { localized("本层得分", en: "Floor Score") }
    static var totalScoreLabel: String { localized("总得分", en: "Total Score") }
    static var goldEarned: String { localized("获得金币", en: "Gold Earned") }
    static var targetScoreLabel: String { localized("目标分数", en: "Target Score") }
    static func floorNumber(_ n: Int) -> String { localized("第 \(n) 层", en: "Floor \(n)") }
    static func comboText(_ combo: Int, bonus: Int) -> String { localized("\(combo) 连击！加成 +\(bonus)%", en: "\(combo) Combo! +\(bonus)% bonus") }
    static func totalScoreValue(_ score: Int) -> String { localized("总分：\(score)", en: "Total: \(score)") }
    static func baseScore(_ score: Int) -> String { localized("基础 \(score) 分", en: "Base \(score) pts") }

    // MARK: - 商店
    static var shop: String { localized("商店", en: "Shop") }
    static var jokerSection: String { localized("规则牌", en: "Jokers") }
    static var buffSection: String { localized("增益道具", en: "Buffs") }
    static var leave: String { localized("离开商店", en: "Leave Shop") }
    static var owned: String { localized("已拥有", en: "Owned") }
    static var full: String { localized("已满", en: "Full") }
    static var shopSubtitle: String { localized("选购规则牌与增益道具", en: "Browse jokers and buffs") }
    static var gold: String { localized("金币", en: "Gold") }
    static var soldOut: String { localized("已售罄", en: "Sold Out") }
    static var equippedJokers: String { localized("已装备规则牌", en: "Equipped Jokers") }
    static var equippedBuffs: String { localized("已装备增益", en: "Equipped Buffs") }

    // MARK: - 试玩结束
    static var demoOver: String { localized("试玩结束", en: "Demo Over") }
    static var unlockFull: String { localized("解锁完整版", en: "Unlock Full Version") }
    static var restorePurchase: String { localized("恢复购买", en: "Restore Purchase") }
    static var demoDescription: String { localized("你已体验了斗破乾坤的核心玩法！\n解锁完整版，继续挑战更高层数。",
                                                    en: "You've experienced the core gameplay!\nUnlock the full version to challenge higher floors.") }
    static func unlockFullPrice(_ price: String) -> String { localized("解锁完整版 — \(price)", en: "Unlock Full — \(price)") }

    // MARK: - 教程
    static var skipTutorial: String { localized("跳过教程", en: "Skip Tutorial") }
    static var nextStep: String { localized("下一步 →", en: "Next →") }
    static var startGame: String { localized("开始游戏！", en: "Start!") }
    static var tutorialWelcomeTitle: String { localized("欢迎来到斗破乾坤！", en: "Welcome to Dou Po Qian Kun!") }
    static var tutorialSelectTitle: String { localized("选牌", en: "Select Cards") }
    static var tutorialPlayTitle: String { localized("出牌", en: "Play Cards") }
    static var tutorialDiscardTitle: String { localized("换牌", en: "Swap Cards") }
    static var tutorialComboTitle: String { localized("连击", en: "Combo") }
    static var tutorialShopTitle: String { localized("商店", en: "Shop") }
    static var tutorialWelcomeMsg: String { localized(
        "在这个 Roguelike 斗地主中，你需要在有限的出牌次数内凑够目标分数。\n\n点击任意位置继续。",
        en: "In this Roguelike Dou Di Zhu, you must reach the target score within limited plays.\n\nTap anywhere to continue.") }
    static var tutorialSelectMsg: String { localized(
        "点击手中的卡牌来选中它们。\n组成合法的斗地主牌型（对子、顺子、炸弹等）可以得分。",
        en: "Tap cards in your hand to select them.\nForm valid patterns (pairs, straights, bombs, etc.) to score.") }
    static var tutorialPlayMsg: String { localized(
        "选好牌后，点击「出牌」按钮打出。\n牌型越复杂、牌越多，得分越高！",
        en: "After selecting, tap \"Play\" to play them.\nMore complex patterns score higher!") }
    static var tutorialDiscardMsg: String { localized(
        "手牌不好？选中不需要的牌，点击「换牌」抽新牌。\n换牌次数有限，要省着用。",
        en: "Bad hand? Select unwanted cards and tap \"Swap\" to draw new ones.\nSwaps are limited, use wisely.") }
    static var tutorialComboMsg: String { localized(
        "连续出牌会触发连击加分！\n每次连击 +15%，不要中断。",
        en: "Consecutive plays trigger combo bonuses!\n+15% per combo, don't break the chain.") }
    static var tutorialShopMsg: String { localized(
        "每隔几关会进入商店。\n购买规则牌和增益道具，打造你的流派！",
        en: "A shop appears every few floors.\nBuy jokers and buffs to build your strategy!") }

    static var tutorialWelcomeTitle: String { localized("🎴 欢迎来到斗破乾坤！", en: "🎴 Welcome to Dou Po Qian Kun!") }
    static var tutorialWelcomeMsg: String { localized(
        "欢迎来到斗破乾坤！这是一款结合斗地主出牌规则的 Roguelike 卡牌冒险。\n\n点击任意位置继续。",
        en: "Welcome to Dou Po Qian Kun! A Roguelike card adventure using Chinese Doudizhu card patterns.\n\nTap anywhere to continue.") }

    static var tutorialGoalTitle: String { localized("🎯 关卡目标", en: "🎯 Floor Goal") }
    static var tutorialGoalMsg: String { localized(
        "每一层有一个目标分数，在有限的出牌次数内达到目标即可过关。",
        en: "Each floor has a target score. Reach it within limited plays to advance.") }

    static var tutorialPatternTitle: String { localized("🃏 牌型基础", en: "🃏 Pattern Basics") }
    static var tutorialPatternMsg: String { localized(
        "出牌规则与斗地主相同：单张、对子、三条、顺子、炸弹等都是合法牌型。不同牌型有不同的基础分。",
        en: "Card patterns follow Doudizhu rules: Single, Pair, Triple, Straight, Bomb, etc. Each pattern has a base score.") }

    static var tutorialBigPatternTitle: String { localized("💡 大牌型得分", en: "💡 Big Patterns") }
    static var tutorialBigPatternMsg: String { localized(
        "💡 大牌型得分更高！炸弹(4张同点) 240分，火箭(双王) 400分，飞机和连对也有丰厚分数。善用大牌型是过关关键！",
        en: "💡 Bigger patterns score more! Bomb (4-of-a-kind) = 240 pts, Rocket (both Jokers) = 400 pts. Using big patterns is key to clearing floors!") }

    static var tutorialSelectTitle: String { localized("👆 选牌与出牌", en: "👆 Select & Play") }
    static var tutorialSelectMsg: String { localized(
        "点击选牌，上方会实时显示牌型和分数。点「出牌」打出。如果选的牌不构成合法牌型，会提示无效。",
        en: "Tap cards to select. The pattern and score appear above. Hit Play to submit. Invalid patterns are flagged.") }

    static var tutorialDiscardTitle: String { localized("♻️ 换牌策略", en: "♻️ Swap Strategy") }
    static var tutorialDiscardMsg: String { localized(
        "不想要的牌可以「换牌」——选中后点换牌按钮，它们会被丢弃并补充新牌。换牌次数有限，请谨慎使用。",
        en: "Use Swap to discard unwanted cards and draw new ones. Swap uses are limited — use wisely.") }

    static var tutorialComboTitle: String { localized("🔥 连击加成", en: "🔥 Combo Bonus") }
    static var tutorialComboMsg: String { localized(
        "连续出牌会形成连击（Combo），每次连击加成 +15%。弃牌会降低连击，所以尽量连续出牌！",
        en: "Consecutive plays build Combo, +15% per level. Discarding reduces combo. Chain plays for max score!") }

    static var tutorialShopTitle: String { localized("🛒 商店与强化", en: "🛒 Shop & Upgrades") }
    static var tutorialShopMsg: String { localized(
        "过关后可以进入商店，用金币购买规则牌和增益道具来强化后续关卡。准备好了吗？开始冒险！",
        en: "After clearing a floor, visit the shop to buy Jokers and Buffs. Ready? Let's go!") }

    // MARK: - 牌型名称
    static var patternSingle: String { localized("单张", en: "Single") }
    static var patternPair: String { localized("对子", en: "Pair") }
    static var patternTriple: String { localized("三条", en: "Triple") }
    static var patternTripleOne: String { localized("三带一", en: "Triple+1") }
    static var patternTriplePair: String { localized("三带二", en: "Full House") }
    static var patternStraight: String { localized("顺子", en: "Straight") }
    static var patternPairStraight: String { localized("连对", en: "Pair Straight") }
    static var patternPlane: String { localized("飞机", en: "Airplane") }
    static var patternPlaneWings: String { localized("飞机带翅膀", en: "Airplane+Wings") }
    static var patternBomb: String { localized("炸弹", en: "Bomb") }
    static var patternRocket: String { localized("火箭", en: "Rocket") }
    static var patternFourTwo: String { localized("四带二", en: "Four+2") }

    // MARK: - 起始流派
    static var buildBalanced: String { localized("稳扎稳打", en: "Balanced") }
    static var buildExplosive: String { localized("炸弹狂人", en: "Bomb Maniac") }
    static var buildCombo: String { localized("连环套", en: "Combo Chain") }

    // MARK: - 图鉴
    static var collection: String { localized("图鉴", en: "Collection") }
    static var patternTab: String { localized("牌型", en: "Patterns") }
    static var achievements: String { localized("成就", en: "Achievements") }
    static var patternGuide: String { localized("牌型参考", en: "Pattern Guide") }
    static var achievementsUnlocked: String { localized("已解锁成就", en: "Achievements Unlocked") }
    static func jokerCount(_ n: Int) -> String { localized("共 \(n) 张规则牌", en: "\(n) Jokers Total") }
    static func buffCount(_ n: Int) -> String { localized("共 \(n) 种增益道具", en: "\(n) Buffs Total") }

    // MARK: - 设置
    static var resetTutorial: String { localized("重置教程", en: "Reset Tutorial") }

    // MARK: - 辅助

    private static func localized(_ zh: String, en: String) -> String {
        isEnglish ? en : zh
    }
}
