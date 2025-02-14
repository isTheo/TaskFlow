//
//  NotificationManager.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import Foundation
import UserNotifications

// `NotificationManager` gestisce tutte le operazioni relative alle notifiche locali
// inclusa la richiesta di autorizzazioni e la pianificazione delle notifiche per i task
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Richiede l'autorizzazione per inviare notifiche
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        return try await center.requestAuthorization(options: options)
    }
    
    // Pianifica una notifica per un task
    func scheduleTaskNotification(for task: Task) {
        // Verifichiamo che il task abbia una data di scadenza
        guard let dueDate = task.dueDate, !task.isCompleted else { return }
        
        // Crea il contenuto della notifica
        let content = UNMutableNotificationContent()
        content.title = "Task in Scadenza"
        content.body = task.title
        content.sound = .default
        
        if let description = task.description {
            content.subtitle = description
        }
        
        content.userInfo = ["priority": task.priority.rawValue]
        
        // Calcola il trigger per la notifica
        // Notifica 1 ora prima della scadenza
        let triggerDate = Calendar.current.date(byAdding: .hour, value: -1, to: dueDate)!
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Crea la richiesta di notifica
        let request = UNNotificationRequest(
            identifier: "task-\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Pianifica la notifica
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Errore nella pianificazione della notifica: \(error.localizedDescription)")
            }
        }
    }
    
    // Rimuove la notifica per un task specifico
    func removeNotification(for task: Task) {
        let identifier = "task-\(task.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // Rimuove tutte le notifiche pianificate
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Aggiorna la notifica per un task
    func updateNotification(for task: Task) {
        removeNotification(for: task)
        scheduleTaskNotification(for: task)
    }
    
    // Verifica lo stato delle autorizzazioni per le notifiche
    func checkNotificationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }
}


// MARK: - Notification Categories
extension NotificationManager {
    // Configura le categorie di notifica con azioni
    func configureNotificationCategories() {
        // Azione per completare il task
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Segna come Completato",
            options: .foreground
        )
        
        // Azione per posticipare
        let postponeAction = UNNotificationAction(
            identifier: "POSTPONE_TASK",
            title: "Posticipa di 1 ora",
            options: .foreground
        )
        
        // Categoria per le notifiche dei task
        let category = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, postponeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Registra la categoria
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
