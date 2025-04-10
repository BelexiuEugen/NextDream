//
//  TaskViewModel+TaskFetching.swift
//  NextDream
//
//  Created by Jan on 09/04/2025.
//

import Foundation
import SwiftData

extension TaskViewModel{
    
    static func fetchTasksByParentID(parentID: String?, modelContext: ModelContext) -> [TaskModel]{
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{ $0.parentID == parentID})
        
        do{
            let taskList = try modelContext.fetch(descriptor)
            return taskList;
        } catch{
            print("There was an error \(error.localizedDescription)")
        }
        
        return [];
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
    
    func fetchTaskByInterval(startDate: Date, endDate: Date){
        
        guard let modelContext = modelContext else { return }
        
        print(startDate);
        print(endDate);
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{endDate > $0.deadline && $0.deadline >= startDate})
        
        do{
            let taskList = try modelContext.fetch(descriptor)
            
            task = taskList;
        } catch{
            print("There was an error \(error.localizedDescription)")
        }
    }
    
    func fetchTaskByDeadline(date: Date){
        
        guard let modelContext = modelContext else { return }
        
        let calendar = Calendar.current
        let startDate: Date? = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate ?? .now)
        
        guard let startDate = startDate, let endDate = endDate else { return }
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{ endDate > $0.deadline && $0.deadline >= startDate })
        
        do{
            let taskList = try modelContext.fetch(descriptor)

            task = taskList;
        }catch{
            print("There was an error \(error.localizedDescription)")
        }
    }
    
    func fetchAllTask(){
        
        guard let modelContext = modelContext else { return }
        
        do{
            let descriptor = FetchDescriptor<TaskModel>();
            let taskList = try modelContext.fetch(descriptor);
            
            task = taskList;
            
        }catch{
            print("There was an error \(error.localizedDescription)");
        }
        
        
    }
    
    func fetchTaskByDescriptorAndSearchString(sort: SortDescriptor<TaskModel>, serchString: String){
        
        guard let modelContext = modelContext else { return }
        
        do{
            var descriptor = FetchDescriptor<TaskModel>()
            
            descriptor.predicate = #Predicate<TaskModel> { task in
                (serchString.isEmpty || task.name.localizedStandardContains(serchString))
                    && task.parentID == nil
            }
            
            descriptor.sortBy = [sort];
            
            task = try modelContext.fetch(descriptor);
            
        } catch{
            print("There was an error \(error.localizedDescription)");
        }
    }
    
}
