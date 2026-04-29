import SwiftUI
import SwiftData
import UIKit
#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct DoudizhuApp: App {
    let modelContainer: ModelContainer

    init() {
        // Firebase 初始化（需要 GoogleService-Info.plist）
        #if canImport(FirebaseCore)
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
        #endif

        // SwiftData 存档容器（Schema 变更时自动重建）
        modelContainer = Self.makeModelContainer()

        // 注入 ModelContext 到 SaveManager（在 ContentView 构建前，避免丢失早期存档）
        SaveManager.shared.configure(with: modelContainer.mainContext)

        GameCenterManager.shared.authenticate()
        LocalNotificationManager.requestPermissionIfNeeded()
        // 首次打开标记 — 漏斗首端
        let firstOpenKey = "has_opened_before"
        if !UserDefaults.standard.bool(forKey: firstOpenKey) {
            UserDefaults.standard.set(true, forKey: firstOpenKey)
            Analytics.shared.track(.appFirstOpen, params: [
                "locale": Locale.current.identifier,
                "device": UIDevice.current.model
            ])
        }
        Analytics.shared.track(.sessionStart)
    }

    /// 创建 ModelContainer，Schema 不兼容时自动备份旧数据后重建
    private static func makeModelContainer() -> ModelContainer {
        // 先尝试正常打开
        if let container = try? ModelContainer(for: GameSaveModel.self) {
            return container
        }

        CrashReporter.shared.log("SwiftData schema migration failed — backing up old data", level: .warning)

        let fm = FileManager.default
        let fallbackDir = URL(fileURLWithPath: NSTemporaryDirectory())
        guard let appSupportDir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            // Cannot locate Application Support — use in-memory fallback
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            do { return try ModelContainer(for: GameSaveModel.self, configurations: config) }
            catch { fatalError("Cannot create ModelContainer: \(error)") }
        }
        let docsDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first ?? fallbackDir
        let backupDir = docsDir
            .appendingPathComponent("SaveBackup", isDirectory: true)
        try? fm.createDirectory(at: backupDir, withIntermediateDirectories: true)

        // 清除所有可能的 SwiftData 文件（default.store / *.sqlite 等）
        let timestamp = ISO8601DateFormatter().string(from: Date())
        if let contents = try? fm.contentsOfDirectory(at: appSupportDir, includingPropertiesForKeys: nil) {
            for file in contents where file.lastPathComponent.contains("default.store") ||
                                       file.lastPathComponent.hasSuffix(".sqlite") ||
                                       file.lastPathComponent.hasSuffix(".sqlite-wal") ||
                                       file.lastPathComponent.hasSuffix(".sqlite-shm") {
                let backup = backupDir.appendingPathComponent("\(timestamp)_\(file.lastPathComponent)")
                try? fm.copyItem(at: file, to: backup)
                try? fm.removeItem(at: file)
            }
        }
        CrashReporter.shared.log("Old save data backed up to \(backupDir.path())", level: .info)

        // 用内存兜底避免 fatalError — 本次运行不持久化但至少不崩溃
        if let container = try? ModelContainer(for: GameSaveModel.self) {
            CrashReporter.shared.log("ModelContainer recreated after backup", level: .info)
            return container
        }

        CrashReporter.shared.log("ModelContainer still fails — using in-memory fallback", level: .error)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: GameSaveModel.self, configurations: config)
        } catch {
            fatalError("Cannot create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .modelContainer(modelContainer)

        }
    }
}
