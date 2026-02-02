//
//  Z_app_Chwile_App.swift
//  Złapp Chwilę
//
//  Created by Dorota Ostrowska on 02/02/2026.
//

import SwiftUI
import CoreData

@main
struct Z_app_Chwile_App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
