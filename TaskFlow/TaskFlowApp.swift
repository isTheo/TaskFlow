//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import SwiftUI

@main
struct TaskFlowApp: App {
    // Crea l'istanza del PersistenceController che verrà utilizzata in tutta l'app
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
