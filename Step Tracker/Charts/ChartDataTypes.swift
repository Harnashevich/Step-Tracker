//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 25.07.25.
//

import Foundation

struct DateValueChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
