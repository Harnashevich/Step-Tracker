//
//  CoachView.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 11.11.25.
//

import SwiftUI

struct CoachView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var selectedStat: HealthMetricContext
    let analyzer = DataAnalyzer.shared
    var metricColor: Color {
        selectedStat == .steps ? .pink : .indigo
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Image(.coach)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(.circle)
                
                Text("Coach")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Ok", systemImage: "checkmark") {
                    dismiss()
                }
                .padding(12)
                .labelStyle(.iconOnly)
                .clipShape(.circle)
                .glassEffect(.regular.tint(metricColor).interactive())
                .tint(.white)
            }
            
            ScrollView {
                Text(analyzer.coachMessage ?? "")
                    .contentTransition(.interpolate)
                    .animation(.easeInOut(duration: 0.8), value: analyzer.coachMessage)
            }
            .overlay {
                if analyzer.isThinking {
                    VStack(spacing: 16) {
                        Image(systemName: "apple.intelligence")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .symbolEffect(.pulse, options: .repeat(.continuous))
                        
                        Text("Thinking...")
                            .font(.callout)
                    }
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 200)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

#Preview {
    CoachView(selectedStat: .weight)
}
