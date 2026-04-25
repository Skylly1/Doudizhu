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
            // 赤金大王 / 翡翠小王（在象牙白底上需要更饱和）
            return card.rank == .jokerRed
                ? SKColor(red: 0.78, green: 0.55, blue: 0.12, alpha: 1)
                : SKColor(red: 0.0, green: 0.48, blue: 0.42, alpha: 1)
        }
        // 朱砂红 / 墨黑（传统扑克配色：红黑分明）
        return isRed
            ? SKColor(red: 0.72, green: 0.08, blue: 0.08, alpha: 1)
            : SKColor(red: 0.10, green: 0.08, blue: 0.06, alpha: 1)
    }

    private func drawCard() {
        // 卡牌背景 — 圆角裁切，避免白边溢出
        let bg = SKShapeNode(rectOf: size, cornerRadius: 6)
        bg.fillColor = SKColor(red: 0.96, green: 0.93, blue: 0.87, alpha: 1.0)
        bg.strokeColor = SKColor(red: 0.65, green: 0.55, blue: 0.42, alpha: 0.45)
        bg.lineWidth = 0.8
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
        let serifFont = Theme.spriteKitSerifFontName
        let topRank = SKLabelNode(text: rankText)
        topRank.fontName = serifFont
        topRank.fontSize = size.width * 0.28
        topRank.fontColor = color
        topRank.horizontalAlignmentMode = .left
        topRank.verticalAlignmentMode = .top
        topRank.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 4)
        addChild(topRank)

        let topSuit = SKLabelNode(text: suitText)
        topSuit.fontSize = size.width * 0.18
        topSuit.fontColor = color
        topSuit.horizontalAlignmentMode = .left
        topSuit.verticalAlignmentMode = .top
        topSuit.position = CGPoint(x: -size.width / 2 + 6, y: size.height / 2 - size.width * 0.30)
        addChild(topSuit)

        // 中央大花色
        let centerSuit = SKLabelNode(text: suitText)
        centerSuit.fontSize = size.width * 0.45
        centerSuit.fontColor = color.withAlphaComponent(0.65)
        centerSuit.verticalAlignmentMode = .center
        centerSuit.position = CGPoint(x: 0, y: -2)
        addChild(centerSuit)

        // 右下角（旋转180°）
        let botRank = SKLabelNode(text: rankText)
        botRank.fontName = serifFont
        botRank.fontSize = size.width * 0.28
        botRank.fontColor = color
        botRank.horizontalAlignmentMode = .right
        botRank.verticalAlignmentMode = .bottom
        botRank.position = CGPoint(x: size.width / 2 - 5, y: -size.height / 2 + size.width * 0.22)
        botRank.zRotation = .pi
        addChild(botRank)

        let botSuit = SKLabelNode(text: suitText)
        botSuit.fontSize = size.width * 0.18
        botSuit.fontColor = color
        botSuit.horizontalAlignmentMode = .right
        botSuit.verticalAlignmentMode = .bottom
        botSuit.position = CGPoint(x: size.width / 2 - 6, y: -size.height / 2 + 4)
        botSuit.zRotation = .pi
        addChild(botSuit)
    }

    private func drawJokerCard() {
        let isRedJoker = card.rank == .jokerRed
        let color = cardColor

        let serifFont = Theme.spriteKitSerifFontName

        // 左上角标识
        let topLabel = SKLabelNode(text: isRedJoker ? "大" : "小")
        topLabel.fontName = serifFont
        topLabel.fontSize = size.width * 0.28
        topLabel.fontColor = color
        topLabel.horizontalAlignmentMode = .left
        topLabel.verticalAlignmentMode = .top
        topLabel.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 4)
        addChild(topLabel)

        // 中央大"王"字
        let centerKing = SKLabelNode(text: "王")
        centerKing.fontName = serifFont
        centerKing.fontSize = size.width * 0.50
        centerKing.fontColor = color
        centerKing.verticalAlignmentMode = .center
        centerKing.position = CGPoint(x: 0, y: 0)
        addChild(centerKing)

        // 底部标注
        let botLabel = SKLabelNode(text: isRedJoker ? "大王" : "小王")
        botLabel.fontName = serifFont
        botLabel.fontSize = size.width * 0.18
        botLabel.fontColor = color.withAlphaComponent(0.5)
        botLabel.verticalAlignmentMode = .center
        botLabel.position = CGPoint(x: 0, y: -size.height / 2 + size.width * 0.18)
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

        // 赤金发光描边
        let highlight = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: size.height + 4),
                                     cornerRadius: 8)
        highlight.fillColor = .clear
        highlight.strokeColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 1.0)
        highlight.lineWidth = 2.5
        highlight.glowWidth = 6
        highlight.name = "highlight"
        highlight.alpha = 0.9
        addChild(highlight)

        // 内层柔光晕
        let innerGlow = SKShapeNode(rectOf: CGSize(width: size.width + 2, height: size.height + 2),
                                     cornerRadius: 7)
        innerGlow.fillColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 0.06)
        innerGlow.strokeColor = .clear
        innerGlow.name = "innerGlow"
        addChild(innerGlow)

        // Pulsing glow
        let pulse = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.6),
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
        childNode(withName: "innerGlow")?.removeFromParent()
    }
}

