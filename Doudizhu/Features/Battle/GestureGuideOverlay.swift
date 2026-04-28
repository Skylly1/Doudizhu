import SwiftUI

/// 首次对战手势引导（3步教学）
struct GestureGuideOverlay: View {
    let onComplete: () -> Void
    
    @State private var step = 0
    @State private var animateHand = false
    
    private let steps: [(icon: String, title: String, titleEn: String, desc: String, descEn: String, gesture: String)] = [
        ("hand.draw", "横滑选牌", "Swipe to Select", "手指横向滑动，快速选中多张牌", "Swipe horizontally across cards to select multiple", "←→"),
        ("hand.point.up", "上滑出牌", "Swipe Up to Play", "选好牌后向上滑动，直接出牌", "Swipe up to play your selected cards", "↑"),
        ("hand.tap", "双击智能选", "Double-Tap Smart Select", "双击任意一张牌，自动选出最佳牌型", "Double-tap any card to auto-select the best pattern", "👆👆")
    ]
    
    var body: some View {
        ZStack {
            // 半透明遮罩
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture { advance() }
            
            VStack(spacing: 32) {
                Spacer()
                
                // 手势动画区域
                ZStack {
                    Circle()
                        .fill(Theme.gold.opacity(0.1))
                        .frame(width: 160, height: 160)
                    
                    Image(systemName: steps[step].icon)
                        .font(.system(size: 64))
                        .foregroundStyle(Theme.goldGradient)
                        .offset(x: animateHand ? (step == 0 ? 30 : 0) : (step == 0 ? -30 : 0),
                                y: animateHand ? (step == 1 ? -30 : 0) : 0)
                        .scaleEffect(step == 2 ? (animateHand ? 1.15 : 0.95) : 1.0)
                }
                
                // 标题 + 描述
                VStack(spacing: 12) {
                    Text(L10n.isEnglish ? steps[step].titleEn : steps[step].title)
                        .font(.title2.bold())
                        .foregroundStyle(Theme.goldGradient)
                    
                    Text(steps[step].gesture)
                        .font(.system(size: 28))
                        .foregroundColor(Theme.textTertiary)
                    
                    Text(L10n.isEnglish ? steps[step].descEn : steps[step].desc)
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // 进度指示器
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        Circle()
                            .fill(i == step ? Theme.gold : Theme.textDisabled)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // 按钮区
                VStack(spacing: 12) {
                    Button {
                        advance()
                    } label: {
                        Text(step < steps.count - 1
                             ? (L10n.isEnglish ? "Next" : "下一步")
                             : (L10n.isEnglish ? "Got it!" : "开始游戏！"))
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.radiusMD)
                                    .fill(Theme.goldGradient)
                            )
                    }
                    .accessibilityLabel(step < steps.count - 1
                                        ? (L10n.isEnglish ? "Next step" : "下一步")
                                        : (L10n.isEnglish ? "Start game" : "开始游戏"))
                    .padding(.horizontal, 48)
                    
                    if step < steps.count - 1 {
                        Button {
                            completeGuide()
                        } label: {
                            Text(L10n.isEnglish ? "Skip" : "跳过")
                                .font(.subheadline)
                                .foregroundColor(Theme.textTertiary)
                        }
                        .accessibilityLabel(L10n.isEnglish ? "Skip tutorial" : "跳过引导")
                        .accessibilityHint(L10n.isEnglish ? "Skip the gesture guide" : "跳过手势引导直接开始")
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func advance() {
        if step < steps.count - 1 {
            withAnimation(.spring(response: 0.4)) {
                step += 1
                animateHand = false
            }
            startAnimation()
        } else {
            completeGuide()
        }
    }
    
    private func completeGuide() {
        UserDefaults.standard.set(true, forKey: "gestureGuideCompleted")
        onComplete()
    }
    
    private func startAnimation() {
        animateHand = false
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.3)) {
            animateHand = true
        }
    }
}
