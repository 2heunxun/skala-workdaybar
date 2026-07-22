import ServiceManagement

enum LaunchAtLogin {
    static var isRegistered: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func register() throws {
        guard SMAppService.mainApp.status != .enabled else { return }
        try SMAppService.mainApp.register()
    }

    static func unregister() throws {
        guard SMAppService.mainApp.status == .enabled else { return }
        try SMAppService.mainApp.unregister()
    }
}
