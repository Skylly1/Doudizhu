import SpriteKit

/// 单张卡牌的 SpriteKit 节点
class CardNode: SKSpriteNode {
    let card: Card
    private var isSelected = false
    private let selectedOffset: CGFloat = 20

    init(card: Card, size: CGSize) {
        self.card = card
        let texture = SKTexture() // placeholder
        super.init(texture: texture, color: .clear, size: size)

        self.name = "card_\(card.id)"
        isUserInteractionEnabled = false
        drawCard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private func drawCard() {
        // 卡牌背景
        let bg = SKShapeNode(rectOf: size, cornerRadius: 6)
        bg.fillColor = .white
        bg.strokeColor = SKColor(white: 0.8, alpha: 1.0)
        bg.lineWidth = 1
        addChild(bg)

        // 花色+点数颜色
        let isRed = card.suit == .heart || card.suit == .diamond || card.rank == .jokerRed

        // 点数文字
        let rankLabel = SKLabelNode(text: card.rank.displayName)
        rankLabel.fontName = "Helvetica-Bold"
        rankLabel.fontSize = 22
        rankLabel.fontColor = isRed ? .red : .black
        rankLabel.verticalAlignmentMode = .center
        rankLabel.position = CGPoint(x: 0, y: 8)
        addChild(rankLabel)

        // 花色文字
        if let suit = card.suit {
            let suitLabel = SKLabelNode(text: suit.rawValue)
            suitLabel.fontSize = 14
            suitLabel.fontColor = isRed ? .red : .black
            suitLabel.verticalAlignmentMode = .center
            suitLabel.position = CGPoint(x: 0, y: -14)
            addChild(suitLabel)
        }
    }

    func select() {
        guard !isSelected else { return }
        isSelected = true
        let moveUp = SKAction.moveBy(x: 0, y: selectedOffset, duration: 0.1)
        moveUp.timingMode = .easeOut
        run(moveUp)
    }

    func deselect() {
        guard isSelected else { return }
        isSelected = false
        let moveDown = SKAction.moveBy(x: 0, y: -selectedOffset, duration: 0.1)
        moveDown.timingMode = .easeOut
        run(moveDown)
    }
}
