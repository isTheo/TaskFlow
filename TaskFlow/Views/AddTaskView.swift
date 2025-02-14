//
//  AddTaskView.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import SwiftUI

// AddTaskView` gestisce l'interfaccia per la creazione di nuovi task
struct AddTaskView: View {
    // Il ViewModel che gestirà il salvataggio del nuovo task
    @ObservedObject var viewModel: TaskListViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form State
    // Stati per gestire i valori del form
    @State private var title = ""
    @State private var description = ""
    @State private var priority = TaskPriority.medium
    @State private var dueDate = Date()
    @State private var includeDueDate = false
    
    // Stato per gestire gli errori di validazione
    @State private var showingValidationError = false
    @State private var validationErrorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Sezione informazioni principali
                Section(header: Text("Informazioni Principali")) {
                    TextField("Titolo", text: $title)
                        .autocapitalization(.sentences)
                    
                    ZStack(alignment: .leading) {
                        TextEditor(text: $description)
                            .frame(height: 100)
                        if description.isEmpty {
                            Text("Descrizione (opzionale)")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                    }
                }
                
                // Sezione priorità
                Section(header: Text("Priorità")) {
                    Picker("Priorità", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priorityColor(for: priority))
                                    .frame(width: 12, height: 12)
                                Text(priority.title)
                            }.tag(priority)
                        }
                    }
                }
                
                // Sezione data di scadenza
                Section(header: Text("Data di Scadenza")) {
                    Toggle("Imposta scadenza", isOn: $includeDueDate)
                    
                    if includeDueDate {
                        DatePicker(
                            "Scadenza",
                            selection: $dueDate,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                    }
                }
            }
            .navigationTitle("Nuova Attività")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") {
                        saveTask()
                    }
                    .disabled(!isValidTask)
                }
            }
            .alert("Errore di Validazione", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationErrorMessage)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    // Verifica se il task è valido per il salvataggio
    private var isValidTask: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Restituisce il colore appropriato per ogni livello di priorità
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
    
    // Gestisce il salvataggio del nuovo task
    private func saveTask() {
        // Validazione del titolo
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            validationErrorMessage = "Il titolo non può essere vuoto"
            showingValidationError = true
            return
        }
        
        // Creazione del nuovo task
        let newTask = Task(
            title: trimmedTitle,
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: includeDueDate ? dueDate : nil,
            priority: priority
        )
        
        // Salvataggio del task e chiusura della view
        viewModel.addTask(newTask)
        dismiss()
    }
}

// MARK: - Preview
struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TaskListViewModel()
        AddTaskView(viewModel: viewModel)
    }
}
