import SwiftUI

struct SettingsView: View {
    let onBack: () -> Void

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("设置")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()

                List {
                    Section("音效") {
                        Toggle("音效", isOn: $soundEnabled)
                        Toggle("背景音乐", isOn: $musicEnabled)
                        Toggle("震动反馈", isOn: $hapticEnabled)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    SettingsView(onBack: {})
}
