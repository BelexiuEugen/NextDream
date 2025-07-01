//
//  UserClass.swift
//  Next Step
//
//  Created by Jan on 21/11/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class TaskViewModel{
    
    var tasks: [TaskModel] = []
    var modelContext: ModelContext
    var taskCount: Int = 0;
    var taskRepository: TaskRepository
    
    var path: NavigationViewModel = NavigationViewModel()
    var isLoading = false;
    var searchText = ""
    var isPresented: Bool = false;
    var sheetDetent: PresentationDetent = .fraction(0.4)
    var sortOrder = SortDescriptor(\TaskModel.name)
    
    var queryDescriptorManager: QueryDescriptorManager = QueryDescriptorManager()
    
    init(modelContext: ModelContext, taskRepository: TaskRepository) {
        self.modelContext = modelContext
        self.taskRepository = taskRepository
    }
    
    func saveDataToDevice(){
        
        do{
            try modelContext.save()
            
        } catch{
            print("there was an error saving the task")
        }
    }
    
    func fetchTaskByDescriptorAndSearchString(sort: SortDescriptor<TaskModel>, serchString: String){
        
        let descriptor = queryDescriptorManager.descriptorForSortAndString(sort: sort, serchString: serchString)
        
        do{
            tasks = try taskRepository.fetchTasks(descriptor: descriptor)
        } catch{
            print("A error must be applied here");
        }
    }
    
    func fetchTasksByParentID(parentID: String?) -> [TaskModel]{
        
        let descriptor = queryDescriptorManager.descriptorForParentID(parentID: parentID)
        
        do{
            return try taskRepository.fetchTasks(descriptor: descriptor)
        } catch{
            print("add an error in here")
        }
        
        return [];
    }
    
}

@Observable
class NavigationViewModel{
    var modelView: [TaskModel] = []
}

extension TaskViewModel{
    
    static func asDictionaryList(tasks: [TaskModel]) -> [[String: Any]]{
        
        var newTasksArray: [[String: Any]] = [];
        
        for task in tasks{
            
            let newTask: [String: Any] = task.createDictionary()
            
            newTasksArray.append(newTask)
        }
        
        return newTasksArray
    }
}


//MARK: Task Deletion

extension TaskViewModel{
    
    func deleteTaskById(id: String){
        
        let subTask: [TaskModel] = fetchTasksByParentID(parentID: id);
        
        for task in subTask{
            
            if task.taskType != .day{
                deleteTaskById(id: task.id)
            }

            modelContext.delete(task)
        }
    }
    
    func deleteTask(_ indexSet: IndexSet){
        for index in indexSet{
        
            let item = tasks[index]
            deleteTaskById(id: item.id)
            modelContext.delete(item)
            
            saveDataToDevice()
            
            tasks = fetchTasksByParentID(parentID: nil);
            
            guard item.id != "" else {return}
            
        }
    }
}

// MARK: Task Creation
