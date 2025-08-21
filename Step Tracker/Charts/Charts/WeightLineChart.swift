//
//  WeightLineChart.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 31.07.25.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    
    @State private var rawSelectedDate: Date?
    
    var chartData: [DateValueChartData]

    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in:  rawSelectedDate)
    }

    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }

    var subtitle: String {
        let average = chartData.map { $0.value }.average
        return "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) lbs"
    }
    
    var body: some View {
        let config = ChartContainerConfiguration(
            title: "Weight",
            symbol: "figure",
            subtitle: subtitle,
            context: .weight,
            isNav: true
        )
        
        ChartContainer(config: config) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .weight)
                }
                
                RuleMark(y: .value("Goal", 155))
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                
                ForEach(chartData) { weight in
                    AreaMark(
                        x: .value("Day", weight.date, unit: .day),
                        yStart: .value("Value", weight.value),
                        yEnd: .value("Min Value", minValue)
                    )
                    .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Day", weight.date, unit: .day),
                        y: .value("Value", weight.value)
                    )
                    .foregroundStyle(.indigo)
                    .interpolationMethod(.catmullRom)
                    .symbol(.circle)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
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
                        systemImageName: "chart.line.downtrend.xyaxis",
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
    WeightLineChart(chartData: ChartHelper.convert(data: MockData.weights))
}
