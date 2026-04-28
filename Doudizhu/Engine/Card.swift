import Foundation

// MARK: - 花色

enum Suit: String, CaseIterable, Codable, Hashable {
    case spade   = "♠"
    case heart   = "♥"
    case club    = "♣"
    case diamond = "♦"
}

// MARK: - 点数

/// 斗地主牌面值，按大小排序（3最小，大王最大）
enum Rank: Int, CaseIterable, Codable, Comparable, Hashable {
    case three = 3
    case four, five, six, seven, eight, nine, ten
    case jack = 11
    case queen = 12
    case king = 13
    case ace = 14      // A
    case two = 15      // 2
    case jokerBlack = 16  // 小王
    case jokerRed = 17    // 大王

    static func < (lhs: Rank, rhs: Rank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .three: "3"
        case .four: "4"
        case .five: "5"
        case .six: "6"
        case .seven: "7"
        case .eight: "8"
        case .nine: "9"
        case .ten: "10"
        case .jack: "J"
        case .queen: "Q"
        case .king: "K"
        case .ace: "A"
        case .two: "2"
        case .jokerBlack: "🃏"
        case .jokerRed: "👑"
        }
    }

    var isJoker: Bool {
        self == .jokerBlack || self == .jokerRed
    }
}

// MARK: - 卡牌

struct Card: Identifiable, Hashable, Codable {
    let id: UUID
    let rank: Rank
    let suit: Suit?  // 大小王没有花色

    init(rank: Rank, suit: Suit? = nil) {
        self.id = UUID()
        self.rank = rank
        self.suit = rank.isJoker ? nil : suit
    }

    var displayName: String {
        if let suit {
            return "\(suit.rawValue)\(rank.displayName)"
        }
        return rank.displayName
    }
}

// MARK: - 一副牌

struct Deck {
    /// 生成一副完整的54张斗地主牌
    static func standard() -> [Card] {
        var cards: [Card] = []

        // 52张普通牌
        for suit in Suit.allCases {
            for rank in Rank.allCases where !rank.isJoker {
                cards.append(Card(rank: rank, suit: suit))
            }
        }

        // 大小王
        cards.append(Card(rank: .jokerBlack))
        cards.append(Card(rank: .jokerRed))

        return cards
    }

    /// 洗牌并发牌：3人各17张 + 3张底牌（经典模式，保留兼容）
    static func deal() -> (player: [Card], bot1: [Card], bot2: [Card], landlordCards: [Card]) {
        var cards = standard().shuffled()
        let landlordCards = Array(cards.suffix(3))
        cards.removeLast(3)

        let player = Array(cards[0..<17]).sorted { $0.rank < $1.rank }
        let bot1 = Array(cards[17..<34]).sorted { $0.rank < $1.rank }
        let bot2 = Array(cards[34..<51]).sorted { $0.rank < $1.rank }

        return (player, bot1, bot2, landlordCards)
    }

    /// Roguelike 模式发牌：发指定数量手牌，剩余作为牌堆
    /// - Parameter seed: 若提供种子，使用确定性洗牌（日挑战同天同牌序）
    static func dealRoguelike(handSize: Int = 10, deckSize: Int? = nil, seed: UInt64? = nil) -> (hand: [Card], drawPile: [Card]) {
        var cards: [Card]
        if let seed {
            var rng = SeededRandomNumberGenerator(seed: seed)
            cards = standard().shuffled(using: &rng)
        } else {
            cards = standard().shuffled()
        }
        // 精简牌组：仅保留前 N 张
        if let size = deckSize, size < cards.count {
            cards = Array(cards.prefix(size))
        }
        let actualHandSize = min(handSize, cards.count)
        let hand = Array(cards.prefix(actualHandSize)).sorted { $0.rank < $1.rank }
        let drawPile = Array(cards.dropFirst(actualHandSize))
        return (hand, drawPile)
    }
}

// MARK: - 确定性随机数生成器（日挑战种子洗牌）

/// SplitMix64 — 快速、确定性的 PRNG，保证同种子同序列
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
}
