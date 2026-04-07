import SwiftUI
import timer

struct SettingsView: View {
    @EnvironmentObject private var model: TimerAppViewModel

    var body: some View {
        Form {
            Section("时间设置") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("专注时长: \(Int(model.focusDuration / 60)) 分钟")
                    Slider(value: $model.focusDuration, in: 15*60...60*60, step: 60)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("短休息时长: \(Int(model.shortBreakDuration / 60)) 分钟")
                    Slider(value: $model.shortBreakDuration, in: 3*60...15*60, step: 60)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("长休息时长: \(Int(model.longBreakDuration / 60)) 分钟")
                    Slider(value: $model.longBreakDuration, in: 10*60...30*60, step: 60)
                }

                Picker("长休息周期", selection: $model.cyclesBeforeLongBreak) {
                    ForEach(2...6, id: \.self) { count in
                        Text("\(count) 个番茄钟").tag(count)
                    }
                }
            }

            Section("提醒设置") {
                Toggle("启用声音", isOn: $model.soundEnabled)
                Toggle("启用通知", isOn: $model.notificationEnabled)
            }

            Section("菜单栏设置") {
                Toggle("显示图标", isOn: $model.menuBarShowIcon)
                Toggle("显示时间", isOn: $model.menuBarShowTime)
                if model.menuBarShowTime {
                    Toggle("显示秒数", isOn: $model.menuBarShowSeconds)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 350, height: 450)
        .padding()
    }
}
