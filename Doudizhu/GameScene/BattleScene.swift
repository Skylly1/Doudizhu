import SpriteKit

/// 牌桌 SpriteKit 场景
class BattleScene: SKScene {
    var rogueRun: RogueRun?

    private var cardNodes: [CardNode] = []
    private var selectedCards: Set<UUID> = []

    // 布局常量
    private let cardWidth: CGFloat = 60
    private let cardHeight: CGFloat = 90
    private let cardOverlap: CGFloat = 30

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1.0)
        layoutHand()
    }

    /// 排列手牌
    private func layoutHand() {
        cardNodes.forEach { $0.removeFromParent() }
        cardNodes.removeAll()

        guard let cards = rogueRun?.handCards else { return }

        let totalWidth = CGFloat(cards.count - 1) * cardOverlap + cardWidth
        let startX = (size.width - totalWidth) / 2 + cardWidth / 2

        for (index, card) in cards.enumerated() {
            let node = CardNode(card: card, size: CGSize(width: cardWidth, height: cardHeight))
            node.position = CGPoint(
                x: startX + CGFloat(index) * cardOverlap,
                y: cardHeight / 2 + 40
            )
            node.zPosition = CGFloat(index)
            addChild(node)
            cardNodes.append(node)
        }
    }

    // MARK: - 触摸交互

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 从最上层开始检测
        for node in cardNodes.reversed() {
            if node.contains(location) {
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

    /// 出牌（外部调用）
    func playSelectedCards() {
        let selectedCardList = cardNodes
            .filter { selectedCards.contains($0.card.id) }
            .map(\.card)

        guard let result = rogueRun?.playCards(selectedCardList) else {
            // 无效牌型，抖动提示
            shakeSelected()
            return
        }

        // 移除已出的牌
        let playedIds = selectedCards
        cardNodes.removeAll { playedIds.contains($0.card.id) }
        selectedCards.removeAll()

        // 显示得分动画
        showScorePopup(result.score, at: CGPoint(x: size.width / 2, y: size.height / 2))

        // 重新排列手牌
        layoutHand()
    }

    // MARK: - 动画

    private func showScorePopup(_ score: Int, at position: CGPoint) {
        let label = SKLabelNode(text: "+\(score)")
        label.fontName = "Helvetica-Bold"
        label.fontSize = 36
        label.fontColor = .yellow
        label.position = position
        label.zPosition = 100
        addChild(label)

        let moveUp = SKAction.moveBy(x: 0, y: 80, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let group = SKAction.group([moveUp, fadeOut])
        label.run(SKAction.sequence([group, .removeFromParent()]))
    }

    private func shakeSelected() {
        for node in cardNodes where selectedCards.contains(node.card.id) {
            let shake = SKAction.sequence([
                .moveBy(x: -5, y: 0, duration: 0.05),
                .moveBy(x: 10, y: 0, duration: 0.05),
                .moveBy(x: -10, y: 0, duration: 0.05),
                .moveBy(x: 5, y: 0, duration: 0.05),
            ])
            node.run(shake)
        }
    }
}
