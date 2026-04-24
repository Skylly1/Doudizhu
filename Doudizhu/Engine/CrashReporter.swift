import Foundation

/// Lightweight crash/error reporter using os_log
/// Can be replaced with Sentry/Firebase later
final class CrashReporter {
    nonisolated(unsafe) static let shared = CrashReporter()

    private let logFile: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        logFile = docs.appendingPathComponent("crash_log.txt")
    }

    func log(_ message: String, level: Level = .info, file: String = #file, line: Int = #line) {
        let entry = "[\(level.rawValue)] \(Date()) \(URL(fileURLWithPath: file).lastPathComponent):\(line) — \(message)\n"
        if let data = entry.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFile.path) {
                if let handle = try? FileHandle(forWritingTo: logFile) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                try? data.write(to: logFile)
            }
        }
    }

    func getRecentLogs() -> String {
        (try? String(contentsOf: logFile)) ?? ""
    }

    func clearLogs() {
        try? FileManager.default.removeItem(at: logFile)
    }

    enum Level: String {
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"
        case fatal = "FATAL"
    }
}
