//
//  TaskStatsView.swift
//  TaskFlow
//
//  Created by Matteo Orru on 12/02/25.
//

import SwiftUI

// TaskStatsView mostra statistiche e metriche sui task dell'utente
struct TaskStatsView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @State private var selectedTimeFrame: TimeFrame = .week
    
    // Periodo di tempo per le statistiche
    enum TimeFrame: String, CaseIterable {
        case week = "Settimana"
        case month = "Mese"
        case year = "Anno"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Selettore del periodo temporale
                Picker("Periodo", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Card delle statistiche generali
                generalStatsCard
                
                // Card delle statistiche per priorità
                priorityStatsCard
                
                // Grafico di completamento
                completionChartCard
                
                // Card della produttività
                productivityCard
            }
            .padding()
        }
    }
    
    // MARK: - Componenti Statistiche
    
    private var generalStatsCard: some View {
        StatCard(title: "Panoramica") {
            HStack {
                StatBox(
                    title: "Totali",
                    value: "\(viewModel.tasks.count)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatBox(
                    title: "Completati",
                    value: "\(viewModel.completedTasks.count)",
                    icon: "checkmark.circle",
                    color: .green
                )
                
                StatBox(
                    title: "In Corso",
                    value: "\(viewModel.pendingTasks.count)",
                    icon: "clock",
                    color: .orange
                )
            }
        }
    }
    
    private var priorityStatsCard: some View {
        StatCard(title: "Distribuzione Priorità") {
            VStack(spacing: 12) {
                PriorityBar(
                    priority: "Alta",
                    count: tasksCount(for: .high),
                    total: viewModel.tasks.count,
                    color: .red
                )
                
                PriorityBar(
                    priority: "Media",
                    count: tasksCount(for: .medium),
                    total: viewModel.tasks.count,
                    color: .yellow
                )
                
                PriorityBar(
                    priority: "Bassa",
                    count: tasksCount(for: .low),
                    total: viewModel.tasks.count,
                    color: .green
                )
            }
        }
    }
    
    private var completionChartCard: some View {
        StatCard(title: "Tasso di Completamento") {
            let completionRate = calculateCompletionRate()
            
            CircularProgressView(progress: completionRate)
                .frame(height: 200)
        }
    }
    
    private var productivityCard: some View {
        StatCard(title: "Produttività Giornaliera") {
            let productivity = calculateDailyProductivity()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(String(format: "%.1f", productivity))")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Task completati al giorno")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: productivity > 3 ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .font(.title)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    // Calcola il numero di task per una data priorità
    private func tasksCount(for priority: TaskPriority) -> Int {
        viewModel.tasks.filter { $0.priority == priority }.count
    }
    
    // Calcola il tasso di completamento dei task
    private func calculateCompletionRate() -> Double {
        guard !viewModel.tasks.isEmpty else { return 0 }
        return Double(viewModel.completedTasks.count) / Double(viewModel.tasks.count)
    }
    
    // Calcola la produttività giornaliera media
    private func calculateDailyProductivity() -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let completedTasks = viewModel.completedTasks
        guard !completedTasks.isEmpty else { return 0 }
        
        let firstCompletionDate = completedTasks
            .compactMap { $0.dueDate }
            .min() ?? now
        
        let days = max(1, calendar.dateComponents([.day], from: firstCompletionDate, to: now).day ?? 1)
        
        return Double(completedTasks.count) / Double(days)
    }
}

// MARK: - Componenti di Supporto

struct StatCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// Box per statistiche singole
struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// Barra per mostrare la distribuzione delle priorità
struct PriorityBar: View {
    let priority: String
    let count: Int
    let total: Int
    let color: Color
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(priority)
                    .font(.subheadline)
                Spacer()
                Text("\(count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
        }
    }
}

// Vista per il progresso circolare
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            VStack {
                Text("\(Int(progress * 100))%")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Completati")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview
struct TaskStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TaskListViewModel(context: PersistenceController.preview.viewContext)
        
        let sampleTasks = [
            Task(title: "Task Alta Priorità", priority: .high),
            Task(title: "Task Media Priorità", priority: .medium),
            Task(title: "Task Bassa Priorità", priority: .low),
            Task(title: "Task Completato", isCompleted: true, priority: .medium)
        ]
        
        sampleTasks.forEach { viewModel.addTask($0) }
        
        return NavigationView {
            TaskStatsView(viewModel: viewModel)
                .navigationTitle("Statistiche")
        }
    }
}
