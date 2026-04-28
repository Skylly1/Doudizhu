import UIKit

/// 触觉 + 音效反馈管理器（骨架）
/// 后期接入真实音效文件时只需替换 play* 方法内部
@MainActor
final class FeedbackManager {
    static let shared = FeedbackManager()
    private init() {}

    // MARK: - 触觉引擎

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    // MARK: - 游戏事件反馈

    /// 选中/取消选中卡牌
    func cardTap() {
        selection.selectionChanged()
    }

    /// 出牌成功
    func playCards(score: Int) {
        if score >= 200 {
            heavyImpact.impactOccurred(intensity: 1.0)
        } else if score >= 80 {
            mediumImpact.impactOccurred()
        } else {
            lightImpact.impactOccurred()
        }
    }

    /// 炸弹/火箭
    func explosion() {
        heavyImpact.impactOccurred(intensity: 1.0)
        // 短延迟后再一次，模拟"爆炸"
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 80_000_000)
            self?.heavyImpact.impactOccurred(intensity: 0.8)
        }
    }

    /// 连击触发
    func comboHit(level: Int) {
        let intensity = min(1.0, 0.4 + Double(level) * 0.15)
        mediumImpact.impactOccurred(intensity: intensity)
    }

    /// 换牌
    func discard() {
        lightImpact.impactOccurred()
    }

    /// 过关
    func floorWin() {
        notification.notificationOccurred(.success)
    }

    /// 失败
    func floorFail() {
        notification.notificationOccurred(.error)
    }

    /// 通用按钮点击
    func buttonTap() {
        lightImpact.impactOccurred(intensity: 0.5)
    }

    /// 购买物品
    func purchase() {
        notification.notificationOccurred(.success)
    }

    /// 通关
    func victory() {
        notification.notificationOccurred(.success)
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            self?.notification.notificationOccurred(.success)
        }
    }
}
