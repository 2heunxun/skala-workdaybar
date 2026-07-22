import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var remainingMenuItem: NSMenuItem?
    private var timer: Timer?
    private var settingsWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.registerDefaults()

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureStatusItem(item)
        statusItem = item

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateIcon),
            name: UserDefaults.didChangeNotification,
            object: nil
        )

        updateIcon()
        startTimer()
    }

    private func configureStatusItem(_ item: NSStatusItem) {
        let menu = NSMenu()
        let remainingItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        menu.addItem(remainingItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "설정…", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "종료", action: #selector(quit), keyEquivalent: "q"))
        item.menu = menu
        for menuItem in menu.items {
            menuItem.target = self
        }
        remainingMenuItem = remainingItem
    }

    private func startTimer() {
        let timer = Timer(timeInterval: 30, target: self, selector: #selector(updateIcon), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    @objc private func updateIcon() {
        guard let statusItem, let button = statusItem.button else { return }

        let now = Date()
        let isWeekendNow = ProgressCalculator.isWeekend(date: now)

        if Preferences.hideOnWeekend && isWeekendNow {
            statusItem.isVisible = false
            return
        }
        statusItem.isVisible = true

        guard let base = loadBaseImage() else { return }

        let schedule = Preferences.schedule
        let progress = ProgressCalculator.progress(now: now, schedule: schedule)
        let phase = ProgressCalculator.phase(now: now, schedule: schedule)

        let rendered = IconRenderer.render(
            base: base,
            progress: progress,
            dimAlpha: CGFloat(Preferences.dimAlpha),
            direction: Preferences.fillDirection
        )
        rendered.isTemplate = false
        button.image = rendered

        let statusText = ProgressCalculator.statusText(for: phase)
        button.toolTip = statusText
        remainingMenuItem?.title = statusText
    }

    private func loadBaseImage() -> NSImage? {
        if let customURL = CustomImageStore.currentImageURL(), let image = NSImage(contentsOf: customURL) {
            return fitToStatusBar(image)
        }

        guard let image = loadDefaultLogo() else { return nil }
        return fitToStatusBar(image)
    }

    /// Scales to the menu bar's icon height while preserving aspect ratio, so
    /// wide or tall custom logos don't get squashed into a fixed square. Caps
    /// the width so an extreme aspect ratio can't crowd out the rest of the
    /// menu bar.
    private func fitToStatusBar(_ image: NSImage) -> NSImage {
        let targetHeight: CGFloat = 18
        let maxWidth: CGFloat = 60
        let aspect = image.size.width / image.size.height
        let width = min(targetHeight * aspect, maxWidth)
        image.size = NSSize(width: width, height: targetHeight)
        return image
    }

    /// Packaged `.app` bundles carry `default-logo.png` under Contents/Resources
    /// (standard bundle layout, required for a valid code signature). `swift run`
    /// during development has no such bundle, so it falls back to SwiftPM's
    /// generated `Bundle.module`, which points at the raw `.build` output.
    private func loadDefaultLogo() -> NSImage? {
        if let url = Bundle.main.url(forResource: "default-logo", withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        if let url = Bundle.module.url(forResource: "default-logo", withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        return nil
    }

    @objc private func openSettings() {
        if settingsWindowController == nil {
            let hosting = NSHostingController(rootView: SettingsView())
            let window = NSWindow(contentViewController: hosting)
            window.title = "WorkdayBar 설정"
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            settingsWindowController = NSWindowController(window: window)
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindowController?.window?.center()
        settingsWindowController?.showWindow(nil)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
