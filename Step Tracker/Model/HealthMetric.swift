//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 23.07.25.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
