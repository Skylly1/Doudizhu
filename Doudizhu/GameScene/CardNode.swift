import SpriteKit

/// 单张卡牌的 SpriteKit 节点 — 扑克风格
class CardNode: SKSpriteNode {
    let card: Card
    private var isSelected = false
    private let selectedOffset: CGFloat = 25

    init(card: Card, size: CGSize) {
        self.card = card
        let texture = SKTexture()
        super.init(texture: texture, color: .clear, size: size)

        self.name = "card_\(card.id)"
        isUserInteractionEnabled = false
        drawCard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private var isRed: Bool {
        card.suit == .heart || card.suit == .diamond || card.rank == .jokerRed
    }

    private var isJoker: Bool {
        card.rank == .jokerBlack || card.rank == .jokerRed
    }

    private var cardColor: SKColor {
        if isJoker {
            return card.rank == .jokerRed ? SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1)
                : SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        }
        return isRed ? SKColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1)
            : SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1)
    }

    private func drawCard() {
        // 阴影
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width - 2, height: size.height - 2),
                                  cornerRadius: 8)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        addChild(shadow)

        // 卡牌背景 — 圆角白色底
        let bg = SKShapeNode(rectOf: size, cornerRadius: 8)
        bg.fillColor = .white
        bg.strokeColor = SKColor(white: 0.85, alpha: 1.0)
        bg.lineWidth = 1.5
        addChild(bg)

        // Joker 特殊处理
        if isJoker {
            drawJokerCard()
            return
        }

        let rankText = card.rank.displayName
        let suitText = card.suit?.rawValue ?? ""
        let color = cardColor

        // 左上角：点数 + 花色（竖排）
        let topRank = SKLabelNode(text: rankText)
        topRank.fontName = "Helvetica-Bold"
        topRank.fontSize = size.width * 0.3
        topRank.fontColor = color
        topRank.horizontalAlignmentMode = .left
        topRank.verticalAlignmentMode = .top
        topRank.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 5)
        addChild(topRank)

        let topSuit = SKLabelNode(text: suitText)
        topSuit.fontSize = size.width * 0.22
        topSuit.fontColor = color
        topSuit.horizontalAlignmentMode = .left
        topSuit.verticalAlignmentMode = .top
        topSuit.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - size.width * 0.33)
        addChild(topSuit)

        // 中央大花色
        let centerSuit = SKLabelNode(text: suitText)
        centerSuit.fontSize = size.width * 0.5
        centerSuit.fontColor = color.withAlphaComponent(0.8)
        centerSuit.verticalAlignmentMode = .center
        centerSuit.position = CGPoint(x: 0, y: 0)
        addChild(centerSuit)

        // 右下角（旋转180°）
        let botRank = SKLabelNode(text: rankText)
        botRank.fontName = "Helvetica-Bold"
        botRank.fontSize = size.width * 0.3
        botRank.fontColor = color
        botRank.horizontalAlignmentMode = .right
        botRank.verticalAlignmentMode = .bottom
        botRank.position = CGPoint(x: size.width / 2 - 5, y: -size.height / 2 + size.width * 0.32)
        botRank.zRotation = .pi
        addChild(botRank)

        let botSuit = SKLabelNode(text: suitText)
        botSuit.fontSize = size.width * 0.22
        botSuit.fontColor = color
        botSuit.horizontalAlignmentMode = .right
        botSuit.verticalAlignmentMode = .bottom
        botSuit.position = CGPoint(x: size.width / 2 - 5, y: -size.height / 2 + 5)
        botSuit.zRotation = .pi
        addChild(botSuit)
    }

    private func drawJokerCard() {
        let isRed = card.rank == .jokerRed
        let color = cardColor

        // 顶部文字
        let topLabel = SKLabelNode(text: isRed ? "大" : "小")
        topLabel.fontName = "PingFangSC-Bold"
        topLabel.fontSize = size.width * 0.3
        topLabel.fontColor = color
        topLabel.horizontalAlignmentMode = .left
        topLabel.verticalAlignmentMode = .top
        topLabel.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 5)
        addChild(topLabel)

        // 中央大王/小王 emoji
        let emoji = SKLabelNode(text: isRed ? "👑" : "🃏")
        emoji.fontSize = size.width * 0.5
        emoji.verticalAlignmentMode = .center
        emoji.position = CGPoint(x: 0, y: 2)
        addChild(emoji)

        // 底部
        let botLabel = SKLabelNode(text: "王")
        botLabel.fontName = "PingFangSC-Bold"
        botLabel.fontSize = size.width * 0.26
        botLabel.fontColor = color
        botLabel.verticalAlignmentMode = .center
        botLabel.position = CGPoint(x: 0, y: -size.height / 2 + size.width * 0.25)
        addChild(botLabel)
    }

    // MARK: - 选中状态

    func select() {
        guard !isSelected else { return }
        isSelected = true

        let moveUp = SKAction.moveBy(x: 0, y: selectedOffset, duration: 0.12)
        moveUp.timingMode = .easeOut
        run(moveUp)

        // 选中高亮边框
        let highlight = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: size.height + 4),
                                     cornerRadius: 10)
        highlight.fillColor = .clear
        highlight.strokeColor = .cyan
        highlight.lineWidth = 2.5
        highlight.glowWidth = 3
        highlight.name = "highlight"
        addChild(highlight)
    }

    func deselect() {
        guard isSelected else { return }
        isSelected = false

        let moveDown = SKAction.moveBy(x: 0, y: -selectedOffset, duration: 0.12)
        moveDown.timingMode = .easeOut
        run(moveDown)

        childNode(withName: "highlight")?.removeFromParent()
    }
}

