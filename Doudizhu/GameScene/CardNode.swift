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

        let serifFont = Theme.spriteKitSerifFontName

        // 左上角：点数 — 大号清晰，核心信息
        let topRank = SKLabelNode(text: rankText)
        topRank.fontName = serifFont
        topRank.fontSize = size.width * 0.38
        topRank.fontColor = color
        topRank.horizontalAlignmentMode = .left
        topRank.verticalAlignmentMode = .top
        topRank.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 3)
        topRank.zPosition = 1
        addChild(topRank)

        // 左上角：花色（紧贴点数下方）
        let topSuit = SKLabelNode(text: suitText)
        topSuit.fontSize = size.width * 0.22
        topSuit.fontColor = color
        topSuit.horizontalAlignmentMode = .left
        topSuit.verticalAlignmentMode = .top
        topSuit.position = CGPoint(x: -size.width / 2 + 6, y: size.height / 2 - size.width * 0.40)
        topSuit.zPosition = 1
        addChild(topSuit)

        // 右上角：小花色（辅助识别，扇形展开时可见）
        let topRightSuit = SKLabelNode(text: suitText)
        topRightSuit.fontSize = size.width * 0.16
        topRightSuit.fontColor = color.withAlphaComponent(0.35)
        topRightSuit.horizontalAlignmentMode = .right
        topRightSuit.verticalAlignmentMode = .top
        topRightSuit.position = CGPoint(x: size.width / 2 - 5, y: size.height / 2 - 4)
        topRightSuit.zPosition = 1
        addChild(topRightSuit)
    }

    private func drawJokerCard() {
        let isRedJoker = card.rank == .jokerRed
        let color = cardColor
        let serifFont = Theme.spriteKitSerifFontName

        // 左上角标识
        let topLabel = SKLabelNode(text: isRedJoker ? "大" : "小")
        topLabel.fontName = serifFont
        topLabel.fontSize = size.width * 0.36
        topLabel.fontColor = color
        topLabel.horizontalAlignmentMode = .left
        topLabel.verticalAlignmentMode = .top
        topLabel.position = CGPoint(x: -size.width / 2 + 5, y: size.height / 2 - 3)
        topLabel.zPosition = 2
        addChild(topLabel)

        // "王"字（紧跟左上角下方）
        let kingLabel = SKLabelNode(text: "王")
        kingLabel.fontName = serifFont
        kingLabel.fontSize = size.width * 0.28
        kingLabel.fontColor = color.withAlphaComponent(0.7)
        kingLabel.horizontalAlignmentMode = .left
        kingLabel.verticalAlignmentMode = .top
        kingLabel.position = CGPoint(x: -size.width / 2 + 6, y: size.height / 2 - size.width * 0.38)
        kingLabel.zPosition = 2
        addChild(kingLabel)

        // 右上角小标记
        let topRightLabel = SKLabelNode(text: isRedJoker ? "大" : "小")
        topRightLabel.fontName = serifFont
        topRightLabel.fontSize = size.width * 0.16
        topRightLabel.fontColor = color.withAlphaComponent(0.35)
        topRightLabel.horizontalAlignmentMode = .right
        topRightLabel.verticalAlignmentMode = .top
        topRightLabel.position = CGPoint(x: size.width / 2 - 5, y: size.height / 2 - 4)
        topRightLabel.zPosition = 2
        addChild(topRightLabel)
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

