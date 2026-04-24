import SwiftUI

@main
struct DoudizhuApp: App {
    init() {
        GameCenterManager.shared.authenticate()
        Analytics.shared.track(.sessionStart)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
