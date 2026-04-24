import SpriteKit

/// 牌桌 SpriteKit 场景
class BattleScene: SKScene {
    var rogueRun: RogueRun?

    private var cardNodes: [CardNode] = []
    private var selectedCards: Set<UUID> = []
    private var playedAreaNode: SKNode = SKNode()

    // 布局常量
    private let cardWidth: CGFloat = 60
    private let cardHeight: CGFloat = 90
    private let cardOverlap: CGFloat = 30

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1.0)

        // 出牌区域
        playedAreaNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(playedAreaNode)

        // 桌面装饰
        drawTableDecor()

        layoutHand()
    }

    private func drawTableDecor() {
        // 中央出牌区域提示
        let circle = SKShapeNode(circleOfRadius: 80)
        circle.fillColor = SKColor.white.withAlphaComponent(0.03)
        circle.strokeColor = SKColor.white.withAlphaComponent(0.08)
        circle.lineWidth = 1
        circle.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        addChild(circle)

        let hint = SKLabelNode(text: "出牌区")
        hint.fontName = "PingFangSC-Light"
        hint.fontSize = 14
        hint.fontColor = SKColor.white.withAlphaComponent(0.15)
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.5 - 6)
        hint.name = "hint"
        addChild(hint)
    }

    /// 排列手牌
    func layoutHand() {
        cardNodes.forEach { $0.removeFromParent() }
        cardNodes.removeAll()
        selectedCards.removeAll()

        guard let cards = rogueRun?.handCards, !cards.isEmpty else { return }

        let overlap = min(cardOverlap, (size.width - 40 - cardWidth) / CGFloat(cards.count - 1))
        let totalWidth = CGFloat(cards.count - 1) * overlap + cardWidth
        let startX = (size.width - totalWidth) / 2 + cardWidth / 2

        for (index, card) in cards.enumerated() {
            let node = CardNode(card: card, size: CGSize(width: cardWidth, height: cardHeight))
            node.position = CGPoint(
                x: startX + CGFloat(index) * overlap,
                y: cardHeight / 2 + 120
            )
            node.zPosition = CGFloat(index)

            // 入场动画：从底部弹入
            let finalY = node.position.y
            node.position.y = -cardHeight
            node.alpha = 0
            let delay = SKAction.wait(forDuration: Double(index) * 0.03)
            let moveUp = SKAction.moveTo(y: finalY, duration: 0.3)
            moveUp.timingMode = .easeOut
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            node.run(SKAction.sequence([delay, SKAction.group([moveUp, fadeIn])]))

            addChild(node)
            cardNodes.append(node)
        }
    }

    // MARK: - 公开接口

    func refreshHand() {
        // 清除出牌区
        playedAreaNode.removeAllChildren()
        layoutHand()
    }

    func getSelectedCards() -> [Card] {
        cardNodes
            .filter { selectedCards.contains($0.card.id) }
            .map(\.card)
    }

    func clearSelection() {
        for node in cardNodes where selectedCards.contains(node.card.id) {
            node.deselect()
        }
        selectedCards.removeAll()
    }

    /// 出牌
    func playSelectedCards() {
        let selectedCardList = getSelectedCards()
        guard !selectedCardList.isEmpty else { return }

        guard let result = rogueRun?.playCards(selectedCardList) else {
            shakeSelected()
            return
        }

        // 出牌动画：选中的牌飞到中央
        showPlayedCards(selectedCardList, pattern: result.pattern)

        // 显示得分
        showScorePopup(result)

        // 移除已出的牌节点
        let playedIds = selectedCards
        cardNodes.filter { playedIds.contains($0.card.id) }.forEach { node in
            let flyTo = CGPoint(x: size.width / 2, y: size.height * 0.5)
            let move = SKAction.move(to: flyTo, duration: 0.25)
            move.timingMode = .easeIn
            let scale = SKAction.scale(to: 0.7, duration: 0.25)
            node.run(SKAction.group([move, scale]))
        }
        cardNodes.removeAll { playedIds.contains($0.card.id) }
        selectedCards.removeAll()
    }

    // MARK: - 触摸交互

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard rogueRun?.phase == .selecting else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for node in cardNodes.reversed() {
            if node.frame.contains(location) {
                toggleSelection(node)
                break
            }
        }
    }

    private func toggleSelection(_ node: CardNode) {
        let cardId = node.card.id

        if selectedCards.contains(cardId) {
            selectedCards.remove(cardId)
            node.deselect()
        } else {
            selectedCards.insert(cardId)
            node.select()
        }
    }

    // MARK: - 动画

    private func showPlayedCards(_ cards: [Card], pattern: CardPattern) {
        playedAreaNode.removeAllChildren()

        // 在出牌区显示打出的牌型名
        let patternLabel = SKLabelNode(text: pattern.type.displayName)
        patternLabel.fontName = "PingFangSC-Semibold"
        patternLabel.fontSize = 20
        patternLabel.fontColor = .cyan
        patternLabel.position = CGPoint(x: 0, y: 60)
        playedAreaNode.addChild(patternLabel)

        // 显示打出的牌（缩小版）
        let smallSize = CGSize(width: 40, height: 60)
        let overlap: CGFloat = 22
        let totalW = CGFloat(cards.count - 1) * overlap + smallSize.width
        let startX = -totalW / 2 + smallSize.width / 2

        for (i, card) in cards.enumerated() {
            let miniCard = CardNode(card: card, size: smallSize)
            miniCard.position = CGPoint(x: startX + CGFloat(i) * overlap, y: 0)
            miniCard.zPosition = CGFloat(i)
            miniCard.alpha = 0
            miniCard.setScale(0.5)

            let appear = SKAction.group([
                .fadeIn(withDuration: 0.2),
                .scale(to: 1.0, duration: 0.2)
            ])
            miniCard.run(SKAction.sequence([
                .wait(forDuration: 0.25),
                appear
            ]))

            playedAreaNode.addChild(miniCard)
        }
    }

    private func showScorePopup(_ result: PlayResult) {
        let y = size.height * 0.5 + 110

        // 分数
        let scoreText = "+\(result.score)"
        let label = SKLabelNode(text: scoreText)
        label.fontName = "Helvetica-Bold"
        label.fontSize = result.score >= 100 ? 44 : 36
        label.fontColor = result.score >= 100 ? SKColor.orange : SKColor.yellow
        label.position = CGPoint(x: size.width / 2, y: y)
        label.zPosition = 100
        label.setScale(0.3)
        addChild(label)

        let popIn = SKAction.scale(to: 1.2, duration: 0.15)
        let settle = SKAction.scale(to: 1.0, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.5)
        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 0.4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        label.run(SKAction.sequence([
            popIn, settle, wait,
            SKAction.group([moveUp, fadeOut]),
            .removeFromParent()
        ]))

        // 连击提示
        if result.combo > 1 {
            let comboLabel = SKLabelNode(text: "\(result.combo)x COMBO!")
            comboLabel.fontName = "Helvetica-Bold"
            comboLabel.fontSize = 18
            comboLabel.fontColor = SKColor.orange
            comboLabel.position = CGPoint(x: size.width / 2, y: y - 35)
            comboLabel.zPosition = 100
            addChild(comboLabel)

            let comboAnim = SKAction.sequence([
                .wait(forDuration: 0.3),
                SKAction.group([
                    .moveBy(x: 0, y: 30, duration: 0.6),
                    .fadeOut(withDuration: 0.6)
                ]),
                .removeFromParent()
            ])
            comboLabel.run(comboAnim)
        }
    }

    private func shakeSelected() {
        for node in cardNodes where selectedCards.contains(node.card.id) {
            let originalPos = node.position
            let shake = SKAction.sequence([
                .moveBy(x: -6, y: 0, duration: 0.04),
                .moveBy(x: 12, y: 0, duration: 0.04),
                .moveBy(x: -12, y: 0, duration: 0.04),
                .moveBy(x: 6, y: 0, duration: 0.04),
                .move(to: originalPos, duration: 0.03),
            ])
            node.run(shake)
        }
    }
}
