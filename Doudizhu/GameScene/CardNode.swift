import SpriteKit

/// 单张卡牌的 SpriteKit 节点 — 国潮扑克风格
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

    private var isFaceCard: Bool {
        card.rank == .jack || card.rank == .queen || card.rank == .king
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

    /// 花色对应的淡彩底色（微妙区分四种花色）
    private var suitTint: SKColor {
        guard let suit = card.suit else { return .clear }
        switch suit {
        case .heart:   return SKColor(red: 0.98, green: 0.94, blue: 0.92, alpha: 1.0) // 暖粉
        case .diamond: return SKColor(red: 0.98, green: 0.96, blue: 0.90, alpha: 1.0) // 暖黄
        case .spade:   return SKColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1.0) // 冷灰蓝
        case .club:    return SKColor(red: 0.93, green: 0.95, blue: 0.93, alpha: 1.0) // 淡青
        }
    }

    private func drawCard() {
        let w = size.width
        let h = size.height

        // 柔和阴影
        let shadow = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 6)
        shadow.fillColor = SKColor(white: 0, alpha: 0.22)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1, y: -2)
        shadow.zPosition = -2
        addChild(shadow)

        // 卡牌主体 — 暖白底
        let bg = SKShapeNode(rectOf: size, cornerRadius: 6)
        bg.fillColor = SKColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1.0)
        bg.strokeColor = SKColor(red: 0.65, green: 0.58, blue: 0.45, alpha: 0.45)
        bg.lineWidth = 0.8
        bg.zPosition = -1
        addChild(bg)

        // 花色底色（微妙的花色区分 — 只在普通牌上）
        if !isJoker {
            let tint = SKShapeNode(rectOf: CGSize(width: w - 2, height: h - 2), cornerRadius: 5)
            tint.fillColor = suitTint
            tint.strokeColor = .clear
            tint.zPosition = -0.5
            addChild(tint)
        }

        // 内边框 — 双线效果
        let innerBorder = SKShapeNode(rectOf: CGSize(width: w - 6, height: h - 6), cornerRadius: 4)
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = SKColor(red: 0.72, green: 0.65, blue: 0.52, alpha: 0.15)
        innerBorder.lineWidth = 0.5
        innerBorder.zPosition = 0
        addChild(innerBorder)

        // 顶部高光边 — 纸牌质感
        let hlPath = CGMutablePath()
        hlPath.move(to: CGPoint(x: -w / 2 + 5, y: h / 2 - 0.5))
        hlPath.addLine(to: CGPoint(x: w / 2 - 5, y: h / 2 - 0.5))
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
        let margin: CGFloat = max(3, w * 0.07)

        // 左上角：点数
        let topRank = SKLabelNode(text: rankText)
        topRank.fontName = serifFont
        topRank.fontSize = w * 0.34
        topRank.fontColor = color
        topRank.horizontalAlignmentMode = .left
        topRank.verticalAlignmentMode = .top
        topRank.position = CGPoint(x: -w / 2 + margin, y: h / 2 - margin)
        topRank.zPosition = 2
        addChild(topRank)

        // 左上角：花色
        let topSuit = SKLabelNode(text: suitText)
        topSuit.fontSize = w * 0.20
        topSuit.fontColor = color
        topSuit.horizontalAlignmentMode = .left
        topSuit.verticalAlignmentMode = .top
        topSuit.position = CGPoint(x: -w / 2 + margin, y: h / 2 - margin - w * 0.35)
        topSuit.zPosition = 2
        addChild(topSuit)

        // 中央大花色 — 视觉锚点
        let centerSuit = SKLabelNode(text: suitText)
        centerSuit.fontSize = w * 0.50
        centerSuit.fontColor = color.withAlphaComponent(0.18)
        centerSuit.horizontalAlignmentMode = .center
        centerSuit.verticalAlignmentMode = .center
        centerSuit.position = CGPoint(x: 0, y: -h * 0.03)
        centerSuit.zPosition = 1
        addChild(centerSuit)

        // JQK 人脸牌 — 中央加书法标记
        if isFaceCard {
            let faceChar: String
            switch card.rank {
            case .jack:  faceChar = "将"
            case .queen: faceChar = "妃"
            case .king:  faceChar = "帅"
            default:     faceChar = ""
            }
            let faceLabel = SKLabelNode(text: faceChar)
            faceLabel.fontName = serifFont
            faceLabel.fontSize = w * 0.28
            faceLabel.fontColor = color.withAlphaComponent(0.10)
            faceLabel.horizontalAlignmentMode = .center
            faceLabel.verticalAlignmentMode = .center
            faceLabel.position = CGPoint(x: 0, y: h * 0.12)
            faceLabel.zPosition = 1
            addChild(faceLabel)

            // 人脸牌底部装饰线
            let decPath = CGMutablePath()
            decPath.move(to: CGPoint(x: -w * 0.22, y: -h * 0.18))
            decPath.addLine(to: CGPoint(x: w * 0.22, y: -h * 0.18))
            let decLine = SKShapeNode(path: decPath)
            decLine.strokeColor = color.withAlphaComponent(0.08)
            decLine.lineWidth = 0.5
            decLine.zPosition = 1
            addChild(decLine)
        }

        // 特殊高亮：A 和 2（斗地主特殊牌）
        if card.rank == .ace || card.rank == .two {
            let glow = SKShapeNode(circleOfRadius: w * 0.18)
            glow.fillColor = color.withAlphaComponent(0.04)
            glow.strokeColor = color.withAlphaComponent(0.06)
            glow.lineWidth = 0.5
            glow.position = CGPoint(x: 0, y: -h * 0.03)
            glow.zPosition = 0.5
            addChild(glow)
        }

        // 右下角：点数（倒置镜像）
        let bottomRank = SKLabelNode(text: rankText)
        bottomRank.fontName = serifFont
        bottomRank.fontSize = w * 0.26
        bottomRank.fontColor = color.withAlphaComponent(0.6)
        bottomRank.horizontalAlignmentMode = .left
        bottomRank.verticalAlignmentMode = .top
        bottomRank.position = CGPoint(x: w / 2 - margin, y: -h / 2 + margin)
        bottomRank.zPosition = 2
        bottomRank.xScale = -1
        bottomRank.yScale = -1
        addChild(bottomRank)

        // 右下角：花色（倒置）
        let bottomSuit = SKLabelNode(text: suitText)
        bottomSuit.fontSize = w * 0.16
        bottomSuit.fontColor = color.withAlphaComponent(0.5)
        bottomSuit.horizontalAlignmentMode = .left
        bottomSuit.verticalAlignmentMode = .top
        bottomSuit.position = CGPoint(x: w / 2 - margin, y: -h / 2 + margin + w * 0.26)
        bottomSuit.zPosition = 2
        bottomSuit.xScale = -1
        bottomSuit.yScale = -1
        addChild(bottomSuit)

        // 角落装饰纹（仅大尺寸卡牌）
        if w >= 50 {
            let dotRadius: CGFloat = 1.2
            let dotPositions: [CGPoint] = [
                CGPoint(x: -w / 2 + 8, y: -h / 2 + 8),
                CGPoint(x: w / 2 - 8, y: h / 2 - 8),
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
    }

    private func drawJokerCard() {
        let isRedJoker = card.rank == .jokerRed
        let color = cardColor
        let serifFont = Theme.spriteKitSerifFontName
        let w = size.width
        let h = size.height
        let margin: CGFloat = max(3, w * 0.07)

        // 特殊背景色调
        let tintOverlay = SKShapeNode(rectOf: CGSize(width: w - 2, height: h - 2), cornerRadius: 5)
        tintOverlay.fillColor = isRedJoker
            ? SKColor(red: 0.95, green: 0.92, blue: 0.85, alpha: 1.0)
            : SKColor(red: 0.90, green: 0.94, blue: 0.93, alpha: 1.0)
        tintOverlay.strokeColor = .clear
        tintOverlay.zPosition = 0
        addChild(tintOverlay)

        // 对角装饰纹路（王牌尊贵感）
        if w >= 40 {
            let diagPath = CGMutablePath()
            diagPath.move(to: CGPoint(x: -w / 2 + 4, y: h / 2 - 4))
            diagPath.addLine(to: CGPoint(x: w / 2 - 4, y: -h / 2 + 4))
            let diag = SKShapeNode(path: diagPath)
            diag.strokeColor = color.withAlphaComponent(0.04)
            diag.lineWidth = w * 0.6
            diag.lineCap = .round
            diag.zPosition = 0.5
            addChild(diag)
        }

        // 左上角标识
        let topLabel = SKLabelNode(text: isRedJoker ? "大" : "小")
        topLabel.fontName = serifFont
        topLabel.fontSize = w * 0.34
        topLabel.fontColor = color
        topLabel.horizontalAlignmentMode = .left
        topLabel.verticalAlignmentMode = .top
        topLabel.position = CGPoint(x: -w / 2 + margin, y: h / 2 - margin)
        topLabel.zPosition = 3
        addChild(topLabel)

        // "王"字
        let kingLabel = SKLabelNode(text: "王")
        kingLabel.fontName = serifFont
        kingLabel.fontSize = w * 0.26
        kingLabel.fontColor = color.withAlphaComponent(0.7)
        kingLabel.horizontalAlignmentMode = .left
        kingLabel.verticalAlignmentMode = .top
        kingLabel.position = CGPoint(x: -w / 2 + margin, y: h / 2 - margin - w * 0.35)
        kingLabel.zPosition = 3
        addChild(kingLabel)

        // 中央大字 — 纯中文"王"取代 emoji
        let centerChar = SKLabelNode(text: "王")
        centerChar.fontName = serifFont
        centerChar.fontSize = w * 0.50
        centerChar.fontColor = color.withAlphaComponent(0.85)
        centerChar.horizontalAlignmentMode = .center
        centerChar.verticalAlignmentMode = .center
        centerChar.position = CGPoint(x: 0, y: -h * 0.03)
        centerChar.zPosition = 2
        addChild(centerChar)

        // 中央装饰光晕
        let glow = SKShapeNode(circleOfRadius: w * 0.26)
        glow.fillColor = color.withAlphaComponent(0.06)
        glow.strokeColor = color.withAlphaComponent(0.10)
        glow.lineWidth = 0.5
        glow.position = CGPoint(x: 0, y: -h * 0.03)
        glow.zPosition = 1
        addChild(glow)

        // 外环装饰（大王/小王区别感强化）
        let outerRing = SKShapeNode(circleOfRadius: w * 0.32)
        outerRing.fillColor = .clear
        outerRing.strokeColor = color.withAlphaComponent(0.06)
        outerRing.lineWidth = 0.8
        outerRing.position = CGPoint(x: 0, y: -h * 0.03)
        outerRing.zPosition = 1
        addChild(outerRing)

        // 右下角倒置标记
        let bottomLabel = SKLabelNode(text: isRedJoker ? "大" : "小")
        bottomLabel.fontName = serifFont
        bottomLabel.fontSize = w * 0.22
        bottomLabel.fontColor = color.withAlphaComponent(0.5)
        bottomLabel.horizontalAlignmentMode = .left
        bottomLabel.verticalAlignmentMode = .top
        bottomLabel.position = CGPoint(x: w / 2 - margin, y: -h / 2 + margin)
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

