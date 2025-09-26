//
//  SwiftDataManager.swift
//  NextDream
//
//  Created by Jan on 30/06/2025.
//

import Foundation
import SwiftData

protocol TaskRepository{
    func fetchTasks(descriptor: FetchDescriptor<TaskModel>)-> [TaskModel]
}

class DefaultTaskRepository: TaskRepository{
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchStatsForTaskID(descriptor: FetchDescriptor<TaskModel>)
    -> (completedDays: Int, totalDays: Int,
               completedWeeks: Int, totalWeeks: Int,
               completedMonths: Int, totalMonths: Int,
               completedYears: Int, totalYears: Int
    ) {
        var completedDays = 0, totalDays = 0
        var completedWeeks = 0, totalWeeks = 0
        var completedMonths = 0, totalMonths = 0
        var completedYears = 0, totalYears = 0
        
        do{
            let taskList = try modelContext.fetch(descriptor)
            let daysList = taskList.filter{ $0.taskTypeID == TaskType.day.rawValue}
            let weeksList = taskList.filter{ $0.taskTypeID == TaskType.week.rawValue}
            let monthsList = taskList.filter{ $0.taskTypeID == TaskType.month.rawValue}
            let yearsList = taskList.filter{ $0.taskTypeID == TaskType.year.rawValue}
            
            totalDays = daysList.count
            totalWeeks = weeksList.count
            totalMonths = monthsList.count
            totalYears = yearsList.count
            
            completedDays = daysList.filter(\.isCompleted).count
            completedWeeks = weeksList.filter(\.isCompleted).count
            completedMonths = monthsList.filter(\.isCompleted).count
            completedYears = yearsList.filter(\.isCompleted).count
            
            
        } catch{
            print(error)
        }
        
        return (completedDays, totalDays
                , completedWeeks, totalWeeks
                , completedMonths, totalMonths
                , completedYears, totalYears
        )
    }
    
    func fetchTasks(descriptor: FetchDescriptor<TaskModel>) -> [TaskModel] {
        do{
            return try modelContext.fetch(descriptor).sorted { $0.deadline < $1.deadline }
        } catch{
            print("There was an error gettings the tasks")
        }
        
        return []
    }
    
    func fetcTasksForProgressChart(descriptor: FetchDescriptor<TaskModel>) -> [(Date, Bool)]{
        
        var result: [(Date, Bool)] = []
        
        do{
            let tasks = try modelContext.fetch(descriptor)
            
            for task in tasks {
                let taskData = (task.deadline, task.isCompleted)
                result.append(taskData)
            }
        } catch{
            print("Error: \(error)")
            return []
        }
        
        return result
    }
    
    func fetchTasksForStatistics(descriptor: FetchDescriptor<TaskModel>) -> [(TaskCategory, Int)]{
        var resultDictionary: [TaskCategory: Int] = [:]
        
        do{
            let tasks = try modelContext.fetch(descriptor)
            
            for task in tasks {
                resultDictionary[task.taskCategory, default: 0] += 1
            }
        } catch{
            print("Error: \(error)")
        }
        
        var resultTuple: [(TaskCategory, Int)] = [];
        
        for cateogry in resultDictionary {
            resultTuple.append((cateogry.key, cateogry.value))
        }
        
        return resultTuple;
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
    
    func fetchMainTasks() -> [TaskModel]{
        
        do{
            let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate { $0.parentID == nil})
            return try modelContext.fetch(descriptor)
        } catch{
            print("There was an error: \(error.localizedDescription)")
        }
        return []
    }
}
