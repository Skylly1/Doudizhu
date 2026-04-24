import Foundation
import StoreKit

/// 购买管理器 — 管理免费试玩 / 完整版状态
/// 当前使用 UserDefaults 标记；正式上线替换为 StoreKit 2 验证
@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isFullVersion: Bool

    /// 免费试玩可到达的最高层数（含）
    static let demoMaxFloor = 4

    /// 完整版产品 ID（App Store Connect 配置后填入）
    static let fullVersionProductID = "com.hongzeng.doudizhu.fullversion"

    private let purchasedKey = "hasFullVersion"

    private init() {
        self.isFullVersion = UserDefaults.standard.bool(forKey: purchasedKey)
    }

    /// 检查当前层是否在试玩范围内
    func canAccessFloor(_ floorIndex: Int) -> Bool {
        isFullVersion || floorIndex < Self.demoMaxFloor
    }

    /// 模拟购买（开发阶段）— 正式上线替换为 StoreKit 2 流程
    func purchaseFullVersion() async -> Bool {
        // TODO: 替换为真实 StoreKit 2 购买
        // let product = try await Product.products(for: [Self.fullVersionProductID]).first
        // let result = try await product.purchase()

        // 开发阶段直接解锁
        isFullVersion = true
        UserDefaults.standard.set(true, forKey: purchasedKey)
        return true
    }

    /// 恢复购买
    func restorePurchases() async {
        // TODO: 替换为真实 StoreKit 2 恢复
        // for await result in Transaction.currentEntitlements { ... }
    }

    /// 重置（调试用）
    func reset() {
        isFullVersion = false
        UserDefaults.standard.set(false, forKey: purchasedKey)
    }
}
