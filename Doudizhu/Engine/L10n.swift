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

    // MARK: - 商店
    static var shop: String { localized("商店", en: "Shop") }
    static var jokerSection: String { localized("规则牌", en: "Jokers") }
    static var buffSection: String { localized("增益道具", en: "Buffs") }
    static var leave: String { localized("离开商店", en: "Leave Shop") }
    static var owned: String { localized("已拥有", en: "Owned") }
    static var full: String { localized("已满", en: "Full") }

    // MARK: - 试玩结束
    static var demoOver: String { localized("试玩结束", en: "Demo Over") }
    static var unlockFull: String { localized("解锁完整版", en: "Unlock Full Version") }
    static var restorePurchase: String { localized("恢复购买", en: "Restore Purchase") }

    // MARK: - 教程
    static var skipTutorial: String { localized("跳过教程", en: "Skip Tutorial") }
    static var nextStep: String { localized("下一步 →", en: "Next →") }
    static var startGame: String { localized("开始游戏！", en: "Start!") }

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

    // MARK: - 辅助

    private static func localized(_ zh: String, en: String) -> String {
        isEnglish ? en : zh
    }
}
