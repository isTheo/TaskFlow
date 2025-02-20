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
    
    @State private var showingEditSheet = false
    
    // Stato per gestire l'espansione/collasso dei dettagli
    @State private var isSelected = false
    
    // stato per gestire l'animazione del checkbox
    @State private var isAnimatingCompletion = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        isAnimatingCompletion = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        viewModel.toggleTaskCompletion(task)
                        isAnimatingCompletion = false
                    }
                }) {
                    Image(systemName: task.isCompleted || isAnimatingCompletion ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(task.isCompleted || isAnimatingCompletion ? .green : .gray)
                        .contentShape(Rectangle())
                        .scaleEffect(isAnimatingCompletion ? 1.3 : 1.0)
                        .rotationEffect(isAnimatingCompletion ? .degrees(360) : .degrees(0))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(task.isCompleted ? "task.mark.incomplete".localized : "task.mark.complete".localized)
                
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted || isAnimatingCompletion)
                    .foregroundColor((task.isCompleted || isAnimatingCompletion) ? .secondary : .primary)
                    .opacity(isAnimatingCompletion ? 0.3 : 1.0)
                
                Spacer()
                
                if isSelected {
                    Button {
                        print("Info button tapped")
                        showingEditSheet = true  // Questo attiverà il foglio di modifica
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 22))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.opacity)
                }
                
                PriorityIndicator(priority: task.priority)
                    .accessibilityLabel("task.priority.level".localized(with: task.priority.title))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                print("Row tapped, isSelected: \(isSelected)")
                withAnimation {
                    isSelected.toggle()
                }
            }
            
            if let description = task.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                    .truncationMode(.tail)
                    .lineLimit(1)
            }
            
            if let dueDate = task.formattedDueDate {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text(dueDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.leading)
                .accessibilityLabel("task.due.date".localized(with: dueDate))
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            TaskEditView(task: task, viewModel: viewModel, isSelected: $isSelected)
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
            title: "task.example.title".localized,
            description: "task.example.description".localized,
            dueDate: Date().addingTimeInterval(86400),
            priority: .high
        )
        
        return List {
            TaskRowView(task: sampleTask, viewModel: viewModel)
        }
        .previewLayout(.sizeThatFits)
    }
}
