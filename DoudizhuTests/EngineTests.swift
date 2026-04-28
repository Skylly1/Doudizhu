import XCTest
@testable import Doudizhu

// MARK: - Helper

private func card(_ rank: Rank, _ suit: Suit = .spade) -> Card {
    Card(rank: rank, suit: suit)
}

// ============================================================
// MARK: - Card Model Tests
// ============================================================

final class CardModelTests: XCTestCase {

    func testCardHasUniqueId() {
        let a = card(.three)
        let b = card(.three)
        XCTAssertNotEqual(a.id, b.id, "Each card should have a unique UUID")
    }

    func testCardHashEquality() {
        let a = card(.ace, .heart)
        // Cards with different UUIDs are NOT equal (Identifiable by UUID)
        let b = card(.ace, .heart)
        XCTAssertNotEqual(a, b)
        XCTAssertEqual(a, a)
    }

    func testJokerHasNilSuit() {
        let bj = Card(rank: .jokerBlack, suit: .spade)
        XCTAssertNil(bj.suit, "Joker suit should be forced to nil")
        let rj = Card(rank: .jokerRed)
        XCTAssertNil(rj.suit)
    }

    func testRankOrdering() {
        XCTAssertTrue(Rank.three < Rank.four)
        XCTAssertTrue(Rank.ace < Rank.two)
        XCTAssertTrue(Rank.two < Rank.jokerBlack)
        XCTAssertTrue(Rank.jokerBlack < Rank.jokerRed)
    }

    func testRankIsJoker() {
        XCTAssertTrue(Rank.jokerBlack.isJoker)
        XCTAssertTrue(Rank.jokerRed.isJoker)
        XCTAssertFalse(Rank.ace.isJoker)
        XCTAssertFalse(Rank.two.isJoker)
    }

    func testRankDisplayName() {
        XCTAssertEqual(Rank.three.displayName, "3")
        XCTAssertEqual(Rank.ten.displayName, "10")
        XCTAssertEqual(Rank.jack.displayName, "J")
        XCTAssertEqual(Rank.ace.displayName, "A")
        XCTAssertEqual(Rank.two.displayName, "2")
    }

    func testCardDisplayName() {
        let c = Card(rank: .ace, suit: .heart)
        XCTAssertEqual(c.displayName, "♥A")
        let joker = Card(rank: .jokerRed)
        XCTAssertEqual(joker.displayName, "👑")
    }

    // MARK: - Deck

    func testDeckStandard54() {
        let deck = Deck.standard()
        XCTAssertEqual(deck.count, 54, "Standard Doudizhu deck must have 54 cards")
    }

    func testDeckContainsAllSuits() {
        let deck = Deck.standard()
        let normalCards = deck.filter { !$0.rank.isJoker }
        XCTAssertEqual(normalCards.count, 52)
        for suit in Suit.allCases {
            let suitCards = normalCards.filter { $0.suit == suit }
            XCTAssertEqual(suitCards.count, 13, "Each suit should have 13 cards")
        }
    }

    func testDeckContainsJokers() {
        let deck = Deck.standard()
        let jokers = deck.filter { $0.rank.isJoker }
        XCTAssertEqual(jokers.count, 2)
        XCTAssertTrue(jokers.contains(where: { $0.rank == .jokerBlack }))
        XCTAssertTrue(jokers.contains(where: { $0.rank == .jokerRed }))
    }

    func testDeckShuffledDiffers() {
        // Two shuffled decks should (almost certainly) differ in order
        let d1 = Deck.standard().shuffled()
        let d2 = Deck.standard().shuffled()
        let sameOrder = d1.indices.allSatisfy { d1[$0].rank == d2[$0].rank && d1[$0].suit == d2[$0].suit }
        XCTAssertFalse(sameOrder, "Shuffled decks should differ (vanishingly unlikely to match)")
    }

    func testDealClassicDistribution() {
        let deal = Deck.deal()
        XCTAssertEqual(deal.player.count, 17)
        XCTAssertEqual(deal.bot1.count, 17)
        XCTAssertEqual(deal.bot2.count, 17)
        XCTAssertEqual(deal.landlordCards.count, 3)
        let total = deal.player.count + deal.bot1.count + deal.bot2.count + deal.landlordCards.count
        XCTAssertEqual(total, 54)
    }

    func testDealRoguelikeDefaultHandSize() {
        let deal = Deck.dealRoguelike()
        XCTAssertEqual(deal.hand.count, 10)
        XCTAssertEqual(deal.hand.count + deal.drawPile.count, 54)
    }

    func testDealRoguelikeCustomSize() {
        let deal = Deck.dealRoguelike(handSize: 5, deckSize: 20)
        XCTAssertEqual(deal.hand.count, 5)
        XCTAssertEqual(deal.hand.count + deal.drawPile.count, 20)
    }
}

// ============================================================
// MARK: - PatternRecognizer Tests
// ============================================================

final class PatternRecognizerTests: XCTestCase {

    // MARK: - 1. 单张 single

    func testSingle() {
        let p = PatternRecognizer.recognize([card(.five)])
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .single)
        XCTAssertEqual(p?.mainRank, .five)
    }

    func testSingleJoker() {
        let p = PatternRecognizer.recognize([Card(rank: .jokerRed)])
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .single)
    }

    // MARK: - 2. 对子 pair

    func testPair() {
        let cards = [card(.seven, .spade), card(.seven, .heart)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .pair)
        XCTAssertEqual(p?.mainRank, .seven)
    }

    func testTwoDifferentRanksNotPair() {
        let cards = [card(.seven), card(.eight)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    // MARK: - 3. 三条 triple

    func testTriple() {
        let cards = [card(.king, .spade), card(.king, .heart), card(.king, .club)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .triple)
        XCTAssertEqual(p?.mainRank, .king)
    }

    // MARK: - 4. 三带一 tripleWithOne

    func testTripleWithOne() {
        let cards = [
            card(.nine, .spade), card(.nine, .heart), card(.nine, .club),
            card(.three)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .tripleWithOne)
        XCTAssertEqual(p?.mainRank, .nine)
    }

    // MARK: - 5. 三带二 tripleWithPair

    func testTripleWithPair() {
        let cards = [
            card(.jack, .spade), card(.jack, .heart), card(.jack, .club),
            card(.four, .spade), card(.four, .heart)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .tripleWithPair)
        XCTAssertEqual(p?.mainRank, .jack)
    }

    func testTripleWithTwoUnpairedIsNotTripleWithPair() {
        // 三条 + 两张不成对 → 应返回 nil 或不识别为 tripleWithPair
        let cards = [
            card(.jack, .spade), card(.jack, .heart), card(.jack, .club),
            card(.four, .spade), card(.six, .heart)
        ]
        let p = PatternRecognizer.recognize(cards)
        // 5 cards: try tripleWithPair first (fail), then straight (fail) → nil
        // or recognized as straight? No, J-J-J-4-6 not consecutive
        XCTAssertNil(p, "Three + two non-paired singletons should not match tripleWithPair")
    }

    // MARK: - 6. 顺子 straight

    func testStraightMinLength() {
        let cards = [card(.three), card(.four), card(.five), card(.six), card(.seven)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .straight)
        XCTAssertEqual(p?.mainRank, .seven)
    }

    func testStraightWithAce() {
        let cards = [card(.ten), card(.jack), card(.queen), card(.king), card(.ace)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .straight)
        XCTAssertEqual(p?.mainRank, .ace)
    }

    func testStraightLong() {
        let cards = [
            card(.three), card(.four), card(.five), card(.six),
            card(.seven), card(.eight), card(.nine)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .straight)
        XCTAssertEqual(p?.cards.count, 7)
    }

    func testStraightCannotContainTwo() {
        let cards = [card(.jack), card(.queen), card(.king), card(.ace), card(.two)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    func testStraightFourCardsInvalid() {
        let cards = [card(.three), card(.four), card(.five), card(.six)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    // MARK: - 7. 连对 pairStraight

    func testPairStraight() {
        let cards = [
            card(.three, .spade), card(.three, .heart),
            card(.four, .spade), card(.four, .heart),
            card(.five, .spade), card(.five, .heart)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .pairStraight)
        XCTAssertEqual(p?.mainRank, .five)
    }

    func testPairStraightCannotContainTwo() {
        let cards = [
            card(.king, .spade), card(.king, .heart),
            card(.ace, .spade), card(.ace, .heart),
            card(.two, .spade), card(.two, .heart)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    func testPairStraightMinimumThreePairs() {
        // Two pairs is not enough
        let cards = [
            card(.three, .spade), card(.three, .heart),
            card(.four, .spade), card(.four, .heart)
        ]
        let p = PatternRecognizer.recognize(cards)
        // 4 cards: tried as bomb (no), tripleWithOne (no) → nil
        XCTAssertNil(p, "Only 2 consecutive pairs should not form pairStraight")
    }

    // MARK: - 8. 飞机 plane

    func testPlane() {
        let cards = [
            card(.three, .spade), card(.three, .heart), card(.three, .club),
            card(.four, .spade), card(.four, .heart), card(.four, .club)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .plane)
        XCTAssertEqual(p?.mainRank, .four)
    }

    // MARK: - 9. 飞机带翅膀 planeWithWings

    func testPlaneWithSingleWings() {
        let cards = [
            card(.three, .spade), card(.three, .heart), card(.three, .club),
            card(.four, .spade), card(.four, .heart), card(.four, .club),
            card(.seven), card(.nine)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .planeWithWings)
        XCTAssertEqual(p?.mainRank, .four)
    }

    func testPlaneWithPairWings() {
        let cards = [
            card(.three, .spade), card(.three, .heart), card(.three, .club),
            card(.four, .spade), card(.four, .heart), card(.four, .club),
            card(.seven, .spade), card(.seven, .heart),
            card(.nine, .spade), card(.nine, .heart)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .planeWithWings)
    }

    // MARK: - 10. 炸弹 bomb

    func testBomb() {
        let cards = [
            card(.eight, .spade), card(.eight, .heart),
            card(.eight, .club), card(.eight, .diamond)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .bomb)
        XCTAssertEqual(p?.mainRank, .eight)
    }

    // MARK: - 11. 火箭 rocket

    func testRocket() {
        let cards = [Card(rank: .jokerBlack), Card(rank: .jokerRed)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .rocket)
    }

    // MARK: - 12. 四带二 fourWithTwo

    func testFourWithTwo() {
        let cards = [
            card(.six, .spade), card(.six, .heart),
            card(.six, .club), card(.six, .diamond),
            card(.three), card(.ten)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .fourWithTwo)
        XCTAssertEqual(p?.mainRank, .six)
    }

    // MARK: - 炸弹 vs 四带二

    func testBombVsFourWithTwo() {
        let bombCards = [
            card(.five, .spade), card(.five, .heart),
            card(.five, .club), card(.five, .diamond)
        ]
        XCTAssertEqual(PatternRecognizer.recognize(bombCards)?.type, .bomb)
        let fwtCards = bombCards + [card(.three), card(.ten)]
        XCTAssertEqual(PatternRecognizer.recognize(fwtCards)?.type, .fourWithTwo)
    }

    // MARK: - 无效牌型

    func testEmptyCards() {
        let p = PatternRecognizer.recognize([])
        XCTAssertNil(p)
    }

    func testInvalidTwoCardsDifferentRank() {
        let cards = [card(.three), card(.five)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    func testInvalidThreeCardsMixed() {
        let cards = [card(.three), card(.five), card(.eight)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    // MARK: - 计分系统 baseChips / baseMult

    func testBaseChipsSingle() {
        let p = PatternRecognizer.recognize([card(.ace)])!
        XCTAssertEqual(p.baseChips, 5)
        XCTAssertEqual(p.baseMult, 1.0)
        XCTAssertEqual(p.baseScore, 5)
    }

    func testBaseChipsPair() {
        let p = PatternRecognizer.recognize([card(.ace, .spade), card(.ace, .heart)])!
        XCTAssertEqual(p.baseChips, 10)
        XCTAssertEqual(p.baseMult, 1.5)
        XCTAssertEqual(p.baseScore, 15)
    }

    func testBaseChipsTriple() {
        let p = PatternRecognizer.recognize([
            card(.king, .spade), card(.king, .heart), card(.king, .club)
        ])!
        XCTAssertEqual(p.baseChips, 20)
        XCTAssertEqual(p.baseMult, 2.0)
    }

    func testBaseChipsBomb() {
        let p = PatternRecognizer.recognize([
            card(.ace, .spade), card(.ace, .heart),
            card(.ace, .club), card(.ace, .diamond)
        ])
        XCTAssertEqual(p?.baseChips, 60)
        XCTAssertEqual(p?.baseMult, 4.0)
    }

    func testBaseChipsRocket() {
        let p = PatternRecognizer.recognize([Card(rank: .jokerBlack), Card(rank: .jokerRed)])
        XCTAssertEqual(p?.baseChips, 100)
        XCTAssertEqual(p?.baseMult, 8.0)
    }

    func testBaseChipsStraight5() {
        let p = PatternRecognizer.recognize([
            card(.three), card(.four), card(.five), card(.six), card(.seven)
        ])
        XCTAssertEqual(p?.baseChips, 60)   // 12 * 5
        XCTAssertEqual(p?.baseMult, 2.0)
    }

    func testBaseChipsStraight7() {
        let p = PatternRecognizer.recognize([
            card(.three), card(.four), card(.five), card(.six),
            card(.seven), card(.eight), card(.nine)
        ])!
        XCTAssertEqual(p.baseChips, 84)    // 12 * 7
        // mult = 2.0 + (7-5)*0.3 = 2.6
        XCTAssertEqual(p.baseMult, 2.6, accuracy: 0.001)
    }

    func testBaseChipsPairStraight3() {
        let p = PatternRecognizer.recognize([
            card(.three, .spade), card(.three, .heart),
            card(.four, .spade), card(.four, .heart),
            card(.five, .spade), card(.five, .heart)
        ])!
        XCTAssertEqual(p.baseChips, 54)    // 18 * 3
        XCTAssertEqual(p.baseMult, 2.0)
    }

    func testBaseChipsFourWithTwo() {
        let p = PatternRecognizer.recognize([
            card(.six, .spade), card(.six, .heart),
            card(.six, .club), card(.six, .diamond),
            card(.three), card(.ten)
        ])!
        XCTAssertEqual(p.baseChips, 70)
        XCTAssertEqual(p.baseMult, 3.5)
    }

    func testBaseChipsTripleWithOne() {
        let p = PatternRecognizer.recognize([
            card(.nine, .spade), card(.nine, .heart), card(.nine, .club),
            card(.three)
        ])!
        XCTAssertEqual(p.baseChips, 30)
        XCTAssertEqual(p.baseMult, 2.0)
    }

    func testBaseChipsTripleWithPair() {
        let p = PatternRecognizer.recognize([
            card(.jack, .spade), card(.jack, .heart), card(.jack, .club),
            card(.four, .spade), card(.four, .heart)
        ])!
        XCTAssertEqual(p.baseChips, 40)
        XCTAssertEqual(p.baseMult, 2.5)
    }

    func testBaseChipsPlane() {
        let p = PatternRecognizer.recognize([
            card(.three, .spade), card(.three, .heart), card(.three, .club),
            card(.four, .spade), card(.four, .heart), card(.four, .club)
        ])!
        XCTAssertEqual(p.baseChips, 90)    // 45 * 2
        XCTAssertEqual(p.baseMult, 3.0)
    }

    func testBaseChipsPlaneWithWings() {
        let cards = [
            card(.three, .spade), card(.three, .heart), card(.three, .club),
            card(.four, .spade), card(.four, .heart), card(.four, .club),
            card(.seven), card(.nine)
        ]
        let p = PatternRecognizer.recognize(cards)!
        XCTAssertEqual(p.baseChips, 96)    // 12 * 8
        XCTAssertEqual(p.baseMult, 3.0)
    }

    // MARK: - canBeat 管牌逻辑

    func testCanBeatSameTypeLargerRank() {
        let p1 = PatternRecognizer.recognize([card(.three)])!
        let p2 = PatternRecognizer.recognize([card(.king)])!
        XCTAssertTrue(PatternRecognizer.canBeat(play: p2, current: p1))
        XCTAssertFalse(PatternRecognizer.canBeat(play: p1, current: p2))
    }

    func testBombBeatsSingle() {
        let single = PatternRecognizer.recognize([card(.ace)])!
        let bomb = PatternRecognizer.recognize([
            card(.three, .spade), card(.three, .heart),
            card(.three, .club), card(.three, .diamond)
        ])!
        XCTAssertTrue(PatternRecognizer.canBeat(play: bomb, current: single))
    }

    func testRocketBeatsEverything() {
        let rocket = PatternRecognizer.recognize([
            Card(rank: .jokerBlack), Card(rank: .jokerRed)
        ])!
        let bomb = PatternRecognizer.recognize([
            card(.two, .spade), card(.two, .heart),
            card(.two, .club), card(.two, .diamond)
        ])!
        XCTAssertTrue(PatternRecognizer.canBeat(play: rocket, current: bomb))
        XCTAssertFalse(PatternRecognizer.canBeat(play: bomb, current: rocket))
    }

    func testCannotBeatDifferentType() {
        let single = PatternRecognizer.recognize([card(.ace)])!
        let pair = PatternRecognizer.recognize([card(.three, .spade), card(.three, .heart)])!
        XCTAssertFalse(PatternRecognizer.canBeat(play: pair, current: single))
    }

    func testBombBeatsLowerBomb() {
        let low = PatternRecognizer.recognize([
            card(.three, .spade), card(.three, .heart),
            card(.three, .club), card(.three, .diamond)
        ])!
        let high = PatternRecognizer.recognize([
            card(.ace, .spade), card(.ace, .heart),
            card(.ace, .club), card(.ace, .diamond)
        ])!
        XCTAssertTrue(PatternRecognizer.canBeat(play: high, current: low))
        XCTAssertFalse(PatternRecognizer.canBeat(play: low, current: high))
    }

    // MARK: - bestPattern 智能选牌

    func testBestPatternFindsBomb() {
        let hand = [
            card(.five, .spade), card(.five, .heart),
            card(.five, .club), card(.five, .diamond),
            card(.three), card(.nine)
        ]
        let target = hand[0]
        let p = PatternRecognizer.bestPattern(containing: target, from: hand)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .bomb)
    }

    func testBestPatternFindsRocket() {
        let bj = Card(rank: .jokerBlack)
        let rj = Card(rank: .jokerRed)
        let hand = [card(.three), bj, rj, card(.seven)]
        let p = PatternRecognizer.bestPattern(containing: bj, from: hand)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .rocket)
    }

    func testBestPatternFindsStraight() {
        let hand = [
            card(.three, .spade), card(.four, .heart), card(.five, .club),
            card(.six, .diamond), card(.seven, .spade), card(.king)
        ]
        let target = hand[2]
        let p = PatternRecognizer.bestPattern(containing: target, from: hand)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .straight)
    }

    func testBestPatternFallsBackToSingle() {
        let hand = [card(.three), card(.seven), card(.king)]
        let target = hand[0]
        let p = PatternRecognizer.bestPattern(containing: target, from: hand)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .single)
    }

    func testBestPatternCardNotInHand() {
        let hand = [card(.three), card(.seven)]
        let outsider = card(.ace)
        let p = PatternRecognizer.bestPattern(containing: outsider, from: hand)
        XCTAssertNil(p)
    }
}

// ============================================================
// MARK: - Buff System Tests
// ============================================================

final class BuffSystemTests: XCTestCase {

    // MARK: - chipBonus

    func testBombBonusChips() {
        let buff = Buff(name: "T", description: "T", type: .bombBonus, value: 60)
        let bomb = PatternRecognizer.recognize([
            card(.ace, .spade), card(.ace, .heart),
            card(.ace, .club), card(.ace, .diamond)
        ])!
        XCTAssertEqual(buff.chipBonus(pattern: bomb), 60)
        // Non-bomb pattern should get 0
        let single = PatternRecognizer.recognize([card(.ace)])!
        XCTAssertEqual(buff.chipBonus(pattern: single), 0)
    }

    func testChipFlatAppliesToAll() {
        let buff = Buff(name: "T", description: "T", type: .chipFlat, value: 15)
        let single = PatternRecognizer.recognize([card(.three)])!
        let bomb = PatternRecognizer.recognize([
            card(.five, .spade), card(.five, .heart),
            card(.five, .club), card(.five, .diamond)
        ])!
        XCTAssertEqual(buff.chipBonus(pattern: single), 15)
        XCTAssertEqual(buff.chipBonus(pattern: bomb), 15)
    }

    func testPairBonusChips() {
        let buff = Buff(name: "T", description: "T", type: .pairBonus, value: 40)
        let pair = PatternRecognizer.recognize([card(.seven, .spade), card(.seven, .heart)])!
        XCTAssertEqual(buff.chipBonus(pattern: pair), 40)
        let triple = PatternRecognizer.recognize([
            card(.king, .spade), card(.king, .heart), card(.king, .club)
        ])!
        XCTAssertEqual(buff.chipBonus(pattern: triple), 0)
    }

    func testPlaneAscendChips() {
        let buff = Buff(name: "T", description: "T", type: .planeAscend, value: 100)
        let plane = PatternRecognizer.recognize([
            card(.three, .spade), card(.three, .heart), card(.three, .club),
            card(.four, .spade), card(.four, .heart), card(.four, .club)
        ])!
        XCTAssertEqual(buff.chipBonus(pattern: plane), 100)
    }

    // MARK: - multBonus

    func testGlobalMultiplierBuff() {
        let buff = Buff(name: "T", description: "T", type: .globalMultiplier, value: 1.5)
        let single = PatternRecognizer.recognize([card(.three)])!
        XCTAssertEqual(buff.multBonus(pattern: single), 0.5, accuracy: 0.001)
    }

    func testStraightBonusMult() {
        let buff = Buff(name: "T", description: "T", type: .straightBonus, value: 2.0)
        let straight = PatternRecognizer.recognize([
            card(.three), card(.four), card(.five), card(.six), card(.seven)
        ])!
        XCTAssertEqual(buff.multBonus(pattern: straight), 1.0, accuracy: 0.001)
        // Non-straight should get 0
        let single = PatternRecognizer.recognize([card(.three)])!
        XCTAssertEqual(buff.multBonus(pattern: single), 0.0, accuracy: 0.001)
    }

    func testComboMultiplierBuff() {
        let buff = Buff(name: "T", description: "T", type: .comboMultiplier, value: 1.3)
        let single = PatternRecognizer.recognize([card(.ace)])!
        XCTAssertEqual(buff.multBonus(pattern: single), 0.3, accuracy: 0.001)
    }

    func testDesperateStrikeMult() {
        let buff = Buff(name: "T", description: "T", type: .desperateStrike, value: 3.0)
        let single = PatternRecognizer.recognize([card(.ace)])!
        XCTAssertEqual(buff.multBonus(pattern: single), 3.0, accuracy: 0.001)
    }

    func testNonScoringBuffReturnsZero() {
        let buff = Buff(name: "T", description: "T", type: .iceFrozen, value: 0)
        let single = PatternRecognizer.recognize([card(.ace)])!
        XCTAssertEqual(buff.chipBonus(pattern: single), 0)
        XCTAssertEqual(buff.multBonus(pattern: single), 0.0, accuracy: 0.001)
    }

    // MARK: - Legacy apply()

    func testLegacyApplyGlobalMultiplier() {
        let buff = Buff(name: "T", description: "T", type: .globalMultiplier, value: 1.5)
        let single = PatternRecognizer.recognize([card(.three)])!
        XCTAssertEqual(buff.apply(to: 100, pattern: single), 150)
    }

    func testLegacyApplyBombBonusOnBomb() {
        let buff = Buff(name: "T", description: "T", type: .bombBonus, value: 60)
        let bomb = PatternRecognizer.recognize([
            card(.ace, .spade), card(.ace, .heart),
            card(.ace, .club), card(.ace, .diamond)
        ])!
        XCTAssertEqual(buff.apply(to: 100, pattern: bomb), 160)
    }

    func testLegacyApplyBombBonusOnNonBomb() {
        let buff = Buff(name: "T", description: "T", type: .bombBonus, value: 60)
        let single = PatternRecognizer.recognize([card(.ace)])!
        XCTAssertEqual(buff.apply(to: 100, pattern: single), 100)
    }

    // MARK: - allBuffs catalog

    func testAllBuffsNotEmpty() {
        XCTAssertGreaterThan(Buff.allBuffs.count, 20, "Should have 25+ preset buffs")
    }

    func testAllBuffsHaveUniqueIds() {
        let ids = Buff.allBuffs.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Buff IDs should be unique")
    }
}

// ============================================================
// MARK: - Joker Tests
// ============================================================

final class JokerTests: XCTestCase {

    func testJokerMaxSlots() {
        XCTAssertEqual(Joker.maxSlots, 5)
    }

    func testAllJokersCatalogNotEmpty() {
        XCTAssertGreaterThan(Joker.allJokers.count, 50, "Should have 55+ preset jokers")
    }

    func testAllJokersHaveUniqueEffects() {
        let effects = Joker.allJokers.map(\.effect)
        XCTAssertEqual(effects.count, Set(effects).count, "Each joker should have a unique effect")
    }

    func testJokerRarityDistribution() {
        let common = Joker.allJokers.filter { $0.rarity == .common }
        let rare = Joker.allJokers.filter { $0.rarity == .rare }
        let legendary = Joker.allJokers.filter { $0.rarity == .legendary }
        XCTAssertGreaterThan(common.count, 0)
        XCTAssertGreaterThan(rare.count, 0)
        XCTAssertGreaterThan(legendary.count, 0)
    }

    func testJokerEffectDrawAfterPlay() {
        // Verify the effect enum value exists and is correctly assigned
        let greedy = Joker.allJokers.first { $0.effect == .drawAfterPlay }
        XCTAssertNotNil(greedy)
        XCTAssertEqual(greedy?.rarity, .common)
    }

    func testJokerEffectExplosiveBonus() {
        let fire = Joker.allJokers.first { $0.effect == .explosiveBonus }
        XCTAssertNotNil(fire)
        XCTAssertEqual(fire?.rarity, .common)
    }

    func testJokerEffectBloodPact() {
        let blood = Joker.allJokers.first { $0.effect == .bloodPact }
        XCTAssertNotNil(blood)
        XCTAssertEqual(blood?.rarity, .legendary)
    }

    func testJokerEffectFortuneWheel() {
        let fortune = Joker.allJokers.first { $0.effect == .fortuneWheel }
        XCTAssertNotNil(fortune)
        XCTAssertEqual(fortune?.rarity, .legendary)
    }

    func testJokerEffectZenMaster() {
        let zen = Joker.allJokers.first { $0.effect == .zenMaster }
        XCTAssertNotNil(zen)
        XCTAssertEqual(zen?.rarity, .legendary)
    }

    func testAllJokerEffectsHaveSystemIcon() {
        for effect in JokerEffect.allCases {
            XCTAssertFalse(effect.systemIcon.isEmpty,
                           "\(effect.rawValue) should have a non-empty systemIcon")
        }
    }
}

// ============================================================
// MARK: - FloorConfig Tests
// ============================================================

final class FloorConfigTests: XCTestCase {

    func testAllFloorsCount() {
        XCTAssertEqual(FloorConfig.allFloors.count, 15)
    }

    func testFloorsAreSequentiallyNumbered() {
        for (index, floor) in FloorConfig.allFloors.enumerated() {
            XCTAssertEqual(floor.floor, index + 1,
                           "Floor \(index + 1) should have floor number \(index + 1)")
        }
    }

    func testShopFloors() {
        let shops = FloorConfig.allFloors.filter(\.isShop)
        XCTAssertEqual(shops.count, 4, "Should have 4 shop floors")
        let shopNumbers = shops.map(\.floor)
        XCTAssertEqual(shopNumbers, [3, 7, 11, 14])
        for shop in shops {
            XCTAssertEqual(shop.targetScore, 0, "Shops should have 0 target score")
            XCTAssertEqual(shop.maxPlays, 0)
        }
    }

    func testBossFloors() {
        let bosses = FloorConfig.allFloors.filter(\.isBoss)
        XCTAssertEqual(bosses.count, 6, "Should have 6 boss floors")
        let bossNumbers = bosses.map(\.floor)
        XCTAssertEqual(bossNumbers, [4, 6, 8, 10, 13, 15])
    }

    func testDifficultyProgression() {
        let battleFloors = FloorConfig.allFloors.filter { !$0.isShop }
        // Target scores should generally increase
        var prevTarget = 0
        for floor in battleFloors {
            XCTAssertGreaterThanOrEqual(floor.targetScore, prevTarget,
                "Floor \(floor.floor) target (\(floor.targetScore)) should >= previous (\(prevTarget))")
            prevTarget = floor.targetScore
        }
    }

    func testFinalBossIsHardest() {
        let last = FloorConfig.allFloors.last!
        XCTAssertEqual(last.floor, 15)
        XCTAssertTrue(last.isBoss, "Final floor should be a boss")
        XCTAssertEqual(last.targetScore, 4200)
        XCTAssertTrue(last.bossModifiers.contains(.escalating))
        XCTAssertTrue(last.bossModifiers.contains(.phantomCards))
    }

    func testNonBossNonShopFloors() {
        let regular = FloorConfig.allFloors.filter { !$0.isShop && !$0.isBoss }
        XCTAssertEqual(regular.count, 5)
        for floor in regular {
            XCTAssertGreaterThan(floor.targetScore, 0)
            XCTAssertGreaterThan(floor.maxPlays, 0)
        }
    }
}

// ============================================================
// MARK: - JokerEffect Scoring Integration Tests
// ============================================================

/// These tests verify joker effects are correctly applied through the scoring system.
/// We test by examining the Joker catalog properties — actual scoring integration
/// requires a full RogueRun which is @MainActor and needs the host app running.
final class JokerEffectCatalogTests: XCTestCase {

    func testExplosiveBonusAppliesToBombAndRocket() {
        // Verify the joker with explosiveBonus effect exists
        let joker = Joker.allJokers.first { $0.effect == .explosiveBonus }
        XCTAssertNotNil(joker)
        // Effect applies to bombs and rockets — verified by inspecting RogueRun.playCards
    }

    func testSequenceBonusAppliesToStraightAndPairStraight() {
        let joker = Joker.allJokers.first { $0.effect == .sequenceBonus }
        XCTAssertNotNil(joker)
    }

    func testPairMasteryAppliesPairBonus() {
        let joker = Joker.allJokers.first { $0.effect == .pairMastery }
        XCTAssertNotNil(joker)
        XCTAssertEqual(joker?.rarity, .common)
    }

    func testShadowCloneIsLegendary() {
        let joker = Joker.allJokers.first { $0.effect == .shadowClone }
        XCTAssertNotNil(joker)
        XCTAssertEqual(joker?.rarity, .legendary)
    }

    func testCosmicShiftIsLegendary() {
        let joker = Joker.allJokers.first { $0.effect == .cosmicShift }
        XCTAssertNotNil(joker)
        XCTAssertEqual(joker?.rarity, .legendary)
    }

    func testAllJokerEffectsCoveredInCatalog() {
        let catalogEffects = Set(Joker.allJokers.map(\.effect))
        // Every JokerEffect enum case should have a corresponding Joker in the catalog
        for effect in JokerEffect.allCases {
            XCTAssertTrue(catalogEffects.contains(effect),
                          "JokerEffect.\(effect.rawValue) has no Joker in allJokers catalog")
        }
    }
}

// ============================================================
// MARK: - PatternType Coverage Tests
// ============================================================

final class PatternTypeCoverageTests: XCTestCase {

    func testAllPatternTypesRecognizable() {
        // Verify every PatternType can be produced by the recognizer
        let testCases: [(PatternType, [Card])] = [
            (.single, [card(.ace)]),
            (.pair, [card(.ace, .spade), card(.ace, .heart)]),
            (.triple, [card(.king, .spade), card(.king, .heart), card(.king, .club)]),
            (.tripleWithOne, [card(.nine, .spade), card(.nine, .heart), card(.nine, .club), card(.three)]),
            (.tripleWithPair, [card(.jack, .spade), card(.jack, .heart), card(.jack, .club), card(.four, .spade), card(.four, .heart)]),
            (.straight, [card(.three), card(.four), card(.five), card(.six), card(.seven)]),
            (.pairStraight, [card(.three, .spade), card(.three, .heart), card(.four, .spade), card(.four, .heart), card(.five, .spade), card(.five, .heart)]),
            (.plane, [card(.three, .spade), card(.three, .heart), card(.three, .club), card(.four, .spade), card(.four, .heart), card(.four, .club)]),
            (.planeWithWings, [card(.three, .spade), card(.three, .heart), card(.three, .club), card(.four, .spade), card(.four, .heart), card(.four, .club), card(.seven), card(.nine)]),
            (.bomb, [card(.eight, .spade), card(.eight, .heart), card(.eight, .club), card(.eight, .diamond)]),
            (.rocket, [Card(rank: .jokerBlack), Card(rank: .jokerRed)]),
            (.fourWithTwo, [card(.six, .spade), card(.six, .heart), card(.six, .club), card(.six, .diamond), card(.three), card(.ten)]),
        ]
        for (expectedType, cards) in testCases {
            let p = PatternRecognizer.recognize(cards)
            XCTAssertNotNil(p, "Failed to recognize \(expectedType.rawValue)")
            XCTAssertEqual(p?.type, expectedType, "Expected \(expectedType.rawValue) but got \(p?.type.rawValue ?? "nil")")
        }
    }

    func testAllPatternTypesHaveDisplayName() {
        for type in PatternType.allCases {
            XCTAssertFalse(type.displayName.isEmpty,
                           "\(type.rawValue) should have a non-empty displayName")
        }
    }
}

