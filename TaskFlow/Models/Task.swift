//
//  Task.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import Foundation
import CoreData


// Conformandosi a Identifiable, ogni task ha un identificatore unico che semplifica la gestione nelle liste SwiftUI e nel database Core Data.
struct Task: Identifiable {
    
    // Identificatore unico per il task. UUID() per garantisce l'unicità anche in scenari di sincronizzazione
    let id: UUID
    
    var title: String
    var description: String?
    
    // La data di scadenza del task
    var dueDate: Date?
    var isCompleted: Bool
    var priority: TaskPriority
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        priority: TaskPriority = .medium
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
    }
}


extension Task {
    // Questo inizializzatore permette di convertire un'entità core data nel modello Task
    init(from entity: TaskEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.description = entity.taskDescription
        self.dueDate = entity.dueDate
        self.isCompleted = entity.isCompleted
        self.priority = TaskPriority(rawValue: Int16(entity.priority)) ?? .medium
    }
    
    // permette di salvare i dati del modello in core data
    func updateEntity(_ entity: TaskEntity) {
        entity.id = self.id
        entity.title = self.title
        entity.taskDescription = self.description
        entity.dueDate = self.dueDate
        entity.isCompleted = self.isCompleted
        entity.priority = self.priority.rawValue
    }
}


// Estensione per aggiungere funzionalità di formattazione delle date
extension Task {
    // Formatta la data di scadenza in un formato leggibile
    var formattedDueDate: String? {
        guard let dueDate = dueDate else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "it_IT")
        
        return formatter.string(from: dueDate)
    }
}


extension Task: Codable {}
