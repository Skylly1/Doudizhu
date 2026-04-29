import Foundation

/// Boss 关卡规则修改器 — 每个Boss有独特规则改变游戏策略
enum BossModifier: String, CaseIterable, Codable {
    case bannedPattern      // 禁用一种随机牌型
    case escalating         // 目标分数每次出牌后+5%
    case scoringDecay       // 每次出牌得分递减10%
    case timeLimit          // 无实际计时，但出牌次数-1
    case greedyTax          // 每次出牌扣10金币
    case noDiscard          // 禁止换牌（已由floor config的0弃牌实现，这里作为显示标记）
    case scoreCap           // 封顶令 — 单次出牌得分上限为目标分60%
    case handShrink         // 缩手缩脚 — 手牌减少2张（发8张而非10张）
    case jokerSilence       // 封印术 — 随机封印一张规则牌
    // 新增 6 种 Boss 修改器
    case blindDraw          // 盲抽 — 手牌全部面朝下，出牌后才能看到
    case pairTax            // 成双税 — 对子得分减半
    case comboBreaker       // 破连 — 无法累积连击
    case goldDrain          // 漏金 — 每回合自动扣 5 金币
    case reverseOrder       // 倒序 — 小牌得分更高，大牌得分降低
    case phantomCards       // 幻影牌 — 随机 2 张手牌无法被选中
    
    var systemIcon: String {
        switch self {
        case .bannedPattern:  return "scroll.fill"
        case .escalating:     return "crown.fill"
        case .scoringDecay:   return "flame.fill"
        case .timeLimit:      return "hourglass"
        case .greedyTax:      return "dollarsign.circle.fill"
        case .noDiscard:      return "nosign"
        case .scoreCap:       return "lock.fill"
        case .handShrink:     return "hand.raised.fill"
        case .jokerSilence:   return "speaker.slash.fill"
        case .blindDraw:      return "eye.slash.fill"
        case .pairTax:        return "equal.circle.fill"
        case .comboBreaker:   return "xmark.circle.fill"
        case .goldDrain:      return "drop.triangle.fill"
        case .reverseOrder:   return "arrow.up.arrow.down"
        case .phantomCards:   return "questionmark.circle.fill"
        }
    }
    
    var name: String {
        switch self {
        case .bannedPattern: return L10n.localized("官府禁令", en: "Imperial Ban", ja: "官府禁令", ko: "관부금령", fr: "Interdiction Impériale", de: "Kaiserliches Verbot", es: "Prohibición Imperial", pt: "Proibição Imperial")
        case .escalating:    return L10n.localized("皇家特权", en: "Royal Privilege", ja: "皇家特権", ko: "황가특권", fr: "Privilège Royal", de: "Königliches Privileg", es: "Privilegio Real", pt: "Privilégio Real")
        case .scoringDecay:  return L10n.localized("双重压制", en: "Double Suppression", ja: "二重抑圧", ko: "이중압제", fr: "Double Suppression", de: "Doppelte Unterdrückung", es: "Doble Supresión", pt: "Dupla Supressão")
        case .timeLimit:     return L10n.localized("时不我待", en: "Time Pressure", ja: "時間制限", ko: "시간압박", fr: "Pression Temporelle", de: "Zeitdruck", es: "Presión de Tiempo", pt: "Pressão de Tempo")
        case .greedyTax:     return L10n.localized("贪婪税", en: "Greed Tax", ja: "強欲税", ko: "탐욕세", fr: "Taxe de Cupidité", de: "Giersteuer", es: "Impuesto de Codicia", pt: "Taxa de Ganância")
        case .noDiscard:     return L10n.localized("背水一战", en: "No Retreat", ja: "退路なし", ko: "배수진", fr: "Pas de Retraite", de: "Kein Rückzug", es: "Sin Retirada", pt: "Sem Recuo")
        case .scoreCap:      return L10n.localized("封顶令", en: "Score Cap", ja: "上限令", ko: "점수상한", fr: "Plafond de Score", de: "Punkteobergrenze", es: "Límite de Puntos", pt: "Limite de Pontos")
        case .handShrink:    return L10n.localized("缩手缩脚", en: "Hand Shrink", ja: "手札縮小", ko: "패줄임", fr: "Main Réduite", de: "Hand-Schrumpf", es: "Mano Reducida", pt: "Mão Reduzida")
        case .jokerSilence:  return L10n.localized("封印术", en: "Joker Silence", ja: "封印術", ko: "봉인술", fr: "Silence du Joker", de: "Joker-Stille", es: "Silencio del Joker", pt: "Silêncio do Joker")
        case .blindDraw:     return L10n.localized("盲抽", en: "Blind Draw", ja: "ブラインドドロー", ko: "블라인드 드로우", fr: "Tirage Aveugle", de: "Blindziehung", es: "Robo a Ciegas", pt: "Sorteio Cego")
        case .pairTax:       return L10n.localized("成双税", en: "Pair Tax", ja: "ペア税", ko: "쌍세", fr: "Taxe de Paire", de: "Paarsteuer", es: "Impuesto de Par", pt: "Taxa de Par")
        case .comboBreaker:  return L10n.localized("破连", en: "Combo Breaker", ja: "コンボブレイカー", ko: "콤보브레이커", fr: "Brise-Combo", de: "Kombobrecher", es: "Rompe-Combo", pt: "Quebra-Combo")
        case .goldDrain:     return L10n.localized("漏金", en: "Gold Drain", ja: "ゴールド流出", ko: "골드유출", fr: "Drain d'Or", de: "Goldabfluss", es: "Fuga de Oro", pt: "Dreno de Ouro")
        case .reverseOrder:  return L10n.localized("倒序乾坤", en: "Reverse Order", ja: "逆順", ko: "역순건곤", fr: "Ordre Inversé", de: "Umgekehrte Ordnung", es: "Orden Inverso", pt: "Ordem Inversa")
        case .phantomCards:  return L10n.localized("幻影牌", en: "Phantom Cards", ja: "ファントムカード", ko: "환영패", fr: "Cartes Fantômes", de: "Phantomkarten", es: "Cartas Fantasma", pt: "Cartas Fantasma")
        }
    }
    
    var description: String {
        switch self {
        case .bannedPattern: return L10n.localized("禁用一种随机牌型（顺子/炸弹/飞机三选一）", en: "One random pattern type is banned")
        case .escalating:    return L10n.localized("目标分数每次出牌后增加5%", en: "Target score increases 5% after each play")
        case .scoringDecay:  return L10n.localized("每次出牌后，下次出牌得分-10%", en: "Each play scores 10% less than the previous")
        case .timeLimit:     return L10n.localized("出牌次数比正常少1次", en: "1 fewer play than normal")
        case .greedyTax:     return L10n.localized("每次出牌扣10金币", en: "Each play costs 10 gold")
        case .noDiscard:     return L10n.localized("本关无法换牌", en: "Cannot swap cards this floor")
        case .scoreCap:      return L10n.localized("单次出牌得分上限为目标分的60%", en: "Single play score capped at 60% of target")
        case .handShrink:    return L10n.localized("手牌减少2张（发8张）", en: "Hand size reduced by 2 cards")
        case .jokerSilence:  return L10n.localized("随机封印一张规则牌本关无效", en: "One random Joker is silenced this floor")
        case .blindDraw:     return L10n.localized("手牌面朝下，出牌后才翻开", en: "Cards are face-down until played")
        case .pairTax:       return L10n.localized("对子得分减半", en: "Pairs score 50% less")
        case .comboBreaker:  return L10n.localized("无法累积连击加成", en: "Combo multiplier is disabled")
        case .goldDrain:     return L10n.localized("每回合自动扣5金币", en: "Lose 5 gold each turn")
        case .reverseOrder:  return L10n.localized("小牌得分更高，大牌得分降低", en: "Lower ranks score higher, higher ranks score lower")
        case .phantomCards:  return L10n.localized("随机2张手牌无法被选中", en: "2 random cards cannot be selected")
        }
    }
}

/// 某一局Boss关的活跃修改器状态
struct BossState {
    let modifiers: [BossModifier]
    var bannedPatternType: PatternType?
    var escalationCount: Int = 0           // 已出牌次数（用于escalating计算）
    var decayCount: Int = 0                // 已出牌次数（用于scoringDecay计算）
    var silencedJokerIndex: Int?           // 被封印的规则牌索引（用于jokerSilence）
    var phantomCardIds: Set<UUID> = []     // 幻影牌ID集合（无法被选中）
    
    init(modifiers: [BossModifier]) {
        self.modifiers = modifiers
        // 如果有禁令修改器，随机选一个牌型禁用
        if modifiers.contains(.bannedPattern) {
            let bannable: [PatternType] = [.straight, .bomb, .plane]
            bannedPatternType = bannable.randomElement()
        } else {
            bannedPatternType = nil
        }
    }
    
    var hasBannedPattern: Bool { modifiers.contains(.bannedPattern) }
    var hasEscalating: Bool { modifiers.contains(.escalating) }
    var hasScoringDecay: Bool { modifiers.contains(.scoringDecay) }
    var hasGreedyTax: Bool { modifiers.contains(.greedyTax) }
}
