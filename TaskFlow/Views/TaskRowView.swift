//
//  TaskRowView.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import SwiftUI

// TaskRowView rappresenta la visualizzazione di un singolo task nella lista
struct TaskRowView: View {
    // Il task da visualizzare
    let task: Task
    
    // Il ViewModel per gestire le azioni sul task
    @ObservedObject var viewModel: TaskListViewModel
    
    // Stato per gestire l'espansione/collasso dei dettagli
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Checkbox per il completamento
                Button(action: { viewModel.toggleTaskCompletion(task) }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
                
                // Titolo del task
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                Spacer()
                
                // Indicatore di priorità
                PriorityIndicator(priority: task.priority)
                
                // Freccia per espandere/comprimere
                if task.description != nil || task.dueDate != nil {
                    Button(action: { isExpanded.toggle() }) {
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .animation(.easeInOut, value: isExpanded)
                    }
                }
            }
            
            // Dettagli del task (solo se espanso)
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    if let description = task.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let dueDate = task.formattedDueDate {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text(dueDate)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.leading)
                .transition(.opacity)
            }
        }
        .contentShape(Rectangle()) // rende l'intera area tappabile
        .onTapGesture {
            if task.description != nil || task.dueDate != nil {
                isExpanded.toggle()
            }
        }
    }
}

// Componente per visualizzare l'indicatore di priorità
struct PriorityIndicator: View {
    let priority: TaskPriority
    
    var body: some View {
        Circle()
            .fill(priorityColor)
            .frame(width: 12, height: 12)
    }
    
    private var priorityColor: Color {
        switch priority {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
}

// Preview per TaskRowView
struct TaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TaskListViewModel()
        let sampleTask = Task(
            title: "Completare il progetto",
            description: "Implementare tutte le funzionalità base",
            dueDate: Date().addingTimeInterval(86400),
            priority: .high
        )
        
        return List {
            TaskRowView(task: sampleTask, viewModel: viewModel)
        }
        .previewLayout(.sizeThatFits)
    }
}
