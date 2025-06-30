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
        
        var descriptor = queryDescriptorManager.descriptorForSortAndString(sort: sort, serchString: serchString)
        
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
    
    static func deleteTaskById(id: String, modelContext: ModelContext){
        
        let subTask: [TaskModel] = fetchTasksByParentID(parentID: id, modelContext: modelContext);
        
        for task in subTask{
            
            if task.taskType != .day{
                deleteTaskById(id: task.id, modelContext: modelContext)
            }

            modelContext.delete(task)
        }
    }
    
    func deleteAllTask(with context: ModelContext){
        
        do{
            let allTasks = try context.fetch(FetchDescriptor<TaskModel>())
            
            // Delete each task
            for task in allTasks {
                context.delete(task)
            }
            
            self.saveDataToDevice()
            
        }catch{
            print("There was an error deleting the data")
        }
    }
    
}

// MARK: Task Creation
