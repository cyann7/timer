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
    private let tabHeaderTopPadding: CGFloat = 16
    private let tabSwitcherHeight: CGFloat = 28
    private let tabHeaderHeight: CGFloat = 56

    enum Tab {
        case timer
        case statistics
    }

    var body: some View {
        if model.showPhaseCompletionAlert {
            PhaseCompletionView()
                .environmentObject(model)
        } else {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    tabSwitcher
                    tabContent
                        .frame(
                            width: proxy.size.width,
                            height: max(0, proxy.size.height - tabHeaderHeight),
                            alignment: .topLeading
                        )
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .frame(minWidth: 420, idealWidth: 420, maxWidth: .infinity, minHeight: 420, idealHeight: 420, maxHeight: .infinity, alignment: .top)
        }
    }

    private var tabSwitcher: some View {
        ZStack(alignment: .top) {
            Picker("", selection: $selectedTab) {
                Text("计时").tag(Tab.timer)
                Text("统计").tag(Tab.statistics)
            }
            .pickerStyle(.segmented)
            .frame(height: tabSwitcherHeight)
            .padding(.horizontal, 24)
            .padding(.top, tabHeaderTopPadding)
        }
        .frame(height: tabHeaderHeight, alignment: .top)
    }

    @ViewBuilder
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .timer:
                timerView
            case .statistics:
                StatisticsView()
                    .padding(24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var timerView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 36)

            Text(model.phaseText)
                .font(.title2.weight(.semibold))
           
            Spacer(minLength: 10)
            
            Text(model.remainingText)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()

            Spacer(minLength: 18)

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

                if model.canTerminate {
                    Button("终止") {
                        Task { await model.terminate() }
                    }
                    .buttonStyle(.bordered)
                }
            }

            Spacer(minLength: 84)
        }
        .padding(24)
    }
}
