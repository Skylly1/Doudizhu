import SwiftUI

/// Roguelike 关卡间的构筑商店：购买 Buff / 移除牌 / 获取特殊牌
struct ShopView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("🏪 商店开发中...")
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

#Preview {
    ShopView()
}
