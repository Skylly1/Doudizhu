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
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height), cornerRadius: 5)
        shadow.fillColor = SKColor(white: 0, alpha: 0.18)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0.5, y: -1.5)
        shadow.zPosition = -2
        addChild(shadow)

        // 卡牌主体 — 暖白底 + 精致细边
        let bg = SKShapeNode(rectOf: size, cornerRadius: 5)
        bg.fillColor = SKColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1.0)
        bg.strokeColor = SKColor(red: 0.70, green: 0.62, blue: 0.50, alpha: 0.35)
        bg.lineWidth = 0.5
        bg.zPosition = -1
        addChild(bg)

        // 顶部高光边 — 纸牌质感
        let hlPath = CGMutablePath()
        hlPath.move(to: CGPoint(x: -size.width / 2 + 4, y: size.height / 2 - 0.5))
        hlPath.addLine(to: CGPoint(x: size.width / 2 - 4, y: size.height / 2 - 0.5))
        let topHighlight = SKShapeNode(path: hlPath)
        topHighlight.strokeColor = SKColor(white: 1, alpha: 0.20)
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

        // 左上角：点数 — 视觉核心，大号加粗
        let serifFont = Theme.spriteKitSerifFontName
        let topRank = SKLabelNode(text: rankText)
        topRank.fontName = serifFont
        topRank.fontSize = size.width * 0.36
        topRank.fontColor = color
        topRank.horizontalAlignmentMode = .left
        topRank.verticalAlignmentMode = .top
        topRank.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 4)
        topRank.zPosition = 1
        addChild(topRank)

        // 左上角：花色
        let topSuit = SKLabelNode(text: suitText)
        topSuit.fontSize = size.width * 0.20
        topSuit.fontColor = color
        topSuit.horizontalAlignmentMode = .left
        topSuit.verticalAlignmentMode = .top
        topSuit.position = CGPoint(x: -size.width / 2 + 6, y: size.height / 2 - size.width * 0.38)
        topSuit.zPosition = 1
        addChild(topSuit)

        // 中央花色 — 低调水印
        let centerSuit = SKLabelNode(text: suitText)
        centerSuit.fontSize = size.width * 0.42
        centerSuit.fontColor = color.withAlphaComponent(0.15)
        centerSuit.verticalAlignmentMode = .center
        centerSuit.horizontalAlignmentMode = .center
        centerSuit.position = CGPoint(x: 2, y: -4)
        centerSuit.zPosition = 1
        addChild(centerSuit)

        // 右下角镜像 — 淡化处理
        let botRank = SKLabelNode(text: rankText)
        botRank.fontName = serifFont
        botRank.fontSize = size.width * 0.24
        botRank.fontColor = color.withAlphaComponent(0.40)
        botRank.horizontalAlignmentMode = .right
        botRank.verticalAlignmentMode = .bottom
        botRank.position = CGPoint(x: size.width / 2 - 5, y: -size.height / 2 + size.width * 0.20)
        botRank.zRotation = .pi
        botRank.zPosition = 1
        addChild(botRank)

        let botSuit = SKLabelNode(text: suitText)
        botSuit.fontSize = size.width * 0.14
        botSuit.fontColor = color.withAlphaComponent(0.30)
        botSuit.horizontalAlignmentMode = .right
        botSuit.verticalAlignmentMode = .bottom
        botSuit.position = CGPoint(x: size.width / 2 - 6, y: -size.height / 2 + 4)
        botSuit.zRotation = .pi
        botSuit.zPosition = 1
        addChild(botSuit)
    }

    private func drawJokerCard() {
        let isRedJoker = card.rank == .jokerRed
        let color = cardColor
        let serifFont = Theme.spriteKitSerifFontName

        // 左上角标识
        let topLabel = SKLabelNode(text: isRedJoker ? "大" : "小")
        topLabel.fontName = serifFont
        topLabel.fontSize = size.width * 0.34
        topLabel.fontColor = color
        topLabel.horizontalAlignmentMode = .left
        topLabel.verticalAlignmentMode = .top
        topLabel.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 4)
        topLabel.zPosition = 2
        addChild(topLabel)

        // 中央光晕
        let glow = SKShapeNode(circleOfRadius: size.width * 0.26)
        glow.fillColor = color.withAlphaComponent(0.06)
        glow.strokeColor = color.withAlphaComponent(0.08)
        glow.lineWidth = 0.5
        glow.position = CGPoint(x: 0, y: -2)
        glow.zPosition = 1
        addChild(glow)

        // 中央"王"字
        let centerKing = SKLabelNode(text: "王")
        centerKing.fontName = serifFont
        centerKing.fontSize = size.width * 0.48
        centerKing.fontColor = color
        centerKing.verticalAlignmentMode = .center
        centerKing.horizontalAlignmentMode = .center
        centerKing.position = CGPoint(x: 0, y: -2)
        centerKing.zPosition = 2
        addChild(centerKing)

        // 右下角镜像
        let botLabel = SKLabelNode(text: isRedJoker ? "大" : "小")
        botLabel.fontName = serifFont
        botLabel.fontSize = size.width * 0.22
        botLabel.fontColor = color.withAlphaComponent(0.35)
        botLabel.horizontalAlignmentMode = .right
        botLabel.verticalAlignmentMode = .bottom
        botLabel.position = CGPoint(x: size.width / 2 - 5, y: -size.height / 2 + 4)
        botLabel.zRotation = .pi
        botLabel.zPosition = 2
        addChild(botLabel)
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

        // 金色选中边框
        let highlight = SKShapeNode(rectOf: CGSize(width: size.width + 3, height: size.height + 3),
                                     cornerRadius: 6)
        highlight.fillColor = .clear
        highlight.strokeColor = SKColor(red: 0.85, green: 0.68, blue: 0.28, alpha: 0.85)
        highlight.lineWidth = 2.0
        highlight.glowWidth = 4
        highlight.name = "highlight"
        addChild(highlight)

        let pulse = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.55, duration: 0.6),
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

