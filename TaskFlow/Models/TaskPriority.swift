//
//  TaskPriority.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import Foundation

// TaskPriority definisce i possibili livelli di priorità per un task
// enum con un tipo raw value Int per facilitare il salvataggio in Core Data
enum TaskPriority: Int16, CaseIterable, Codable {
    case low = 0
    case medium = 1
    case high = 2
    
    var title: String {
        switch self {
        case .low: return "priority.low".localized
        case .medium: return "priority.medium".localized
        case .high: return "priority.high".localized
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "red"
        }
    }
}
