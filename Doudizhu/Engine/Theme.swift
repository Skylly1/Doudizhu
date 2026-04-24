import SwiftUI
import UIKit

// MARK: - 统一设计系统

/// 全局设计 Token — 所有 View 从这里取颜色、字体、间距
enum Theme {

    // MARK: 主色板

    /// 金色系 — 用于标题、CTA、高亮
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let goldLight = Color(red: 1.0, green: 0.93, blue: 0.55)
    static let goldDark = Color(red: 0.85, green: 0.65, blue: 0.0)
    static let goldGradient = LinearGradient(
        colors: [goldLight, gold, goldDark],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    /// 青色系 — 规则牌、选中态、信息
    static let cyan = Color(red: 0.0, green: 0.87, blue: 0.87)
    static let cyanDim = Color(red: 0.0, green: 0.87, blue: 0.87).opacity(0.2)

    /// 橙色系 — Buff、连击、警告
    static let flame = Color(red: 1.0, green: 0.55, blue: 0.0)
    static let flameDim = Color(red: 1.0, green: 0.55, blue: 0.0).opacity(0.2)

    /// 红色系 — 危险、失败、弃牌
    static let danger = Color(red: 0.9, green: 0.2, blue: 0.2)
    static let dangerDim = Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.15)

    /// 绿色系 — 成功、普通稀有度
    static let success = Color(red: 0.2, green: 0.85, blue: 0.4)

    /// 紫色系 — 传说稀有度
    static let legendary = Color(red: 0.65, green: 0.3, blue: 0.9)

    // MARK: 背景

    /// 主背景 — 深蓝黑
    static let bgPrimary = Color(red: 0.04, green: 0.06, blue: 0.10)
    /// 二级背景 — 卡片/面板
    static let bgCard = Color.white.opacity(0.06)
    /// 三级背景 — 输入/内嵌区域
    static let bgInset = Color.white.opacity(0.03)
    /// 描边
    static let border = Color.white.opacity(0.12)
    static let borderLight = Color.white.opacity(0.06)

    // MARK: 文字

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)
    static let textDisabled = Color.white.opacity(0.25)

    // MARK: 字体

    /// 大标题 — 游戏名（书法衬线）
    static let fontTitle = Font.system(size: 44, weight: .black, design: .serif)
    /// 页面标题（书法衬线）
    static let fontHeading = Font.system(size: 28, weight: .bold, design: .serif)
    /// 区块标题
    static let fontSection = Font.system(size: 18, weight: .semibold)
    /// 正文
    static let fontBody = Font.system(size: 15, weight: .regular)
    /// 说明
    static let fontCaption = Font.system(size: 12, weight: .regular)
    /// 数字
    static let fontMono = Font.system(size: 15, weight: .medium, design: .monospaced)

    // MARK: 中国书法风格字体

    /// 中文标题 — 用于游戏名等大标题
    static let titleFont: Font = .system(size: 28, weight: .heavy, design: .serif)
    /// 中文副标题 — 用于关卡名、楼层名
    static let subtitleFont: Font = .system(size: 20, weight: .bold, design: .serif)
    /// Joker 王牌标题 — 用于大王/小王
    static let jokerTitleFont: Font = .system(size: 16, weight: .heavy, design: .serif)

    /// SpriteKit 书法字体名 — 宋体（iOS 内置中文衬线字体），回退到 PingFang
    static var spriteKitSerifFontName: String {
        if UIFont(name: "STSongti-SC-Bold", size: 14) != nil {
            return "STSongti-SC-Bold"
        }
        return "PingFangSC-Semibold"
    }

    // MARK: 间距

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48

    // MARK: 圆角

    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 14
    static let radiusLG: CGFloat = 20

    // MARK: 便捷视图修饰器

    // MARK: - Responsive Helpers

    /// Screen width-based scaling for different devices
    static var screenScale: CGFloat {
        let width = UIScreen.main.bounds.width
        if width <= 375 { return 0.85 }       // iPhone SE/mini
        if width <= 393 { return 1.0 }         // iPhone 15
        if width <= 430 { return 1.05 }        // iPhone 15 Plus/Pro Max
        return 1.2                              // iPad
    }

    static var isCompactScreen: Bool { UIScreen.main.bounds.width <= 375 }
    static var isIPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    /// Responsive font that scales with Dynamic Type
    static func responsiveTitle(_ baseSize: CGFloat = 44) -> Font {
        .system(size: baseSize * screenScale, weight: .black, design: .serif)
    }

    static func responsiveHeading(_ baseSize: CGFloat = 28) -> Font {
        .system(size: baseSize * screenScale, weight: .bold, design: .serif)
    }
}

// MARK: - 通用卡片样式

struct CardPanel<Content: View>: View {
    let content: Content
    var highlight: Color? = nil

    init(highlight: Color? = nil, @ViewBuilder content: () -> Content) {
        self.highlight = highlight
        self.content = content()
    }

    var body: some View {
        content
            .padding(Theme.spacingMD)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(Theme.bgCard)
                    .stroke(highlight ?? Theme.border, lineWidth: highlight != nil ? 1.5 : 0.5)
            )
    }
}

// MARK: - 主按钮样式

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var gradient: LinearGradient = Theme.goldGradient
    let action: () -> Void

    var body: some View {
        Button(action: {
            Task { @MainActor in FeedbackManager.shared.buttonTap() }
            action()
        }) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.body.weight(.bold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(gradient)
            )
            .shadow(color: Theme.gold.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(GameButtonStyle(pressScale: 0.93))
    }
}

// MARK: - 次要按钮样式

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    var color: Color = Theme.textSecondary
    let action: () -> Void

    var body: some View {
        Button(action: {
            Task { @MainActor in FeedbackManager.shared.buttonTap() }
            action()
        }) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(color)
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(color.opacity(0.1))
                    .stroke(color.opacity(0.2))
            )
        }
        .buttonStyle(GameButtonStyle(pressScale: 0.96))
    }
}

// MARK: - Button Press Animation

struct GameButtonStyle: ButtonStyle {
    var pressScale: CGFloat = 0.95

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressScale : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func gameButtonStyle(pressScale: CGFloat = 0.95) -> some View {
        self.buttonStyle(GameButtonStyle(pressScale: pressScale))
    }
}

// MARK: - 页面背景 modifier

struct GameBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            // 微妙的径向渐变
            RadialGradient(
                colors: [
                    Color(red: 0.08, green: 0.10, blue: 0.18).opacity(0.6),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 600
            )
            .ignoresSafeArea()

            content
        }
    }
}

extension View {
    func gameBackground() -> some View {
        modifier(GameBackground())
    }
}

// MARK: - 导航顶栏

struct GameNavBar: View {
    var title: String = ""
    var subtitle: String? = nil
    var onBack: (() -> Void)? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack {
            if let onBack {
                Button(action: {
                    FeedbackManager.shared.buttonTap()
                    onBack()
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.ultraThinMaterial)
                        .symbolRenderingMode(.hierarchical)
                }
            }

            Spacer()

            VStack(spacing: 2) {
                if !title.isEmpty {
                    Text(title)
                        .font(Theme.fontSection)
                        .foregroundColor(Theme.textPrimary)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(Theme.fontCaption)
                        .foregroundColor(Theme.textTertiary)
                }
            }

            Spacer()

            if let trailing {
                trailing
            } else if onBack != nil {
                // 占位保持居中
                Color.clear.frame(width: 32)
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.top, Theme.spacingSM)
    }
}
