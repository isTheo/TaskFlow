//
//  PersistenceController.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import CoreData
import Foundation

// Il PersistenceController è responsabile della gestione dello stack Core Data.
// Implementa il pattern Singleton per garantire un unico punto di accesso al database.
class PersistenceController {
    // MARK: - Singleton
    
    // Istanza condivisa accessibile da tutta l'applicazione, static let assicura che venga creata una sola volta e sia thread-safe.
    static let shared = PersistenceController()
    
    // MARK: - Core Data Stack
    
    // Il container che contiene il modello di Core Data, il coordinator e i context. È un componente principale dello stack Core Data.
    let container: NSPersistentContainer
    
    // Inizializzatore principale privato che configura il container. È privato per forzare l'uso del singleton shared.
    private init() {
        // Crea il container usando il nome del modello .xcdatamodeld
        container = NSPersistentContainer(name: "TaskFlow")
        
        // Configura il context principale per gestire automaticamente i merge da altri context
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Imposta una policy di merge che favorisce i cambiamenti più recenti
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Carica il database
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Errore nel caricamento di Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Convenience Methods
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // Crea un nuovo context per operazioni in background, questo dovrebbe essere usato per operazioni pesanti o batch updates.
    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
    
    // Salva il context principale se ci sono modifiche pendenti, gestisce anche gli errori di salvataggio.
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Qua si potrebbe gestire l'errore in modo più appropriato, magari con un sistema di logging o alert per l'utente
                print("Errore nel salvataggio del context: \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - Preview Support
    
    // Crea un container per le preview di SwiftUI e i test. A sua volta il container usa un database in memoria che viene cancellato al riavvio.
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // datio di esempio per le preview
        let sampleTask = TaskEntity(context: viewContext)
        sampleTask.id = UUID()
        sampleTask.title = "task.example.title".localized
        sampleTask.taskDescription = "task.example.description".localized
        sampleTask.dueDate = Date()
        sampleTask.priority = TaskPriority.medium.rawValue
        sampleTask.isCompleted = false
        
        try? viewContext.save()
        return controller
    }()
    
    // Inizializzatore per testing e preview che può creare un database in memoria invece che su disco.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaskFlow")
        
        if inMemory {
            // Per il database in memoria viene usato /dev/null come percorso
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("error.coredata.loading".localized(with: error.localizedDescription))
            }
        }
    }
}
