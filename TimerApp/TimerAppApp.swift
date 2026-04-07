//
//  TimerAppApp.swift
//  TimerApp
//
//  Created by czq on 2026/4/1.
//

import SwiftUI
import AppKit

@main
struct TimerAppApp: App {
    @StateObject private var model = TimerAppViewModel()

    var body: some Scene {
        Window("Timer", id: "main-window") {
            ContentView()
                .environmentObject(model)
                .task {
                    await model.bootstrapIfNeeded()
                }
                .background(FixedWindowConfigurator())
        }
        .defaultSize(width: 420, height: 420)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(model)
        }

        MenuBarExtra {
            MenuBarView()
                .environmentObject(model)
                .frame(width: 280)
                .task {
                    await model.bootstrapIfNeeded()
                }
        } label: {
            Label(model.menuBarTitle, systemImage: "timer")
        }
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
