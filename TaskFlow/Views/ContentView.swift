//
//  ContentView.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import SwiftUI

struct ContentView: View {
    // ViewModel condiviso che gestisce tutti i task dell'applicazione
    // Usando @StateObject ci assicuriamo che il ViewModel persista per l'intero ciclo di vita della view
    @StateObject private var viewModel = TaskListViewModel()
    
    // Stato per gestire la visualizzazione del menu delle impostazioni
    @State private var showingSettings = false
    
    // Stato per gestire la view attiva nella tab bar
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab delle attività
            NavigationView {
                TaskListView(viewModel: viewModel)
                    .navigationTitle("app.name".localized)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showingSettings = true }) {
                                Image(systemName: "gear")
                            }
                        }
                    }
            }
            .tabItem {
                Label("tab.tasks".localized, systemImage: "checklist")
            }
            .tag(0)
            
            // Tab del calendario
            NavigationView {
                TaskCalendarView(viewModel: viewModel)
                    .navigationTitle("tab.calendar".localized)
            }
            .tabItem {
                Label("tab.calendar".localized, systemImage: "calendar")
            }
            .tag(1)
            
            // Tab delle statistiche
            NavigationView {
                TaskStatsView(viewModel: viewModel)
                    .navigationTitle("tab.stats".localized)
            }
            .tabItem {
                Label("tab.stats".localized, systemImage: "chart.bar")
            }
            .tag(2)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .accentColor(.blue)
        .onAppear {
            // Carica i dati di esempio solo in modalità preview
#if DEBUG
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                //task di esempio per le preview
                let sampleTask = Task(
                    title: "task.example.title".localized,
                    description: "task.example.description".localized,
                    dueDate: Date(),
                    priority: .medium
                )
                viewModel.addTask(sampleTask)
            }
#endif
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
