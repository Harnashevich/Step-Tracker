//
//  WeightDiffBarChart.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 1.08.25.
//

import SwiftUI
import Charts

struct WeightDiffBarChart: View {
    
    @State private var rawSelectedDate: Date?
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in:  rawSelectedDate)
    }
    
    var body: some View {
        ChartContainer(chartType: .weightDiffBar) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .weight)
                }
                
                ForEach(chartData) { weightDiff in
                    BarMark(
                        x: .value("Date", weightDiff.date, unit: .day),
                        y: .value("Weight Diff", weightDiff.value)
                    )
                    .foregroundStyle(weightDiff.value >= 0 ? Color.indigo.gradient : Color.mint.gradient)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    
                    AxisValueLabel()
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(
                        systemImageName: "chart.bar",
                        title: "No Data",
                        description: "There is no weight data from the Health App."
                    )
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedData?.value)
    }
}

#Preview {
    WeightDiffBarChart(chartData: MockData.weightDiffs)
}
