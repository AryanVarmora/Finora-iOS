//
//  FinoraApp.swift
//  Finora
//
//  Created by Aryan Varmora on 11/20/25.
//

import SwiftUI

@main
struct FinoraApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.context)
            } else {
                LoginView()
            }
        }
    }
}
