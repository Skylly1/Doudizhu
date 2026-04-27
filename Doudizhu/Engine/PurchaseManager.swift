import Foundation
import StoreKit

/// 购买管理器 — StoreKit 2 真实 IAP 实现
/// 买断制：免费试玩前4层 → 一次性购买解锁完整版
@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isFullVersion: Bool
    @Published var product: Product?
    @Published var purchaseState: PurchaseState = .idle

    enum PurchaseState: Equatable {
        case idle, loading, purchasing, purchased, failed(String)
    }

    /// 免费试玩可到达的最高层数（含）
    static let demoMaxFloor = 5

    /// 完整版产品 ID — 需在 App Store Connect 配置
    static let fullVersionProductID = "com.hongzeng.doudizhu.fullversion"

    private let purchasedKey = "hasFullVersion"
    private var transactionListener: Task<Void, Never>?

    private init() {
        // 从缓存快速恢复，后续通过 Transaction 验证
        self.isFullVersion = UserDefaults.standard.bool(forKey: purchasedKey)
        transactionListener = listenForTransactions()
        Task { await loadProduct() }
        Task { await verifyEntitlements() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Public API

    /// 免费体验额度（一次性加1层）
    private var freePeekUsed: Bool {
        UserDefaults.standard.bool(forKey: "demoGateFreePeekUsed")
    }

    /// 检查当前层是否在试玩范围内
    func canAccessFloor(_ floorIndex: Int) -> Bool {
        if isFullVersion { return true }
        let effectiveMax = freePeekUsed ? Self.demoMaxFloor + 1 : Self.demoMaxFloor
        return floorIndex < effectiveMax
    }

    /// 加载产品信息
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.fullVersionProductID])
            self.product = products.first
        } catch {
            CrashReporter.shared.log("Failed to load products: \(error)", level: .error)
        }
    }

    /// 购买完整版
    func purchaseFullVersion() async -> Bool {
        guard let product else {
            purchaseState = .failed(L10n.isEnglish ? "Product not available" : "商品暂不可用")
            return false
        }

        purchaseState = .purchasing
        Analytics.shared.track(.iapInitiated)

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                unlock()
                purchaseState = .purchased
                Analytics.shared.track(.iapCompleted)
                return true

            case .userCancelled:
                purchaseState = .idle
                return false

            case .pending:
                purchaseState = .idle
                return false

            @unknown default:
                purchaseState = .idle
                return false
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
            Analytics.shared.track(.iapFailed, params: ["error": error.localizedDescription])
            CrashReporter.shared.log("Purchase failed: \(error)", level: .error)
            return false
        }
    }

    /// 恢复购买
    func restorePurchases() async {
        purchaseState = .loading
        var foundEntitlement = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.fullVersionProductID {
                foundEntitlement = true
                unlock()
                Analytics.shared.track(.iapRestored)
                break
            }
        }

        if !foundEntitlement {
            // 也尝试 AppStore.sync 刷新收据
            do {
                try await AppStore.sync()
                // 再检查一次
                for await result in Transaction.currentEntitlements {
                    if case .verified(let transaction) = result,
                       transaction.productID == Self.fullVersionProductID {
                        foundEntitlement = true
                        unlock()
                        break
                    }
                }
            } catch {
                CrashReporter.shared.log("AppStore.sync failed: \(error)", level: .warning)
            }
        }

        purchaseState = foundEntitlement ? .purchased : .idle
    }

    /// 重置（调试用）
    func reset() {
        isFullVersion = false
        UserDefaults.standard.set(false, forKey: purchasedKey)
        purchaseState = .idle
    }

    /// 格式化价格 — fallback 必须与 App Store Connect 定价一致
    var formattedPrice: String {
        product?.displayPrice ?? (L10n.isEnglish ? "$4.99" : "¥25")
    }

    // MARK: - Private

    private func unlock() {
        isFullVersion = true
        UserDefaults.standard.set(true, forKey: purchasedKey)
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }

    /// 启动时验证已有权益
    private func verifyEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.fullVersionProductID {
                unlock()
                return
            }
        }
    }

    /// 监听新交易（处理 Ask to Buy、促销购买等）
    private func listenForTransactions() -> Task<Void, Never> {
        let productID = Self.fullVersionProductID
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result,
                   transaction.productID == productID {
                    await transaction.finish()
                    await self?.unlock()
                }
            }
        }
    }
}
