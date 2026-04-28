import SwiftUI
import UIKit

// MARK: - 统一设计系统

/// 全局设计 Token — 所有 View 从这里取颜色、字体、间距
enum Theme {

    // MARK: 主色板 — 国潮水墨

    /// 赤金系 — 标题、CTA、高亮
    static let gold = Color(red: 0.85, green: 0.68, blue: 0.28)
    static let goldLight = Color(red: 0.96, green: 0.84, blue: 0.45)
    static let goldDark = Color(red: 0.62, green: 0.45, blue: 0.12)
    static let goldGradient = LinearGradient(
        colors: [goldLight, gold, goldDark],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    /// 翡翠青系 — 规则牌、选中态、信息
    static let cyan = Color(red: 0.0, green: 0.65, blue: 0.58)
    static let cyanDim = Color(red: 0.0, green: 0.65, blue: 0.58).opacity(0.2)

    /// 朱砂红系 — 红色花色、Buff、连击
    static let flame = Color(red: 0.82, green: 0.22, blue: 0.18)
    static let flameDim = Color(red: 0.82, green: 0.22, blue: 0.18).opacity(0.2)

    /// 殷红系 — 危险、失败
    static let danger = Color(red: 0.75, green: 0.15, blue: 0.10)
    static let dangerDim = Color(red: 0.75, green: 0.15, blue: 0.10).opacity(0.15)

    /// 竹青系 — 成功、普通稀有度
    static let success = Color(red: 0.15, green: 0.50, blue: 0.30)

    /// 紫气系 — 传说稀有度
    static let legendary = Color(red: 0.50, green: 0.20, blue: 0.72)

    // MARK: 背景 — 紫檀暖木

    /// 主背景 — 暖紫檀色（OLED 大幅提亮可见）
    static let bgPrimary = Color(red: 0.22, green: 0.16, blue: 0.11)
    /// 二级背景 — 花梨木面板
    static let bgCard = Color(red: 0.28, green: 0.21, blue: 0.15)
    /// 三级背景 — 嵌入区域
    static let bgInset = Color(red: 0.25, green: 0.18, blue: 0.13)
    /// 描边 — 暖金灰
    static let border = Color(red: 0.42, green: 0.35, blue: 0.25).opacity(0.65)
    static let borderLight = Color(red: 0.38, green: 0.30, blue: 0.22).opacity(0.4)

    /// 牌面象牙白 — 用于扑克牌正面
    static let cardFace = Color(red: 0.95, green: 0.92, blue: 0.86)
    /// 牌面暗色（SpriteKit 用）
    static let cardFaceDark = Color(red: 0.88, green: 0.84, blue: 0.76)

    // MARK: 文字

    /// 主文字 — 暖白（宣纸上的墨）
    static let textPrimary = Color(red: 0.93, green: 0.90, blue: 0.85)
    static let textSecondary = Color(red: 0.80, green: 0.75, blue: 0.67)
    static let textTertiary = Color(red: 0.62, green: 0.57, blue: 0.49)
    static let textDisabled = Color(red: 0.40, green: 0.36, blue: 0.30)

    // MARK: 字体

    /// 大标题 — 游戏名（书法衬线）
    // UX-TODO: Font sizes are hardcoded — consider @ScaledMetric for Dynamic Type support
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
    /// 微型文字（9pt — 徽章、标签）
    static let fontMicro = Font.system(size: 9, weight: .regular)
    /// 微型文字加粗
    static let fontMicroBold = Font.system(size: 9, weight: .bold)
    /// 小号文字（10pt — 说明、辅助）
    static let fontSmall = Font.system(size: 10, weight: .regular)
    /// 小号文字加粗
    static let fontSmallBold = Font.system(size: 10, weight: .semibold)
    /// 小号文字等宽（10pt — 数字显示）
    static let fontSmallMono = Font.system(size: 10, weight: .semibold, design: .monospaced)
    /// 大图标尺寸（48pt — 弹窗、页面大图标）
    static let fontIconLarge = Font.system(size: 48)
    /// 超大图标（56pt — 成功/失败动画）
    static let fontIconXL = Font.system(size: 56)
    /// 装饰图标（64pt — 教程手势）
    static let fontIconXXL = Font.system(size: 64)
    /// 大标题数字（44pt — 统计数字）
    static let fontStatNumber = Font.system(size: 44, weight: .black, design: .monospaced)
    /// 中号图标（32pt — 日历、列表图标）
    static let fontIconMedium = Font.system(size: 32)
    /// 中号标题（28pt — 构筑选择、教程）
    static let fontSubtitleLarge = Font.system(size: 28, weight: .bold, design: .serif)

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
    /// 极小圆角（4pt — 进度条、徽章）
    static let radiusXS: CGFloat = 4

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
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .stroke(highlight ?? Theme.gold.opacity(0.15), lineWidth: highlight != nil ? 1.5 : 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }
}

// MARK: - 毛玻璃面板 modifier

struct GlassPanel: ViewModifier {
    var cornerRadius: CGFloat = Theme.radiusMD
    var borderColor: Color = Theme.gold.opacity(0.15)
    var shadowRadius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: shadowRadius, y: 4)
    }
}

extension View {
    func glassPanel(
        cornerRadius: CGFloat = Theme.radiusMD,
        border: Color = Theme.gold.opacity(0.15),
        shadow: CGFloat = 8
    ) -> some View {
        modifier(GlassPanel(cornerRadius: cornerRadius, borderColor: border, shadowRadius: shadow))
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
            .frame(minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(gradient)
            )
            .shadow(color: Theme.gold.opacity(0.35), radius: 10, y: 5)
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
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.2), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
        .buttonStyle(GameButtonStyle(pressScale: 0.96))
    }
}

// MARK: - 三级按钮（暂停菜单等场景）

struct TertiaryButton: View {
    let title: String
    var icon: String? = nil
    var color: Color = Theme.textSecondary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.headline)
            .foregroundColor(color)
            .frame(width: 220, height: 46)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .stroke(color.opacity(0.3))
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
        .buttonStyle(GameButtonStyle())
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
            // 三段渐变背景 — 温暖国潮色
            LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.25, blue: 0.17),
                    Color(red: 0.24, green: 0.17, blue: 0.12),
                    Color(red: 0.17, green: 0.12, blue: 0.09)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // 顶部金色氛围光晕 — 高可见度
            RadialGradient(
                colors: [
                    Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.22),
                    Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.06),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 350
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
        HStack(spacing: 12) {
            if let onBack {
                Button(action: {
                    FeedbackManager.shared.buttonTap()
                    onBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundColor(Theme.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .accessibilityLabel(L10n.back)
                .accessibilityHint(L10n.isEnglish ? "Go back to previous screen" : "返回上一页")
            }

            Spacer()

            Text(title)
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            if let trailing {
                trailing
            } else if onBack != nil {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, 6)
    }
}

// MARK: - 水墨分割线

struct InkDivider: View {
    var color: Color = Theme.gold.opacity(0.3)

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color.clear, color],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(height: 1)
            Image(systemName: "diamond.fill")
                .font(.system(size: 6))
                .foregroundColor(color)
            Rectangle()
                .fill(LinearGradient(
                    colors: [color, Color.clear],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(height: 1)
        }
        .padding(.horizontal, Theme.spacingMD)
    }
}

// MARK: - 印章标签

struct StampBadge: View {
    let text: String
    var color: Color = Theme.flame

    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color, lineWidth: 1.5)
            )
            .rotationEffect(.degrees(-3))
    }
}
