import UserNotifications
import Foundation

@MainActor
enum LocalNotificationManager {

    /// Request notification permission (call once at app launch)
    static func requestPermissionIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
            }
        }
    }

    /// Schedule re-engagement notifications (call when app enters background)
    static func scheduleReEngagement() {
        let center = UNUserNotificationCenter.current()
        // Remove old re-engagement notifications first
        center.removePendingNotificationRequests(withIdentifiers: ["reengagement_24h", "reengagement_72h"])

        // 24h reminder
        let content24 = UNMutableNotificationContent()
        content24.title = L10n.localized("你的冒险还在等你！", en: "Your adventure awaits!")
        content24.body = L10n.localized("你的牌组已就绪 — 继续闯关吧！🃏", en: "Your deck is ready — continue your Roguelike run! 🃏")
        content24.sound = .default

        let trigger24 = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 3600, repeats: false)
        let request24 = UNNotificationRequest(identifier: "reengagement_24h", content: content24, trigger: trigger24)
        center.add(request24)

        // 72h reminder (different message)
        let content72 = UNMutableNotificationContent()
        content72.title = L10n.localized("今日挑战已更新！", en: "New daily challenge available!")
        content72.body = L10n.localized("新的挑战等你来战 — 能超越昨天的记录吗？🏆", en: "A new challenge is waiting — can you beat yesterday's score? 🏆")
        content72.sound = .default

        let trigger72 = UNTimeIntervalNotificationTrigger(timeInterval: 72 * 3600, repeats: false)
        let request72 = UNNotificationRequest(identifier: "reengagement_72h", content: content72, trigger: trigger72)
        center.add(request72)
    }

    /// Cancel re-engagement notifications (call when app becomes active)
    static func cancelReEngagement() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["reengagement_24h", "reengagement_72h"])
    }

    /// Schedule daily challenge reminder (if player has streak)
    static func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily_challenge"])

        let content = UNMutableNotificationContent()
        content.title = L10n.localized("每日挑战已就绪！", en: "Daily Challenge Ready!")
        content.body = L10n.localized("别断了连胜记录 — 今天的挑战等你来！🔥", en: "Don't break your streak — today's challenge is waiting! 🔥")
        content.sound = .default

        // Trigger at 10:00 AM local time every day
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_challenge", content: content, trigger: trigger)
        center.add(request)
    }
}
