//
//  UserClass.swift
//  Next Step
//
//  Created by Jan on 21/11/2024.
//

import Foundation
import SwiftData

@Observable
class TaskViewModel{
    
    var tasks: [TaskModel] = []
    
    var modelContext: ModelContext
    
    var taskCount: Int = 0;
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveDataToDevice(){
        
        do{
            try modelContext.save()
            
        } catch{
            print("there was an error saving the task")
        }
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
