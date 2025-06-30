//
//  DashboardViewModel.swift
//  NextDream
//
//  Created by Jan on 27/06/2025.
//

import Foundation
import SwiftData

@Observable
final class DashboardViewModel{
    
    var tasks: [TaskModel] = []
    
    var isLoggingOut:Bool = false;
    var modelContext: ModelContext
    var taskRepository: TaskRepository
    var queryDescriptorManager: QueryDescriptorManager = QueryDescriptorManager()
    
    init(modelContext: ModelContext, taskRepository: TaskRepository) {
        self.modelContext = modelContext
        self.taskRepository = taskRepository
        self.fetchTaskByDeadline(date: .now)
    }
    
    var chartData: [(String, Int)] {
        let completed = tasks.filter { $0.isCompleted }.count
        let uncompleted = tasks.count - completed
        return [("Completed", completed), ("Uncompleted", uncompleted)]
    }
    
    func fetchTaskByDeadline(date: Date = .now){
        guard let descriptor = queryDescriptorManager.fetchTaskByDeadline(date: date) else { return }
        do{
            tasks = try taskRepository.fetchTasks(descriptor: descriptor)
        } catch{
            print("Implement, error handling in here")
        }
    }
    
    
}
