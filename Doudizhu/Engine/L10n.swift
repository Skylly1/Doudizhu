import Foundation

/// 本地化字符串管理器 — 支持 8 种语言
/// zh 中文 · en 英文 · ja 日本語 · ko 한국어 · fr Français · de Deutsch · es Español · pt Português
enum L10n {

    // MARK: - 语言检测

    enum Language: String, CaseIterable {
        case zh, en, ja, ko, fr, de, es, pt
    }

    /// 当前语言（跟随系统设置，启动时确定一次）
    static let currentLanguage: Language = {
        guard let code = Locale.current.language.languageCode?.identifier else { return .en }
        return Language(rawValue: code) ?? .en
    }()

    /// 非中文环境统一回退英文（兼容 inline 三元表达式）
    static var isEnglish: Bool { currentLanguage != .zh }

    // MARK: - 通用
    static var appName: String { localized("斗破乾坤", en: "Dou Po Qian Kun") }
    static var appSubtitle: String { localized("肉鸽牌局 · 乾坤一掷", en: "Roguelike Dou Di Zhu", ja: "ローグライク闘地主", ko: "로그라이크 더우디주", fr: "Dou Di Zhu Roguelike", de: "Roguelike Dou Di Zhu", es: "Dou Di Zhu Roguelike", pt: "Dou Di Zhu Roguelike") }
    static var back: String { localized("返回", en: "Back", ja: "戻る", ko: "뒤로", fr: "Retour", de: "Zurück", es: "Volver", pt: "Voltar") }
    static var confirm: String { localized("确认", en: "Confirm", ja: "確認", ko: "확인", fr: "Confirmer", de: "Bestätigen", es: "Confirmar", pt: "Confirmar") }
    static var cancel: String { localized("取消", en: "Cancel", ja: "キャンセル", ko: "취소", fr: "Annuler", de: "Abbrechen", es: "Cancelar", pt: "Cancelar") }

    // MARK: - 主菜单
    static var startAdventure: String { localized("开始冒险", en: "Start Adventure", ja: "冒険開始", ko: "모험 시작", fr: "Commencer", de: "Abenteuer starten", es: "Iniciar aventura", pt: "Iniciar aventura") }
    static var cardCollection: String { localized("卡牌收藏", en: "Card Collection", ja: "カード図鑑", ko: "카드 컬렉션", fr: "Collection", de: "Kartensammlung", es: "Colección", pt: "Coleção") }
    static var settings: String { localized("设置", en: "Settings", ja: "設定", ko: "설정", fr: "Paramètres", de: "Einstellungen", es: "Ajustes", pt: "Configurações") }
    static var chooseBuild: String { localized("选择流派", en: "Choose Build", ja: "ビルド選択", ko: "빌드 선택", fr: "Choisir un build", de: "Build wählen", es: "Elegir estilo", pt: "Escolher estilo") }
    static var buildHint: String { localized("不同流派影响你的起始装备和金币",
                                              en: "Different builds affect your starting gear and gold",
                                              ja: "ビルドにより初期装備とゴールドが変化",
                                              ko: "빌드에 따라 시작 장비와 골드가 달라집니다",
                                              fr: "Chaque build change l'équipement et l'or de départ",
                                              de: "Builds beeinflussen Startausrüstung und Gold",
                                              es: "Cada estilo cambia equipo y oro inicial",
                                              pt: "Cada estilo muda equipamento e ouro inicial") }

    // MARK: - 地图
    static var adventurePath: String { localized("冒险之路", en: "Adventure Path") }
    static var mapSubtitle: String { localized("穿越 15 层牌局", en: "Cross 15 floors of card battles") }
    static var depart: String { localized("出发", en: "Depart") }
    static func playsLabel(_ n: Int) -> String { localized("\(n)次出牌", en: n == 1 ? "1 Play" : "\(n) Plays") }
    static func discardsLabel(_ n: Int) -> String { localized("\(n)次换牌", en: n == 1 ? "1 Swap" : "\(n) Swaps") }
    static var mapHighestProgress: String { localized("最高进度", en: "Highest") }
    static func mapHighestFloor(_ n: Int) -> String { localized("最高第\(n)层", en: "Floor \(n)") }
    static func mapTotalRuns(_ n: Int) -> String { localized("\(n)次冒险", en: n == 1 ? "1 Run" : "\(n) Runs") }
    static func mapHighestScore(_ n: Int) -> String { localized("最高分\(n)", en: "Best \(n)") }

    // MARK: - 战斗
    static var play: String { localized("出牌", en: "Play", ja: "出す", ko: "내기", fr: "Jouer", de: "Spielen", es: "Jugar", pt: "Jogar") }
    static var swap: String { localized("换牌", en: "Swap", ja: "交換", ko: "교환", fr: "Échanger", de: "Tauschen", es: "Cambiar", pt: "Trocar") }
    static var floor: String { localized("层", en: "Floor", ja: "階", ko: "층", fr: "Étage", de: "Etage", es: "Piso", pt: "Andar") }
    static var combo: String { localized("连击", en: "Combo", ja: "コンボ", ko: "콤보", fr: "Combo", de: "Combo", es: "Combo", pt: "Combo") }
    static var cleared: String { localized("过关！", en: "Cleared!", ja: "クリア！", ko: "클리어!", fr: "Réussi !", de: "Geschafft!", es: "¡Superado!", pt: "Passou!") }
    static var failed: String { localized("失败", en: "Failed", ja: "失敗", ko: "실패", fr: "Échoué", de: "Gescheitert", es: "Fallido", pt: "Falhou") }
    static var victory: String { localized("通关！", en: "Victory!", ja: "勝利！", ko: "승리!", fr: "Victoire !", de: "Sieg!", es: "¡Victoria!", pt: "Vitória!") }
    static var continueForward: String { localized("继续前进 →", en: "Continue →", ja: "進む →", ko: "계속 →", fr: "Continuer →", de: "Weiter →", es: "Continuar →", pt: "Continuar →") }
    static var restart: String { localized("重新开始", en: "Restart", ja: "やり直す", ko: "다시 시작", fr: "Recommencer", de: "Neustart", es: "Reiniciar", pt: "Reiniciar") }
    static var backToMenu: String { localized("返回主菜单", en: "Back to Menu", ja: "メニューへ", ko: "메뉴로", fr: "Menu principal", de: "Hauptmenü", es: "Menú principal", pt: "Menu principal") }
    static var targetNotReached: String { localized("未达到目标分数", en: "Target score not reached", ja: "目標スコア未達成", ko: "목표 점수 미달", fr: "Score cible non atteint", de: "Zielpunktzahl nicht erreicht", es: "Objetivo no alcanzado", pt: "Pontuação não atingida") }
    static var bossDefeated: String { localized("你击败了恶霸地主！", en: "You defeated the Landlord!", ja: "地主を倒した！", ko: "지주를 물리쳤다!", fr: "Vous avez vaincu le Boss !", de: "Du hast den Boss besiegt!", es: "¡Derrotaste al jefe!", pt: "Você derrotou o chefe!") }
    static var playAgain: String { localized("再来一局", en: "Play Again", ja: "もう一回", ko: "다시 하기", fr: "Rejouer", de: "Nochmal", es: "Jugar de nuevo", pt: "Jogar de novo") }
    static var achievementUnlocked: String { localized("成就解锁", en: "Achievement Unlocked", ja: "実績解除", ko: "업적 달성", fr: "Succès débloqué", de: "Erfolg freigeschaltet", es: "Logro desbloqueado", pt: "Conquista desbloqueada") }
    static var invalidPattern: String { localized("无效牌型", en: "Invalid Pattern", ja: "無効な役", ko: "무효 패턴", fr: "Invalide", de: "Ungültiges Muster", es: "Patrón inválido", pt: "Padrão inválido") }
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
    static var quickStart: String { localized("快速开战", en: "Quick Start", ja: "クイックスタート", ko: "빠른 시작", fr: "Partie rapide", de: "Schnellstart", es: "Inicio rápido", pt: "Início rápido") }
    static var continueRun: String { localized("继续冒险", en: "Continue Run", ja: "冒険を続ける", ko: "모험 계속", fr: "Continuer", de: "Weiter spielen", es: "Continuar", pt: "Continuar") }
    static var dailyChallenge: String { localized("每日挑战", en: "Daily Challenge", ja: "デイリーチャレンジ", ko: "일일 도전", fr: "Défi du jour", de: "Tägliche Herausforderung", es: "Desafío diario", pt: "Desafio diário") }
    static var comingSoon: String { localized("即将推出", en: "Coming Soon", ja: "近日公開", ko: "곧 출시", fr: "Bientôt", de: "Demnächst", es: "Próximamente", pt: "Em breve") }

    // MARK: - 商店
    static var shop: String { localized("商店", en: "Shop", ja: "ショップ", ko: "상점", fr: "Boutique", de: "Shop", es: "Tienda", pt: "Loja") }
    static var jokerSection: String { localized("规则牌", en: "Jokers", ja: "ジョーカー", ko: "조커", fr: "Jokers", de: "Joker", es: "Jokers", pt: "Jokers") }
    static var buffSection: String { localized("增益道具", en: "Buffs", ja: "バフ", ko: "버프", fr: "Bonus", de: "Buffs", es: "Mejoras", pt: "Bônus") }
    static var leave: String { localized("离开商店", en: "Leave Shop", ja: "ショップを出る", ko: "상점 나가기", fr: "Quitter", de: "Verlassen", es: "Salir", pt: "Sair") }
    static var owned: String { localized("已拥有", en: "Owned", ja: "所持中", ko: "보유", fr: "Possédé", de: "Besitzt", es: "Poseído", pt: "Possuído") }
    static var full: String { localized("已满", en: "Full", ja: "満杯", ko: "가득", fr: "Plein", de: "Voll", es: "Lleno", pt: "Cheio") }
    static var shopSubtitle: String { localized("选购规则牌与增益道具", en: "Browse jokers and buffs", ja: "ジョーカーとバフを探索", ko: "조커와 버프 구매", fr: "Parcourez jokers et bonus", de: "Joker und Buffs durchsuchen", es: "Busca jokers y mejoras", pt: "Explore jokers e bônus") }
    static var gold: String { localized("金币", en: "Gold", ja: "ゴールド", ko: "골드", fr: "Or", de: "Gold", es: "Oro", pt: "Ouro") }
    static var soldOut: String { localized("已售罄", en: "Sold Out", ja: "売り切れ", ko: "품절", fr: "Épuisé", de: "Ausverkauft", es: "Agotado", pt: "Esgotado") }
    static var equippedJokers: String { localized("已装备规则牌", en: "Equipped Jokers", ja: "装備中のジョーカー", ko: "장착된 조커", fr: "Jokers équipés", de: "Ausgerüstete Joker", es: "Jokers equipados", pt: "Jokers equipados") }
    static var equippedBuffs: String { localized("已装备增益", en: "Equipped Buffs", ja: "装備中のバフ", ko: "장착된 버프", fr: "Bonus équipés", de: "Ausgerüstete Buffs", es: "Mejoras equipadas", pt: "Bônus equipados") }

    // MARK: - 试玩结束
    static var demoOver: String { localized("试玩结束", en: "Trial Complete") }
    static var unlockFull: String { localized("解锁完整版", en: "Unlock Full Version") }
    static var restorePurchase: String { localized("恢复购买", en: "Restore Purchase") }
    static var demoDescription: String { localized("你已经体验了乡野篇的精彩牌局！\n更刺激的府城暗局和江湖争霸在等着你。",
                                                    en: "You've conquered the Village chapter!\nMore intense battles await in City and Martial arcs.") }
    static func unlockFullPrice(_ price: String) -> String { localized("解锁完整版 — \(price)", en: "Unlock Full — \(price)") }

    // MARK: - 教程
    static var skipTutorial: String { localized("跳过", en: "Skip", ja: "スキップ", ko: "건너뛰기", fr: "Passer", de: "Überspringen", es: "Saltar", pt: "Pular") }
    static var nextStep: String { localized("下一步 →", en: "Next →", ja: "次へ →", ko: "다음 →", fr: "Suivant →", de: "Weiter →", es: "Siguiente →", pt: "Próximo →") }
    static var startGame: String { localized("开始！", en: "Start!", ja: "開始！", ko: "시작!", fr: "C'est parti !", de: "Los!", es: "¡Empezar!", pt: "Começar!") }
    static var tutorialPlayTitle: String { localized("出牌", en: "Play Cards", ja: "カードを出す", ko: "카드 내기", fr: "Jouer", de: "Karten spielen", es: "Jugar cartas", pt: "Jogar cartas") }

    static var tutorialWelcomeTitle: String { localized(
        "🎴 欢迎来到斗破乾坤！",
        en: "🎴 Welcome to Dou Po Qian Kun!",
        ja: "🎴 斗破乾坤へようこそ！",
        ko: "🎴 투파건곤에 오신 것을 환영합니다!",
        fr: "🎴 Bienvenue dans Dou Po Qian Kun !",
        de: "🎴 Willkommen bei Dou Po Qian Kun!",
        es: "🎴 ¡Bienvenido a Dou Po Qian Kun!",
        pt: "🎴 Bem-vindo ao Dou Po Qian Kun!") }
    static var tutorialWelcomeMsg: String { localized(
        "斗地主 × 肉鸽冒险\n打出牌型得分，收集强化，击败最终地主！",
        en: "Doudizhu × Roguelike Adventure\nPlay patterns to score, collect upgrades, defeat the Landlord!",
        ja: "闘地主 × ローグライク冒険\n役を出して得点、強化を集めて地主を倒せ！",
        ko: "더우디주 × 로그라이크 모험\n패를 내어 점수 획득, 강화 수집, 지주를 처치!",
        fr: "Doudizhu × Roguelike\nJouez des combinaisons, collectez des améliorations, battez le Boss !",
        de: "Doudizhu × Roguelike\nSpiele Kartenmuster, sammle Upgrades, besiege den Boss!",
        es: "Doudizhu × Roguelike\n¡Juega combinaciones, colecciona mejoras y vence al jefe!",
        pt: "Doudizhu × Roguelike\nJogue combinações, colete melhorias e derrote o chefe!") }

    static var tutorialGoalTitle: String { localized("🎯 关卡目标", en: "🎯 Floor Goal", ja: "🎯 フロア目標", ko: "🎯 층 목표", fr: "🎯 Objectif", de: "🎯 Etagen-Ziel", es: "🎯 Objetivo", pt: "🎯 Objetivo") }
    static var tutorialGoalMsg: String { localized(
        "每层有目标分，出牌次数有限\n合理搭配，精准过关",
        en: "Each floor has a target score with limited plays\nPlan wisely to clear each floor",
        ja: "各フロアに目標スコアとプレイ回数制限\n計画的にクリアしよう",
        ko: "각 층마다 목표 점수와 제한된 플레이 횟수\n전략적으로 클리어하세요",
        fr: "Chaque étage a un score cible et des coups limités\nPlanifiez bien pour réussir",
        de: "Jede Etage hat eine Zielpunktzahl mit begrenzten Zügen\nPlane klug!",
        es: "Cada piso tiene puntuación objetivo y jugadas limitadas\n¡Planifica bien!",
        pt: "Cada andar tem pontuação alvo e jogadas limitadas\nPlaneje bem!") }

    static var tutorialPatternTitle: String { localized("🃏 牌型基础", en: "🃏 Pattern Basics", ja: "🃏 役の基本", ko: "🃏 패턴 기초", fr: "🃏 Combinaisons", de: "🃏 Muster-Grundlagen", es: "🃏 Patrones básicos", pt: "🃏 Padrões básicos") }
    static var tutorialPatternMsg: String { localized(
        "单张 → 对子 → 三条 → 顺子 → 炸弹\n牌型越大，得分越高！",
        en: "Single → Pair → Triple → Straight → Bomb\nBigger patterns = higher scores!",
        ja: "シングル → ペア → トリプル → ストレート → ボム\n大きな役ほど高得点！",
        ko: "싱글 → 페어 → 트리플 → 스트레이트 → 폭탄\n큰 패턴 = 높은 점수!",
        fr: "Simple → Paire → Brelan → Suite → Bombe\nPlus c'est gros, plus ça rapporte !",
        de: "Einzel → Paar → Drilling → Straße → Bombe\nGrößere Muster = mehr Punkte!",
        es: "Simple → Par → Trío → Escalera → Bomba\n¡Más grande = más puntos!",
        pt: "Simples → Par → Trinca → Sequência → Bomba\nMaiores = mais pontos!") }

    static var tutorialBigPatternTitle: String { localized("💡 大牌型得分", en: "💡 Big Patterns", ja: "💡 大きな役", ko: "💡 큰 패턴", fr: "💡 Gros motifs", de: "💡 Große Muster", es: "💡 Patrones grandes", pt: "💡 Padrões grandes") }
    static var tutorialBigPatternMsg: String { localized(
        "炸弹 240分 · 火箭 400分\n大牌型是通关关键！",
        en: "Bomb 240 pts · Rocket 400 pts\nBig patterns are key to victory!",
        ja: "ボム 240点 · ロケット 400点\n大きな役がクリアの鍵！",
        ko: "폭탄 240점 · 로켓 400점\n큰 패턴이 클리어의 열쇠!",
        fr: "Bombe 240 pts · Fusée 400 pts\nLes gros motifs sont la clé !",
        de: "Bombe 240 Pkt · Rakete 400 Pkt\nGroße Muster sind der Schlüssel!",
        es: "Bomba 240 pts · Cohete 400 pts\n¡Los patrones grandes son la clave!",
        pt: "Bomba 240 pts · Foguete 400 pts\nPadrões grandes são a chave!") }

    static var tutorialSelectTitle: String { localized("👆 选牌出牌", en: "👆 Select & Play", ja: "👆 選んで出す", ko: "👆 선택 & 플레이", fr: "👆 Choisir & Jouer", de: "👆 Wählen & Spielen", es: "👆 Elegir y jugar", pt: "👆 Escolher e jogar") }
    static var tutorialSelectMsg: String { localized(
        "点牌选中，点「出牌」打出\n上方实时预览牌型和分数",
        en: "Tap cards to select, tap Play to submit\nPattern and score preview shown above",
        ja: "カードをタップで選択、「出す」で提出\n上部に役とスコアをプレビュー",
        ko: "카드를 탭하여 선택, 내기 탭으로 제출\n위에서 패턴과 점수 미리보기",
        fr: "Touchez pour sélectionner, puis Jouer\nAperçu du motif et du score en haut",
        de: "Tippe zum Auswählen, dann Spielen\nMuster und Punkte oben angezeigt",
        es: "Toca para seleccionar, luego Jugar\nVista previa de patrón y puntos arriba",
        pt: "Toque para selecionar, depois Jogar\nPrevisão do padrão e pontos acima") }

    static var tutorialDiscardTitle: String { localized("♻️ 换牌策略", en: "♻️ Swap Strategy", ja: "♻️ 交換の戦略", ko: "♻️ 교환 전략", fr: "♻️ Stratégie d'échange", de: "♻️ Tausch-Strategie", es: "♻️ Estrategia de cambio", pt: "♻️ Estratégia de troca") }
    static var tutorialDiscardMsg: String { localized(
        "选中不要的牌，点「换牌」换新牌\n次数有限，谨慎使用",
        en: "Select unwanted cards, tap Swap to draw new ones\nLimited uses — spend wisely",
        ja: "不要なカードを選び「交換」をタップ\n回数制限あり — 慎重に使おう",
        ko: "필요없는 카드 선택 후 교환 탭\n횟수 제한 — 신중하게 사용",
        fr: "Sélectionnez les cartes à échanger, puis Échanger\nUtilisations limitées — choisissez bien",
        de: "Ungewünschte Karten wählen, dann Tauschen\nBegrenzte Nutzung — weise einsetzen",
        es: "Selecciona cartas no deseadas, toca Cambiar\nUsos limitados — úsalos bien",
        pt: "Selecione cartas indesejadas, toque Trocar\nUsos limitados — use com sabedoria") }

    static var tutorialComboTitle: String { localized("🔥 连击加成", en: "🔥 Combo Bonus", ja: "🔥 コンボボーナス", ko: "🔥 콤보 보너스", fr: "🔥 Bonus Combo", de: "🔥 Combo-Bonus", es: "🔥 Bonus Combo", pt: "🔥 Bônus Combo") }
    static var tutorialComboMsg: String { localized(
        "连续出牌触发连击，每次 +15%\n换牌打断连击，合理取舍！",
        en: "Chain plays trigger combo, +15% each\nSwapping breaks combo — balance wisely!",
        ja: "連続プレイでコンボ発動、毎回 +15%\n交換でコンボ中断 — 慎重に！",
        ko: "연속 플레이로 콤보 발동, 매회 +15%\n교환은 콤보 중단 — 신중하게!",
        fr: "Enchaînez pour un combo, +15% par coup\nÉchanger interrompt le combo !",
        de: "Kettenspiele lösen Combo aus, +15% pro Zug\nTauschen unterbricht Combo!",
        es: "Encadena jugadas para combo, +15% cada vez\n¡Cambiar rompe el combo!",
        pt: "Jogadas em cadeia ativam combo, +15% cada\nTrocar quebra o combo!") }

    static var tutorialShopTitle: String { localized("🛒 商店强化", en: "🛒 Shop & Upgrades", ja: "🛒 ショップと強化", ko: "🛒 상점 & 강화", fr: "🛒 Boutique", de: "🛒 Shop & Upgrades", es: "🛒 Tienda y mejoras", pt: "🛒 Loja e melhorias") }
    static var tutorialShopMsg: String { localized(
        "过关后进入商店\n用金币购买规则牌和增益，越打越强！",
        en: "Visit the shop between floors\nBuy Jokers and Buffs with gold — get stronger!",
        ja: "フロア間でショップへ\nゴールドでジョーカーとバフを購入して強化！",
        ko: "층 사이에 상점 방문\n골드로 조커와 버프 구매 — 더 강해지세요!",
        fr: "Visitez la boutique entre les étages\nAchetez Jokers et Bonus avec de l'or !",
        de: "Besuche den Shop zwischen Etagen\nKaufe Joker und Buffs mit Gold!",
        es: "Visita la tienda entre pisos\n¡Compra Jokers y Mejoras con oro!",
        pt: "Visite a loja entre andares\nCompre Jokers e Bônus com ouro!") }

    // MARK: - 牌型名称
    static var patternSingle: String { localized("单张", en: "Single", ja: "シングル", ko: "싱글", fr: "Simple", de: "Einzel", es: "Simple", pt: "Simples") }
    static var patternPair: String { localized("对子", en: "Pair", ja: "ペア", ko: "페어", fr: "Paire", de: "Paar", es: "Par", pt: "Par") }
    static var patternTriple: String { localized("三条", en: "Triple", ja: "トリプル", ko: "트리플", fr: "Brelan", de: "Drilling", es: "Trío", pt: "Trinca") }
    static var patternTripleOne: String { localized("三带一", en: "Triple+1", ja: "トリプル+1", ko: "트리플+1", fr: "Brelan+1", de: "Drilling+1", es: "Trío+1", pt: "Trinca+1") }
    static var patternTriplePair: String { localized("三带二", en: "Full House", ja: "フルハウス", ko: "풀하우스", fr: "Full", de: "Full House", es: "Full", pt: "Full House") }
    static var patternStraight: String { localized("顺子", en: "Straight", ja: "ストレート", ko: "스트레이트", fr: "Suite", de: "Straße", es: "Escalera", pt: "Sequência") }
    static var patternPairStraight: String { localized("连对", en: "Pair Straight", ja: "連ペア", ko: "연속 페어", fr: "Suite de paires", de: "Paarstraße", es: "Escalera doble", pt: "Sequência dupla") }
    static var patternPlane: String { localized("飞机", en: "Airplane", ja: "飛行機", ko: "비행기", fr: "Avion", de: "Flugzeug", es: "Avión", pt: "Avião") }
    static var patternPlaneWings: String { localized("飞机带翅膀", en: "Airplane+Wings", ja: "飛行機+翼", ko: "비행기+날개", fr: "Avion+Ailes", de: "Flugzeug+Flügel", es: "Avión+Alas", pt: "Avião+Asas") }
    static var patternBomb: String { localized("炸弹", en: "Bomb", ja: "ボム", ko: "폭탄", fr: "Bombe", de: "Bombe", es: "Bomba", pt: "Bomba") }
    static var patternRocket: String { localized("火箭", en: "Rocket", ja: "ロケット", ko: "로켓", fr: "Fusée", de: "Rakete", es: "Cohete", pt: "Foguete") }
    static var patternFourTwo: String { localized("四带二", en: "Four+2", ja: "フォー+2", ko: "포+2", fr: "Carré+2", de: "Vierer+2", es: "Cuatro+2", pt: "Quadra+2") }

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
    static var collection: String { localized("图鉴", en: "Collection", ja: "図鑑", ko: "도감", fr: "Collection", de: "Sammlung", es: "Colección", pt: "Coleção") }
    static var patternTab: String { localized("牌型", en: "Patterns", ja: "役", ko: "패턴", fr: "Motifs", de: "Muster", es: "Patrones", pt: "Padrões") }
    static var achievements: String { localized("成就", en: "Achievements", ja: "実績", ko: "업적", fr: "Succès", de: "Erfolge", es: "Logros", pt: "Conquistas") }
    static var statsTab: String { localized("统计", en: "Stats", ja: "統計", ko: "통계", fr: "Stats", de: "Statistiken", es: "Estadísticas", pt: "Estatísticas") }
    static var patternGuide: String { localized("牌型参考", en: "Pattern Guide", ja: "役ガイド", ko: "패턴 가이드", fr: "Guide", de: "Muster-Guide", es: "Guía", pt: "Guia") }
    static var achievementsUnlocked: String { localized("已解锁成就", en: "Achievements Unlocked") }
    static func jokerCount(_ n: Int) -> String { localized("共 \(n) 张规则牌", en: n == 1 ? "1 Joker Total" : "\(n) Jokers Total") }
    static func buffCount(_ n: Int) -> String { localized("共 \(n) 种增益道具", en: n == 1 ? "1 Buff Total" : "\(n) Buffs Total") }

    // MARK: - 设置
    static var settingsSound: String { localized("音效", en: "Sound", ja: "サウンド", ko: "사운드", fr: "Son", de: "Sound", es: "Sonido", pt: "Som") }
    static var settingsSoundEffect: String { localized("音效", en: "Sound Effects", ja: "効果音", ko: "효과음", fr: "Effets sonores", de: "Soundeffekte", es: "Efectos de sonido", pt: "Efeitos sonoros") }
    static var settingsVolume: String { localized("音量", en: "Volume", ja: "音量", ko: "음량", fr: "Volume", de: "Lautstärke", es: "Volumen", pt: "Volume") }
    static var settingsMusic: String { localized("背景音乐", en: "Background Music", ja: "BGM", ko: "배경음악", fr: "Musique", de: "Musik", es: "Música", pt: "Música") }
    static var settingsHaptic: String { localized("震动反馈", en: "Haptic Feedback", ja: "触覚フィードバック", ko: "햅틱 피드백", fr: "Retour haptique", de: "Haptisches Feedback", es: "Vibración", pt: "Vibração") }
    static var settingsGame: String { localized("游戏", en: "Game", ja: "ゲーム", ko: "게임", fr: "Jeu", de: "Spiel", es: "Juego", pt: "Jogo") }
    static var settingsAbout: String { localized("关于", en: "About", ja: "情報", ko: "정보", fr: "À propos", de: "Über", es: "Acerca de", pt: "Sobre") }
    static var settingsVersion: String { localized("版本", en: "Version") }
    static var settingsEngine: String { localized("引擎", en: "Engine") }
    static var settingsInspiration: String { localized("灵感来源", en: "Inspiration") }
    static var versionString: String { localized("v1.0 · 斗破乾坤", en: "v1.0 · Dou Po Qian Kun") }
    static var resetTutorial: String { localized("重置教程", en: "Reset Tutorial") }
    static var settingsLanguage: String { localized("语言", en: "Language") }
    static var settingsLanguageHint: String { localized("跟随系统语言设置", en: "Follows system language") }
    static var settingsCurrentLang: String {
        localized("当前：中文", en: "Current: English", ja: "現在：日本語", ko: "현재: 한국어", fr: "Actuel : Français", de: "Aktuell: Deutsch", es: "Actual: Español", pt: "Atual: Português")
    }

    // MARK: - 首页
    static func highestAscLabel(_ n: Int) -> String { localized("最高挑战: A\(n)", en: "Highest: A\(n)") }

    // MARK: - 战斗
    static func bannedPatternLabel(_ name: String) -> String { localized("已禁用: \(name)", en: "Banned: \(name)") }
    static func ascensionChallenge(_ n: Int) -> String { localized("挑战 A\(n)", en: "Challenge A\(n)") }

    // MARK: - 试玩特权
    static var featureAllFloors: String { localized("全部 15 层关卡 + 3 大 Boss 挑战", en: "All 15 floors + 3 Boss fights") }
    static var featureAscension: String { localized("挑战等级系统 — 10 级难度", en: "Ascension system — 10 difficulty levels") }
    static var featureJokers: String {
        let count = Joker.allJokers.count
        return localized("\(count) 张规则牌 · 9 种流派 · 无限搭配", en: "\(count) Jokers · 9 Builds · Infinite combos")
    }
    static var featureLeaderboard: String { localized("排行榜 + 17 项成就", en: "Leaderboard + 17 Achievements") }
    static var featureUpdates: String { localized("买断制永久拥有 · 持续免费更新", en: "One-time purchase · Free updates forever") }

    // 付费墙 — 情感锚点
    static var demoGateTrialSummary: String { localized("你的试玩成绩", en: "Your Trial Stats") }
    static func demoGateFloorsCleared(_ n: Int) -> String { localized("闯过 \(n) 层", en: n == 1 ? "1 Floor Cleared" : "\(n) Floors Cleared") }
    static func demoGateBestScore(_ n: Int) -> String { localized("最高得分 \(n)", en: "Best Score: \(n)") }
    static func demoGateBestCombo(_ n: Int) -> String { localized("最长连击 ×\(n)", en: "Best Combo: ×\(n)") }
    static var demoGateWhatsNext: String { localized("接下来的冒险", en: "What's Next") }
    static var demoGateDailyFree: String { localized("每日挑战免费畅玩", en: "Daily Challenge is always free") }

    // MARK: - Joker Rarity
    static var rarityCommon: String { localized("普通", en: "Common", ja: "ノーマル", ko: "일반", fr: "Commun", de: "Gewöhnlich", es: "Común", pt: "Comum") }
    static var rarityRare: String { localized("稀有", en: "Rare", ja: "レア", ko: "희귀", fr: "Rare", de: "Selten", es: "Raro", pt: "Raro") }
    static var rarityLegendary: String { localized("传说", en: "Legendary", ja: "伝説", ko: "전설", fr: "Légendaire", de: "Legendär", es: "Legendario", pt: "Lendário") }

    // MARK: - Jokers
    static var jokerGreedyName: String { localized("贪心鬼", en: "Greedy Ghost") }
    static var jokerGreedyDesc: String { localized("出牌后从牌堆额外抽1张牌", en: "Draw 1 extra card after playing") }
    static var jokerChainPlotName: String { localized("连环计", en: "Chain Plot") }
    static var jokerChainPlotDesc: String { localized("连击加成翻倍（15%→30%/级）", en: "Combo bonus doubled (15%→30%/level)") }
    static var jokerEmptyFortName: String { localized("空城计", en: "Empty Fort") }
    static var jokerEmptyFortDesc: String { localized("手牌≤5张时，所有得分×1.5", en: "Score ×1.5 when hand ≤5 cards") }
    static var jokerFireBlazeName: String { localized("火烧连营", en: "Blaze Barrage") }
    static var jokerFireBlazeDesc: String { localized("炸弹和火箭得分×1.75", en: "Bomb & Rocket score ×1.75") }
    static var jokerRideWaveName: String { localized("顺势而为", en: "Ride the Wave") }
    static var jokerRideWaveDesc: String { localized("顺子和连对得分×2", en: "Straight & Pair Straight score ×2") }
    static var jokerSiegeName: String { localized("四面楚歌", en: "Siege") }
    static var jokerSiegeDesc: String { localized("手牌中每张2或A，+8筹码", en: "+8 chips per 2 or A in hand") }
    static var jokerSecretPathName: String { localized("暗度陈仓", en: "Secret Path") }
    static var jokerSecretPathDesc: String { localized("每关换牌次数+2", en: "+2 swaps per floor") }
    static var jokerThunderStrikeName: String { localized("一鸣惊人", en: "Thunderstrike") }
    static var jokerThunderStrikeDesc: String { localized("每关第一次出牌倍率+1.0", en: "+1.0 mult on first play each floor") }
    static var jokerSwitcherooName: String { localized("偷梁换柱", en: "Switcheroo") }
    static var jokerSwitcherooDesc: String { localized("换牌时多抽1张牌", en: "Draw 1 extra card when swapping") }
    static var jokerLastStandName: String { localized("破釜沉舟", en: "Last Stand") }
    static var jokerLastStandDesc: String { localized("最后1次出牌倍率+1.5", en: "+1.5 mult on your final play") }
    static var jokerPairMasteryName: String { localized("成双成对", en: "Perfect Pair") }
    static var jokerPairMasteryDesc: String { localized("对子得分×2", en: "Pair score ×2") }
    static var jokerTripleThreatName: String { localized("三生万物", en: "Triple Threat") }
    static var jokerTripleThreatDesc: String { localized("三带类牌型倍率+0.8", en: "+0.8 mult for triple-type patterns") }
    static var jokerGoldRushName: String { localized("点石成金", en: "Gold Rush") }
    static var jokerGoldRushDesc: String { localized("每次出牌额外获得 8 金币", en: "+8 gold per play") }
    static var jokerSecondWindName: String { localized("回光返照", en: "Second Wind") }
    static var jokerSecondWindDesc: String { localized("每关额外获得 1 次出牌机会", en: "+1 extra play per floor") }
    static var jokerCardCounterName: String { localized("心算如飞", en: "Card Counter") }
    static var jokerCardCounterDesc: String { localized("出牌≥5张时得分+40%", en: "+40% score when playing ≥5 cards") }
    static var jokerLuckyDrawName: String { localized("锦鲤附体", en: "Lucky Koi") }
    static var jokerLuckyDrawDesc: String { localized("换牌改从牌堆底部取（底牌运气更好）", en: "Swap draws from bottom of deck (luckier cards)") }
    static var jokerScoreSurgeName: String { localized("厚积薄发", en: "Score Surge") }
    static var jokerScoreSurgeDesc: String { localized("层得分≥目标50%时+20筹码", en: "+20 chips when floor score ≥50% target") }
    static var jokerMiniHandName: String { localized("精打细算", en: "Precision Play") }
    static var jokerMiniHandDesc: String { localized("出3张及以下的牌型+60%", en: "+60% for patterns of 3 or fewer cards") }
    static var jokerMultiKillName: String { localized("连环杀", en: "Multi Kill") }
    static var jokerMultiKillDesc: String { localized("连击≥3时倍率+0.4", en: "+0.4 mult at combo ≥3") }
    static var jokerShieldBreakerName: String { localized("破甲", en: "Shield Breaker") }
    static var jokerShieldBreakerDesc: String { localized("上次出牌≥60分时，本次倍率+0.5", en: "+0.5 mult if last play scored ≥60") }
    static var jokerCriticalHitName: String { localized("暴击之手", en: "Critical Hit") }
    static var jokerCriticalHitDesc: String { localized("10%概率双倍得分", en: "10% chance to double score") }
    static var jokerInsuranceName: String { localized("保险单", en: "Insurance") }
    static var jokerInsuranceDesc: String { localized("失败时保留50%分数", en: "Keep 50% score on failure") }
    static var jokerCollectorName: String { localized("同花顺缘", en: "Flush Fate") }
    static var jokerCollectorDesc: String { localized("同花色出5张+35筹码", en: "+35 chips for 5+ same-suit cards") }
    static var jokerNightOwlName: String { localized("夜枭", en: "Night Owl") }
    static var jokerNightOwlDesc: String { localized("后半程(8-15关)倍率+0.4", en: "+0.4 mult in floors 8-15") }
    static var jokerEarlyBirdName: String { localized("先声夺人", en: "Early Bird") }
    static var jokerEarlyBirdDesc: String { localized("每关第一手出牌+100分", en: "+100 pts on first play each floor") }
    static var jokerMiserName: String { localized("守财奴", en: "Miser") }
    static var jokerMiserDesc: String { localized("每持有50金币+8筹码", en: "+8 chips per 50 gold held") }
    static var jokerGamblerName: String { localized("赌徒之心", en: "Gambler's Heart") }
    static var jokerGamblerDesc: String { localized("随机±30%得分（期望+5%）", en: "Random ±30% score (expected +5%)") }
    static var jokerPhoenixName: String { localized("浴火凤凰", en: "Phoenix") }
    static var jokerPhoenixDesc: String { localized("每局游戏可复活一次", en: "Revive once per run") }
    static var jokerDragonName: String { localized("神龙摆尾", en: "Dragon Tail") }
    static var jokerDragonDesc: String { localized("连击达到5时倍率+2.0", en: "+2.0 mult when reaching 5-combo") }
    static var jokerTideTurnerName: String { localized("逆转乾坤", en: "Tide Turner") }
    static var jokerTideTurnerDesc: String { localized("得分低于目标40%时倍率+0.8", en: "+0.8 mult when score <40% of target") }

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
    static var dailyChallengeTitle: String { localized("每日挑战", en: "Daily Challenge", ja: "デイリーチャレンジ", ko: "일일 도전", fr: "Défi du jour", de: "Tägliche Herausforderung", es: "Desafío diario", pt: "Desafio diário") }
    static var dailyChallengeSubtitle: String { localized("每日限定规则，全服同种子", en: "Daily rules, same seed for all", ja: "毎日限定ルール、全員同じシード", ko: "매일 한정 규칙, 전원 동일 시드", fr: "Règles quotidiennes, même seed pour tous", de: "Tägliche Regeln, gleicher Seed für alle", es: "Reglas diarias, misma semilla para todos", pt: "Regras diárias, mesma seed para todos") }
    static var todayModifiers: String { localized("今日规则", en: "Today's Rules", ja: "今日のルール", ko: "오늘의 규칙", fr: "Règles du jour", de: "Heutige Regeln", es: "Reglas de hoy", pt: "Regras de hoje") }
    static var rewardMultiplier: String { localized("奖励倍率", en: "Reward Multiplier", ja: "報酬倍率", ko: "보상 배율", fr: "Multiplicateur", de: "Belohnungsmultiplikator", es: "Multiplicador", pt: "Multiplicador") }
    static var bonusGoldLabel: String { localized("额外金币", en: "Bonus Gold", ja: "ボーナスゴールド", ko: "보너스 골드", fr: "Or bonus", de: "Bonusgold", es: "Oro extra", pt: "Ouro bônus") }
    static var startDailyChallenge: String { localized("开始挑战", en: "Start Challenge", ja: "チャレンジ開始", ko: "도전 시작", fr: "Commencer le défi", de: "Herausforderung starten", es: "Iniciar desafío", pt: "Iniciar desafio") }
    static var dailyChallengeCompleted: String { localized("今日已完成", en: "Completed Today", ja: "本日完了", ko: "오늘 완료", fr: "Terminé aujourd'hui", de: "Heute abgeschlossen", es: "Completado hoy", pt: "Concluído hoje") }
    static func dailyBestScore(_ n: Int) -> String { localized("今日最高分: \(n)", en: "Today's Best: \(n)") }
    static var dailyChallengeNoBombs: String { localized("禁止使用炸弹和火箭", en: "Bombs and Rockets are banned") }
    static var dailyChallengeNoDiscards: String { localized("禁止换牌", en: "Discards are disabled") }

    // MARK: - 空状态
    static var emptyStats: String { localized("开始你的第一次冒险吧！", en: "Start your first adventure!") }
    static var emptyAchievements: String { localized("还没有解锁成就，继续冒险吧！", en: "No achievements yet. Keep adventuring!") }
    static var shopRestocking: String { localized("商店正在补货...", en: "Shop is restocking...") }

    // MARK: - 重试 & 超额奖励
    static var retryFloor: String { localized("重试本关", en: "Retry Floor", ja: "リトライ", ko: "재도전", fr: "Réessayer", de: "Wiederholen", es: "Reintentar", pt: "Tentar de novo") }
    static var overscoreBonus: String { localized("超额奖励", en: "Overscore Bonus") }
    static var chipsLabel: String { localized("筹码", en: "Chips") }
    static var multLabel: String { localized("倍率", en: "Mult") }
    static func refreshShopCost(_ cost: Int) -> String { localized("🔄 刷新 (-\(cost)💰)", en: "🔄 Refresh (-\(cost)💰)") }

    // MARK: - 排序
    static var sortByRank: String { localized("按点数", en: "By Rank", ja: "ランク順", ko: "숫자순", fr: "Par rang", de: "Nach Rang", es: "Por rango", pt: "Por valor") }
    static var sortBySuit: String { localized("按花色", en: "By Suit", ja: "スート順", ko: "무늬순", fr: "Par couleur", de: "Nach Farbe", es: "Por palo", pt: "Por naipe") }

    // MARK: - 引导系统
    static var gameGuide: String { localized("游戏指南", en: "Game Guide") }
    static var shopIntroTitle: String { localized("🛒 欢迎来到商店！", en: "🛒 Welcome to the Shop!") }
    static var shopIntroMsg: String { localized(
        "这里是你变强的关键！\n\n🃏 规则牌 — 改变游戏规则的永久能力\n✨ 增益道具 — 特定牌型得分加成\n📖 武功秘籍 — 永久强化牌型基础分\n\n用金币购买，打造你的专属流派！",
        en: "This is where you get stronger!\n\n🃏 Jokers — Permanent abilities that change rules\n✨ Buffs — Score bonuses for specific patterns\n📖 Manuals — Permanently upgrade pattern scores\n\nSpend gold to build your unique playstyle!") }
    static var shopIntroGotIt: String { localized("明白了！", en: "Got it!") }
    static var firstJokerTitle: String { localized("🎉 获得规则牌！", en: "🎉 Joker Acquired!") }
    static var firstJokerMsg: String { localized(
        "规则牌已自动装备，效果立即生效！\n\n💡 最多装备 5 张规则牌\n💡 不同规则牌可以组合出强力搭配\n💡 通过成就解锁更多稀有规则牌",
        en: "Joker equipped automatically! Effect is active now.\n\n💡 Max 5 Jokers equipped\n💡 Combine Jokers for powerful synergies\n💡 Unlock rare Jokers via Achievements") }
    static var stuckHintBomb: String { localized("💡 试试攒炸弹（4张同点数），得分是普通牌型的10倍！", en: "💡 Try saving for a Bomb (4-of-a-kind) — 10× more points!") }
    static var stuckHintStraight: String { localized("💡 顺子（5张连续）得分很高，注意不能含2和王", en: "💡 Straights (5+ consecutive) score high! No 2s or Jokers") }
    static var stuckHintCombo: String { localized("💡 连续出牌触发连击加成，每次+15%！", en: "💡 Chain plays for combo bonus: +15% each!") }
    static var stuckHintSwap: String { localized("💡 换牌可以重组手牌，别忘了还有换牌机会", en: "💡 Swap to rebuild your hand — don't forget your swaps!") }

    // MARK: - 帮助与FAQ
    static var helpTitle: String { localized("帮助与FAQ", en: "Help & FAQ") }

    static var helpQuickStartTitle: String { localized("🎮 快速入门", en: "🎮 Quick Start") }
    static var helpQuickStartBody: String { localized(
        "斗破乾坤是一款肉鸽斗地主游戏。\n\n" +
        "🎯 目标：打出牌型得分，达到目标分即可过关\n" +
        "🃏 选牌：点击手牌选中，再点「出牌」\n" +
        "🔄 换牌：选中不想要的牌，点「换牌」从牌堆抽新牌\n" +
        "💰 商店：过关后用金币购买规则牌和增益\n" +
        "🏆 通关：闯过15层击败最终Boss即为通关！",
        en: "Dou Po Qian Kun is a Roguelike Doudizhu game.\n\n" +
        "🎯 Goal: Play card patterns to score, reach the target to clear the floor\n" +
        "🃏 Select: Tap cards to select, then tap 'Play'\n" +
        "🔄 Swap: Select unwanted cards and tap 'Swap' to draw new ones\n" +
        "💰 Shop: Buy Jokers and Buffs with gold between floors\n" +
        "🏆 Win: Clear all 15 floors and defeat the final Boss!") }

    static var helpPatternsTitle: String { localized("📋 牌型大全", en: "📋 Pattern Guide") }
    static var helpPatternsBody: String { localized(
        "牌面大小：3 < 4 < 5 < … < K < A < 2 < 小王 < 大王\n\n" +
        "单张 — 任意一张牌\n" +
        "对子 — 两张相同点数\n" +
        "三条 — 三张相同点数\n" +
        "三带一 — 三条 + 1张\n" +
        "三带二 — 三条 + 1对\n" +
        "顺子 — 5张以上连续（不含2和王）\n" +
        "连对 — 3对以上连续对子\n" +
        "飞机 — 2组以上连续三条\n" +
        "飞机带翅膀 — 飞机 + 等量单张或对子\n" +
        "炸弹 — 四张相同点数 ⚡ 高分！\n" +
        "火箭 — 大小王 🚀 最强牌型！\n" +
        "四带二 — 四张 + 2张单牌",
        en: "Card ranking: 3 < 4 < 5 < … < K < A < 2 < Black Joker < Red Joker\n\n" +
        "Single — Any one card\n" +
        "Pair — Two of same rank\n" +
        "Triple — Three of same rank\n" +
        "Triple+1 — Triple + 1 kicker\n" +
        "Triple+2 — Triple + 1 pair\n" +
        "Straight — 5+ consecutive (no 2s or Jokers)\n" +
        "Pair Straight — 3+ consecutive pairs\n" +
        "Plane — 2+ consecutive triples\n" +
        "Plane+Wings — Plane + equal single/pair kickers\n" +
        "Bomb — Four of same rank ⚡ High score!\n" +
        "Rocket — Both Jokers 🚀 Highest pattern!\n" +
        "Four+Two — Four + 2 singles") }

    static var helpScoringTitle: String { localized("🔢 计分系统", en: "🔢 Scoring System") }
    static var helpScoringBody: String { localized(
        "得分 = 基础筹码(Chips) × 倍率(Mult)\n\n" +
        "📊 每种牌型有不同的基础筹码和倍率\n" +
        "⚡ 连击：连续出牌不换牌，每次+15%倍率\n" +
        "🃏 规则牌可以额外增加筹码或倍率\n" +
        "✨ 增益道具也会加成特定牌型\n" +
        "📖 武功秘籍可以永久提升牌型基础分\n\n" +
        "💡 策略：组合高筹码牌型 + 高倍率规则牌 = 爆炸伤害！",
        en: "Score = Base Chips × Multiplier (Mult)\n\n" +
        "📊 Each pattern has different base chips and mult\n" +
        "⚡ Combo: Chain plays without swapping for +15% mult each\n" +
        "🃏 Jokers add extra chips or mult bonuses\n" +
        "✨ Buffs boost specific pattern scores\n" +
        "📖 Pattern upgrades permanently increase base scores\n\n" +
        "💡 Strategy: High chips pattern + high mult Jokers = explosive damage!") }

    static var helpJokersTitle: String { localized("🃏 规则牌是什么？", en: "🃏 What are Jokers?") }
    static var helpJokersBody: String { localized(
        "规则牌是改变游戏规则的核心能力卡！\n\n" +
        "🟢 普通 — 基础加成效果\n" +
        "🔵 稀有 — 强力组合效果（通关第5层解锁）\n" +
        "🟣 传说 — 改变玩法的终极能力（通关全15层解锁）\n\n" +
        "📌 最多同时装备 5 张规则牌\n" +
        "📌 在商店用金币购买\n" +
        "📌 效果跨层持久生效\n" +
        "📌 不同规则牌可以组合出强力搭配！\n\n" +
        "例如：「连环计」让连击加成翻倍 + 「一鸣惊人」让首手得分×2 = 开局即爆发",
        en: "Jokers are core ability cards that change the rules!\n\n" +
        "🟢 Common — Basic bonus effects\n" +
        "🔵 Rare — Powerful combo effects (unlock by reaching Floor 5)\n" +
        "🟣 Legendary — Game-changing abilities (unlock by full clear)\n\n" +
        "📌 Max 5 Jokers equipped at once\n" +
        "📌 Buy with gold in the shop\n" +
        "📌 Effects persist across floors\n" +
        "📌 Combine Jokers for powerful synergies!\n\n" +
        "Example: 'Chain Plot' doubles combo bonus + 'Thunderstrike' gives 2× first play = explosive opening") }

    static var helpBuffsTitle: String { localized("✨ 增益道具是什么？", en: "✨ What are Buffs?") }
    static var helpBuffsBody: String { localized(
        "增益道具是临时的得分加成效果。\n\n" +
        "🔥 部分增益仅在当前楼层有效\n" +
        "⚡ 部分增益是一次性使用\n" +
        "💰 在商店用金币购买\n\n" +
        "与规则牌的区别：\n" +
        "• 规则牌 = 持久能力（跨层生效）\n" +
        "• 增益 = 临时加成（本层/一次性）\n\n" +
        "💡 增益价格更低，适合短期增强特定策略！",
        en: "Buffs are temporary score bonus effects.\n\n" +
        "🔥 Some Buffs last for the current floor only\n" +
        "⚡ Some Buffs are one-time use\n" +
        "💰 Buy with gold in the shop\n\n" +
        "Difference from Jokers:\n" +
        "• Jokers = Permanent abilities (persist across floors)\n" +
        "• Buffs = Temporary boosts (current floor/one-time)\n\n" +
        "💡 Buffs are cheaper — great for short-term strategy!") }

    static var helpShopTitle: String { localized("🛒 商店指南", en: "🛒 Shop Guide") }
    static var helpShopBody: String { localized(
        "商店出现在第3、7、11、14层，是你变强的关键！\n\n" +
        "🃏 规则牌区 — 购买或刷新获得新的规则牌\n" +
        "✨ 增益区 — 购买临时加成道具\n" +
        "📖 武功秘籍 — 永久提升某种牌型的基础分\n" +
        "🔄 刷新 — 花费金币刷新商品（费用递增）\n\n" +
        "💡 金币来源：\n" +
        "• 过关奖励（超额越多奖励越多）\n" +
        "• 规则牌「点石成金」每次出牌+8金\n" +
        "• 特殊事件奖励",
        en: "The shop appears on Floors 3, 7, 11, 14 — key to getting stronger!\n\n" +
        "🃏 Joker Section — Buy or refresh for new Jokers\n" +
        "✨ Buff Section — Buy temporary boost items\n" +
        "📖 Pattern Upgrades — Permanently increase pattern base scores\n" +
        "🔄 Refresh — Spend gold to refresh stock (cost increases)\n\n" +
        "💡 Gold sources:\n" +
        "• Floor clear rewards (more for overscore)\n" +
        "• 'Gold Rush' Joker gives +8 gold per play\n" +
        "• Special event rewards") }

    static var helpBossTitle: String { localized("⚔️ Boss关说明", en: "⚔️ Boss Floors") }
    static var helpBossBody: String { localized(
        "Boss关是每章最后一层，有特殊修改器改变规则！\n\n" +
        "常见Boss修改器：\n" +
        "🔒 封顶令 — 单次得分上限60%\n" +
        "✋ 缩手缩脚 — 手牌减少2张\n" +
        "🔇 封印术 — 随机封印一张规则牌\n" +
        "📈 皇家特权 — 目标分每次出牌+5%\n" +
        "📉 双重压制 — 每次出牌得分递减10%\n" +
        "👻 幻影牌 — 2张手牌无法被选中\n\n" +
        "💡 遇到Boss前，先在商店做好准备！",
        en: "Boss floors are the last floor of each chapter with special modifiers!\n\n" +
        "Common Boss Modifiers:\n" +
        "🔒 Score Cap — Single play score capped at 60%\n" +
        "✋ Hand Shrink — 2 fewer cards in hand\n" +
        "🔇 Joker Silence — One random Joker disabled\n" +
        "📈 Escalating — Target increases 5% per play\n" +
        "📉 Scoring Decay — Each play scores 10% less\n" +
        "👻 Phantom Cards — 2 random cards can't be selected\n\n" +
        "💡 Prepare in the shop before facing the Boss!") }

    static var helpAchievementsTitle: String { localized("🏆 成就与解锁", en: "🏆 Achievements & Unlocks") }
    static var helpAchievementsBody: String { localized(
        "成就不仅是荣誉，还能解锁新内容！\n\n" +
        "🔓 到达第5层 → 解锁稀有规则牌\n" +
        "🔓 通关全15层 → 解锁传说规则牌\n" +
        "🔓 完成特定成就 → 解锁隐藏内容\n\n" +
        "在「卡牌收藏」→「成就」页面查看所有成就进度。\n" +
        "带有「🔓 解锁规则牌」标记的成就完成后会在商店出现对应的规则牌。",
        en: "Achievements aren't just badges — they unlock new content!\n\n" +
        "🔓 Reach Floor 5 → Unlock Rare Jokers\n" +
        "🔓 Full 15-floor clear → Unlock Legendary Jokers\n" +
        "🔓 Complete specific achievements → Unlock hidden content\n\n" +
        "Check progress in 'Card Collection' → 'Achievements'.\n" +
        "Achievements marked with '🔓 Unlocks Joker' will make new Jokers appear in the shop.") }

    static var helpDailyTitle: String { localized("📅 每日挑战", en: "📅 Daily Challenge") }
    static var helpDailyBody: String { localized(
        "每天一个独特的挑战模式！\n\n" +
        "🎯 特殊修改器改变游戏规则\n" +
        "🏅 挑战完成后查看排名\n" +
        "📊 每日挑战不影响正常存档\n\n" +
        "修改器示例：\n" +
        "• 速通 — 每层仅3次出牌\n" +
        "• 巨手 — 手牌+5张\n" +
        "• 纯炸弹 — 只有炸弹和火箭计分\n" +
        "• 双倍得分 — 所有得分×2",
        en: "A unique challenge every day!\n\n" +
        "🎯 Special modifiers change the rules\n" +
        "🏅 Check rankings after completing\n" +
        "📊 Daily challenges don't affect your main save\n\n" +
        "Modifier examples:\n" +
        "• Speed Run — Only 3 plays per floor\n" +
        "• Giant Hand — +5 cards in hand\n" +
        "• All or Nothing — Only Bombs and Rockets score\n" +
        "• Double Score — All scores ×2") }

    static var helpAscensionTitle: String { localized("🔥 挑战等级", en: "🔥 Ascension Levels") }
    static var helpAscensionBody: String { localized(
        "通关后可以提高挑战等级重玩！\n\n" +
        "A1+ — 目标分+8%\n" +
        "A3+ — 出牌次数-1\n" +
        "A5+ — 换牌次数-1\n" +
        "A7+ — 起始金币-30\n" +
        "A10 — 最高难度，终极挑战！\n\n" +
        "💡 挑战等级越高，胜利越有成就感！\n" +
        "你的最高通关等级会显示在首页。",
        en: "After clearing, raise the Ascension level for a harder run!\n\n" +
        "A1+ — Target score +8%\n" +
        "A3+ — 1 fewer play per floor\n" +
        "A5+ — 1 fewer swap per floor\n" +
        "A7+ — Starting gold -30\n" +
        "A10 — Maximum difficulty!\n\n" +
        "💡 Higher Ascension = greater achievement!\n" +
        "Your highest clear is shown on the home screen.") }

    static var helpTipsTitle: String { localized("💡 策略小贴士", en: "💡 Strategy Tips") }
    static var helpTipsBody: String { localized(
        "1️⃣ 连击很重要！尽量不换牌保持连击链\n" +
        "2️⃣ 炸弹和火箭是翻盘利器，别轻易拆\n" +
        "3️⃣ 商店里优先买规则牌，效果跨层持久\n" +
        "4️⃣ 关注规则牌之间的组合搭配\n" +
        "5️⃣ 超额过关可以获得更多金币奖励\n" +
        "6️⃣ Boss关前留足出牌次数应对修改器\n" +
        "7️⃣ 换牌不消耗出牌次数，但会打断连击\n" +
        "8️⃣ 武功秘籍是永久的，长期投资回报高\n" +
        "9️⃣ 每日挑战可以练手，不影响主线进度\n" +
        "🔟 享受过程，每一局都是独一无二的！",
        en: "1️⃣ Combos matter! Avoid swapping to keep the chain\n" +
        "2️⃣ Bombs and Rockets are comeback kings — don't break them early\n" +
        "3️⃣ Prioritize Jokers in shop — effects persist across floors\n" +
        "4️⃣ Look for Joker synergies and combos\n" +
        "5️⃣ Overscore floors for bonus gold rewards\n" +
        "6️⃣ Save plays for Boss modifiers\n" +
        "7️⃣ Swapping doesn't cost plays, but breaks combos\n" +
        "8️⃣ Pattern upgrades are permanent — great long-term investment\n" +
        "9️⃣ Daily challenges are great practice, no save impact\n" +
        "🔟 Enjoy the journey — every run is unique!") }

    // MARK: - 设置页面新增
    static var helpAndFaq: String { localized("帮助", en: "Help & FAQ", ja: "ヘルプ", ko: "도움말", fr: "Aide", de: "Hilfe", es: "Ayuda", pt: "Ajuda") }
    static var resetContextHints: String { localized("重置引导提示", en: "Reset Context Hints", ja: "ヒントをリセット", ko: "힌트 초기화", fr: "Réinitialiser les indices", de: "Hinweise zurücksetzen", es: "Restablecer pistas", pt: "Redefinir dicas") }
    static var resetContextHintsDesc: String { localized("重新显示所有游戏内引导提示", en: "Re-show all in-game guidance hints") }
    static var dataManagement: String { localized("数据管理", en: "Data Management", ja: "データ管理", ko: "데이터 관리", fr: "Gestion des données", de: "Datenverwaltung", es: "Gestión de datos", pt: "Gerenciamento de dados") }
    static var clearSaveData: String { localized("清除存档", en: "Clear Save Data", ja: "セーブデータ削除", ko: "저장 데이터 삭제", fr: "Effacer la sauvegarde", de: "Speicherdaten löschen", es: "Borrar datos guardados", pt: "Limpar dados salvos") }
    static var clearSaveDataDesc: String { localized("删除当前进行中的游戏存档", en: "Delete current in-progress game save") }
    static var resetStats: String { localized("重置统计", en: "Reset Statistics", ja: "統計リセット", ko: "통계 초기화", fr: "Réinitialiser les stats", de: "Statistiken zurücksetzen", es: "Restablecer estadísticas", pt: "Redefinir estatísticas") }
    static var resetStatsDesc: String { localized("清除所有游戏统计（局数、最高分等）", en: "Clear all game stats (runs, high scores, etc.)") }
    static var resetAllData: String { localized("重置所有数据", en: "Reset All Data", ja: "全データリセット", ko: "모든 데이터 초기화", fr: "Tout réinitialiser", de: "Alle Daten zurücksetzen", es: "Restablecer todo", pt: "Redefinir tudo") }
    static var resetAllDataDesc: String { localized("清除所有数据（存档+统计+成就+升级）⚠️ 不可恢复", en: "Clear everything (saves, stats, achievements, upgrades) ⚠️ Irreversible") }
    static var confirmReset: String { localized("确认重置", en: "Confirm Reset", ja: "リセット確認", ko: "초기화 확인", fr: "Confirmer", de: "Bestätigen", es: "Confirmar", pt: "Confirmar") }
    static var privacyPolicy: String { localized("隐私政策", en: "Privacy Policy", ja: "プライバシーポリシー", ko: "개인정보 처리방침", fr: "Politique de confidentialité", de: "Datenschutz", es: "Política de privacidad", pt: "Política de privacidade") }
    static var done: String { localized("完成", en: "Done", ja: "完了", ko: "완료", fr: "Terminé", de: "Fertig", es: "Listo", pt: "Concluído") }
    static var hintResetDone: String { localized("已重置", en: "Reset Done", ja: "リセット完了", ko: "초기화 완료", fr: "Réinitialisé", de: "Zurückgesetzt", es: "Restablecido", pt: "Redefinido") }

    // MARK: - 成就

    static var achievementFirstWinName: String { localized("初出茅庐", en: "First Steps") }
    static var achievementFirstWinDesc: String { localized("首次通关第1层", en: "Clear Floor 1 for the first time") }

    static var achievementMidRunName: String { localized("渐入佳境", en: "Getting Warmed Up") }
    static var achievementMidRunDesc: String { localized("到达第5层", en: "Reach Floor 5") }

    static var achievementFullClearName: String { localized("斗破乾坤", en: "World Breaker") }
    static var achievementFullClearDesc: String { localized("首次通关全部关卡", en: "Clear all floors for the first time") }

    static var achievementGames10Name: String { localized("常客", en: "Regular") }
    static var achievementGames10Desc: String { localized("累计游戏10局", en: "Play 10 games total") }

    static var achievementGames50Name: String { localized("老牌手", en: "Veteran") }
    static var achievementGames50Desc: String { localized("累计游戏50局", en: "Play 50 games total") }

    static var achievementScore500Name: String { localized("小试牛刀", en: "Warming Up") }
    static var achievementScore500Desc: String { localized("单局累计500分", en: "Score 500 in a single run") }

    static var achievementScore2000Name: String { localized("一骑当千", en: "Unstoppable") }
    static var achievementScore2000Desc: String { localized("单局累计2000分", en: "Score 2000 in a single run") }

    static var achievementScore5000Name: String { localized("登峰造极", en: "Peak Performance") }
    static var achievementScore5000Desc: String { localized("单局累计5000分", en: "Score 5000 in a single run") }

    static var achievementSingle200Name: String { localized("一击必杀", en: "One-Shot") }
    static var achievementSingle200Desc: String { localized("单次出牌得分≥200", en: "Score 200+ in a single play") }

    static var achievementSingle500Name: String { localized("天崩地裂", en: "Earth-Shaking") }
    static var achievementSingle500Desc: String { localized("单次出牌得分≥500", en: "Score 500+ in a single play") }

    static var achievementCombo5Name: String { localized("连击大师", en: "Combo Master") }
    static var achievementCombo5Desc: String { localized("达成5连击", en: "Achieve a 5-hit combo") }

    static var achievementBombs10Name: String { localized("爆破专家", en: "Demolition Expert") }
    static var achievementBombs10Desc: String { localized("累计使用10次炸弹", en: "Use bombs 10 times total") }

    static var achievementRockets5Name: String { localized("火箭狂人", en: "Rocket Maniac") }
    static var achievementRockets5Desc: String { localized("累计使用5次火箭", en: "Use rockets 5 times total") }

    static var achievementJokersCollect5Name: String { localized("规则收藏家", en: "Rule Collector") }
    static var achievementJokersCollect5Desc: String { localized("单局装备5张规则牌", en: "Equip 5 Joker cards in one run") }

    static var achievementNoDiscardWinName: String { localized("完美牌局", en: "Perfect Hand") }
    static var achievementNoDiscardWinDesc: String { localized("不换牌通过一层", en: "Clear a floor without discarding") }

    static var achievementGold300Name: String { localized("富甲一方", en: "Wealthy") }
    static var achievementGold300Desc: String { localized("持有300+金币", en: "Hold 300+ gold") }

    static var achievementWins5Name: String { localized("常胜将军", en: "Victorious") }
    static var achievementWins5Desc: String { localized("累计通关5次", en: "Clear the game 5 times") }

    static var achievementAscension1Name: String { localized("初入挑战", en: "Challenger") }
    static var achievementAscension1Desc: String { localized("达到挑战等级1", en: "Reach Ascension Level 1") }

    static var achievementAscension5Name: String { localized("挑战强者", en: "Elite Challenger") }
    static var achievementAscension5Desc: String { localized("达到挑战等级5", en: "Reach Ascension Level 5") }

    static var achievementAscension10Name: String { localized("绝世高手", en: "Grandmaster") }
    static var achievementAscension10Desc: String { localized("达到挑战等级10", en: "Reach Ascension Level 10") }

    static var achievementDailyStreak3Name: String { localized("三日不辍", en: "Three-Day Streak") }
    static var achievementDailyStreak3Desc: String { localized("每日挑战连续3天", en: "3-day Daily Challenge streak") }

    static var achievementDailyStreak7Name: String { localized("周周坚持", en: "Weekly Warrior") }
    static var achievementDailyStreak7Desc: String { localized("每日挑战连续7天", en: "7-day Daily Challenge streak") }

    static var achievementDailyStreak30Name: String { localized("月度传奇", en: "Monthly Legend") }
    static var achievementDailyStreak30Desc: String { localized("每日挑战连续30天", en: "30-day Daily Challenge streak") }

    static var achievementBuilds3Name: String { localized("多面手", en: "Versatile") }
    static var achievementBuilds3Desc: String { localized("使用3种不同构筑通关", en: "Clear with 3 different builds") }

    static var achievementBuilds9Name: String { localized("全能大师", en: "Master of All") }
    static var achievementBuilds9Desc: String { localized("使用所有9种构筑通关", en: "Clear with all 9 builds") }

    static var achievementStraights20Name: String { localized("顺子达人", en: "Straight Expert") }
    static var achievementStraights20Desc: String { localized("累计打出20次顺子", en: "Play 20 straights total") }

    static var achievementBombs50Name: String { localized("炸弹狂魔", en: "Bomb Maniac") }
    static var achievementBombs50Desc: String { localized("累计使用50次炸弹", en: "Use bombs 50 times total") }

    static var achievementScore10000Name: String { localized("万分俱乐部", en: "10K Club") }
    static var achievementScore10000Desc: String { localized("单局累计10000分", en: "Score 10000 in a single run") }

    static var achievementSingle1000Name: String { localized("毁天灭地", en: "Annihilation") }
    static var achievementSingle1000Desc: String { localized("单次出牌得分≥1000", en: "Score 1000+ in a single play") }

    // MARK: - 本地化引擎

    static func localized(
        _ zh: String,
        en: String,
        ja: String? = nil,
        ko: String? = nil,
        fr: String? = nil,
        de: String? = nil,
        es: String? = nil,
        pt: String? = nil
    ) -> String {
        switch currentLanguage {
        case .zh: return zh
        case .en: return en
        case .ja: return ja ?? en
        case .ko: return ko ?? en
        case .fr: return fr ?? en
        case .de: return de ?? en
        case .es: return es ?? en
        case .pt: return pt ?? en
        }
    }

    // MARK: - 战斗界面 (BattleView)

    static var battleCardTable: String { localized("牌桌", en: "Card table") }
    static func battleLastPlayWarning(_ gap: Int) -> String { localized("最后一次出牌！还差 \(gap) 分", en: "Last play! Need \(gap) more") }
    static var battleHintSingle: String { localized("单张可以直接出", en: "Play single cards") }
    static var battleHintPair: String { localized("需要两张相同点数组成对子", en: "Need a pair (same rank)") }
    static var battleHintTriple: String { localized("需要三张相同点数", en: "Need three of a kind") }
    static var battleHintFour: String { localized("试试三带一、炸弹，或凑顺子", en: "Try 3+1, bomb, or extend to straight") }
    static var battleHintFivePlus: String { localized("试试顺子（5张以上连续）", en: "Try a straight (5+ consecutive)") }
    static var battleBonus: String { localized("加成", en: "Bonus") }
    static var battlePenalty: String { localized("减益", en: "Penalty") }
    static var battleEarned: String { localized("得分", en: "Earned") }
    static var battleSaveQuit: String { localized("暂离保存", en: "Save & Quit") }
    static var battleGap: String { localized("差距", en: "Gap") }
    static var battleCardsPlayed: String { localized("出牌数", en: "Cards Played") }
    static var battleBestHand: String { localized("最佳一手", en: "Best Hand") }
    static var battleBestCombo: String { localized("最高连击", en: "Best Combo") }
    static func battleLockedContent(_ n: Int) -> String { localized("还有\(n)层关卡 · 稀有规则牌 · 无尽模式", en: "\(n) more floors · Rare Jokers · Endless mode") }
    static var battleSeeMore: String { localized("了解更多", en: "See More") }
    static var battleRestartRunTitle: String { localized("重新开始？", en: "Restart Run?") }
    static var battleRestartRunMessage: String { localized("当前冒险进度将丢失，从第1层重新开始。", en: "Current run progress will be lost. Start a fresh run from Floor 1.") }
    static var battleBackToMenuTitle: String { localized("返回主菜单？", en: "Back to Menu?") }
    static var battleSaveAndQuit: String { localized("保存并退出", en: "Save & Quit") }
    static var battleQuitNoSave: String { localized("不保存退出", en: "Quit without saving") }
    static var battleBackToMenuMessage: String { localized("保存后可以下次继续重试，不保存将丢失本局进度。", en: "Save your run to retry later, or quit without saving.") }
    static var battleFloorsCleared: String { localized("通过层数", en: "Floors Cleared") }
    static var battleTotalCardsPlayed: String { localized("出牌总数", en: "Cards Played") }
    static var battleJokers: String { localized("规则牌", en: "Jokers") }
    static var battleGoldRemaining: String { localized("剩余金币", en: "Gold Remaining") }
    static var battleVictoryTitle: String { localized("斗破乾坤", en: "Victory!") }
    static func battleShareText(_ score: Int) -> String { localized("我在斗破乾坤中取得了 \(score) 分！🏆", en: "I scored \(score) in Dou Po Qian Kun! 🏆") }
    static var battleShare: String { localized("分享战绩", en: "Share") }
    static var battleSkip: String { localized("跳过", en: "Skip") }
    static var battlePaused: String { localized("已暂停", en: "Paused") }
    static var battleScore: String { localized("得分", en: "Score") }
    static var battleGold: String { localized("金币", en: "Gold") }
    static var battleResume: String { localized("继续游戏", en: "Resume") }
    static var battleRetryFloorTitle: String { localized("重试本关？", en: "Retry Floor?") }
    static var battleRetry: String { localized("重试", en: "Retry") }
    static var battleRetryMessage: String { localized("本层进度将被重置。", en: "Your progress on this floor will be reset.") }
    static var battleSound: String { localized("音效", en: "Sound") }
    static var battleMusic: String { localized("音乐", en: "Music") }
    static var battleHaptics: String { localized("震动", en: "Haptics") }
    static var battleSortBySuit: String { localized("按花色排列", en: "Sort by Suit") }
    static var battleSortByRank: String { localized("按点数排列", en: "Sort by Rank") }
    static var battleAbandonRun: String { localized("放弃冒险", en: "Abandon Run") }
    static var battleAbandonTitle: String { localized("确认放弃？", en: "Abandon Run?") }
    static var battleAbandon: String { localized("放弃", en: "Abandon") }
    static var battleAbandonMessage: String { localized("本局所有进度将丢失，无法恢复。", en: "All progress in this run will be lost.") }

    // MARK: - 无障碍 (Accessibility)

    static var a11yPause: String { localized("暂停", en: "Pause") }
    static var a11yGold: String { localized("金币", en: "Gold") }
    static var a11yPatternRef: String { localized("牌型参考", en: "Pattern Reference") }
    static var a11yPlaysRemaining: String { localized("剩余出牌次数", en: "Plays remaining") }
    static var a11yDiscardsRemaining: String { localized("剩余弃牌次数", en: "Discards remaining") }
    static var a11yCurrentScore: String { localized("当前分数", en: "Current score") }
    static var a11yTargetScore: String { localized("目标分数", en: "Target score") }
    static var a11yDiscard: String { localized("弃牌", en: "Discard") }
    static var a11yPlayCards: String { localized("出牌", en: "Play cards") }
    static var a11yDailyChallenge: String { localized("每日挑战", en: "Daily Challenge") }
    static var a11yDailyChallengeComplete: String { localized("每日挑战已完成", en: "Daily Challenge completed") }
    static var a11yContinueAdventure: String { localized("继续冒险", en: "Continue adventure") }
    static var a11yNewAdventure: String { localized("新的冒险", en: "New adventure") }
    static var a11yStartAdventure: String { localized("开始冒险", en: "Start adventure") }
    static var a11yQuickStart: String { localized("快速开始", en: "Quick start") }
    static var a11yCardCollection: String { localized("卡牌收集", en: "Card collection") }
    static var a11ySettings: String { localized("设置", en: "Settings") }
    static var a11yTodayStats: String { localized("今日数据", en: "Today's stats") }
    static var a11yHelpFaq: String { localized("帮助与常见问题", en: "Help & FAQ") }
    static var a11yVolume: String { localized("音量", en: "Volume") }
    static var a11yResetTutorial: String { localized("重置新手引导", en: "Reset tutorial") }
    static var a11yRefreshShop: String { localized("刷新商店", en: "Refresh shop") }
    static var a11yGotIt: String { localized("我知道了", en: "Got it") }
    static var a11yUnlockFull: String { localized("解锁完整版", en: "Unlock full version") }
    static var a11yFreePreview: String { localized("免费体验下一层", en: "Try one more floor free") }
    static var a11yRestorePurchase: String { localized("恢复购买", en: "Restore purchase") }
    static var a11yBackToMenu: String { localized("返回主菜单", en: "Back to main menu") }
    static var a11yDepart: String { localized("出发", en: "Depart") }
    static var a11yAchievementProgress: String { localized("成就进度", en: "Achievement progress") }
    static func a11yBuyJoker(_ name: String) -> String { localized("购买\(name)", en: "Buy \(name)") }
    static func a11yBuyBuff(_ name: String) -> String { localized("购买\(name)", en: "Buy \(name)") }
}
