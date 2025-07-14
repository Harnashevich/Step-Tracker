//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 14.07.25.
//

import SwiftUI

struct HealthDataListView: View {
    
    @State private var isShowingAddData = false
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    
    var metric: HealthMetricContext
    
    var body: some View {
        List(0..<28) { i in
            HStack {
                Text(Date(), format: .dateTime.month().day().year())
                Spacer()
                Text(10_000, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar {
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }
}

extension HealthDataListView {
    
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                HStack {
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .padding(.leading, 20)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                    //                        .frame(width: 140)
                }
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dissmiss") {
                        isShowingAddData = false
                    }
                }
            }
        }
    }

}

#Preview {
    NavigationStack {
        HealthDataListView(metric: .weight)
    }
}
