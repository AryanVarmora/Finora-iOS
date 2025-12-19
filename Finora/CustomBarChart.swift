//
//  CustomBarChart.swift
//  Finora
//
//  Created by Aryan Varmora on 12/19/25.
//


//
//  CustomBarChart.swift
//  Finora - FIXED with ChartExpenseData
//

import SwiftUI

struct CustomBarChart: View {
    let data: [ChartExpenseData]
    
    private var maxValue: Double {
        data.map { $0.amount }.max() ?? 1
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data) { item in
                VStack(spacing: 4) {
                    // Bar
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "3B82F6"),
                                    Color(hex: "2563EB")
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: max(barHeight(for: item.amount), 4))
                    
                    // Day label
                    Text(item.day)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func barHeight(for amount: Double) -> CGFloat {
        guard maxValue > 0 else { return 4 }
        let ratio = amount / maxValue
        return CGFloat(ratio) * 140 // Max height of 140
    }
}

#Preview {
    CustomBarChart(data: [
        ChartExpenseData(day: "Mon", amount: 50),
        ChartExpenseData(day: "Tue", amount: 75),
        ChartExpenseData(day: "Wed", amount: 30),
        ChartExpenseData(day: "Thu", amount: 90),
        ChartExpenseData(day: "Fri", amount: 60),
        ChartExpenseData(day: "Sat", amount: 40),
        ChartExpenseData(day: "Sun", amount: 20)
    ])
    .frame(height: 180)
    .padding()
}
