//
//  StepPieChart.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 29.07.25.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    
    @State private var rawSelectedChartValue: Double?

    var chartData: [WeekdayChartData]

    var body: some View {
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
            
            Chart {
                ForEach(chartData) { weekday in
                    SectorMark(
                        angle: .value("Average Steps", weekday.value),
                        innerRadius: .ratio(0.6),
                        angularInset: 1)
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(6)
                }
            }
            .chartAngleSelection(value: $rawSelectedChartValue)
            .frame(height: 240)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .onChange(of: rawSelectedChartValue) { oldValue, newValue in
            print(newValue)
        }
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
}
