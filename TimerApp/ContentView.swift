//
//  ContentView.swift
//  TimerApp
//
//  Created by czq on 2026/4/1.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: TimerAppViewModel
    @State private var selectedTab: Tab = .timer

    enum Tab {
        case timer
        case statistics
    }

    var body: some View {
        if model.showPhaseCompletionAlert {
            PhaseCompletionView()
                .environmentObject(model)
        } else {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("计时").tag(Tab.timer)
                    Text("统计").tag(Tab.statistics)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.top, 16)

                switch selectedTab {
                case .timer:
                    timerView
                case .statistics:
                    StatisticsView()
                        .padding(24)
                }
            }
            .frame(minWidth: 420, idealWidth: 420, minHeight: 420, idealHeight: 420)
        }
    }

    private var timerView: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(model.phaseText.capitalized)
                .font(.title2.weight(.semibold))

            Text(model.remainingText)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()

            HStack(spacing: 12) {
                if model.canStart {
                    Button("开始") {
                        Task { await model.start() }
                    }
                    .buttonStyle(.borderedProminent)

                    if model.canSkipBeforeStart {
                        Button("跳过") {
                            Task { await model.skip() }
                        }
                        .buttonStyle(.bordered)
                    }
                }

                if model.canPause {
                    Button("暂停") {
                        Task { await model.pause() }
                    }
                    .buttonStyle(.bordered)
                }

                if model.canResume {
                    Button("继续") {
                        Task { await model.resume() }
                    }
                    .buttonStyle(.bordered)
                }

                if model.canStop {
                    Button("停止") {
                        Task { await model.stop() }
                    }
                    .buttonStyle(.bordered)
                }

                if model.canSkip {
                    Button("跳过") {
                        Task { await model.skip() }
                    }
                    .buttonStyle(.bordered)
                }
            }

            Spacer()
        }
        .padding(24)
    }
}
