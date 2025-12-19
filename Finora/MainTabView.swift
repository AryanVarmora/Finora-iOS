//
//  MainTabView.swift
//  Finora - COMPLETE FIX with NavigationView
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            // Expenses Tab
            ExpenseListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(1)
            
            // Add Expense Tab (Center)
            AddExpenseView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            // Analytics Tab
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            // Profile Tab - WRAPPED IN NAVIGATIONVIEW
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(4)
        }
        .accentColor(Color(hex: "3B82F6"))
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToAnalytics"))) { _ in
            selectedTab = 3  // Switch to Analytics tab
            print("📊 Switching to Analytics tab")
        }
    }
}

#Preview {
    MainTabView()
}
