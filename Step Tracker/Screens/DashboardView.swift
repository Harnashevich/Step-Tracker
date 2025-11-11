//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 23.07.25.
//

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight
    var id: Self { self }

    var title: String {
        return switch self {
        case .steps:
            "Steps"
        case .weight:
            "Weight"
        }
    }
}

struct DashboardView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(HealthKitData.self) private var hkData
    @Namespace var zoomTransition
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingAlert = false
    @State private var fetchError: STError = .noData
    @State private var isShowingCoachView = false
    
    var metricColor: Color {
        selectedStat == .steps ? .pink : .indigo
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChart(chartData: ChartHelper.convert(data: hkData.stepData))
                        StepPieChart(chartData: ChartHelper.averageWeekdayCount(for: hkData.stepData))
                    case .weight:
                        WeightLineChart(chartData: ChartHelper.convert(data: hkData.weightData))
                        WeightDiffBarChart(chartData: ChartHelper.averageDailyWeightDiffs(for: hkData.weightDiffData))
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding()
            .task { fetchHealthData() }
            .navigationTitle("Dashboard")
            .toolbarTitleDisplayMode(.inlineLarge)
            .background(LinearGradient(
                colors: [metricColor.opacity(0.25), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing))
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .fullScreenCover(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                fetchHealthData()
            }, content: {
                HealthKitPermissionPrimingView()
            })
            .sheet(isPresented: $isShowingCoachView) {
                DataAnalyzer.shared.coachMessage = ""
            } content: {
                CoachView(selectedStat: selectedStat)
                    .presentationDetents([.fraction(0.8)])
                    .navigationTransition(.zoom(sourceID: "coachview", in: zoomTransition))
            }
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                // Actions
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
            .toolbar {
                if DataAnalyzer.shared.model.isAvailable {
                    ToolbarItem {
                        Button("Analyze Data", systemImage: "apple.intelligence") {
                            isShowingCoachView.toggle()
                            Task { await DataAnalyzer.shared.analyzeHealthData() }
                        }
                    }
                    .matchedTransitionSource(id: "coachview", in: zoomTransition)
                }
            }
        }
        .tint(metricColor)
    }
    
    private func fetchHealthData() {
        Task {
            do {
//                await hkManager.addSimulatorData()
                async let steps = hkManager.fetchStepCount()
                async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)

                hkData.stepData = try await steps
                hkData.weightData = try await weightsForLineChart
                hkData.weightDiffData = try await weightsForDiffBarChart
            } catch STError.authNotDetermined {
                isShowingPermissionPrimingSheet = true
            } catch STError.noData {
                fetchError = .noData
                isShowingAlert = true
            } catch {
                fetchError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
        .environment(HealthKitData())
}
