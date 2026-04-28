import Foundation

/// AI 玩家协议
protocol AIPlayerProtocol {
    func choosePlay(hand: [Card], lastPattern: CardPattern?) -> [Card]?
}

/// 规则 AI：基于简单策略的出牌
struct RuleBasedAI: AIPlayerProtocol {
    let difficulty: AIDifficulty

    func choosePlay(hand: [Card], lastPattern: CardPattern?) -> [Card]? {
        guard let lastPattern else {
            // 主动出牌：从最小的单张开始
            return hand.first.map { [$0] }
        }

        // 被动跟牌：找能管上的最小牌型
        let candidates = findValidPlays(hand: hand, toBeat: lastPattern)
        return candidates.first
    }

    /// 找出所有能管上的牌型组合
    private func findValidPlays(hand: [Card], toBeat pattern: CardPattern) -> [[Card]] {
        var results: [[Card]] = []
        let groups = Dictionary(grouping: hand) { $0.rank }

        switch pattern.type {
        case .single:
            for card in hand where card.rank > pattern.mainRank {
                results.append([card])
            }

        case .pair:
            for (rank, cards) in groups where rank > pattern.mainRank && cards.count >= 2 {
                results.append(Array(cards.prefix(2)))
            }

        case .triple:
            for (rank, cards) in groups where rank > pattern.mainRank && cards.count >= 3 {
                results.append(Array(cards.prefix(3)))
            }

        case .tripleWithOne:
            for (rank, cards) in groups where rank > pattern.mainRank && cards.count >= 3 {
                let triple = Array(cards.prefix(3))
                let usedIds = Set(triple.map(\.id))
                if let kicker = hand.first(where: { !usedIds.contains($0.id) }) {
                    results.append(triple + [kicker])
                }
            }

        case .tripleWithPair:
            for (rank, cards) in groups where rank > pattern.mainRank && cards.count >= 3 {
                let triple = Array(cards.prefix(3))
                let usedIds = Set(triple.map(\.id))
                let remaining = hand.filter { !usedIds.contains($0.id) }
                let remGroups = Dictionary(grouping: remaining) { $0.rank }
                if let pairEntry = remGroups.first(where: { $0.value.count >= 2 }) {
                    results.append(triple + Array(pairEntry.value.prefix(2)))
                }
            }

        case .bomb:
            for (rank, cards) in groups where rank > pattern.mainRank && cards.count == 4 {
                results.append(cards)
            }

        case .straight:
            let targetLen = pattern.cards.count
            let minRaw = Rank.three.rawValue
            let maxRaw = Rank.ace.rawValue
            // Find all straights of the same length with higher mainRank
            for start in minRaw...(maxRaw - targetLen + 1) {
                let endRaw = start + targetLen - 1
                guard let endRank = Rank(rawValue: endRaw), endRank > pattern.mainRank else { continue }
                var straightCards: [Card] = []
                var ok = true
                for r in start...endRaw {
                    guard let rank = Rank(rawValue: r),
                          let avail = groups[rank], !avail.isEmpty else { ok = false; break }
                    straightCards.append(avail[0])
                }
                if ok { results.append(straightCards) }
            }

        case .pairStraight:
            let targetPairs = pattern.cards.count / 2
            let minRaw = Rank.three.rawValue
            let maxRaw = Rank.ace.rawValue
            for start in minRaw...(maxRaw - targetPairs + 1) {
                let endRaw = start + targetPairs - 1
                guard let endRank = Rank(rawValue: endRaw), endRank > pattern.mainRank else { continue }
                var pairCards: [Card] = []
                var ok = true
                for r in start...endRaw {
                    guard let rank = Rank(rawValue: r),
                          let avail = groups[rank], avail.count >= 2 else { ok = false; break }
                    pairCards.append(contentsOf: avail.prefix(2))
                }
                if ok { results.append(pairCards) }
            }

        case .fourWithTwo:
            for (rank, cards) in groups where rank > pattern.mainRank && cards.count == 4 {
                let usedIds = Set(cards.map(\.id))
                let kickers = hand.filter { !usedIds.contains($0.id) }
                if kickers.count >= 2 {
                    results.append(cards + Array(kickers.prefix(2)))
                }
            }

        case .plane, .planeWithWings:
            // Simplified: skip complex plane matching for AI
            break

        case .rocket:
            // Nothing beats rocket
            break
        }

        // 炸弹和火箭可以管任何非炸弹/火箭牌型
        if pattern.type != .bomb && pattern.type != .rocket {
            for (_, cards) in groups where cards.count == 4 {
                results.append(cards)
            }
        }

        // 检查火箭
        let jokers = hand.filter { $0.rank.isJoker }
        if jokers.count == 2 && pattern.type != .rocket {
            results.append(jokers)
        }

        // 按牌力从小到大排序（优先出小牌）
        results.sort { ($0.first?.rank ?? .three) < ($1.first?.rank ?? .three) }

        return results
    }
}

enum AIDifficulty: String, Codable {
    case easy
    case medium
    case hard
    case boss
}
