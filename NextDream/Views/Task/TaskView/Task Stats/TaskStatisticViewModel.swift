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
    
    var daysCompleted: Int = 0
    var totalDays: Int = 0
    var weeksCompleted: Int = 0
    var totalWeeks: Int = 0
    var monthsCompleted: Int = 0
    var totalMonths: Int = 0
    var yearsCompleted: Int = 0
    var totalYears: Int = 0
    
    var defaultTaskRepository: DefaultTaskRepository
    var queryDescriptorManager: QueryDescriptorManager = QueryDescriptorManager()
    
    init(taskID: String, modelContext: ModelContext){
        defaultTaskRepository = DefaultTaskRepository(modelContext: modelContext)
        self.taskID = taskID
        let descriptor = queryDescriptorManager.descriptorForNumberOfTaskByMainTask(id: taskID)
        
        (daysCompleted, totalDays, weeksCompleted, totalWeeks, monthsCompleted, totalMonths, yearsCompleted, totalYears) = defaultTaskRepository.fetchTaskByMainTask(descriptor: descriptor)
        
    }

}
