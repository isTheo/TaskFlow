//
//  TaskListViewModel.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import CoreData
import SwiftUI
import Foundation
import UserNotifications

@MainActor
class TaskListViewModel: ObservableObject {
    // MARK: - Properties
    private let viewContext: NSManagedObjectContext
    @Published private(set) var tasks: [Task] = []
    @Published private(set) var isLoading = false
    @Published var error: TaskError?
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.viewContext = context
        loadTasks()
        NotificationManager.shared.configureNotificationCategories()
        startObservingSettings()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Core Data Operations
    @MainActor
    func loadTasks() {
        _Concurrency.Task {
            // Impostiamo lo stato di caricamento all'interno del task asincrono
            await MainActor.run {
                self.isLoading = true
            }
            
            let request = TaskEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \TaskEntity.priority, ascending: false),
                NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)
            ]
            
            do {
                let fetchedEntities = try viewContext.fetch(request)
                // Aggiorniamo i dati sul thread principale
                await MainActor.run {
                    self.tasks = fetchedEntities.map { Task(from: $0) }
                    self.isLoading = false
                }
            } catch {
                // Gestiamo gli errori sul thread principale
                await MainActor.run {
                    self.error = .fetchError(error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    
    func addTask(_ task: Task) {
        let entity = TaskEntity(context: viewContext)
        task.updateEntity(entity)
        saveContext()
        scheduleNotificationsForNewTask(task)
    }
    
    
    func updateTask(_ task: Task) {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            if let existingEntity = results.first {
                task.updateEntity(existingEntity)
                saveContext()
                updateNotificationsForTask(task)
            } else {
                error = .taskNotFound
            }
        } catch {
            self.error = .updateError(error.localizedDescription)
        }
    }
    
    
    func deleteTask(_ task: Task) {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            if let entityToDelete = results.first {
                viewContext.delete(entityToDelete)
                saveContext()
                removeNotificationsForTask(task)
            }
        } catch {
            self.error = .deleteError(error.localizedDescription)
        }
    }
    
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        
        // Aggiorniamo immediatamente l'array locale dei task
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = updatedTask
        }
        
        // Salviamo in Core Data
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            if let existingEntity = results.first {
                updatedTask.updateEntity(existingEntity)
                try viewContext.save()
            }
        } catch {
            print("Errore nell'aggiornamento del task: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Helper Methods
    private func saveContext() {
        do {
            try viewContext.save()
            loadTasks()
        } catch {
            self.error = .saveError(error.localizedDescription)
        }
    }
    
    // MARK: - Filtered Views
    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }
    
    var pendingTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }
    
    var tasksDueToday: [Task] {
        let calendar = Calendar.current
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDateInToday(dueDate)
        }
    }
    
    
    // MARK: - Error Handling
    enum TaskError: LocalizedError {
        case fetchError(String)
        case saveError(String)
        case updateError(String)
        case deleteError(String)
        case taskNotFound
        
        var errorDescription: String? {
            switch self {
            case .fetchError(let message):
                return "Errore nel caricamento dei task: \(message)"
            case .saveError(let message):
                return "Errore nel salvataggio: \(message)"
            case .updateError(let message):
                return "Errore nell'aggiornamento: \(message)"
            case .deleteError(let message):
                return "Errore nell'eliminazione: \(message)"
            case .taskNotFound:
                return "Task non trovato"
            }
        }
    }
}


// MARK: - Notification Management
extension TaskListViewModel {
    private func scheduleNotificationsForNewTask(_ task: Task, earlyReminder: EarlyReminder? = nil) {
        _Concurrency.Task {
            let status = await NotificationManager.shared.checkNotificationStatus()
            if status == .authorized {
                NotificationManager.shared.scheduleTaskNotification(for: task, earlyReminder: earlyReminder)
            } else if status == .notDetermined {
                do {
                    let granted = try await NotificationManager.shared.requestAuthorization()
                    if granted {
                        NotificationManager.shared.scheduleTaskNotification(for: task, earlyReminder: earlyReminder)
                    }
                } catch {
                    print("Errore nella richiesta di autorizzazione: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
     func updateNotificationsForTask(_ task: Task, earlyReminder: EarlyReminder? = nil) {
        _Concurrency.Task {
            let status = await NotificationManager.shared.checkNotificationStatus()
            if status == .authorized {
                NotificationManager.shared.updateNotification(for: task, earlyReminder: earlyReminder)
            }
        }
    }
    
    
    private func removeNotificationsForTask(_ task: Task) {
        NotificationManager.shared.removeNotification(for: task)
    }
    
    
    private var settings: SettingsManager {
        SettingsManager.shared
    }
    
    
    func startObservingSettings() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    
    @objc private func settingsChanged() {
        loadTasks()
    }
    
    
    
    
}




