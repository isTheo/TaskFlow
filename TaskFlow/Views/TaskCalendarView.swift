//
//  TaskCalendarView.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import SwiftUI

struct TaskCalendarView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @State private var selectedDate = Date()
    @State private var showingAddTask = false
    
    // Calendario configurato per l'Italia
    private let calendar = Calendar(identifier: .gregorian)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private let weekDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                calendarHeader
                
                // Griglia giorni della settimana
                weekDayHeader
                
                // Griglia del calendario
                calendarGrid
                
                // Lista dei task per la data selezionata
                if let tasksForSelectedDate = tasksForDate(selectedDate) {
                    taskList(for: tasksForSelectedDate)
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(viewModel: viewModel)
        }
        .navigationTitle("tab.calendar".localized)
    }
    
    // MARK: - Componenti del Calendario
    
    private var calendarHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
            }
            
            Text(dateFormatter.string(from: selectedDate))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
    
    private var weekDayHeader: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var calendarGrid: some View {
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 0
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(0..<42) { index in
                if index < firstWeekday - 1 || index >= firstWeekday - 1 + daysInMonth {
                    Color.clear
                        .aspectRatio(1, contentMode: .fill)
                } else {
                    let day = index - (firstWeekday - 1) + 1
                    calendarCell(for: day)
                }
            }
        }
    }
    
    private func calendarCell(for day: Int) -> some View {
        let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
        let hasTask = tasksForDate(date)?.isEmpty == false
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        
        return Button(action: { selectedDate = date }) {
            VStack {
                Text("\(day)")
                    .font(.system(.body, design: .rounded))
                
                if hasTask {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func taskList(for tasks: [Task]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(format: NSLocalizedString("task.dueDate".localized, comment: ""), selectedDate.formatted(.dateTime.day().month())))
                .font(.headline)
                .padding(.top)
            
            ForEach(tasks) { task in
                TaskRowView(task: task, viewModel: viewModel)
                    .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Helper Methods
    
    private var firstDayOfMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
    }
    
    private func tasksForDate(_ date: Date) -> [Task]? {
        viewModel.tasks.filter { task in
            guard let taskDate = task.dueDate else { return false }
            return calendar.isDate(taskDate, inSameDayAs: date)
        }
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

// MARK: - Preview
struct TaskCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TaskListViewModel(context: PersistenceController.preview.viewContext)
        
        // Aggiungiamo alcuni task di esempio con date diverse
        let sampleTasks = [
            Task(title: "task.example.title".localized,
                 description: "task.example.description".localized,
                 dueDate: Date(),
                 priority: .high),
            Task(title: "task.example.title".localized,
                 dueDate: Date().addingTimeInterval(86400),
                 priority: .medium)
        ]
        
        sampleTasks.forEach { viewModel.addTask($0) }
        
        return NavigationView {
            TaskCalendarView(viewModel: viewModel)
                .navigationTitle("tab.calendar".localized)
        }
    }
}
