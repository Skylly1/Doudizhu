import SwiftUI

struct HomeView: View {
    let onNavigate: (AppScreen) -> Void
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 40
    @State private var buttonsOpacity: Double = 0

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            // 装饰背景
            VStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.gold.opacity(0.08), Color.clear],
                            center: .center,
                            startRadius: 0, endRadius: 250
                        )
                    )
                    .frame(width: 500, height: 500)
                    .offset(y: -100)
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // 标题区
                VStack(spacing: 12) {
                    Text("🎴")
                        .font(.system(size: 56))

                    Text(L10n.appName)
                        .font(Theme.responsiveTitle())
                        .foregroundStyle(Theme.goldGradient)

                    Text(L10n.appSubtitle)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Theme.textTertiary)
                        .tracking(4)
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

                Spacer().frame(height: Theme.isCompactScreen ? Theme.spacingLG : Theme.spacingXXL)

                // Ascension 等级展示
                let highestAsc = UserDefaults.standard.integer(forKey: "highestAscensionCleared")
                if highestAsc > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Theme.flame)
                        Text(L10n.highestAscLabel(highestAsc))
                            .font(.subheadline.bold().monospacedDigit())
                            .foregroundColor(Theme.flame)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Theme.flameDim))
                    .padding(.bottom, 8)
                }

                // 菜单按钮
                VStack(spacing: 14) {
                    PrimaryButton(title: L10n.startAdventure, icon: "play.fill") {
                        onNavigate(.map)
                    }
                    .padding(.horizontal, 60)

                    SecondaryButton(title: L10n.quickStart, icon: "bolt.fill") {
                        onNavigate(.buildSelect)
                    }
                    .padding(.horizontal, 60)

                    HStack(spacing: 12) {
                        SecondaryButton(title: L10n.cardCollection, icon: "rectangle.stack.fill") {
                            onNavigate(.collection)
                        }
                        SecondaryButton(title: L10n.settings, icon: "gearshape.fill") {
                            onNavigate(.settings)
                        }
                    }
                }
                .offset(y: buttonsOffset)
                .opacity(buttonsOpacity)

                Spacer()

                // 版本信息
                Text(L10n.versionString)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textDisabled)
                    .padding(.bottom, Theme.spacingMD)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
                buttonsOffset = 0
                buttonsOpacity = 1.0
            }
        }
    }
}

#Preview {
    HomeView(onNavigate: { _ in })
}
