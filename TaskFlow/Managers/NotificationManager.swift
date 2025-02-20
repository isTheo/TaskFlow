//
//  NotificationManager.swift
//  TaskFlow
//
//  Created by Matteo Orru on 13/02/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    private var settings: SettingsManager {
        SettingsManager.shared
    }
    
    
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await center.requestAuthorization(options: options)
    }
    
    
    func scheduleTaskNotification(for task: Task, earlyReminder: EarlyReminder? = nil) {
        guard settings.showNotifications else { return }
        guard let dueDate = task.dueDate, !task.isCompleted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "notification.task.due".localized
        content.body = task.title
        content.sound = .default
        
        if let description = task.description {
            content.subtitle = description
        }
        
        content.userInfo = [
            "taskId": task.id.uuidString,
            "priority": task.priority.rawValue
        ]
        
        
        // Calcola la data di notifica in base all'early reminder
        let notificationMinutes = earlyReminder?.rawValue ?? settings.notificationTime
        let triggerDate = Calendar.current.date(
            byAdding: .minute,
            value: -notificationMinutes,
            to: dueDate
        )!
        
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        
        let identifier = earlyReminder != nil ?
            "task-\(task.id.uuidString)-early-\(notificationMinutes)" :
            "task-\(task.id.uuidString)"
        
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("notification.error.scheduling".localized(with: error.localizedDescription))
            }
        }
    }
    
    
    func scheduleNotificationWithReminder(for task: Task, earlyReminder: EarlyReminder? = nil) {
        // Modifichiamo la guard per usare solo quello che ci serve
        guard task.dueDate != nil, !task.isCompleted else { return }
        
        _Concurrency.Task {
            let status = await checkNotificationStatus()
            if status == .authorized {
                updateNotification(for: task, earlyReminder: earlyReminder)
            }
        }
    }
    
    
    func removeNotification(for task: Task) {
        // Rimuove tutte le notifiche associate al task
        let baseIdentifier = "task-\(task.id.uuidString)"
        let identifiers = [baseIdentifier] + EarlyReminder.allCases.map {
            "\(baseIdentifier)-early-\($0.rawValue)"
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    
    
    func updateNotification(for task: Task, earlyReminder: EarlyReminder? = nil) {
        removeNotification(for: task)
        scheduleTaskNotification(for: task, earlyReminder: earlyReminder)
    }
    
    
    func checkNotificationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }
    
    
}



extension NotificationManager {
    func configureNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "notification.action.complete".localized,
            options: .foreground
        )
        
        let postponeAction = UNNotificationAction(
            identifier: "POSTPONE_TASK",
            title: "notification.action.postpone".localized,
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, postponeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
