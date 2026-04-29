import Foundation
import StoreKit
import Security

/// 购买管理器 — StoreKit 2 真实 IAP 实现
/// 买断制：免费试玩前6层 → 一次性购买解锁完整版
/// 安全层：Keychain双写 + JWS验证 + BundleID校验 + 退款检测
// REVENUE-TODO: [P2] 加入「支持开发者」打赏入口（tip jar），非消耗品 $1.99/$4.99/$9.99
// REVENUE-TODO: [P3] 加入季节通行证（Season Pass）订阅模式，解锁独占每日挑战奖励+卡背皮肤
@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isFullVersion: Bool
    @Published var product: Product?
    @Published var purchaseState: PurchaseState = .idle

    enum PurchaseState: Equatable {
        case idle, loading, purchasing, purchased, pending, failed(String)
    }

    /// 免费试玩可到达的最高层数（含）— 前6层含2次商店+2次Boss，充分展示核心循环
    static let demoMaxFloor = 6

    /// 完整版产品 ID — 需在 App Store Connect 配置
    static let fullVersionProductID = "com.hongzeng.doudizhu.fullversion"

    private let purchasedKey = "hasFullVersion"
    private var transactionListener: Task<Void, Never>?
    private var productLoadRetryCount = 0
    private static let maxProductLoadRetries = 3

    // REVENUE-FIX: 使用 Keychain 存储购买状态，防止 UserDefaults 被轻易篡改
    private static let keychainService = "com.hongzeng.doudizhu.purchase"
    private static let keychainAccount = "fullVersionEntitlement"

    private init() {
        // 从缓存快速恢复，后续通过 Transaction 验证
        // 双重验证：UserDefaults + Keychain 一致时才信任缓存
        let udValue = UserDefaults.standard.bool(forKey: purchasedKey)
        let kcValue = Self.readKeychain()
        self.isFullVersion = udValue && kcValue
        transactionListener = listenForTransactions()
        Task { await loadProduct(); await verifyEntitlements() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Public API

    /// 检查当前层是否在试玩范围内
    func canAccessFloor(_ floorIndex: Int) -> Bool {
        if isFullVersion { return true }
        return floorIndex < Self.demoMaxFloor
    }

    /// 加载产品信息（含自动重试，非递归）
    func loadProduct() async {
        for attempt in 1...Self.maxProductLoadRetries {
            do {
                let products = try await Product.products(for: [Self.fullVersionProductID])
                self.product = products.first
                productLoadRetryCount = 0
                return
            } catch {
                CrashReporter.shared.log("Failed to load products (attempt \(attempt)): \(error)", level: .error)
                let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                try? await Task.sleep(nanoseconds: delay)
            }
        }
    }

    /// 购买完整版
    func purchaseFullVersion() async -> Bool {
        guard let product else {
            // 商品未加载，尝试重新加载后再购买
            await loadProduct()
            guard self.product != nil else {
                purchaseState = .failed(L10n.isEnglish ? "Product not available. Check your network." : "商品暂不可用，请检查网络。")
                Analytics.shared.track(.iapFailed, params: ["error": "product_not_loaded"])
                return false
            }
            return await purchaseFullVersion()
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
                Analytics.shared.track(.iapFailed, params: ["error": "user_cancelled"])
                return false

            case .pending:
                // Ask to Buy / 家长审批：交易未完成，等待 Transaction.updates 回调
                purchaseState = .pending
                Analytics.shared.track(.iapPending, params: ["product": Self.fullVersionProductID])
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

    #if DEBUG
    /// 重置（仅调试用 — 生产环境不可用）
    func reset() {
        isFullVersion = false
        UserDefaults.standard.set(false, forKey: purchasedKey)
        purchaseState = .idle
    }
    #endif

    /// 格式化价格 — fallback 必须与 App Store Connect 定价一致
    var formattedPrice: String {
        product?.displayPrice ?? "—"
    }

    /// 待审批购买的用户提示文案
    var pendingMessage: String {
        L10n.isEnglish
            ? "Purchase is waiting for approval. It will unlock automatically once approved."
            : "购买正在等待审批，审批通过后将自动解锁。"
    }

    // MARK: - Private

    private func unlock() {
        isFullVersion = true
        UserDefaults.standard.set(true, forKey: purchasedKey)
        Self.writeKeychain(true)
    }

    /// 退款/撤销后锁定（由 Transaction 监听器调用）
    private func revoke() {
        isFullVersion = false
        UserDefaults.standard.set(false, forKey: purchasedKey)
        Self.writeKeychain(false)
        purchaseState = .idle
        Analytics.shared.track(.iapRevoked)
        CrashReporter.shared.log("Purchase revoked (refund detected)", level: .warning)
    }

    // MARK: - Keychain Helpers (防篡改存储)

    private static func writeKeychain(_ value: Bool) {
        let data = Data([value ? 1 : 0])
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        SecItemDelete(query as CFDictionary)
        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    private static func readKeychain() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data, !data.isEmpty else {
            return false
        }
        return data[0] == 1
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            Analytics.shared.track(.iapFailed, params: ["error": "jws_unverified"])
            CrashReporter.shared.log("JWS verification failed: \(error)", level: .error)
            throw error
        case .verified(let value):
            return value
        }
    }

    /// 深度验证交易合法性（StoreKit 2 JWS之上的额外校验）
    private func validateTransaction(_ transaction: Transaction) -> Bool {
        // 1. Bundle ID 必须匹配（防止跨App交易注入）
        guard transaction.appBundleID == Bundle.main.bundleIdentifier else {
            CrashReporter.shared.log("Transaction bundleID mismatch: \(transaction.appBundleID)", level: .error)
            Analytics.shared.track(.iapFailed, params: ["error": "bundle_mismatch"])
            return false
        }

        // 2. 产品ID匹配
        guard transaction.productID == Self.fullVersionProductID else { return false }

        // 3. 环境一致性（Release build不应接受sandbox交易）
        #if !DEBUG
        if transaction.environment == .sandbox {
            CrashReporter.shared.log("Sandbox transaction in production build", level: .warning)
            // 允许但记录 — TestFlight用sandbox
        }
        #endif

        // 4. 未被撤销
        if transaction.revocationDate != nil {
            return false
        }

        return true
    }

    /// 启动时验证已有权益（含退款检测 + 深度校验）
    private func verifyEntitlements() async {
        var hasEntitlement = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.fullVersionProductID {
                // 深度校验
                guard validateTransaction(transaction) else {
                    revoke()
                    return
                }
                hasEntitlement = true
                unlock()
                return
            }
        }
        // 如果 UserDefaults 说已购买但 Transaction 没有权益 → 退款或异常
        if !hasEntitlement && UserDefaults.standard.bool(forKey: purchasedKey) {
            revoke()
        }
    }

    /// 监听新交易（处理 Ask to Buy、促销购买、退款等）
    private func listenForTransactions() -> Task<Void, Never> {
        let productID = Self.fullVersionProductID
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result,
                   transaction.productID == productID {
                    // 深度校验
                    let valid = await self?.validateTransaction(transaction) ?? false
                    if !valid || transaction.revocationDate != nil {
                        await self?.revoke()
                    } else {
                        await transaction.finish()
                        await self?.unlock()
                    }
                }
            }
        }
    }
}
