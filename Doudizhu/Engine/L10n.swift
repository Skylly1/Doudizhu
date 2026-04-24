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
    static var mapSubtitle: String { localized("穿越 15 层牌局", en: "Cross 15 floors of card battles") }
    static var depart: String { localized("出发", en: "Depart") }
    static func playsLabel(_ n: Int) -> String { localized("\(n)次出牌", en: "\(n) Plays") }
    static func discardsLabel(_ n: Int) -> String { localized("\(n)次换牌", en: "\(n) Swaps") }
    static var mapHighestProgress: String { localized("最高进度", en: "Highest") }
    static func mapHighestFloor(_ n: Int) -> String { localized("最高第\(n)层", en: "Floor \(n)") }
    static func mapTotalRuns(_ n: Int) -> String { localized("\(n)次冒险", en: "\(n) Runs") }
    static func mapHighestScore(_ n: Int) -> String { localized("最高分\(n)", en: "Best \(n)") }

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
    static var exitConfirmTitle: String { localized("确认退出?", en: "Quit Battle?") }
    static var exitConfirmMessage: String { localized("当前进度将丢失", en: "Current progress will be lost") }
    static var exitConfirmContinue: String { localized("继续游戏", en: "Continue") }
    static var exitConfirmQuit: String { localized("退出", en: "Quit") }
    static var selectCardsFirst: String { localized("先点选牌再操作", en: "Select cards first") }
    static var hintSelectCards: String { localized("💡 点选手牌，组成牌型后出牌得分", en: "💡 Tap cards to select, then play to score") }
    static var hintTrySwap: String { localized("💡 不满意手牌？选中后点「换牌」换新牌", en: "💡 Don't like your hand? Select & tap Swap") }
    static var hintPairsWorthMore: String { localized("💡 对子、三条比单张得分更高哦", en: "💡 Pairs & triples score much higher!") }
    static var hintComboBonus: String { localized("🔥 连续出牌会触发连击加成！", en: "🔥 Consecutive plays trigger combo bonus!") }
    static var floorScoreLabel: String { localized("本层得分", en: "Floor Score") }
    static var totalScoreLabel: String { localized("总得分", en: "Total Score") }
    static var goldEarned: String { localized("获得金币", en: "Gold Earned") }
    static var targetScoreLabel: String { localized("目标分数", en: "Target Score") }
    static func floorNumber(_ n: Int) -> String { localized("第 \(n) 层", en: "Floor \(n)") }
    static func comboText(_ combo: Int, bonus: Int) -> String { localized("\(combo) 连击！加成 +\(bonus)%", en: "\(combo) Combo! +\(bonus)% bonus") }
    static func totalScoreValue(_ score: Int) -> String { localized("总分：\(score)", en: "Total: \(score)") }
    static func baseScore(_ score: Int) -> String { localized("基础 \(score) 分", en: "Base \(score) pts") }

    // MARK: - Ascension
    static var ascension: String { localized("挑战等级", en: "Ascension") }
    static func ascensionLevel(_ n: Int) -> String { localized("挑战等级 \(n)", en: "Ascension \(n)") }
    static var ascensionHint: String { localized("通关后解锁更高挑战等级", en: "Clear to unlock higher Ascension") }
    static var highestAscension: String { localized("最高挑战", en: "Highest") }
    
    // MARK: - Boss
    static var bossWarning: String { localized("⚔️ Boss 关", en: "⚔️ Boss Floor") }
    static var bossModifierLabel: String { localized("特殊规则", en: "Special Rules") }
    static var bannedPatternWarning: String { localized("⛔ 已禁用", en: "⛔ Banned") }
    
    // MARK: - 商店刷新
    static var refreshShop: String { localized("🔄 刷新 (-15💰)", en: "🔄 Refresh (-15💰)") }
    static var refreshCost: String { localized("花费15金币刷新商品", en: "Spend 15 gold to refresh items") }
    
    // MARK: - 首屏
    static var quickStart: String { localized("⚡ 快速开战", en: "⚡ Quick Start") }
    static var continueRun: String { localized("▶ 继续冒险", en: "▶ Continue Run") }
    static var dailyChallenge: String { localized("📅 每日挑战", en: "📅 Daily Challenge") }
    static var comingSoon: String { localized("即将推出", en: "Coming Soon") }

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
    static var tutorialPlayTitle: String { localized("出牌", en: "Play Cards") }

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

    // MARK: - Card Pattern Guide
    static func pts(_ n: Int) -> String { localized("\(n) 分", en: "\(n) pts") }
    static func ptsPlus(_ n: Int) -> String { localized("\(n)+ 分", en: "\(n)+ pts") }

    // Section headers
    static var sectionBasicPatterns: String { localized("基础牌型", en: "Basic Patterns") }
    static var sectionComboPatterns: String { localized("组合牌型", en: "Combo Patterns") }
    static var sectionSequencePatterns: String { localized("顺序牌型", en: "Sequence Patterns") }
    static var sectionBombs: String { localized("炸弹类 💥", en: "Bombs 💥") }
    static var sectionStrategy: String { localized("策略要点", en: "Strategy Tips") }

    // Pattern examples
    static var exampleSingle: String { localized("任意一张牌", en: "Any single card") }
    static var examplePair: String { localized("两张相同点数", en: "Two cards of same rank") }
    static var exampleTriple: String { localized("三张相同点数", en: "Three cards of same rank") }
    static var exampleTripleOne: String { localized("三条 + 一张单牌", en: "Triple + one single") }
    static var exampleTriplePair: String { localized("三条 + 一对", en: "Triple + one pair") }
    static var exampleFourTwo: String { localized("四张同点 + 两张单牌", en: "Four of a kind + two singles") }
    static var exampleStraight: String { localized("5+ 张连续单牌 (3-7, 8-Q-K-A 等)", en: "5+ consecutive singles (3-7, 8-Q-K-A etc.)") }
    static var examplePairStraight: String { localized("3+ 连续对子 (33-44-55 等)", en: "3+ consecutive pairs (33-44-55 etc.)") }
    static var examplePlane: String { localized("2+ 连续三条 (333-444 等)", en: "2+ consecutive triples (333-444 etc.)") }
    static var examplePlaneWings: String { localized("飞机 + 等量单牌或对子", en: "Airplane + equal singles or pairs") }
    static var exampleBomb: String { localized("四张相同点数", en: "Four cards of same rank") }
    static var exampleRocket: String { localized("大王 + 小王", en: "Red Joker + Black Joker") }

    // Pattern tips
    static var tipSingle: String { localized("效率最低，尽量避免", en: "Least efficient, avoid if possible") }
    static var tipPair: String { localized("6 分/张", en: "6 pts/card") }
    static var tipTriple: String { localized("6.7 分/张", en: "6.7 pts/card") }
    static var tipTripleOne: String { localized("⭐ 8.75 分/张，性价比高", en: "⭐ 8.75 pts/card, great value") }
    static var tipTriplePair: String { localized("⭐⭐ 10 分/张，推荐！", en: "⭐⭐ 10 pts/card, recommended!") }
    static var tipFourTwo: String { localized("⭐⭐ 25 分/张", en: "⭐⭐ 25 pts/card") }
    static var tipStraight: String { localized("越长越值！不含 2 和王", en: "Longer = more points! No 2s or Jokers") }
    static var tipPairStraight: String { localized("长度奖励", en: "Length bonus") }
    static var tipPlane: String { localized("强力！18.3 分/张", en: "Powerful! 18.3 pts/card") }
    static var tipPlaneWings: String { localized("出完大量牌", en: "Play many cards at once") }
    static var tipBomb: String { localized("⭐⭐⭐ 30 分/张！", en: "⭐⭐⭐ 30 pts/card!") }
    static var tipRocket: String { localized("⭐⭐⭐ 最强！125 分/张", en: "⭐⭐⭐ Strongest! 125 pts/card") }

    // Strategy tips
    static var strategyComboTitle: String { localized("连击加分", en: "Combo Bonus") }
    static var strategyComboDesc: String { localized("连续出牌每次 +15%。换牌会减 1 点连击，不会归零。",
                                                      en: "Consecutive plays +15% each. Discarding reduces combo by 1, doesn't reset.") }
    static var strategyBigTitle: String { localized("出大牌", en: "Play Big") }
    static var strategyBigDesc: String { localized("三带二 > 三带一 > 三条。组合越复杂越值。",
                                                    en: "Full House > Triple+1 > Triple. More complex = more points.") }
    static var strategySaveBombsTitle: String { localized("攒炸弹", en: "Save Bombs") }
    static var strategySaveBombsDesc: String { localized("炸弹 120 分是普通出牌的 10 倍+，值得等！",
                                                          en: "Bomb 120 pts is 10x+ a normal play. Worth saving!") }
    static var strategyJokersTitle: String { localized("规则牌", en: "Joker Cards") }
    static var strategyJokersDesc: String { localized("商店的规则牌能改变玩法规则，不只是加分。",
                                                       en: "Shop Jokers change game rules, not just add points.") }

    // MARK: - 起始流派
    static var buildBalanced: String { localized("稳扎稳打", en: "Balanced") }
    static var buildExplosive: String { localized("炸弹狂人", en: "Bomb Maniac") }
    static var buildCombo: String { localized("连环套", en: "Combo Chain") }
    static var buildPrecision: String { localized("精打细算", en: "Precision") }
    static var buildGreed: String { localized("贪婪商人", en: "Greedy Merchant") }
    static var buildAllIn: String { localized("背水一战", en: "All In") }
    static var buildStraightMaster: String { localized("顺子专家", en: "Straight Master") }
    static var buildDefensive: String { localized("防御大师", en: "Defensive") }
    static var buildGambler: String { localized("赌徒", en: "Gambler") }
    // Descriptions
    static var buildBalancedDesc: String { localized("均衡开局，适合新手。起始多 50 金币。", en: "Balanced start for beginners. +50 gold.") }
    static var buildExplosiveDesc: String { localized("炸弹路线。携带「火烧连营」和「火药桶」。", en: "Bomb build. Starts with Explosive Bonus + Bomb Buff.") }
    static var buildComboDesc: String { localized("连击路线。携带「连环计」（连击翻倍）。", en: "Combo build. Starts with Double Combo Rate.") }
    static var buildPrecisionDesc: String { localized("小牌精准路线。携带「精打细算」。", en: "Small-hand precision with Mini Hand Bonus.") }
    static var buildGreedDesc: String { localized("经济路线。携带「点石成金」，初始金币少。", en: "Economy build. Gold Rush Joker, less starting gold.") }
    static var buildAllInDesc: String { localized("高风险高回报。「破釜沉舟」，只有 80 金币。", en: "High risk. Last Stand Joker, only 80 gold.") }
    static var buildStraightMasterDesc: String { localized("顺子路线。携带「顺势而为」。", en: "Straight build with Sequence Bonus Joker.") }
    static var buildDefensiveDesc: String { localized("防守反击。「暗度陈仓」换牌+2，200金币。", en: "Defensive. Extra Discards +2, 200 gold.") }
    static var buildGamblerDesc: String { localized("命运由天。「赌徒之心」随机±30%，100金币。", en: "Fate decides. Gambler (±30%), 100 gold.") }

    // MARK: - 图鉴
    static var collection: String { localized("图鉴", en: "Collection") }
    static var patternTab: String { localized("牌型", en: "Patterns") }
    static var achievements: String { localized("成就", en: "Achievements") }
    static var statsTab: String { localized("统计", en: "Stats") }
    static var patternGuide: String { localized("牌型参考", en: "Pattern Guide") }
    static var achievementsUnlocked: String { localized("已解锁成就", en: "Achievements Unlocked") }
    static func jokerCount(_ n: Int) -> String { localized("共 \(n) 张规则牌", en: "\(n) Jokers Total") }
    static func buffCount(_ n: Int) -> String { localized("共 \(n) 种增益道具", en: "\(n) Buffs Total") }

    // MARK: - 设置
    static var settingsSound: String { localized("🔊 音效", en: "🔊 Sound") }
    static var settingsSoundEffect: String { localized("音效", en: "Sound Effects") }
    static var settingsVolume: String { localized("音量", en: "Volume") }
    static var settingsMusic: String { localized("背景音乐", en: "Background Music") }
    static var settingsHaptic: String { localized("震动反馈", en: "Haptic Feedback") }
    static var settingsGame: String { localized("🎮 游戏", en: "🎮 Game") }
    static var settingsAbout: String { localized("ℹ️ 关于", en: "ℹ️ About") }
    static var settingsVersion: String { localized("版本", en: "Version") }
    static var settingsEngine: String { localized("引擎", en: "Engine") }
    static var settingsInspiration: String { localized("灵感", en: "Inspiration") }
    static var versionString: String { localized("v1.0 · 斗破乾坤", en: "v1.0 · Dou Po Qian Kun") }
    static var resetTutorial: String { localized("重置教程", en: "Reset Tutorial") }
    static var settingsLanguage: String { localized("🌐 语言", en: "🌐 Language") }
    static var settingsLanguageHint: String { localized("跟随系统语言设置", en: "Follows system language") }
    static var settingsCurrentLang: String { localized("当前：中文", en: "Current: English") }

    // MARK: - 首页
    static func highestAscLabel(_ n: Int) -> String { localized("最高挑战: A\(n)", en: "Highest: A\(n)") }

    // MARK: - 战斗
    static func bannedPatternLabel(_ name: String) -> String { localized("已禁用: \(name)", en: "Banned: \(name)") }
    static func ascensionChallenge(_ n: Int) -> String { localized("挑战 A\(n)", en: "Challenge A\(n)") }

    // MARK: - 试玩特权
    static var featureAllFloors: String { localized("全部 15 层关卡 + 3 大 Boss 挑战", en: "All 15 floors + 3 Boss fights") }
    static var featureAscension: String { localized("挑战等级系统(Ascension) — 10级难度", en: "Ascension system — 10 difficulty levels") }
    static var featureJokers: String { localized("20 张规则牌，无限流派搭配", en: "20 Joker cards, unlimited builds") }
    static var featureLeaderboard: String { localized("排行榜 + 成就系统", en: "Leaderboard + Achievements") }
    static var featureUpdates: String { localized("持续更新：新牌、新关卡、新模式", en: "Ongoing updates: new cards, floors, modes") }

    // MARK: - Joker Rarity
    static var rarityCommon: String { localized("普通", en: "Common") }
    static var rarityRare: String { localized("稀有", en: "Rare") }
    static var rarityLegendary: String { localized("传说", en: "Legendary") }

    // MARK: - Jokers
    static var jokerGreedyName: String { localized("贪心鬼", en: "Greedy Ghost") }
    static var jokerGreedyDesc: String { localized("出牌后从牌堆额外抽1张牌", en: "Draw 1 extra card after playing") }
    static var jokerChainPlotName: String { localized("连环计", en: "Chain Plot") }
    static var jokerChainPlotDesc: String { localized("连击加成翻倍（15%→30%/级）", en: "Combo bonus doubled (15%→30%/level)") }
    static var jokerEmptyFortName: String { localized("空城计", en: "Empty Fort") }
    static var jokerEmptyFortDesc: String { localized("手牌≤5张时，所有得分×1.5", en: "Score ×1.5 when hand ≤5 cards") }
    static var jokerFireBlazeName: String { localized("火烧连营", en: "Blaze Barrage") }
    static var jokerFireBlazeDesc: String { localized("炸弹和火箭得分×2", en: "Bomb & Rocket score ×2") }
    static var jokerRideWaveName: String { localized("顺势而为", en: "Ride the Wave") }
    static var jokerRideWaveDesc: String { localized("顺子和连对得分×2", en: "Straight & Pair Straight score ×2") }
    static var jokerSiegeName: String { localized("四面楚歌", en: "Siege") }
    static var jokerSiegeDesc: String { localized("手牌中每张2或A，得分+10%", en: "+10% score per 2 or A in hand") }
    static var jokerSecretPathName: String { localized("暗度陈仓", en: "Secret Path") }
    static var jokerSecretPathDesc: String { localized("每关换牌次数+2", en: "+2 swaps per floor") }
    static var jokerThunderStrikeName: String { localized("一鸣惊人", en: "Thunderstrike") }
    static var jokerThunderStrikeDesc: String { localized("每关第一次出牌得分×2.5", en: "First play each floor scores ×2.5") }
    static var jokerSwitcherooName: String { localized("偷梁换柱", en: "Switcheroo") }
    static var jokerSwitcherooDesc: String { localized("换牌时多抽1张牌", en: "Draw 1 extra card when swapping") }
    static var jokerLastStandName: String { localized("破釜沉舟", en: "Last Stand") }
    static var jokerLastStandDesc: String { localized("最后1次出牌机会时得分×3", en: "Score ×3 on your final play") }
    static var jokerPairMasteryName: String { localized("成双成对", en: "Perfect Pair") }
    static var jokerPairMasteryDesc: String { localized("对子得分×2", en: "Pair score ×2") }
    static var jokerTripleThreatName: String { localized("三生万物", en: "Triple Threat") }
    static var jokerTripleThreatDesc: String { localized("三带类牌型得分+50%", en: "Triple-type patterns +50%") }
    static var jokerGoldRushName: String { localized("点石成金", en: "Gold Rush") }
    static var jokerGoldRushDesc: String { localized("每次出牌额外获得 5 金币", en: "+5 gold per play") }
    static var jokerSecondWindName: String { localized("回光返照", en: "Second Wind") }
    static var jokerSecondWindDesc: String { localized("每关额外获得 1 次出牌机会", en: "+1 extra play per floor") }
    static var jokerCardCounterName: String { localized("心算如飞", en: "Card Counter") }
    static var jokerCardCounterDesc: String { localized("出牌≥5张时得分+40%", en: "+40% score when playing ≥5 cards") }
    static var jokerLuckyDrawName: String { localized("锦鲤附体", en: "Lucky Koi") }
    static var jokerLuckyDrawDesc: String { localized("换牌改从牌堆底部取（底牌运气更好）", en: "Swap draws from bottom of deck (luckier cards)") }
    static var jokerScoreSurgeName: String { localized("厚积薄发", en: "Score Surge") }
    static var jokerScoreSurgeDesc: String { localized("当前层得分≥目标50%时，出牌+30%", en: "+30% when floor score ≥50% of target") }
    static var jokerMiniHandName: String { localized("精打细算", en: "Precision Play") }
    static var jokerMiniHandDesc: String { localized("出3张及以下的牌型+60%", en: "+60% for patterns of 3 or fewer cards") }
    static var jokerMultiKillName: String { localized("连环杀", en: "Multi Kill") }
    static var jokerMultiKillDesc: String { localized("连击≥3时额外+20%加成", en: "Extra +20% at combo ≥3") }
    static var jokerShieldBreakerName: String { localized("破甲", en: "Shield Breaker") }
    static var jokerShieldBreakerDesc: String { localized("上次出牌≥100分时，本次+25%", en: "+25% if last play scored ≥100") }
    static var jokerCriticalHitName: String { localized("暴击之手", en: "Critical Hit") }
    static var jokerCriticalHitDesc: String { localized("10%概率双倍得分", en: "10% chance to double score") }
    static var jokerInsuranceName: String { localized("保险单", en: "Insurance") }
    static var jokerInsuranceDesc: String { localized("失败时保留50%分数", en: "Keep 50% score on failure") }
    static var jokerCollectorName: String { localized("同花顺缘", en: "Flush Fate") }
    static var jokerCollectorDesc: String { localized("同花色出5张以上+50分", en: "+50 pts for 5+ same-suit cards") }
    static var jokerNightOwlName: String { localized("夜枭", en: "Night Owl") }
    static var jokerNightOwlDesc: String { localized("后半程(8-15关)得分+20%", en: "+20% score in floors 8-15") }
    static var jokerEarlyBirdName: String { localized("先声夺人", en: "Early Bird") }
    static var jokerEarlyBirdDesc: String { localized("每关第一手出牌+100分", en: "+100 pts on first play each floor") }
    static var jokerMiserName: String { localized("守财奴", en: "Miser") }
    static var jokerMiserDesc: String { localized("每持有50金币，得分+5%", en: "+5% score per 50 gold held") }
    static var jokerGamblerName: String { localized("赌徒之心", en: "Gambler's Heart") }
    static var jokerGamblerDesc: String { localized("随机±30%得分（期望+5%）", en: "Random ±30% score (expected +5%)") }
    static var jokerPhoenixName: String { localized("浴火凤凰", en: "Phoenix") }
    static var jokerPhoenixDesc: String { localized("每局游戏可复活一次", en: "Revive once per run") }
    static var jokerDragonName: String { localized("神龙摆尾", en: "Dragon Tail") }
    static var jokerDragonDesc: String { localized("连击达到5时，下一手3倍得分", en: "×3 score after reaching 5-combo") }
    static var jokerTideTurnerName: String { localized("逆转乾坤", en: "Tide Turner") }
    static var jokerTideTurnerDesc: String { localized("得分低于目标30%时，出牌+50%", en: "+50% when score <30% of target") }

    // MARK: - Floors
    static var floor1Name: String { localized("乡野牌局", en: "Village Game") }
    static var floor1Desc: String { localized("村口老槐树下的牌局", en: "A card game under the old village tree") }
    static var floor2Name: String { localized("集市赌坊", en: "Market Gamble") }
    static var floor2Desc: String { localized("赶集路上遇到的牌摊", en: "A card stall at the market") }
    static var floor3Name: String { localized("杂货铺", en: "General Store") }
    static var floor3Desc: String { localized("补充装备，继续上路", en: "Stock up and press on") }
    static var floor4Name: String { localized("茶馆对弈", en: "Teahouse Match") }
    static var floor4Desc: String { localized("茶馆里的老牌手", en: "Veteran players at the teahouse") }
    static var floor5Name: String { localized("县城擂台", en: "County Arena") }
    static var floor5Desc: String { localized("县城里的斗地主擂台", en: "Doudizhu arena in the county") }
    static var floor6Name: String { localized("府衙暗局", en: "Magistrate's Scheme") }
    static var floor6Desc: String { localized("知府大人设下的暗局", en: "A secret game set by the magistrate") }
    static var floor7Name: String { localized("兵器铺", en: "Armory") }
    static var floor7Desc: String { localized("精良的装备等着你", en: "Fine equipment awaits you") }
    static var floor8Name: String { localized("⚔️ 县令挑战", en: "⚔️ Magistrate Boss") }
    static var floor8Desc: String { localized("县令大人的赌局——禁用一种牌型！", en: "The magistrate's gamble — one pattern banned!") }
    static var floor9Name: String { localized("镖局较量", en: "Escort Duel") }
    static var floor9Desc: String { localized("押镖路上遇到的高手", en: "Masters met on the escort road") }
    static var floor10Name: String { localized("武林大会", en: "Martial Summit") }
    static var floor10Desc: String { localized("各路英雄齐聚一堂", en: "Heroes gather from all corners") }
    static var floor11Name: String { localized("藏宝阁", en: "Treasure Vault") }
    static var floor11Desc: String { localized("最后的准备机会", en: "Last chance to prepare") }
    static var floor12Name: String { localized("皇城暗影", en: "Imperial Shadow") }
    static var floor12Desc: String { localized("京城地下赌场", en: "Underground casino in the capital") }
    static var floor13Name: String { localized("⚔️ 太子赌局", en: "⚔️ Prince's Gamble") }
    static var floor13Desc: String { localized("太子的赌局——分数越打越高！", en: "The prince's game — scores escalate!") }
    static var floor14Name: String { localized("藏宝阁·终", en: "Final Vault") }
    static var floor14Desc: String { localized("最后一次强化机会", en: "Last chance to upgrade") }
    static var floor15Name: String { localized("⚔️ 斗破乾坤", en: "⚔️ Final Showdown") }
    static var floor15Desc: String { localized("最终Boss——得分递减+无弃牌！", en: "Final Boss — decaying score + no swaps!") }

    // MARK: - Buffs
    static var buffPowderKegName: String { localized("火药桶", en: "Powder Keg") }
    static var buffPowderKegDesc: String { localized("炸弹得分 +60", en: "Bomb score +60") }
    static var buffSkyRocketName: String { localized("冲天炮", en: "Sky Rocket") }
    static var buffSkyRocketDesc: String { localized("火箭得分 +120", en: "Rocket score +120") }
    static var buffTailwindName: String { localized("顺风车", en: "Tailwind") }
    static var buffTailwindDesc: String { localized("顺子得分 ×2", en: "Straight score ×2") }
    static var buffAirParadeName: String { localized("大阅兵", en: "Air Parade") }
    static var buffAirParadeDesc: String { localized("飞机得分 ×2.5", en: "Airplane score ×2.5") }
    static var buffDoubleCharmName: String { localized("翻倍符", en: "Double Charm") }
    static var buffDoubleCharmDesc: String { localized("全局得分 ×1.5", en: "All scores ×1.5") }
    static var buffFortuneGodName: String { localized("财神爷", en: "Fortune God") }
    static var buffFortuneGodDesc: String { localized("全局得分 ×1.3", en: "All scores ×1.3") }
    static var buffDoubleBlastName: String { localized("双响炮", en: "Double Blast") }
    static var buffDoubleBlastDesc: String { localized("炸弹得分 +100", en: "Bomb score +100") }
    static var buffIronChainName: String { localized("铁索连舟", en: "Iron Chain") }
    static var buffIronChainDesc: String { localized("顺子得分 ×2.5", en: "Straight score ×2.5") }
    static var buffSkyFortressName: String { localized("空中堡垒", en: "Sky Fortress") }
    static var buffSkyFortressDesc: String { localized("飞机得分 ×3", en: "Airplane score ×3") }
    static var buffDivineTouchName: String { localized("神来之手", en: "Divine Touch") }
    static var buffDivineTouchDesc: String { localized("全局得分 ×2", en: "All scores ×2") }

    // MARK: - 每日挑战
    static var dailyChallengeTitle: String { localized("每日挑战", en: "Daily Challenge") }
    static var dailyChallengeSubtitle: String { localized("每日限定规则，全服同种子", en: "Daily rules, same seed for all") }
    static var todayModifiers: String { localized("今日规则", en: "Today's Rules") }
    static var rewardMultiplier: String { localized("奖励倍率", en: "Reward Multiplier") }
    static var bonusGoldLabel: String { localized("额外金币", en: "Bonus Gold") }
    static var startDailyChallenge: String { localized("开始每日挑战", en: "Start Daily Challenge") }
    static var dailyChallengeCompleted: String { localized("今日已完成", en: "Completed Today") }
    static func dailyBestScore(_ n: Int) -> String { localized("今日最高分: \(n)", en: "Today's Best: \(n)") }
    static var dailyChallengeNoBombs: String { localized("禁止使用炸弹和火箭", en: "Bombs and Rockets are banned") }
    static var dailyChallengeNoDiscards: String { localized("禁止换牌", en: "Discards are disabled") }

    // MARK: - 空状态
    static var emptyStats: String { localized("开始你的第一次冒险吧！", en: "Start your first adventure!") }
    static var emptyAchievements: String { localized("还没有解锁成就，继续冒险吧！", en: "No achievements yet. Keep adventuring!") }
    static var shopRestocking: String { localized("商店正在补货...", en: "Shop is restocking...") }

    // MARK: - 辅助

    private static func localized(_ zh: String, en: String) -> String {
        isEnglish ? en : zh
    }
}
