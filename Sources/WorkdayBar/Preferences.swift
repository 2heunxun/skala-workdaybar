import Foundation

enum FillDirectionPreference: String, CaseIterable, Identifiable {
    case leftToRight
    case bottomToTop

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .leftToRight: return "왼쪽 → 오른쪽"
        case .bottomToTop: return "아래 → 위"
        }
    }

    var asFillDirection: FillDirection {
        switch self {
        case .leftToRight: return .leftToRight
        case .bottomToTop: return .bottomToTop
        }
    }
}

enum PreferenceKeys {
    static let clockInHour = "clockInHour"
    static let clockInMinute = "clockInMinute"
    static let clockOutHour = "clockOutHour"
    static let clockOutMinute = "clockOutMinute"
    static let dimAlpha = "dimAlpha"
    static let fillDirection = "fillDirection"
    static let hideOnWeekend = "hideOnWeekend"
    static let launchAtLogin = "launchAtLogin"
    static let customImagePath = "customImagePath"
}

enum Preferences {
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            PreferenceKeys.clockInHour: 9,
            PreferenceKeys.clockInMinute: 0,
            PreferenceKeys.clockOutHour: 18,
            PreferenceKeys.clockOutMinute: 0,
            PreferenceKeys.dimAlpha: 0.15,
            PreferenceKeys.fillDirection: FillDirectionPreference.leftToRight.rawValue,
            PreferenceKeys.hideOnWeekend: false,
            PreferenceKeys.launchAtLogin: false
        ])
    }

    static var schedule: WorkdaySchedule {
        let d = UserDefaults.standard
        return WorkdaySchedule(
            clockInHour: d.integer(forKey: PreferenceKeys.clockInHour),
            clockInMinute: d.integer(forKey: PreferenceKeys.clockInMinute),
            clockOutHour: d.integer(forKey: PreferenceKeys.clockOutHour),
            clockOutMinute: d.integer(forKey: PreferenceKeys.clockOutMinute)
        )
    }

    static var dimAlpha: Double {
        UserDefaults.standard.double(forKey: PreferenceKeys.dimAlpha)
    }

    static var fillDirection: FillDirection {
        let raw = UserDefaults.standard.string(forKey: PreferenceKeys.fillDirection) ?? ""
        return (FillDirectionPreference(rawValue: raw) ?? .leftToRight).asFillDirection
    }

    static var hideOnWeekend: Bool {
        UserDefaults.standard.bool(forKey: PreferenceKeys.hideOnWeekend)
    }

    static var launchAtLogin: Bool {
        UserDefaults.standard.bool(forKey: PreferenceKeys.launchAtLogin)
    }
}

enum CustomImageStore {
    static func directoryURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("WorkdayBar", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func currentImageURL() -> URL? {
        guard let path = UserDefaults.standard.string(forKey: PreferenceKeys.customImagePath) else { return nil }
        let url = URL(fileURLWithPath: path)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    @discardableResult
    static func importImage(from sourceURL: URL) throws -> URL {
        let dir = directoryURL()
        if let existing = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
            for file in existing where file.lastPathComponent.hasPrefix("custom-logo") {
                try? FileManager.default.removeItem(at: file)
            }
        }

        let ext = sourceURL.pathExtension.isEmpty ? "png" : sourceURL.pathExtension
        let destination = dir.appendingPathComponent("custom-logo").appendingPathExtension(ext)
        try FileManager.default.copyItem(at: sourceURL, to: destination)
        UserDefaults.standard.set(destination.path, forKey: PreferenceKeys.customImagePath)
        return destination
    }

    static func resetToDefault() {
        if let current = currentImageURL() {
            try? FileManager.default.removeItem(at: current)
        }
        UserDefaults.standard.removeObject(forKey: PreferenceKeys.customImagePath)
    }
}
