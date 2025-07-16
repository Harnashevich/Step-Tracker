//
//  Step_TrackerApp.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 8.07.25.
//

import SwiftUI

@main
struct Step_TrackerApp: App {
    
    let hkManager = HealthManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkManager)
        }
    }
}
