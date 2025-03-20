//
//  TaskEditView.swift
//  TaskFlow
//
//  Created by Matteo Orru on 18/02/25.
//

import SwiftUI

struct TaskEditView: View {
    
    let task: Task
    @ObservedObject var viewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var isSelected: Bool
    
    @State private var title: String
    @State private var description: String
    @State private var url: String
    @State private var repeatOption: RepeatOption
    @State private var dueDate: Date
    @State private var includeDueDate: Bool
    @State private var earlyReminder: EarlyReminder?
    @State private var showDatePicker = false
    
    init(task: Task, viewModel: TaskListViewModel, isSelected: Binding<Bool>) {
        self.task = task
        self.viewModel = viewModel
        self._isSelected = isSelected
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description ?? "")
        _url = State(initialValue: task.url ?? "")
        _repeatOption = State(initialValue: task.repeatOption)
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _includeDueDate = State(initialValue: task.dueDate != nil)
        _earlyReminder = State(initialValue: nil) // andrà configurato in base alle notifiche esistenti
    }
    
    var body: some View {
        NavigationView {
            List {
                // Sezione titolo
                Section {
                    TextField("task.title".localized, text: $title)
                        .autocapitalization(.sentences)
                }
                
                // Sezione data e ora
                Section(header: Text("Date & Time")) {
                    Toggle("Set Due Date", isOn: $includeDueDate)
                    
                    if includeDueDate {
                        DatePicker(
                            "Due Date",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        
                        // Early Reminder Picker
                        Picker("Early Reminder", selection: $earlyReminder) {
                            Text("None").tag(nil as EarlyReminder?)
                            ForEach(EarlyReminder.allCases) { reminder in
                                Text(reminder.title).tag(reminder as EarlyReminder?)
                            }
                        }
                    }
                }
                
                // Sezione dettagli
                Section {
                    // Campo note
                    VStack(alignment: .leading) {
                        Text("task.description".localized)
                            .foregroundColor(.secondary)
                            .font(.footnote)
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                    
                    // Campo URL
                    VStack(alignment: .leading) {
                        Text("task.url".localized)
                            .foregroundColor(.secondary)
                            .font(.footnote)
                        TextField("https://...", text: $url)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                }
                
                // Sezione ripetizione
                Section(header: Text("task.repeat".localized)) {
                    Picker("task.repeat".localized, selection: $repeatOption) {
                        ForEach(RepeatOption.allCases, id: \.self) { option in
                            Text(option.title)
                                .tag(option)
                        }
                    }
                }
                
                // Sezione eliminazione task
                Section {
                    Button(role: .destructive) {
                        viewModel.deleteTask(task)
                        isSelected = false
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("button.delete".localized)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("task.edit.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("button.cancel".localized) {
                        isSelected = false
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button.done".localized) {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    
    private func saveChanges() {
        var updatedTask = task
        updatedTask.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTask.description = description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTask.url = url.isEmpty ? nil : url.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTask.repeatOption = repeatOption
        updatedTask.dueDate = includeDueDate ? dueDate : nil
        
        viewModel.updateTask(updatedTask)
        
        if includeDueDate {
            viewModel.updateNotificationsForTask(updatedTask, earlyReminder: earlyReminder)
        }
        
        isSelected = false
        dismiss()
    }
    
    
}
