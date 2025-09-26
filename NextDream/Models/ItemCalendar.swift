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
    var itemLoaded: Bool = false
    
    init(task: TaskModel, isSelected: Bool = false, showChildren: Bool = false, itemLoaded: Bool = false) {
        self.task = task
        self.isSelected = isSelected
        self.showChildren = showChildren
        self.itemLoaded = itemLoaded
    }
}


@Observable
class ItemDropdownContainer{
    var items: [ItemDropdownModel] = []
    var defaultTaskRepostiory: TaskRepository
    var queryManager = QueryDescriptorManager()
    
    init(defaultTaskRepository: TaskRepository) {
        self.defaultTaskRepostiory = defaultTaskRepository
        let descriptor = queryManager.descriptorForParentID(parentID: nil)
        let tasks = defaultTaskRepository.fetchTasks(descriptor: descriptor)
        for task in tasks {
            self.items.append(ItemDropdownModel(task: task, isSelected: false, showChildren: false))
        }
    }
    
    func fetchSubChildren(parentID: String){
        let descriptor = queryManager.descriptorForParentID(parentID: parentID)
        let subTasks: [TaskModel] = defaultTaskRepostiory.fetchTasks(descriptor: descriptor)
        
        for subTask in subTasks {
            let newItem = ItemDropdownModel(task: subTask, isSelected: false, showChildren: false)
            items.append(newItem)
        }
    }
}

