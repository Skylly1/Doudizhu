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
        FirebaseApp.configure()
        #endif

        // SwiftData 存档容器（Schema 变更时自动重建）
        do {
            modelContainer = try ModelContainer(for: GameSaveModel.self)
        } catch {
            // Schema 不兼容 — 备份旧数据再重建
            CrashReporter.shared.log("SwiftData schema migration failed: \(error)", level: .warning)
            
            let fm = FileManager.default
            let storeDir = URL.applicationSupportDirectory
            let backupDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("SaveBackup", isDirectory: true)
            
            // 创建备份目录
            try? fm.createDirectory(at: backupDir, withIntermediateDirectories: true)
            
            // 备份旧数据库文件
            let timestamp = ISO8601DateFormatter().string(from: Date())
            for suffix in ["", "-wal", "-shm"] {
                let fileName = "default.store\(suffix)"
                let source = storeDir.appending(path: fileName)
                let backup = backupDir.appendingPathComponent("\(timestamp)_\(fileName)")
                if fm.fileExists(atPath: source.path()) {
                    try? fm.copyItem(at: source, to: backup)
                    try? fm.removeItem(at: source)
                }
            }
            CrashReporter.shared.log("Old save data backed up to \(backupDir.path())", level: .info)
            
            // 重建容器
            do {
                modelContainer = try ModelContainer(for: GameSaveModel.self)
                CrashReporter.shared.log("ModelContainer recreated successfully after migration", level: .info)
            } catch {
                fatalError("Failed to init ModelContainer after backup+reset: \(error)")
            }
        }

        GameCenterManager.shared.authenticate()
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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .modelContainer(modelContainer)
                .onAppear {
                    // 注入 ModelContext 到 SaveManager
                    let context = modelContainer.mainContext
                    SaveManager.shared.configure(with: context)
                }
        }
    }
}
