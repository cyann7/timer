import SwiftUI

@main
struct TimerMacApp: App {
    @StateObject private var model = TimerAppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .task {
                    await model.bootstrapIfNeeded()
                }
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
