//
//  SettingsView.swift
//  TaskFlow
//
//  Created by Matteo Orru on 16/02/25.
//


import SwiftUI


struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = SettingsManager.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Preferenze Task
                Section(header: Text("settings.preferences.localized")) {
                    Picker("settings.defaultPriority".localized, selection: $settings.defaultPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priorityColor(for: priority))
                                    .frame(width: 12, height: 12)
                                Text(priority.title)
                            }.tag(priority)
                        }
                    }
                    
                    Picker("settings.sortBy".localized, selection: $settings.sortBy) {
                        ForEach(SettingsManager.SortOption.allCases, id: \.self) { option in
                            Text(option.title).tag(option)
                        }
                    }
                }
                
                // MARK: - Notifiche
                Section(header: Text("settings.notifications".localized)) {
                    Toggle("settings.enableNotifications".localized, isOn: $settings.showNotifications)
                    
                    if settings.showNotifications {
                        Picker("settings.notifyBefore".localized, selection: $settings.notificationTime) {
                            Text("notification.before.15".localized).tag(15)
                            Text("notification.before.30".localized).tag(30)
                            Text("notification.before.60".localized).tag(60)
                            Text("notification.before.120".localized).tag(120)
                            Text("notification.before.1440".localized).tag(1440)
                        }
                    }
                }
                
                
                // MARK: - Aspetto
                Section(header: Text("settings.appearance".localized)) {
                    Toggle("settings.darkMode".localized, isOn: $settings.useDarkMode)
                }
                
                
                Section(header: Text("settings.language".localized)) {
                    Picker("settings.language".localized, selection: $settings.language) {
                        ForEach(SettingsManager.Language.allCases, id: \.self) { language in
                            Text(language.title).tag(language)
                        }
                    }
                }
                
                
                // MARK: - Ripristino
                Section {
                    Button(action: { showingResetAlert = true }) {
                        HStack {
                            Text("settings.reset".localized)
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                
                // MARK: - Informazioni
                Section(header: Text("settings.version".localized)) {
                    HStack {
                        Text("settings.version".localized)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("settings.title".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button.done".localized) {
                        dismiss()
                    }
                }
            }
            
            .alert("settings.reset".localized, isPresented: $showingResetAlert) {
                Button("button.cancel".localized, role: .cancel) { }
                Button("settings.reset".localized, role: .destructive) {
                    settings.resetToDefaults()
                }
            } message: {
                Text("settings.resetConfirm".localized)
            }
        }
    }
    
    
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
    
    
}


// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
