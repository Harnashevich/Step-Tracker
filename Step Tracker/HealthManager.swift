//
//  HealthManager.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 15.07.25.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthManager {
    
    let store = HKHealthStore()
    let types: Set = [
        HKQuantityType(.stepCount),
        HKQuantityType(.bodyMass)
    ]
}
