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
            return card.rank == .jokerRed ? SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1)
                : SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1)
        }
        return isRed ? SKColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1)
            : SKColor(red: 0.75, green: 0.85, blue: 1.0, alpha: 1)
    }

    private func drawCard() {
        // 阴影
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width - 2, height: size.height - 2),
                                  cornerRadius: 8)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.5)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -3)
        shadow.zPosition = -1
        addChild(shadow)

        // 卡牌背景 — 暗色主题
        let bg = SKShapeNode(rectOf: size, cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1.0)
        bg.strokeColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.35)
        bg.lineWidth = 1.0
        addChild(bg)

        // Inner subtle gradient effect (lighter at top, darker at bottom)
        let innerGlow = SKShapeNode(rectOf: CGSize(width: size.width - 4, height: size.height - 4),
                                     cornerRadius: 6)
        innerGlow.fillColor = SKColor(red: 0.18, green: 0.18, blue: 0.25, alpha: 0.5)
        innerGlow.strokeColor = .clear
        innerGlow.position = CGPoint(x: 0, y: size.height * 0.05)
        innerGlow.alpha = 0.6
        addChild(innerGlow)

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

        // 右上角：点数（确保被叠时仍可见）
        let rightRank = SKLabelNode(text: rankText)
        rightRank.fontName = "Helvetica-Bold"
        rightRank.fontSize = size.width * 0.28
        rightRank.fontColor = color
        rightRank.horizontalAlignmentMode = .right
        rightRank.verticalAlignmentMode = .top
        rightRank.position = CGPoint(x: size.width / 2 - 5, y: size.height / 2 - 5)
        addChild(rightRank)

        // 右上角花色
        let rightSuit = SKLabelNode(text: suitText)
        rightSuit.fontSize = size.width * 0.20
        rightSuit.fontColor = color
        rightSuit.horizontalAlignmentMode = .right
        rightSuit.verticalAlignmentMode = .top
        rightSuit.position = CGPoint(x: size.width / 2 - 5, y: size.height / 2 - size.width * 0.31)
        addChild(rightSuit)

        // 中央大花色
        let centerSuit = SKLabelNode(text: suitText)
        centerSuit.fontSize = size.width * 0.5
        centerSuit.fontColor = color.withAlphaComponent(0.4)
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

        // 顶部文字 — 书法衬线字体
        let serifFont = Theme.spriteKitSerifFontName
        let topLabel = SKLabelNode(text: isRed ? "大" : "小")
        topLabel.fontName = serifFont
        topLabel.fontSize = size.width * 0.3
        topLabel.fontColor = color
        topLabel.horizontalAlignmentMode = .left
        topLabel.verticalAlignmentMode = .top
        topLabel.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 5)
        addChild(topLabel)

        // 右上角 大/小 标识
        let rightLabel = SKLabelNode(text: isRed ? "大" : "小")
        rightLabel.fontName = serifFont
        rightLabel.fontSize = size.width * 0.28
        rightLabel.fontColor = color
        rightLabel.horizontalAlignmentMode = .right
        rightLabel.verticalAlignmentMode = .top
        rightLabel.position = CGPoint(x: size.width / 2 - 5, y: size.height / 2 - 5)
        addChild(rightLabel)

        // 中央大王/小王 emoji
        let emoji = SKLabelNode(text: isRed ? "👑" : "🃏")
        emoji.fontSize = size.width * 0.5
        emoji.verticalAlignmentMode = .center
        emoji.position = CGPoint(x: 0, y: 2)
        addChild(emoji)

        // Joker special glow
        let jokerGlow = SKShapeNode(circleOfRadius: size.width * 0.35)
        jokerGlow.fillColor = (isRed ? SKColor.red : SKColor.purple).withAlphaComponent(0.08)
        jokerGlow.strokeColor = .clear
        jokerGlow.position = CGPoint(x: 0, y: 2)
        jokerGlow.zPosition = -0.5
        addChild(jokerGlow)

        // 底部 — 书法衬线字体
        let botLabel = SKLabelNode(text: "王")
        botLabel.fontName = serifFont
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

        // Move up + slight scale
        let moveUp = SKAction.moveBy(x: 0, y: selectedOffset, duration: 0.12)
        moveUp.timingMode = .easeOut
        let scaleUp = SKAction.scale(to: 1.08, duration: 0.12)
        scaleUp.timingMode = .easeOut
        run(SKAction.group([moveUp, scaleUp]))

        // Glowing highlight border
        let highlight = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: size.height + 4),
                                     cornerRadius: 10)
        highlight.fillColor = .clear
        highlight.strokeColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        highlight.lineWidth = 2.5
        highlight.glowWidth = 5
        highlight.name = "highlight"
        highlight.alpha = 0.8
        addChild(highlight)

        // Pulsing glow
        let pulse = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.6),
                SKAction.fadeAlpha(to: 1.0, duration: 0.6)
            ])
        )
        highlight.run(pulse, withKey: "pulse")
    }

    func deselect() {
        guard isSelected else { return }
        isSelected = false

        let moveDown = SKAction.moveBy(x: 0, y: -selectedOffset, duration: 0.12)
        moveDown.timingMode = .easeOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.12)
        scaleDown.timingMode = .easeOut
        run(SKAction.group([moveDown, scaleDown]))

        childNode(withName: "highlight")?.removeFromParent()
    }
}

