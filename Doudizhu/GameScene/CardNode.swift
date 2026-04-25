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
        // 阴影 — 暖色调
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width - 2, height: size.height - 2),
                                  cornerRadius: 8)
        shadow.fillColor = SKColor(red: 0.06, green: 0.04, blue: 0.02, alpha: 0.4)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -3)
        shadow.zPosition = -1
        addChild(shadow)

        // 卡牌背景 — 象牙白牌面（仿真实扑克牌）
        let bg = SKShapeNode(rectOf: size, cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.95, green: 0.92, blue: 0.86, alpha: 1.0)
        bg.strokeColor = SKColor(red: 0.72, green: 0.62, blue: 0.48, alpha: 0.5)
        bg.lineWidth = 1.0
        addChild(bg)

        // 宣纸纹理层（淡黄古纸质感）
        let textureBg = SKShapeNode(rectOf: CGSize(width: size.width - 4, height: size.height - 4),
                                     cornerRadius: 6)
        textureBg.fillColor = SKColor(red: 0.90, green: 0.86, blue: 0.78, alpha: 0.25)
        textureBg.strokeColor = .clear
        textureBg.position = CGPoint(x: 0, y: size.height * 0.03)
        textureBg.alpha = 0.4
        addChild(textureBg)

        // 四角回纹装饰（中式传统纹样）— 加强可见度
        for (dx, dy) in [(-1, 1), (1, 1), (-1, -1), (1, -1)] as [(CGFloat, CGFloat)] {
            let corner = SKShapeNode()
            let path = CGMutablePath()
            let cx = dx * (size.width / 2 - 6)
            let cy = dy * (size.height / 2 - 6)
            let len: CGFloat = 8
            path.move(to: CGPoint(x: cx - dx * len, y: cy))
            path.addLine(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: cx, y: cy - dy * len))
            corner.path = path
            corner.strokeColor = SKColor(red: 0.72, green: 0.55, blue: 0.35, alpha: 0.40)
            corner.lineWidth = 0.8
            corner.fillColor = .clear
            addChild(corner)
        }

        // 牌面内框线（仿真实扑克牌的内边框）
        let innerBorder = SKShapeNode(rectOf: CGSize(width: size.width - 8, height: size.height - 8),
                                       cornerRadius: 5)
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = SKColor(red: 0.72, green: 0.55, blue: 0.35, alpha: 0.12)
        innerBorder.lineWidth = 0.5
        addChild(innerBorder)

        // Joker 特殊处理
        if isJoker {
            drawJokerCard()
            return
        }

        let rankText = card.rank.displayName
        let suitText = card.suit?.rawValue ?? ""
        let color = cardColor

        // 左上角：点数 + 花色（竖排）— 宋体书法风
        let serifFont = Theme.spriteKitSerifFontName
        let topRank = SKLabelNode(text: rankText)
        topRank.fontName = serifFont
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
        rightRank.fontName = serifFont
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

        // 中央大花色 — 水印效果（象牙白底上需要更淡）
        let centerSuit = SKLabelNode(text: suitText)
        centerSuit.fontSize = size.width * 0.5
        centerSuit.fontColor = color.withAlphaComponent(0.12)
        centerSuit.verticalAlignmentMode = .center
        centerSuit.position = CGPoint(x: 0, y: 0)
        addChild(centerSuit)

        // 右下角（旋转180°）
        let botRank = SKLabelNode(text: rankText)
        botRank.fontName = serifFont
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

        // 中央大"王"字书法
        let centerKing = SKLabelNode(text: "王")
        centerKing.fontName = serifFont
        centerKing.fontSize = size.width * 0.55
        centerKing.fontColor = color
        centerKing.verticalAlignmentMode = .center
        centerKing.position = CGPoint(x: 0, y: 2)
        addChild(centerKing)

        // 发光光环（赤金/翡翠青）
        let jokerGlow = SKShapeNode(circleOfRadius: size.width * 0.35)
        jokerGlow.fillColor = color.withAlphaComponent(0.1)
        jokerGlow.strokeColor = color.withAlphaComponent(0.25)
        jokerGlow.lineWidth = 1.5
        jokerGlow.position = CGPoint(x: 0, y: 2)
        jokerGlow.zPosition = -0.5
        addChild(jokerGlow)

        // 脉冲发光动画
        let pulse = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.8),
                SKAction.fadeAlpha(to: 1.0, duration: 0.8)
            ])
        )
        jokerGlow.run(pulse)

        // 底部 "大王"/"小王" 完整标注
        let botLabel = SKLabelNode(text: isRed ? "大王" : "小王")
        botLabel.fontName = serifFont
        botLabel.fontSize = size.width * 0.2
        botLabel.fontColor = color.withAlphaComponent(0.6)
        botLabel.verticalAlignmentMode = .center
        botLabel.position = CGPoint(x: 0, y: -size.height / 2 + size.width * 0.2)
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
                                     cornerRadius: 10)
        highlight.fillColor = .clear
        highlight.strokeColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 1.0)
        highlight.lineWidth = 2.5
        highlight.glowWidth = 8
        highlight.name = "highlight"
        highlight.alpha = 0.9
        addChild(highlight)

        // 内层柔光晕
        let innerGlow = SKShapeNode(rectOf: CGSize(width: size.width + 2, height: size.height + 2),
                                     cornerRadius: 9)
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

