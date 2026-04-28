import Foundation

// MARK: - 牌型

/// 斗地主所有合法牌型
enum PatternType: String, Codable, Hashable, CaseIterable {
    case single          // 单张
    case pair            // 对子
    case triple          // 三条
    case tripleWithOne   // 三带一
    case tripleWithPair  // 三带二
    case straight        // 顺子（5+连续单张）
    case pairStraight    // 连对（3+连续对子）
    case plane           // 飞机（2+连续三条）
    case planeWithWings  // 飞机带翅膀
    case bomb            // 炸弹（四张相同）
    case rocket          // 火箭（大小王）
    case fourWithTwo     // 四带二

    var displayName: String {
        switch self {
        case .single:         return L10n.patternSingle
        case .pair:           return L10n.patternPair
        case .triple:         return L10n.patternTriple
        case .tripleWithOne:  return L10n.patternTripleOne
        case .tripleWithPair: return L10n.patternTriplePair
        case .straight:       return L10n.patternStraight
        case .pairStraight:   return L10n.patternPairStraight
        case .plane:          return L10n.patternPlane
        case .planeWithWings: return L10n.patternPlaneWings
        case .bomb:           return "💣 " + L10n.patternBomb
        case .rocket:         return "🚀 " + L10n.patternRocket
        case .fourWithTwo:    return L10n.patternFourTwo
        }
    }
}

/// 已识别的牌型
struct CardPattern: Hashable {
    let type: PatternType
    let cards: [Card]
    let mainRank: Rank   // 用于比较大小的主要点数

    /// 基础筹码（chips×mult 计分系统）
    var baseChips: Int {
        switch type {
        case .single:         return 5
        case .pair:           return 10
        case .triple:         return 20
        case .tripleWithOne:  return 30
        case .tripleWithPair: return 40
        case .straight:       return 12 * cards.count
        case .pairStraight:   return 18 * (cards.count / 2)
        case .plane:          return 45 * (cards.count / 3)
        case .planeWithWings: return cards.count * 12
        case .bomb:           return 60
        case .rocket:         return 100
        case .fourWithTwo:    return 70
        }
    }

    /// 基础倍率（chips×mult 计分系统）
    var baseMult: Double {
        switch type {
        case .single:         return 1.0
        case .pair:           return 1.5
        case .triple:         return 2.0
        case .tripleWithOne:  return 2.0
        case .tripleWithPair: return 2.5
        case .straight:       return 2.0 + Double(max(0, cards.count - 5)) * 0.3
        case .pairStraight:   return 2.0 + Double(max(0, cards.count / 2 - 3)) * 0.4
        case .plane:          return 3.0
        case .planeWithWings: return 3.0
        case .bomb:           return 4.0
        case .rocket:         return 8.0
        case .fourWithTwo:    return 3.5
        }
    }

    /// Legacy compatibility — returns chips × mult as int
    var baseScore: Int {
        Int(Double(baseChips) * baseMult)
    }
}

// MARK: - 牌型识别器

struct PatternRecognizer {

    /// 识别一组牌的牌型，无效返回 nil
    static func recognize(_ cards: [Card]) -> CardPattern? {
        let sorted = cards.sorted { $0.rank < $1.rank }
        let count = sorted.count

        guard count > 0 else { return nil }

        switch count {
        case 1:
            return CardPattern(type: .single, cards: sorted, mainRank: sorted[0].rank)

        case 2:
            return recognizePairOrRocket(sorted)

        case 3:
            if isAllSameRank(sorted) {
                return CardPattern(type: .triple, cards: sorted, mainRank: sorted[0].rank)
            }

        case 4:
            if isAllSameRank(sorted) {
                return CardPattern(type: .bomb, cards: sorted, mainRank: sorted[0].rank)
            }
            if let pattern = recognizeTripleWith(sorted, wingSize: 1) {
                return pattern
            }

        case 5:
            if let pattern = recognizeTripleWith(sorted, wingSize: 2) {
                return pattern
            }
            if let pattern = recognizeStraight(sorted) {
                return pattern
            }

        default:
            // 顺子、连对、飞机等复杂牌型
            if let pattern = recognizeStraight(sorted) { return pattern }
            if let pattern = recognizePairStraight(sorted) { return pattern }
            if let pattern = recognizePlane(sorted) { return pattern }
            if let pattern = recognizeFourWithTwo(sorted) { return pattern }
        }

        return nil
    }

    /// 判断是否能管上（play 能否打过 current）
    static func canBeat(play: CardPattern, current: CardPattern) -> Bool {
        // 火箭最大
        if play.type == .rocket { return true }
        if current.type == .rocket { return false }

        // 炸弹大于非炸弹
        if play.type == .bomb && current.type != .bomb { return true }
        if current.type == .bomb && play.type != .bomb { return false }

        // 同类型比较
        guard play.type == current.type,
              play.cards.count == current.cards.count else {
            return false
        }

        return play.mainRank > current.mainRank
    }

    // MARK: - Private

    private static func isAllSameRank(_ cards: [Card]) -> Bool {
        cards.allSatisfy { $0.rank == cards[0].rank }
    }

    private static func recognizePairOrRocket(_ cards: [Card]) -> CardPattern? {
        // 火箭
        if cards[0].rank == .jokerBlack && cards[1].rank == .jokerRed {
            return CardPattern(type: .rocket, cards: cards, mainRank: .jokerRed)
        }
        // 对子
        if cards[0].rank == cards[1].rank {
            return CardPattern(type: .pair, cards: cards, mainRank: cards[0].rank)
        }
        return nil
    }

    private static func recognizeTripleWith(_ cards: [Card], wingSize: Int) -> CardPattern? {
        let groups = Dictionary(grouping: cards) { $0.rank }
        guard let tripleRank = groups.first(where: { $0.value.count == 3 })?.key else {
            return nil
        }
        // Validate wing: tripleWithPair requires the wing to be an actual pair
        if wingSize == 2 {
            let wingCards = cards.filter { $0.rank != tripleRank }
            guard wingCards.count == 2, wingCards[0].rank == wingCards[1].rank else { return nil }
        }
        let type: PatternType = wingSize == 1 ? .tripleWithOne : .tripleWithPair
        return CardPattern(type: type, cards: cards, mainRank: tripleRank)
    }

    private static func recognizeStraight(_ cards: [Card]) -> CardPattern? {
        guard cards.count >= 5 else { return nil }
        // 顺子不能包含 2 和大小王
        guard cards.allSatisfy({ $0.rank.rawValue <= Rank.ace.rawValue }) else { return nil }

        for i in 1..<cards.count {
            if cards[i].rank.rawValue != cards[i-1].rank.rawValue + 1 {
                return nil
            }
        }
        return CardPattern(type: .straight, cards: cards, mainRank: cards.last!.rank)
    }

    private static func recognizePairStraight(_ cards: [Card]) -> CardPattern? {
        guard cards.count >= 6, cards.count % 2 == 0 else { return nil }
        let pairs = stride(from: 0, to: cards.count, by: 2).map { Array(cards[$0..<$0+2]) }

        guard pairs.allSatisfy({ $0[0].rank == $0[1].rank }) else { return nil }
        guard pairs.allSatisfy({ $0[0].rank.rawValue <= Rank.ace.rawValue }) else { return nil }

        for i in 1..<pairs.count {
            if pairs[i][0].rank.rawValue != pairs[i-1][0].rank.rawValue + 1 {
                return nil
            }
        }
        return CardPattern(type: .pairStraight, cards: cards, mainRank: pairs.last![0].rank)
    }

    private static func recognizePlane(_ cards: [Card]) -> CardPattern? {
        let groups = Dictionary(grouping: cards) { $0.rank }
        let triples = groups.filter { $0.value.count >= 3 }
            .keys.sorted()

        guard triples.count >= 2 else { return nil }

        // 飞机的连续三条不能包含2和王（与顺子/连对规则一致）
        guard triples.allSatisfy({ $0.rawValue <= Rank.ace.rawValue }) else { return nil }

        // 检查三条是否连续
        for i in 1..<triples.count {
            if triples[i].rawValue != triples[i-1].rawValue + 1 {
                return nil
            }
        }

        let tripleCount = triples.count
        let wingCount = cards.count - tripleCount * 3

        if wingCount == 0 {
            return CardPattern(type: .plane, cards: cards, mainRank: triples.last!)
        } else if wingCount == tripleCount {
            return CardPattern(type: .planeWithWings, cards: cards, mainRank: triples.last!)
        } else if wingCount == tripleCount * 2 {
            return CardPattern(type: .planeWithWings, cards: cards, mainRank: triples.last!)
        }

        return nil
    }

    private static func recognizeFourWithTwo(_ cards: [Card]) -> CardPattern? {
        guard cards.count == 6 else { return nil }
        let groups = Dictionary(grouping: cards) { $0.rank }
        guard let fourRank = groups.first(where: { $0.value.count == 4 })?.key else {
            return nil
        }
        return CardPattern(type: .fourWithTwo, cards: cards, mainRank: fourRank)
    }

    // MARK: - 智能选牌

    /// 智能选牌：找到包含指定牌的最高得分牌型
    /// 按优先级搜索：火箭 > 炸弹 > 飞机带翅膀 > 飞机 > 连对 > 顺子 > 四带二 > 三带二 > 三带一 > 三条 > 对子 > 单张
    static func bestPattern(containing card: Card, from hand: [Card]) -> CardPattern? {
        guard hand.contains(where: { $0.id == card.id }) else { return nil }

        // 按点数分组，快速查找同点数牌
        let groups = Dictionary(grouping: hand) { $0.rank }
        let targetRank = card.rank

        /// 从同点数牌中取 count 张，确保包含目标牌
        func pick(_ rank: Rank, _ count: Int) -> [Card]? {
            guard let avail = groups[rank], avail.count >= count else { return nil }
            if rank == targetRank {
                return [card] + Array(avail.filter { $0.id != card.id }.prefix(count - 1))
            }
            return Array(avail.prefix(count))
        }

        // =====================================================
        // 1. 火箭：目标牌是王且手牌有大小王 — O(1)
        // =====================================================
        if targetRank == .jokerBlack || targetRank == .jokerRed,
           let blacks = groups[.jokerBlack], !blacks.isEmpty,
           let reds = groups[.jokerRed], !reds.isEmpty {
            if let p = recognize([blacks[0], reds[0]]) { return p }
        }

        // =====================================================
        // 2. 炸弹：目标点数恰好4张 — O(1)
        // =====================================================
        if let g = groups[targetRank], g.count == 4, let p = recognize(g) {
            return p
        }

        // =====================================================
        // 3. 飞机带翅膀：连续三条 + 等量单张/对子翅膀
        // =====================================================
        if let p = bestPlaneWithWings(card: card, hand: hand, groups: groups) {
            return p
        }

        // =====================================================
        // 4. 飞机（纯连续三条，目标牌必须在三条中）
        // =====================================================
        if let p = bestPlane(card: card, groups: groups) {
            return p
        }

        // =====================================================
        // 5. 连对（3+ 连续对子）
        // =====================================================
        if let p = bestPairStraight(card: card, groups: groups) {
            return p
        }

        // =====================================================
        // 6. 顺子（5+ 连续单张）
        // =====================================================
        if let p = bestStraight(card: card, groups: groups) {
            return p
        }

        // =====================================================
        // 7. 四带二：四条 + 2 张踢脚
        // =====================================================
        // 7a: 目标牌在四条中（需要额外踢脚）
        if let g = groups[targetRank], g.count == 4 {
            let usedIds = Set(g.map { $0.id })
            let kickers = hand.filter { !usedIds.contains($0.id) }
            if kickers.count >= 2 {
                if let p = recognize(g + Array(kickers.prefix(2))) { return p }
            }
        }
        // 7b: 目标牌作为踢脚
        for (rank, g) in groups where g.count == 4 && rank != targetRank {
            let usedIds = Set(g.map { $0.id })
            var kickers = [card]
            kickers += hand.filter { !usedIds.contains($0.id) && $0.id != card.id }.prefix(1)
            if kickers.count == 2, let p = recognize(g + kickers) { return p }
        }

        // =====================================================
        // 8. 三带二：三条 + 对子
        // =====================================================
        // 8a: 目标牌在三条中，搭配任意对子
        if let triple = pick(targetRank, 3) {
            let usedIds = Set(triple.map { $0.id })
            let remGroups = Dictionary(grouping: hand.filter { !usedIds.contains($0.id) }) { $0.rank }
            for (_, cards) in remGroups.sorted(by: { $0.key > $1.key }) where cards.count >= 2 {
                if let p = recognize(triple + Array(cards.prefix(2))) { return p }
            }
        }
        // 8b: 目标牌在对子中，搭配任意三条
        if let tg = groups[targetRank], tg.count >= 2 {
            let pair = [card] + Array(tg.filter { $0.id != card.id }.prefix(1))
            for (rank, g) in groups.sorted(by: { $0.key > $1.key }) where rank != targetRank && g.count >= 3 {
                if let p = recognize(Array(g.prefix(3)) + pair) { return p }
            }
        }

        // =====================================================
        // 9. 三带一：三条 + 单张
        // =====================================================
        // 9a: 目标牌在三条中，搭配任意单张
        if let triple = pick(targetRank, 3) {
            let usedIds = Set(triple.map { $0.id })
            if let kicker = hand.first(where: { !usedIds.contains($0.id) }) {
                if let p = recognize(triple + [kicker]) { return p }
            }
        }
        // 9b: 目标牌作为踢脚，搭配任意三条
        for (rank, g) in groups.sorted(by: { $0.key > $1.key }) where rank != targetRank && g.count >= 3 {
            if let p = recognize(Array(g.prefix(3)) + [card]) { return p }
        }

        // =====================================================
        // 10. 三条
        // =====================================================
        if let triple = pick(targetRank, 3), let p = recognize(triple) { return p }

        // =====================================================
        // 11. 对子
        // =====================================================
        if let pair = pick(targetRank, 2), let p = recognize(pair) { return p }

        // =====================================================
        // 12. 单张（兜底，始终有效）
        // =====================================================
        return recognize([card])
    }

    // MARK: - 智能选牌 Private Helpers

    /// 滑动窗口寻找包含目标牌的最优顺子（更长 = 更高分，首个有效即为最优）
    private static func bestStraight(card: Card, groups: [Rank: [Card]]) -> CardPattern? {
        let targetRaw = card.rank.rawValue
        let minRaw = Rank.three.rawValue   // 3
        let maxRaw = Rank.ace.rawValue     // 14
        // 顺子不含 2 和王
        guard targetRaw >= minRaw, targetRaw <= maxRaw else { return nil }

        let maxLen = maxRaw - minRaw + 1   // 12
        for len in stride(from: maxLen, through: 5, by: -1) {
            let wLo = max(minRaw, targetRaw - len + 1)
            let wHi = min(maxRaw - len + 1, targetRaw)
            guard wLo <= wHi else { continue }

            for start in wLo...wHi {
                var cards: [Card] = []
                var ok = true
                for r in start...(start + len - 1) {
                    guard let rank = Rank(rawValue: r),
                          let avail = groups[rank], !avail.isEmpty else { ok = false; break }
                    cards.append(rank == card.rank ? card : avail[0])
                }
                guard ok else { continue }
                if let p = recognize(cards) { return p }
            }
        }
        return nil
    }

    /// 滑动窗口寻找包含目标牌的最优连对
    private static func bestPairStraight(card: Card, groups: [Rank: [Card]]) -> CardPattern? {
        let targetRaw = card.rank.rawValue
        let minRaw = Rank.three.rawValue
        let maxRaw = Rank.ace.rawValue
        // 连对不含 2 和王，且目标点数至少有 2 张
        guard targetRaw >= minRaw, targetRaw <= maxRaw else { return nil }
        guard (groups[card.rank]?.count ?? 0) >= 2 else { return nil }

        let maxPairs = maxRaw - minRaw + 1
        for pairCount in stride(from: maxPairs, through: 3, by: -1) {
            let wLo = max(minRaw, targetRaw - pairCount + 1)
            let wHi = min(maxRaw - pairCount + 1, targetRaw)
            guard wLo <= wHi else { continue }

            for start in wLo...wHi {
                var cards: [Card] = []
                var ok = true
                for r in start...(start + pairCount - 1) {
                    guard let rank = Rank(rawValue: r),
                          let avail = groups[rank], avail.count >= 2 else { ok = false; break }
                    if rank == card.rank {
                        cards.append(card)
                        guard let other = avail.first(where: { $0.id != card.id }) else { ok = false; break }
                        cards.append(other)
                    } else {
                        cards.append(contentsOf: avail.prefix(2))
                    }
                }
                guard ok else { continue }
                if let p = recognize(cards) { return p }
            }
        }
        return nil
    }

    /// 滑动窗口寻找包含目标牌的最优飞机（纯连续三条，目标牌必须在三条中）
    private static func bestPlane(card: Card, groups: [Rank: [Card]]) -> CardPattern? {
        let targetRaw = card.rank.rawValue
        let minRaw = Rank.three.rawValue
        let maxRaw = Rank.ace.rawValue
        guard targetRaw >= minRaw, targetRaw <= maxRaw else { return nil }
        guard (groups[card.rank]?.count ?? 0) >= 3 else { return nil }

        for tripleCount in stride(from: 6, through: 2, by: -1) {
            let wLo = max(minRaw, targetRaw - tripleCount + 1)
            let wHi = min(maxRaw - tripleCount + 1, targetRaw)
            guard wLo <= wHi else { continue }

            for start in wLo...wHi {
                var cards: [Card] = []
                var ok = true
                for r in start...(start + tripleCount - 1) {
                    guard let rank = Rank(rawValue: r),
                          let avail = groups[rank], avail.count >= 3 else { ok = false; break }
                    if rank == card.rank {
                        cards.append(card)
                        cards.append(contentsOf: avail.filter { $0.id != card.id }.prefix(2))
                    } else {
                        cards.append(contentsOf: avail.prefix(3))
                    }
                }
                guard ok else { continue }
                if let p = recognize(cards) { return p }
            }
        }
        return nil
    }

    /// 寻找包含目标牌的最优飞机带翅膀（目标牌可在三条部分或翅膀中）
    private static func bestPlaneWithWings(
        card: Card, hand: [Card], groups: [Rank: [Card]]
    ) -> CardPattern? {
        let minRaw = Rank.three.rawValue
        let maxRaw = Rank.ace.rawValue

        // 从最多连续三条开始尝试（更多三条 = 更高分）
        for tripleCount in stride(from: 6, through: 2, by: -1) {
            var candidates: [CardPattern] = []

            for start in minRaw...(max(minRaw, maxRaw - tripleCount + 1)) {
                let end = start + tripleCount - 1
                guard end <= maxRaw else { continue }

                // 组装三条部分
                var tripleCards: [Card] = []
                var ok = true
                var targetInTriples = false

                for r in start...end {
                    guard let rank = Rank(rawValue: r),
                          let avail = groups[rank], avail.count >= 3 else { ok = false; break }
                    if rank == card.rank {
                        targetInTriples = true
                        tripleCards.append(card)
                        tripleCards.append(contentsOf: avail.filter { $0.id != card.id }.prefix(2))
                    } else {
                        tripleCards.append(contentsOf: avail.prefix(3))
                    }
                }
                guard ok else { continue }

                let usedIds = Set(tripleCards.map { $0.id })
                let remaining = hand.filter { !usedIds.contains($0.id) }

                if targetInTriples {
                    // 目标牌已在三条中，翅膀任选
                    appendWingCandidates(
                        tripleCards: tripleCards, remaining: remaining,
                        tripleCount: tripleCount, mustContain: nil, candidates: &candidates)
                } else if remaining.contains(where: { $0.id == card.id }) {
                    // 目标牌作为翅膀
                    appendWingCandidates(
                        tripleCards: tripleCards, remaining: remaining,
                        tripleCount: tripleCount, mustContain: card, candidates: &candidates)
                }
            }

            // 当前三条数量级别有候选，选得分最高的返回
            if let best = candidates.max(by: {
                Double($0.baseChips) * $0.baseMult < Double($1.baseChips) * $1.baseMult
            }) {
                return best
            }
        }
        return nil
    }

    /// 为飞机三条部分添加翅膀（对子或单张），生成候选牌型
    /// - Parameters:
    ///   - mustContain: 翅膀中必须包含的牌（目标牌作为翅膀时传入）
    private static func appendWingCandidates(
        tripleCards: [Card], remaining: [Card], tripleCount: Int,
        mustContain: Card?, candidates: inout [CardPattern]
    ) {
        let remGroups = Dictionary(grouping: remaining) { $0.rank }

        // 优先尝试对子翅膀（牌数多，得分高）
        var pairWings: [Card] = []
        var usedPairRanks = Set<Rank>()
        // 如果必须包含某张牌，先选它所在的对子
        if let must = mustContain, let tg = remGroups[must.rank], tg.count >= 2 {
            pairWings.append(must)
            if let other = tg.first(where: { $0.id != must.id }) {
                pairWings.append(other)
                usedPairRanks.insert(must.rank)
            }
        }
        for (rank, cards) in remGroups.sorted(by: { $0.key > $1.key }) {
            if pairWings.count / 2 >= tripleCount { break }
            if usedPairRanks.contains(rank) { continue }
            if cards.count >= 2 { pairWings.append(contentsOf: cards.prefix(2)) }
        }
        if pairWings.count == tripleCount * 2 {
            if let p = recognize(tripleCards + pairWings) { candidates.append(p) }
        }

        // 单张翅膀
        if remaining.count >= tripleCount {
            var singleWings: [Card]
            if let must = mustContain {
                singleWings = [must]
                singleWings.append(contentsOf: remaining.filter { $0.id != must.id }.prefix(tripleCount - 1))
            } else {
                singleWings = Array(remaining.prefix(tripleCount))
            }
            if singleWings.count == tripleCount {
                if let p = recognize(tripleCards + singleWings) { candidates.append(p) }
            }
        }
    }
}


