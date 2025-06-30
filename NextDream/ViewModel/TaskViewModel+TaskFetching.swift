//
//  TaskViewModel+TaskFetching.swift
//  NextDream
//
//  Created by Jan on 09/04/2025.
//

import Foundation
import SwiftData

extension TaskViewModel{
    
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
    
    func fetchTaskByInterval(startDate: Date, endDate: Date){
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{endDate > $0.deadline && $0.deadline >= startDate})
        
        do{
            let taskList = try modelContext.fetch(descriptor)
            
            tasks = taskList;
        } catch{
            print("There was an error \(error.localizedDescription)")
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
    
    func fetchAllTask(){
        
        do{
            let descriptor = FetchDescriptor<TaskModel>();
            let taskList = try modelContext.fetch(descriptor);
            
            tasks = taskList;
            
        }catch{
            print("There was an error \(error.localizedDescription)");
        }
        
        
    }
    
    func fetchMainTasks(){
        
        do{
            let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate { $0.parentID == nil})
            
            tasks = try modelContext.fetch(descriptor)
        } catch{
            print("There was an error \(error.localizedDescription)")
        }
    }
}
