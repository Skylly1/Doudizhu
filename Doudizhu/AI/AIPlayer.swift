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

        switch pattern.type {
        case .single:
            // 找更大的单张
            for card in hand where card.rank > pattern.mainRank {
                results.append([card])
            }

        case .pair:
            let groups = Dictionary(grouping: hand) { $0.rank }
            for (rank, cards) in groups where rank > pattern.mainRank && cards.count >= 2 {
                results.append(Array(cards.prefix(2)))
            }

        case .bomb:
            let groups = Dictionary(grouping: hand) { $0.rank }
            for (rank, cards) in groups where rank > pattern.mainRank && cards.count == 4 {
                results.append(cards)
            }

        default:
            // TODO: 实现更复杂的牌型匹配
            break
        }

        // 炸弹和火箭可以管任何非炸弹/火箭牌型
        if pattern.type != .bomb && pattern.type != .rocket {
            let groups = Dictionary(grouping: hand) { $0.rank }
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
