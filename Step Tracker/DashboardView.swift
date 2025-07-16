//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 8.07.25.
//

import SwiftUI

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
    
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming: Bool = false
    @State private var isShowingPermissionPrimingSheet: Bool = false
    @State private var selectedStat: HealthMetricContext = .steps
    var isSteps: Bool { selectedStat == .steps }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) { metric in
                            Text(metric.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    VStack {
                        NavigationLink(value: selectedStat) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Label("Steps", systemImage: "figure.walk")
                                        .font(.title3.bold())
                                        .foregroundStyle(.pink)
                                    
                                    Text("Avg: 10K Steps")
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 150)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Label("Averages", systemImage: "calendar")
                                .font(.title3.bold())
                                .foregroundStyle(.pink)
                            
                            Text("Last 28 Days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 12)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 240)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12)
                         .fill(Color(.secondarySystemBackground)))
                }
            }
            .scrollIndicators(.never)
            .padding()
            .onAppear {
                isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet) {
                // fetch health data
            } content: {
                HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
            }

        }
        .tint(isSteps ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthManager())
}
