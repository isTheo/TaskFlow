//
//  SettingsManager.swift
//  TaskFlow
//
//  Created by Matteo Orru on 13/02/25.
//

import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard
    
    // MARK: - Published Properties
    @Published var defaultPriority: TaskPriority {
        didSet {
            defaults.set(defaultPriority.rawValue, forKey: Keys.defaultPriority.rawValue)
        }
    }
    
    @Published var showNotifications: Bool {
        didSet {
            defaults.set(showNotifications, forKey: Keys.showNotifications.rawValue)
        }
    }
    
    @Published var notificationTime: Int {
        didSet {
            defaults.set(notificationTime, forKey: Keys.notificationTime.rawValue)
        }
    }
    
    @Published var useDarkMode: Bool {
        didSet {
            defaults.set(useDarkMode, forKey: Keys.useDarkMode.rawValue)
        }
    }
    
    @Published var sortBy: SortOption {
        didSet {
            defaults.set(sortBy.rawValue, forKey: Keys.sortBy.rawValue)
        }
    }
    
    // MARK: - Enums
    enum Keys: String {
        case defaultPriority
        case showNotifications
        case notificationTime
        case useDarkMode
        case sortBy
    }
    
    enum SortOption: Int, CaseIterable {
        case priority
        case dueDate
        case created
        
        var title: String {
            switch self {
            case .priority: return "Priorità"
            case .dueDate: return "Data Scadenza"
            case .created: return "Data Creazione"
            }
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Carica i valori salvati o usa i default
        self.defaultPriority = TaskPriority(rawValue: Int16(defaults.integer(forKey: Keys.defaultPriority.rawValue))) ?? .medium
        self.showNotifications = defaults.bool(forKey: Keys.showNotifications.rawValue)
        self.notificationTime = defaults.integer(forKey: Keys.notificationTime.rawValue)
        self.useDarkMode = defaults.bool(forKey: Keys.useDarkMode.rawValue)
        self.sortBy = SortOption(rawValue: defaults.integer(forKey: Keys.sortBy.rawValue)) ?? .priority
        
        // Imposta i valori di default se non sono mai stati salvati
        if !defaults.bool(forKey: "hasInitializedDefaults") {
            self.setDefaultValues()
            defaults.set(true, forKey: "hasInitializedDefaults")
        }
    }
    
    // MARK: - Helper Methods
    private func setDefaultValues() {
        defaultPriority = .medium
        showNotifications = true
        notificationTime = 60 // minuti prima della scadenza
        useDarkMode = false
        sortBy = .priority
    }
    
    func resetToDefaults() {
        setDefaultValues()
    }
}
