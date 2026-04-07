//
//  ContentView.swift
//  TimerApp
//
//  Created by czq on 2026/4/1.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: TimerAppViewModel

    var body: some View {
        VStack(spacing: 16) {
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

            Divider()

            StatisticsView()
        }
        .padding(24)
        .frame(minWidth: 420, idealWidth: 420, minHeight: 420, idealHeight: 420)
    }
}
