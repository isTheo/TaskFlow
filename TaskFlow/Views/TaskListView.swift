//
//  TaskListView.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import SwiftUI

// TaskListView è la vista principale che mostra la lista delle attività.
struct TaskListView: View {
    @ObservedObject var viewModel: TaskListViewModel
    
    // Stato per gestire la visualizzazione del foglio di aggiunta task
    @State private var showingAddTask = false
    
    // Stato per gestire il filtro di visualizzazione
    @State private var selectedFilter: TaskFilter = .all
    
    // Enum per gestire i diversi tipi di filtro
    enum TaskFilter {
        case all, pending, completed
        
        var title: String {
            switch self {
            case .all: return "filter.all".localized
            case .pending: return "filter.pending".localized
            case .completed: return "filter.completed".localized
            }
        }
    }
    
    var body: some View {
        List {
            // Picker per il filtro
            Picker("filter.title".localized, selection: $selectedFilter) {
                Text(TaskFilter.all.title).tag(TaskFilter.all)
                Text(TaskFilter.pending.title).tag(TaskFilter.pending)
                Text(TaskFilter.completed.title).tag(TaskFilter.completed)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical)
            
            // Sezione task con scadenza oggi
            if !filteredTasksDueToday.isEmpty {
                Section(header: Text("task.due.today".localized)) {
                    ForEach(filteredTasksDueToday) { task in
                        TaskRowView(task: task, viewModel: viewModel)
                    }
                }
            }
            
            // Sezione task rimanenti
            Section(header: Text("task.section.title".localized)) {
                if filteredTasks.isEmpty {
                    Text("task.empty.message".localized)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(filteredTasks) { task in
                        TaskRowView(task: task, viewModel: viewModel)
                    }
                    .onDelete(perform: deleteTasks)
                }
            }
        }
        .navigationTitle("app.name".localized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(viewModel: viewModel)
        }
    }
    
    // Filtra i task in base al filtro selezionato
    private var filteredTasks: [Task] {
        switch selectedFilter {
        case .all:
            return viewModel.pendingTasks
        case .pending:
            return viewModel.pendingTasks
        case .completed:
            return viewModel.completedTasks
        }
    }
    
    // Filtra i task in scadenza oggi in base al filtro selezionato
    private var filteredTasksDueToday: [Task] {
        let tasksForToday = viewModel.tasksDueToday
        switch selectedFilter {
        case .all:
            return tasksForToday
        case .pending:
            return tasksForToday.filter { !$0.isCompleted }
        case .completed:
            return tasksForToday.filter { $0.isCompleted }
        }
    }
    
    // Gestisce l'eliminazione dei task dalla lista
    private func deleteTasks(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = filteredTasks[index]
            viewModel.deleteTask(task)
        }
    }
}

// Preview per TaskListView
struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        // Crea un'istanza del ViewModel usando il PersistenceController
        let viewModel = TaskListViewModel(context: PersistenceController.preview.viewContext)
        
        let sampleTasks = [
            Task(title: "task.example.project".localized,
                 description: "task.example.project.description".localized,
                 dueDate: Date().addingTimeInterval(86400),
                 priority: .high),
            
            Task(title: "task.example.shopping".localized,
                 description: "task.example.shopping.description".localized,
                 dueDate: Date(),
                 priority: .medium),
            
            Task(title: "task.example.reading".localized,
                 isCompleted: true, priority: .low)
        ]
        
        //aggiunge i task al ViewModel
        sampleTasks.forEach { viewModel.addTask($0) }
        
        //restituisce la preview della view
        return NavigationView {
            TaskListView(viewModel: viewModel)
        }
    }
}
