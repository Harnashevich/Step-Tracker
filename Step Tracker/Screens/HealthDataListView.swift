//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 23.07.25.
//

import SwiftUI

struct HealthDataListView: View {

    @Environment(HealthKitData.self) private var hkData
    @Environment(HealthKitManager.self) private var hkManager
    @Namespace var zoomTransition
    @State private var isShowingAddData = false
    @State private var isShowingAlert = false
    @State private var writeError: STError = .noData
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""

    var metric: HealthMetricContext

    var listData: [HealthMetric] {
        metric == .steps ? hkData.stepData : hkData.weightData
    }
    
    var metricColor: Color {
        metric == .steps ? .pink : .indigo
    }

    var body: some View {
        List(listData.reversed()) { data in
            LabeledContent {
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            } label: {
                Text(data.date, format: .dateTime.month().day().year())
                    .accessibilityLabel(data.date.accesibilityDate)
            }
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.35))
            .accessibilityElement(children: .combine)
        }
        .navigationTitle(metric.title)
        .scrollContentBackground(.hidden)
        .background(LinearGradient(
            colors: [metricColor.opacity(0.25), .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing))
        .sheet(isPresented: $isShowingAddData) {
            addDataView
                .presentationDetents([.fraction(0.4)])
                .scrollContentBackground(.hidden)
                .navigationTransition(.zoom(sourceID: "addData", in: zoomTransition))
        }
        .overlay {
            if listData.isEmpty {
                ContentUnavailableView("No \(metric.title) to Display", systemImage: metric == .steps ? "figure.walk" : "figure")
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Add Data", systemImage: "plus") {
                    isShowingAddData = true
                }
                .buttonStyle(.glassProminent)
                .tint(metricColor)
            }
            .matchedTransitionSource(id: "addData", in: zoomTransition)
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                LabeledContent(metric.title) {
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                switch writeError {
                case .authNotDetermined, .noData, .unableToCompleteRequest, .invalidValue:
                    EmptyView()
                case .sharingDenied:
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    
                    Button("Cancel", role: .cancel) { }
                }
            } message: { writeError in
                Text(writeError.failureReason)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        addDataToHealthKit()
                    }
                    .tint(metricColor)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close) {
                        isShowingAddData = false
                    }
                }
            }
        }
    }
    
    private func addDataToHealthKit() {
        guard let value = Double(valueToAdd) else {
            writeError = .invalidValue
            isShowingAlert = true
            valueToAdd = ""
            return
        }
        Task {
            do {
                if metric == .steps {
                    try await hkManager.addStepData(for: addDataDate, value: value)
                    hkData.stepData = try await hkManager.fetchStepCount()
                } else {
                    try await hkManager.addWeightData(for: addDataDate, value: value)
                    async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                    async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)

                    hkData.weightData = try await weightsForLineChart
                    hkData.weightDiffData = try await weightsForDiffBarChart
                }

                isShowingAddData = false
            } catch STError.sharingDenied(let quantityType) {
                writeError = .sharingDenied(quantityType: quantityType)
                isShowingAlert = true
            } catch {
                writeError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthDataListView(metric: .weight)
            .environment(HealthKitManager())
    }
}
