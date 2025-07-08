//
//  ContentView.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 8.07.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack {
                        HStack {
                            
                        }
                    }
                }
                .padding()
            }
            .scrollDisabled(false)
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    ContentView()
}
