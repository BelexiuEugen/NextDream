//
//  QueryDescriptorManager.swift
//  NextDream
//
//  Created by Jan on 30/06/2025.
//

import SwiftData
import Foundation

class QueryDescriptorManager{
    
    func descriptorForNumberOfTaskByMainTask(id: String) -> FetchDescriptor<TaskModel>{
        FetchDescriptor<TaskModel> (predicate: #Predicate{ $0.mainTaskID == id })
    }
    
    func fetchTaskByDeadline(date: Date) -> FetchDescriptor<TaskModel>?{
        let calendar = Calendar.current
        let startDate: Date? = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate ?? .now)
        
        guard let startDate, let endDate else { return nil}
        
        return FetchDescriptor<TaskModel>(predicate: #Predicate{ endDate > $0.deadline && $0.deadline >= startDate })
    }
    
    func fetchTaskByInterval(startDate: Date, endDate: Date) -> FetchDescriptor<TaskModel>{
        FetchDescriptor<TaskModel>(predicate: #Predicate{endDate > $0.deadline && $0.deadline >= startDate})
    }
    
    func descriptorForMainTasks() -> FetchDescriptor<TaskModel>{
        FetchDescriptor<TaskModel>(predicate: #Predicate { $0.parentID == nil})
    }
    
    func descriptorForSortAndString(sort: SortDescriptor<TaskModel>, serchString: String) -> FetchDescriptor<TaskModel>{
        var descriptor = FetchDescriptor<TaskModel>()
        
        descriptor.predicate = #Predicate<TaskModel> { task in
            (serchString.isEmpty || task.name.localizedStandardContains(serchString))
                && task.parentID == nil
        }
        
        descriptor.sortBy = [sort];
        
        return descriptor
    }
    
    func descriptorForParentID(parentID: String?) -> FetchDescriptor<TaskModel>{
        FetchDescriptor<TaskModel>(predicate: #Predicate{ $0.parentID == parentID})
    }
    
    func descriptorForSearchingByTaskTypeAndMainID(taskType: TaskType, mainID: String) -> FetchDescriptor<TaskModel>{
        FetchDescriptor<TaskModel>(predicate: #Predicate{ $0.taskTypeID == taskType.rawValue && $0.mainTaskID == mainID })
    }
}

