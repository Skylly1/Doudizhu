import SwiftUI

/// 卡牌图鉴 / 已解锁 Buff 收藏
struct CollectionView: View {
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("卡牌收藏")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()

                Spacer()
                Text("📖 收藏册开发中...")
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
            }
        }
    }
}

#Preview {
    CollectionView(onBack: {})
}
