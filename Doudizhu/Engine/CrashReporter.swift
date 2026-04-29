import Foundation
#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif
import os.log

/// 轻量级崩溃/错误报告 — os_log + 本地文件持久化
/// MVP 阶段零依赖；上线后可对接 Sentry/Crashlytics
@MainActor final class CrashReporter {
    static let shared = CrashReporter()

    private let logger = Logger(subsystem: "com.hongzeng.doudizhu", category: "crash")
    private let logFile: URL
    private let maxLogSize = 512 * 1024 // 512KB 上限

    /// 面包屑：最近操作记录，帮助定位问题
    private var breadcrumbs: [(message: String, timestamp: Date)] = []
    private let maxBreadcrumbs = 50

    private init() {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("crash_log.txt")
            return
        }
        logFile = docs.appendingPathComponent("crash_log.txt")
        rotateIfNeeded()
    }

    /// 记录面包屑（用户操作轨迹）
    func addBreadcrumb(_ message: String) {
        breadcrumbs.append((message: message, timestamp: Date()))
        if breadcrumbs.count > maxBreadcrumbs {
            breadcrumbs.removeFirst()
        }
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().log(message)
        #endif
    }

    func log(_ message: String, level: Level = .info, file: String = #file, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let entry = "[\(level.rawValue)] \(Date()) \(fileName):\(line) — \(message)\n"

        // os_log 输出（Console.app + Xcode 可见）
        switch level {
        case .info:    logger.info("\(entry)")
        case .warning: logger.warning("⚠️ \(entry)")
        case .error:   logger.error("❌ \(entry)")
        case .fatal:   logger.critical("🔥 \(entry)")
        }

        // Crashlytics 转发
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().log("\(level.rawValue): \(message)")
        if level == .error || level == .fatal {
            let error = NSError(domain: "com.hongzeng.doudizhu", code: level == .fatal ? -1 : -2,
                              userInfo: [NSLocalizedDescriptionKey: message])
            Crashlytics.crashlytics().record(error: error)
        }
        #endif

        // 文件持久化
        if let data = entry.data(using: .utf8) {
            appendToFile(data)
        }

        // Fatal 级别附加面包屑
        if level == .fatal || level == .error {
            let crumbs = breadcrumbs.suffix(10)
                .map { "  📌 \($0.timestamp): \($0.message)" }
                .joined(separator: "\n")
            if !crumbs.isEmpty, let data = ("  Breadcrumbs:\n\(crumbs)\n").data(using: .utf8) {
                appendToFile(data)
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

    // MARK: - Private

    private func appendToFile(_ data: Data) {
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

    private func rotateIfNeeded() {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: logFile.path),
              let size = attrs[.size] as? Int, size > maxLogSize else { return }
        // 保留最后 256KB
        if let content = try? Data(contentsOf: logFile) {
            let keep = content.suffix(256 * 1024)
            try? keep.write(to: logFile)
        }
    }
}
