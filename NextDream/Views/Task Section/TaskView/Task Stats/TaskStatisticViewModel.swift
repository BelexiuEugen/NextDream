//
//  TaskStatisticViewModel.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 16.09.2025.
//

import Foundation
import SwiftData

@Observable
class TaskStatisticViewModel {
    
    var taskID: String
    var taskStartDate: Date
    
    var daysCompleted: Int = 0
    var totalDays: Int = 0
    var weeksCompleted: Int = 0
    var totalWeeks: Int = 0
    var monthsCompleted: Int = 0
    var totalMonths: Int = 0
    var yearsCompleted: Int = 0
    var totalYears: Int = 0
    
    var selectedTaskType: TaskType = .day{
        didSet{
            self.fillArrays()
        }
    }
    
    var allTasks: [(Date, Int)] = []
    var completedTasks: [(Date, Int)] = []
    
    var defaultTaskRepository: DefaultTaskRepository
    var queryDescriptorManager: QueryDescriptorManager = QueryDescriptorManager()
    
    init(taskID: String, taskStartDate: Date, modelContext: ModelContext){
        defaultTaskRepository = DefaultTaskRepository(modelContext: modelContext)
        self.taskID = taskID
        self.taskStartDate = taskStartDate
        let descriptor = queryDescriptorManager.descriptorForNumberOfTaskByMainTask(id: taskID)
        
        (daysCompleted, totalDays, weeksCompleted, totalWeeks, monthsCompleted, totalMonths, yearsCompleted, totalYears) = defaultTaskRepository.fetchStatsForTaskID(descriptor: descriptor)
        
        fillArrays()
        
    }
    
    func fillArrays(){
        allTasks = [(taskStartDate, 0)]
        completedTasks = [(taskStartDate, 0)]
        let descriptor = queryDescriptorManager.descriptorForSearchingByTaskTypeAndMainID(taskType: selectedTaskType, mainID: taskID)
        let data = defaultTaskRepository.fetcTasksForProgressChart(descriptor: descriptor)
        
        fillAllTasksArray(data: data)
        fillCompletedTasksArray(data: data)
    }
    
    func fillAllTasksArray(data: [(Date, Bool)]){
        var count = 1
        for item in data{
            allTasks.append((item.0, count))
            count += 1
        }
    }
    
    func fillCompletedTasksArray(data: [(Date, Bool)]){
        var count = 0
        for item in data{
            if item.0 > .now {
                break
            }
            if item.1{
                count += 1
            }
            
            completedTasks.append((item.0, count))
        }
    }

}
