import SwiftUI

/// 首购成功庆典页面
struct PurchaseSuccessView: View {
    let onStart: () -> Void
    
    @State private var showRewards = false
    @State private var celebrationScale: CGFloat = 0.5
    @State private var celebrationOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // 庆典标题
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.goldGradient)
                        .shadow(color: Theme.gold.opacity(0.5), radius: 20)
                    
                    Text(L10n.isEnglish ? "Welcome, Champion!" : "欢迎，勇者！")
                        .font(.title.bold())
                        .foregroundStyle(Theme.goldGradient)
                    
                    Text(L10n.isEnglish ? "Full version unlocked — your journey begins!" : "完整版已解锁 — 你的传奇之旅正式开始！")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .scaleEffect(celebrationScale)
                .opacity(celebrationOpacity)
                
                // 首购奖励卡片
                if showRewards {
                    VStack(spacing: 12) {
                        Text(L10n.isEnglish ? "🎁 First Purchase Rewards" : "🎁 首购奖励")
                            .font(.headline)
                            .foregroundColor(Theme.gold)
                        
                        rewardRow(icon: "suit.spade.fill", color: Theme.cyan,
                                 title: L10n.isEnglish ? "Random Joker" : "随机规则牌",
                                 desc: L10n.isEnglish ? "A rare Joker to boost your deck" : "一张稀有规则牌助力你的牌组")
                        
                        rewardRow(icon: "arrow.triangle.2.circlepath", color: Theme.flame,
                                 title: L10n.isEnglish ? "+2 Discards" : "+2 换牌次数",
                                 desc: L10n.isEnglish ? "Extra discards for this run" : "本次冒险额外换牌")
                        
                        rewardRow(icon: "flame.fill", color: Theme.gold,
                                 title: L10n.isEnglish ? "+1 Combo Start" : "+1 初始连击",
                                 desc: L10n.isEnglish ? "Start combos from 1" : "连击从1开始计算")
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusLG)
                            .fill(Theme.bgCard)
                            .overlay(RoundedRectangle(cornerRadius: Theme.radiusLG)
                                .stroke(Theme.gold.opacity(0.3)))
                    )
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                
                // 开始按钮
                Button {
                    onStart()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text(L10n.isEnglish ? "Begin Adventure" : "开始冒险")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .fill(Theme.goldGradient)
                    )
                    .shadow(color: Theme.gold.opacity(0.4), radius: 12, y: 4)
                }
                .accessibilityLabel(L10n.isEnglish ? "Begin Adventure" : "开始冒险")
                .accessibilityHint(L10n.isEnglish ? "Start your full adventure" : "开始完整版冒险之旅")
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                celebrationScale = 1.0
                celebrationOpacity = 1.0
            }
            withAnimation(.spring(response: 0.5).delay(0.5)) {
                showRewards = true
            }
        }
    }
    
    private func rewardRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
            }
            
            Spacer()
        }
    }
}
