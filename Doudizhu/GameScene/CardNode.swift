import SpriteKit

/// 单张卡牌的 SpriteKit 节点 — 扑克风格
class CardNode: SKSpriteNode {
    let card: Card
    private var isSelected = false
    private let selectedOffset: CGFloat = 20

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
            return card.rank == .jokerRed
                ? SKColor(red: 0.82, green: 0.58, blue: 0.14, alpha: 1)  // 赤金
                : SKColor(red: 0.12, green: 0.52, blue: 0.46, alpha: 1)  // 翡翠
        }
        return isRed
            ? SKColor(red: 0.80, green: 0.12, blue: 0.12, alpha: 1)      // 朱砂红
            : SKColor(red: 0.14, green: 0.12, blue: 0.10, alpha: 1)      // 墨黑
    }

    private func drawCard() {
        // 柔和阴影
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height), cornerRadius: 6)
        shadow.fillColor = SKColor(white: 0, alpha: 0.22)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1, y: -2)
        shadow.zPosition = -2
        addChild(shadow)

        // 卡牌主体 — 暖白底 + 精致描边
        let bg = SKShapeNode(rectOf: size, cornerRadius: 6)
        bg.fillColor = SKColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1.0)
        bg.strokeColor = SKColor(red: 0.65, green: 0.58, blue: 0.45, alpha: 0.45)
        bg.lineWidth = 0.8
        bg.zPosition = -1
        addChild(bg)

        // 内边框 — 双线效果增加精致感
        let innerBorder = SKShapeNode(rectOf: CGSize(width: size.width - 6, height: size.height - 6), cornerRadius: 4)
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = SKColor(red: 0.72, green: 0.65, blue: 0.52, alpha: 0.15)
        innerBorder.lineWidth = 0.5
        innerBorder.zPosition = 0
        addChild(innerBorder)

        // 顶部高光边 — 纸牌质感
        let hlPath = CGMutablePath()
        hlPath.move(to: CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 0.5))
        hlPath.addLine(to: CGPoint(x: size.width / 2 - 5, y: size.height / 2 - 0.5))
        let topHighlight = SKShapeNode(path: hlPath)
        topHighlight.strokeColor = SKColor(white: 1, alpha: 0.25)
        topHighlight.lineWidth = 0.5
        topHighlight.zPosition = 0
        addChild(topHighlight)

        // Joker 特殊处理
        if isJoker {
            drawJokerCard()
            return
        }

        let rankText = card.rank.displayName
        let suitText = card.suit?.rawValue ?? ""
        let color = cardColor
        let serifFont = Theme.spriteKitSerifFontName

        // 左上角：点数 — 粗体清晰
        let topRank = SKLabelNode(text: rankText)
        topRank.fontName = serifFont
        topRank.fontSize = size.width * 0.36
        topRank.fontColor = color
        topRank.horizontalAlignmentMode = .left
        topRank.verticalAlignmentMode = .top
        topRank.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 4)
        topRank.zPosition = 2
        addChild(topRank)

        // 左上角：花色（紧贴点数下方）
        let topSuit = SKLabelNode(text: suitText)
        topSuit.fontSize = size.width * 0.22
        topSuit.fontColor = color
        topSuit.horizontalAlignmentMode = .left
        topSuit.verticalAlignmentMode = .top
        topSuit.position = CGPoint(x: -size.width / 2 + 6, y: size.height / 2 - size.width * 0.38)
        topSuit.zPosition = 2
        addChild(topSuit)

        // 中央大花色 — 视觉锚点
        let centerSuit = SKLabelNode(text: suitText)
        centerSuit.fontSize = size.width * 0.55
        centerSuit.fontColor = color.withAlphaComponent(0.18)
        centerSuit.horizontalAlignmentMode = .center
        centerSuit.verticalAlignmentMode = .center
        centerSuit.position = CGPoint(x: 0, y: -size.height * 0.05)
        centerSuit.zPosition = 1
        addChild(centerSuit)

        // 右下角：点数（倒置镜像 — 标准扑克牌布局）
        let bottomRank = SKLabelNode(text: rankText)
        bottomRank.fontName = serifFont
        bottomRank.fontSize = size.width * 0.28
        bottomRank.fontColor = color.withAlphaComponent(0.6)
        bottomRank.horizontalAlignmentMode = .right
        bottomRank.verticalAlignmentMode = .bottom
        bottomRank.position = CGPoint(x: size.width / 2 - 5, y: -size.height / 2 + 4)
        bottomRank.zPosition = 2
        bottomRank.xScale = -1
        bottomRank.yScale = -1
        addChild(bottomRank)

        // 右下角：花色（倒置）
        let bottomSuit = SKLabelNode(text: suitText)
        bottomSuit.fontSize = size.width * 0.18
        bottomSuit.fontColor = color.withAlphaComponent(0.5)
        bottomSuit.horizontalAlignmentMode = .right
        bottomSuit.verticalAlignmentMode = .bottom
        bottomSuit.position = CGPoint(x: size.width / 2 - 5, y: -size.height / 2 + size.width * 0.28)
        bottomSuit.zPosition = 2
        bottomSuit.xScale = -1
        bottomSuit.yScale = -1
        addChild(bottomSuit)

        // 角落装饰纹 — 精致小点
        let dotRadius: CGFloat = 1.2
        let dotPositions: [CGPoint] = [
            CGPoint(x: -size.width / 2 + 8, y: -size.height / 2 + 8),
            CGPoint(x: size.width / 2 - 8, y: size.height / 2 - 8),
        ]
        for pos in dotPositions {
            let dot = SKShapeNode(circleOfRadius: dotRadius)
            dot.fillColor = color.withAlphaComponent(0.12)
            dot.strokeColor = .clear
            dot.position = pos
            dot.zPosition = 1
            addChild(dot)
        }
    }

    private func drawJokerCard() {
        let isRedJoker = card.rank == .jokerRed
        let color = cardColor
        let serifFont = Theme.spriteKitSerifFontName

        // 特殊背景色调 — 区别于普通牌
        let tintOverlay = SKShapeNode(rectOf: CGSize(width: size.width - 2, height: size.height - 2), cornerRadius: 5)
        tintOverlay.fillColor = isRedJoker
            ? SKColor(red: 0.95, green: 0.92, blue: 0.85, alpha: 1.0)
            : SKColor(red: 0.90, green: 0.94, blue: 0.93, alpha: 1.0)
        tintOverlay.strokeColor = .clear
        tintOverlay.zPosition = 0
        addChild(tintOverlay)

        // 左上角标识
        let topLabel = SKLabelNode(text: isRedJoker ? "大" : "小")
        topLabel.fontName = serifFont
        topLabel.fontSize = size.width * 0.36
        topLabel.fontColor = color
        topLabel.horizontalAlignmentMode = .left
        topLabel.verticalAlignmentMode = .top
        topLabel.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 4)
        topLabel.zPosition = 3
        addChild(topLabel)

        // "王"字（紧跟左上角下方）
        let kingLabel = SKLabelNode(text: "王")
        kingLabel.fontName = serifFont
        kingLabel.fontSize = size.width * 0.28
        kingLabel.fontColor = color.withAlphaComponent(0.7)
        kingLabel.horizontalAlignmentMode = .left
        kingLabel.verticalAlignmentMode = .top
        kingLabel.position = CGPoint(x: -size.width / 2 + 6, y: size.height / 2 - size.width * 0.38)
        kingLabel.zPosition = 3
        addChild(kingLabel)

        // 中央大图标 — 视觉主体
        let centerIcon = SKLabelNode(text: isRedJoker ? "👑" : "🃏")
        centerIcon.fontSize = size.width * 0.45
        centerIcon.horizontalAlignmentMode = .center
        centerIcon.verticalAlignmentMode = .center
        centerIcon.position = CGPoint(x: 0, y: -size.height * 0.05)
        centerIcon.zPosition = 2
        addChild(centerIcon)

        // 中央装饰光晕
        let glow = SKShapeNode(circleOfRadius: size.width * 0.28)
        glow.fillColor = color.withAlphaComponent(0.06)
        glow.strokeColor = color.withAlphaComponent(0.10)
        glow.lineWidth = 0.5
        glow.position = CGPoint(x: 0, y: -size.height * 0.05)
        glow.zPosition = 1
        addChild(glow)

        // 右下角倒置标记
        let bottomLabel = SKLabelNode(text: isRedJoker ? "大" : "小")
        bottomLabel.fontName = serifFont
        bottomLabel.fontSize = size.width * 0.24
        bottomLabel.fontColor = color.withAlphaComponent(0.5)
        bottomLabel.horizontalAlignmentMode = .right
        bottomLabel.verticalAlignmentMode = .bottom
        bottomLabel.position = CGPoint(x: size.width / 2 - 5, y: -size.height / 2 + 4)
        bottomLabel.zPosition = 3
        bottomLabel.xScale = -1
        bottomLabel.yScale = -1
        addChild(bottomLabel)
    }

    // MARK: - 选中状态

    func select() {
        guard !isSelected else { return }
        isSelected = true

        let moveUp = SKAction.moveBy(x: 0, y: selectedOffset, duration: 0.12)
        moveUp.timingMode = .easeOut
        let scaleUp = SKAction.scale(to: 1.06, duration: 0.12)
        scaleUp.timingMode = .easeOut
        run(SKAction.group([moveUp, scaleUp]))

        // 金色选中边框 — 双层辉光
        let highlight = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: size.height + 4),
                                     cornerRadius: 7)
        highlight.fillColor = .clear
        highlight.strokeColor = SKColor(red: 0.85, green: 0.68, blue: 0.28, alpha: 0.90)
        highlight.lineWidth = 2.5
        highlight.glowWidth = 5
        highlight.name = "highlight"
        addChild(highlight)

        // 底部金色光晕
        let bottomGlow = SKShapeNode(rectOf: CGSize(width: size.width - 4, height: 3), cornerRadius: 1.5)
        bottomGlow.fillColor = SKColor(red: 0.85, green: 0.68, blue: 0.28, alpha: 0.4)
        bottomGlow.strokeColor = .clear
        bottomGlow.position = CGPoint(x: 0, y: -size.height / 2 - 4)
        bottomGlow.name = "highlight_glow"
        bottomGlow.zPosition = -1
        addChild(bottomGlow)

        let pulse = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.50, duration: 0.6),
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
        childNode(withName: "highlight_glow")?.removeFromParent()
    }
}

