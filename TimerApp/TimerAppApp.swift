//
//  TimerAppApp.swift
//  TimerApp
//
//  Created by czq on 2026/4/1.
//

import SwiftUI
import AppKit
import Combine

extension Notification.Name {
    static let openMainWindow = Notification.Name("openMainWindow")
}

@main
struct TimerAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var model = TimerAppViewModel()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        Window("Timer", id: "main-window") {
            ContentView()
                .environmentObject(model)
                .task {
                    await model.bootstrapIfNeeded()
                    appDelegate.setupStatusBar(model: model)
                }
                .background(FixedWindowConfigurator())
                .onReceive(NotificationCenter.default.publisher(for: .openMainWindow)) { _ in
                    openWindow(id: "main-window")
                }
        }
        .defaultSize(width: 420, height: 420)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(model)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var model: TimerAppViewModel?
    private var cancellables = Set<AnyCancellable>()

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openMainWindow()
        }
        return true
    }

    @MainActor
    func setupStatusBar(model: TimerAppViewModel) {
        guard statusItem == nil else { return }
        self.model = model

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.title = model.menuBarTitle
            button.target = self
            button.action = #selector(statusBarClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // 监听 menuBarTitle 变化
        model.$menuBarShowIcon
            .merge(with: model.$menuBarShowTime)
            .merge(with: model.$menuBarShowSeconds)
            .merge(with: model.$remainingSeconds.map { _ in true })
            .receive(on: DispatchQueue.main)
            .sink { [weak self, weak model] _ in
                guard let model = model else { return }
                self?.statusItem?.button?.title = model.menuBarTitle
            }
            .store(in: &cancellables)
    }

    @objc private func statusBarClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            // 右键：显示菜单
            showContextMenu(sender)
        } else {
            // 左键：打开主窗口
            openMainWindow()
        }
    }

    private func openMainWindow() {
        // Try to find and show existing window
        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "main-window" || $0.title == "Timer" }) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        // Post notification to open window via SwiftUI
        NotificationCenter.default.post(name: .openMainWindow, object: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func showContextMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()

        Task { @MainActor in
            if let model = model {
                if model.canStart {
                    let startItem = NSMenuItem(title: "开始", action: #selector(startTimer), keyEquivalent: "")
                    startItem.target = self
                    menu.addItem(startItem)
                } else if model.canPause {
                    let pauseItem = NSMenuItem(title: "暂停", action: #selector(pauseTimer), keyEquivalent: "")
                    pauseItem.target = self
                    menu.addItem(pauseItem)
                } else if model.canResume {
                    let resumeItem = NSMenuItem(title: "继续", action: #selector(resumeTimer), keyEquivalent: "")
                    resumeItem.target = self
                    menu.addItem(resumeItem)
                }
            }

            menu.addItem(NSMenuItem.separator())

            let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
            quitItem.target = self
            menu.addItem(quitItem)

            statusItem?.menu = menu
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil
        }
    }

    @objc private func startTimer() {
        guard let model = model else { return }
        Task { @MainActor in
            await model.start()
        }
    }

    @objc private func pauseTimer() {
        guard let model = model else { return }
        Task { @MainActor in
            await model.pause()
        }
    }

    @objc private func resumeTimer() {
        guard let model = model else { return }
        Task { @MainActor in
            await model.resume()
        }
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

private struct FixedWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            apply(to: view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            apply(to: nsView.window)
        }
    }

    private func apply(to window: NSWindow?) {
        guard let window else { return }
        let size = NSSize(width: 420, height: 420)
        window.setContentSize(size)
        window.minSize = size
        window.maxSize = size
    }
}
