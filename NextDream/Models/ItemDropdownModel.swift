//
//  Untitled.swift
//  NextDream
//
//  Created by Jan on 22/01/2025.
//

import Foundation
import Observation


@Observable
class ItemDropdownModel: Identifiable{
    var task: TaskModel
    var isSelected: Bool
    var showChildren: Bool = false
    
    init(task: TaskModel, isSelected: Bool = false, showChildren: Bool = false) {
        self.task = task
        self.isSelected = isSelected
        self.showChildren = showChildren
    }
}


@Observable
class ItemDropdownContainer{
    var items: [String: [ItemDropdownModel]] = [:]
    var defaultTaskRepostiory: TaskRepository
    var queryManager = QueryDescriptorManager()
    var taskAreLoading: Bool = true
    var taskFetched: Int = 0;
    
    init(defaultTaskRepository: TaskRepository) {
        self.defaultTaskRepostiory = defaultTaskRepository
    }
    
    func getTasks(parentID: String? = nil) async {
        let descriptor = queryManager.descriptorForParentID(parentID: parentID)
        let tasks: [TaskModel] = defaultTaskRepostiory.fetchTasks(descriptor: descriptor)
        for task in tasks{
            
            items[parentID ?? "nil", default: []].append(ItemDropdownModel(task: task))
            taskFetched += 1
            if task.taskType != .day{
                await getTasks(parentID: task.id)
            }
        }
    }
        
    func markChildrenAsFather(parentID: String, isSelected: Bool) async {
        
        guard let children = items[parentID] else { return }
        
        for child in children{
            child.isSelected = isSelected
            if child.task.taskType == .day { continue }
            await markChildrenAsFather(parentID: child.task.id, isSelected: isSelected)
        }
    }
}

