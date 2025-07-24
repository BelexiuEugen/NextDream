//
//  SwiftDataManager.swift
//  NextDream
//
//  Created by Jan on 30/06/2025.
//

import Foundation
import SwiftData

protocol TaskRepository{
    func fetchTasks(descriptor: FetchDescriptor<TaskModel>) throws -> [TaskModel]
}

class DefaultTaskRepository: TaskRepository{
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchTasks(descriptor: FetchDescriptor<TaskModel>) throws -> [TaskModel] {
        do{
            return try modelContext.fetch(descriptor)
        } catch{
            throw error
        }
    }
    
    func fetchTasksByParentID(parentID: String?) throws -> [TaskModel]{
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{ $0.parentID == parentID})
        
        do{
            let taskList = try modelContext.fetch(descriptor)
            return taskList;
        } catch{
            throw error
        }
    }
    
    static func getTaskByID(id: String, modelContext: ModelContext) -> TaskModel?{
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{ $0.id == id})
        
        do{
            let taskResult: TaskModel? = try modelContext.fetch(descriptor).first ?? nil
            return taskResult;
        } catch{
            print("Error fetch the task with ID: \(id)");
        }
        
        return nil;
    }
    
    func fetchTaskByInterval(startDate: Date, endDate: Date) throws -> [TaskModel]{
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{endDate > $0.deadline && $0.deadline >= startDate})
        
        do{
            return try modelContext.fetch(descriptor)

        } catch{
            throw error
        }
    }
    
    func fetchTaskByDeadline(date: Date){
        
        let calendar = Calendar.current
        let startDate: Date? = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate ?? .now)
        
        guard let startDate = startDate, let endDate = endDate else { return }
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{ endDate > $0.deadline && $0.deadline >= startDate })
        
        do{
            let taskList = try modelContext.fetch(descriptor)

            for task in taskList{
                print(task.name);
            }
//            task = taskList;
        }catch{
            print("There was an error \(error.localizedDescription)")
        }
    }
    
    func fetchAllTask() throws -> [TaskModel]{
        
        do{
            let descriptor = FetchDescriptor<TaskModel>();
            return  try modelContext.fetch(descriptor);
            
        }catch{
            throw error
        }
    }
    
    func fetchTaskByDescriptorAndSearchString(sort: SortDescriptor<TaskModel>, serchString: String) throws -> [TaskModel]{
        
        do{
            var descriptor = FetchDescriptor<TaskModel>()
            
            descriptor.predicate = #Predicate<TaskModel> { task in
                (serchString.isEmpty || task.name.localizedStandardContains(serchString))
                    && task.parentID == nil
            }
            
            descriptor.sortBy = [sort];
            
            return try modelContext.fetch(descriptor);
            
        } catch{
            throw error
        }
    }
    
    func fetchMainTasks() throws -> [TaskModel]{
        
        do{
            let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate { $0.parentID == nil})
            return try modelContext.fetch(descriptor)
        } catch{
            throw error
        }
    }
}
