import SwiftUI
import SwiftData
import UIKit

@main
struct DoudizhuApp: App {
    let modelContainer: ModelContainer

    init() {
        // SwiftData 存档容器
        do {
            modelContainer = try ModelContainer(for: GameSaveModel.self)
        } catch {
            fatalError("Failed to init ModelContainer: \(error)")
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
