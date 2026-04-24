import Foundation

// MARK: - 牌型

/// 斗地主所有合法牌型
enum PatternType: String, Codable, Hashable {
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
        case .single:         return "单张"
        case .pair:           return "对子"
        case .triple:         return "三条"
        case .tripleWithOne:  return "三带一"
        case .tripleWithPair: return "三带二"
        case .straight:       return "顺子"
        case .pairStraight:   return "连对"
        case .plane:          return "飞机"
        case .planeWithWings: return "飞机带翅膀"
        case .bomb:           return "💣 炸弹"
        case .rocket:         return "🚀 火箭"
        case .fourWithTwo:    return "四带二"
        }
    }
}

/// 已识别的牌型
struct CardPattern: Hashable {
    let type: PatternType
    let cards: [Card]
    let mainRank: Rank   // 用于比较大小的主要点数

    /// 基础得分（Roguelike 模式下的计分基础）
    var baseScore: Int {
        switch type {
        case .single:         return 5
        case .pair:           return 10
        case .triple:         return 20
        case .tripleWithOne:  return 25
        case .tripleWithPair: return 30
        case .straight:       return 15 * cards.count
        case .pairStraight:   return 20 * (cards.count / 2)
        case .plane:          return 50 * (cards.count / 3)
        case .planeWithWings: return 60 * (cards.count / 4)
        case .bomb:           return 100
        case .rocket:         return 200
        case .fourWithTwo:    return 80
        }
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
}
