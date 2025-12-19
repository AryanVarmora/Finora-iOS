//
//  BudgetAlertsCard.swift
//  Finora - FIXED budget alerts
//

import SwiftUI

struct BudgetAlertsCard: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @ObservedObject var budgetManager = BudgetManager.shared
    @Binding var showBudgetSettings: Bool
    
    var alerts: [BudgetAlert] {
        budgetManager.getAlerts(viewModel: viewModel)
    }
    
    var body: some View {
        if !alerts.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Text("Budget Alerts")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        showBudgetSettings = true
                    }) {
                        Text("Manage")
                            .font(.caption)
                            .foregroundColor(Color(hex: "3B82F6"))
                    }
                }
                
                VStack(spacing: 12) {
                    ForEach(alerts.prefix(3)) { alert in
                        BudgetAlertRow(alert: alert)
                    }
                }
                
                if alerts.count > 3 {
                    Button(action: {
                        showBudgetSettings = true
                    }) {
                        HStack {
                            Spacer()
                            Text("View All (\(alerts.count) alerts)")
                                .font(.caption)
                                .foregroundColor(Color(hex: "3B82F6"))
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}

struct BudgetAlertRow: View {
    let alert: BudgetAlert
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.icon)
                .font(.title3)
                .foregroundColor(Color(hex: alert.color))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(alert.percentage)%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: alert.color))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: alert.color).opacity(0.1))
                .cornerRadius(8)
        }
        .padding(12)
        .background(Color(hex: alert.color).opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    BudgetAlertsCard(
        viewModel: ExpenseViewModel(),
        budgetManager: BudgetManager.shared,
        showBudgetSettings: .constant(false)
    )
}
