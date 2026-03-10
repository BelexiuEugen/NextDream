//
//  DashboardViewModel.swift
//  NextDream
//
//  Created by Jan on 27/06/2025.
//

import Foundation
import SwiftData
import WidgetKit

@Observable
final class DashboardViewModel{
    
    var tasks: [TaskModel] = []{
        didSet{
            updateWidgetData()
        }
    }
    
    var isLoggingOut:Bool = false;
    var modelContext: ModelContext
    var taskRepository: TaskRepository
    var queryDescriptorManager: QueryDescriptorManager = QueryDescriptorManager()
    
    // Task achievement stats for dashboard streak
    var totalTaskAchieved: Int {
        let descriptor = FetchDescriptor<TaskModel>()
        guard let allTasks = try? taskRepository.fetchTasks(descriptor: descriptor) else { return 0 }
        return allTasks.filter { task in
            task.isCompleted
        }.count
    }
    var monthlyTaskAchieved: Int {
        let descriptor = FetchDescriptor<TaskModel>()
        guard let allTasks = try? taskRepository.fetchTasks(descriptor: descriptor) else { return 0 }
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        return allTasks.filter { task in
            task.isCompleted &&
            calendar.component(.month, from: task.deadline) == currentMonth &&
            calendar.component(.year, from: task.deadline) == currentYear
        }.count
    }
    var dailyTaskAchieved: Int {
        let descriptor = FetchDescriptor<TaskModel>()
        let stats = (taskRepository as? DefaultTaskRepository)?.fetchStatsForTaskID(descriptor: descriptor)
        return stats?.completedDays ?? 0
    }
    
    init(modelContext: ModelContext, taskRepository: TaskRepository) {
        self.modelContext = modelContext
        self.taskRepository = taskRepository
        self.fetchTaskByDeadline(date: .now)
    }
    
    func reloadTasks(){
        self.fetchTaskByDeadline(date: .now)
    }
    
    func updateWidgetData(){
        let arrayToWidget = toStringArray()
        let sharedDefaults = UserDefaults(suiteName: "group.com.Person.NextDream")
        sharedDefaults?.set(arrayToWidget, forKey: "widgetMessage")

        WidgetCenter.shared.reloadTimelines(ofKind: "mediumWidget")
        
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

extension DashboardViewModel{
    func toStringArray() -> [String]{
        var result: [String] = []
        
        for task in tasks{
            result.append(task.name)
        }
        
        return result
    }
}
