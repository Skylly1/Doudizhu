import XCTest

// MARK: - Helper

private func card(_ rank: Rank, _ suit: Suit = .spade) -> Card {
    Card(rank: rank, suit: suit)
}

// MARK: - PatternRecognizer 牌型识别测试

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

    // MARK: - 6. 顺子 straight

    func testStraightMinLength() {
        // 最短顺子：5张
        let cards = [card(.three), card(.four), card(.five), card(.six), card(.seven)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .straight)
        XCTAssertEqual(p?.mainRank, .seven)
    }

    func testStraightWithAce() {
        // 10-J-Q-K-A 是合法顺子
        let cards = [card(.ten), card(.jack), card(.queen), card(.king), card(.ace)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.type, .straight)
        XCTAssertEqual(p?.mainRank, .ace)
    }

    func testStraightLong() {
        // 3-4-5-6-7-8-9 七张顺子
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
        // J-Q-K-A-2 不是合法顺子（含2）
        let cards = [card(.jack), card(.queen), card(.king), card(.ace), card(.two)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    func testStraightFourCardsInvalid() {
        // 4张不能成顺子
        let cards = [card(.three), card(.four), card(.five), card(.six)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    // MARK: - 7. 连对 pairStraight

    func testPairStraight() {
        // 3对连对：33-44-55
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
        // KK-AA-22 不合法
        let cards = [
            card(.king, .spade), card(.king, .heart),
            card(.ace, .spade), card(.ace, .heart),
            card(.two, .spade), card(.two, .heart)
        ]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    // MARK: - 8. 飞机 plane

    func testPlane() {
        // 两组连续三条：333-444
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
        // 333-444 + 带2张单牌翅膀
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
        // 333-444 + 带2对翅膀（共10张）
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
        // 4张相同 = bomb
        let bombCards = [
            card(.five, .spade), card(.five, .heart),
            card(.five, .club), card(.five, .diamond)
        ]
        XCTAssertEqual(PatternRecognizer.recognize(bombCards)?.type, .bomb)

        // 4张相同 + 2张 = fourWithTwo
        let fwtCards = bombCards + [card(.three), card(.ten)]
        XCTAssertEqual(PatternRecognizer.recognize(fwtCards)?.type, .fourWithTwo)
    }

    // MARK: - 无效牌型

    func testEmptyCards() {
        let p = PatternRecognizer.recognize([])
        XCTAssertNil(p)
    }

    func testInvalidTwoCardsDifferentRank() {
        // 两张不同点数、非大小王 → nil
        let cards = [card(.three), card(.five)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    func testInvalidThreeCardsMixed() {
        // 3张不同点数 → nil
        let cards = [card(.three), card(.five), card(.eight)]
        let p = PatternRecognizer.recognize(cards)
        XCTAssertNil(p)
    }

    // MARK: - 计分系统 baseChips / baseMult

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
        // straight chips = 12 * count
        XCTAssertEqual(p?.baseChips, 60)
        XCTAssertEqual(p?.baseMult, 2.0)
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

    // MARK: - bestPattern 智能选牌

    func testBestPatternFindsBomb() {
        let hand = [
            card(.five, .spade), card(.five, .heart),
            card(.five, .club), card(.five, .diamond),
            card(.three), card(.nine)
        ]
        let target = hand[0] // ♠5
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
        let target = hand[2] // ♣5
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
