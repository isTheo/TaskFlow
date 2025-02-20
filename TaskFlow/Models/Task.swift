//
//  Task.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import Foundation
import CoreData


enum RepeatOption: Int, Codable, CaseIterable {
    case never = 0
    case hourly
    case daily
    case weekdays
    case weekends
    case weekly
    case monthly
    case quarterly
    case biannually
    case yearly
    
    var title: String {
        "repeat.option.\(self.rawValue)".localized
    }
}


enum EarlyReminder: Int, CaseIterable, Identifiable {
    case fiveMinutes = 5
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60
    case twoHours = 120
    case oneDay = 1440      // 24 * 60
    case twoDays = 2880     // 48 * 60
    case oneWeek = 10080    // 7 * 24 * 60
    case oneMonth = 43200   // 30 * 24 * 60
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .fiveMinutes: return "5 minutes before"
        case .fifteenMinutes: return "15 minutes before"
        case .thirtyMinutes: return "30 minutes before"
        case .oneHour: return "1 hour before"
        case .twoHours: return "2 hours before"
        case .oneDay: return "1 day before"
        case .twoDays: return "2 days before"
        case .oneWeek: return "1 week before"
        case .oneMonth: return "1 month before"
        }
    }
}


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
    
    var url: String?
    var repeatOption: RepeatOption
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        priority: TaskPriority = .medium,
        url: String? = nil,
        repeatOption: RepeatOption = .never
        
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.repeatOption = repeatOption
        self.url = url
        self.repeatOption = repeatOption
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
        self.url = entity.url
        self.repeatOption = RepeatOption(rawValue: Int(entity.repeatOption)) ?? .never
    }
    
    // permette di salvare i dati del modello in core data
    func updateEntity(_ entity: TaskEntity) {
        entity.id = self.id
        entity.title = self.title
        entity.taskDescription = self.description
        entity.dueDate = self.dueDate
        entity.isCompleted = self.isCompleted
        entity.priority = self.priority.rawValue
        entity.url = self.url
        entity.repeatOption = Int16(self.repeatOption.rawValue)
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
        formatter.locale = Locale.current
        
        return formatter.string(from: dueDate)
    }
}


extension Task: Codable {}
