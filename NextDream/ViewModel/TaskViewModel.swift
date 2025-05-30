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
    
    var task: [TaskModel] = []
    
    var modelContext: ModelContext? = nil
    
    var taskCount: Int = 0;
    
    func saveDataToDevice(){
        
        guard let modelContext = modelContext else { return }
        
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

// MARK: Task Creation (Tools)

extension TaskViewModel{
    func createFreeWeek(_ daysToSkip: inout Int,totalMonthDays: Int, parentID: String, startDate: Date, taskPriority: TaskPriority) {
        // Create Free & Plan Week
        switch totalMonthDays{
        case 31:
             daysToSkip += 3;
        case 30:
             daysToSkip += 2;
        case 29:
             daysToSkip += 1;
        default:
            return
        }
        
        let subTaskData = TaskModelCreationData(name: "Rest & Plan", parentID: parentID, taskStartDate: startDate, totalWeekDays: daysToSkip - 1)
        
        _ = createWeek(taskData: subTaskData, taskPriority: taskPriority)
    }
    
    func createMonthByName(monthName: String, parentID: String, startDate: Date, taskPriority: TaskPriority){
        
        let currentYear = Calendar.current.component(.year, from: startDate)
        
        var numberOfDays = 0;
        
        switch monthName{
        case "January", "March", "May", "July", "August", "October", "December" :
            numberOfDays = 31;
        case "April", "June", "September", "November":
            numberOfDays = 30;
        default:
            if isLeapYear(currentYear){
                numberOfDays = 29;
            } else{
                numberOfDays = 28;
            }
        }
        
        let taskData: TaskModelCreationData = TaskModelCreationData(name: monthName, parentID: parentID, taskStartDate: startDate, totalMonthDays: numberOfDays)
        
        _ = createMonth(taskData: taskData, taskPriority: taskPriority)
    }
    
    func getNumberOfDays(_ monthName: String, currentYear: Int) -> Int{
        
        switch monthName{
        case "January", "March", "May", "July", "August", "October", "December" :
            return 31;
        case "April", "June", "September", "November":
            return 30;
        default:
            if isLeapYear(currentYear){
                return 29;
            } else{
                return 28;
            }
        }
    }
    
    func isLeapYear(_ year: Int) -> Bool{
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
    
    func getDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
    
    func weekRange(for weekStart: Date) -> String {
        let calendar = Calendar.current
        // Get the start and end of the week
        
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        
        // Format day numbers (12, 17) and month name (February)
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let startDay = dayFormatter.string(from: weekStart)
        let endDay = dayFormatter.string(from: weekEnd)
        let month = monthFormatter.string(from: weekStart)
        
        return "\(startDay) - \(endDay) \(month)"
    }
}
