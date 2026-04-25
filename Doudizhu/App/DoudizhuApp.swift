import SwiftUI
import SwiftData

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
