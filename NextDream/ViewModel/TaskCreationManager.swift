//
//  TaskViewModel+TaskCreation.swift
//  NextDream
//
//  Created by Jan on 27/03/2025.
//

import Foundation
import SwiftData

protocol TaskCreation{
    func createTask(selectedOption: TaskType, taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?
}

class TaskCreationManager: TaskCreation{
    
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createTask(selectedOption: TaskType, taskData: TaskModelCreationData, taskPriority: TaskPriority = .low) -> TaskModel?{
        
//        taskCount += 1;
        
        var result: TaskModel?;
        var newTaskData = taskData;
        
        switch selectedOption {
        case .day:
            newTaskData.name = taskData.taskStartDate.getDayName()
            result = createDay(taskData: newTaskData, taskPriority: taskPriority);
        case .week:
            newTaskData.name = taskData.taskStartDate.weekRange()
            result = createWeek(taskData: newTaskData, taskPriority: taskPriority)
        case .month:
            result = createMonth(taskData: taskData, taskPriority: taskPriority)
        case .year:
            newTaskData.name = "\(Calendar.current.component(.year, from: taskData.taskStartDate))"
            result = createYear(taskData: taskData, taskPriority: taskPriority)
        default:
            result = createCustom(taskData: taskData, taskPriority: taskPriority)
            break;
        }
        
        self.saveDataToDevice()
        
        return result;
    }
    
    func createDay(taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?{
        
        let newDayModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: taskData.taskStartDate, taskType: .day, taskPriority: taskPriority);
        
        modelContext.insert(newDayModel);
        
        self.saveDataToDevice()
        
//        taskCount += 1;
        
        return newDayModel;
    }
    
    func createWeek(taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?{
        
        guard let deadline = Calendar.current.date(byAdding: .day, value: taskData.totalWeekDays, to: taskData.taskStartDate) else { return nil};
        
        let newWeekModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline, taskType: .week, taskPriority: taskPriority);
        
        modelContext.insert(newWeekModel);
        
        var subTaskStartDate = taskData.taskStartDate
        
        for _ in 0...taskData.totalWeekDays{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 1, to: subTaskStartDate) else { break }
            
            let subTaskData = TaskModelCreationData(
                name: subTaskStartDate.getDayName(),
                parentID: newWeekModel.id,
                taskStartDate: subTaskStartDate)
            
            _ = createDay(taskData: subTaskData, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
        }
        
        return newWeekModel;
    }
    
    func createMonth(taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?{
        
        guard let deadline = Calendar.current.date(byAdding: .day, value: taskData.totalMonthDays - 1, to: taskData.taskStartDate) else { return nil};
        
        let newMonthModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline, taskType: .month, taskPriority: taskPriority);
        
        modelContext.insert(newMonthModel);
        
        var daysToSkip = 0;
        
        createFreeWeek(&daysToSkip, totalMonthDays: taskData.totalMonthDays, parentID: newMonthModel.id, startDate: taskData.taskStartDate, taskPriority: taskPriority)
        
        guard var subTaskStartDate = Calendar.current.date(byAdding: .day, value: daysToSkip, to: taskData.taskStartDate) else { return nil}
        
        for _ in 0...3{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 7, to: subTaskStartDate) else { break }
            
            let subTaskData = TaskModelCreationData(
                name: subTaskStartDate.weekRange(),
                parentID: newMonthModel.id,
                taskStartDate: subTaskStartDate
            )
            
            _ = createWeek(taskData: subTaskData, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
        }
        
        return newMonthModel;
    }
    
    func createYear(taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?{
        
        guard let deadline = Calendar.current.date(byAdding: .year, value: 1, to: taskData.taskStartDate) else { return nil};
        
        let newYearModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline - 1, taskType: .year, taskPriority: taskPriority);
        
        modelContext.insert(newYearModel)
        
        createYearSubTasks(parentID: newYearModel.id, taskData: taskData, taskPriority: taskPriority)
        
        return newYearModel;
        
    }
    
    func createYearSubTasks(parentID: String, taskData: TaskModelCreationData, taskPriority: TaskPriority){
        
        let month = Calendar.current.component(.month, from: taskData.taskStartDate) - 1
        
        var subTaskStartTime = taskData.taskStartDate;
        let currentYear = Calendar.current.component(.year, from: subTaskStartTime)
        
        for i in 0...11 {
            
            let currentMonth: String = DateFormatter().monthSymbols[(month + i) % 12]
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: getNumberOfDays(currentMonth, currentYear: currentYear), to: subTaskStartTime) else {break}
            
            createMonthByName(monthName: currentMonth, parentID: parentID, startDate: subTaskStartTime, taskPriority: taskPriority);
            
            subTaskStartTime = startDate
        }
    }
    
    func createCustom(taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?{
        
        guard let deadlineWithYears = Calendar.current.date(byAdding: .year, value: taskData.numberOfYears, to: taskData.taskStartDate) else { return nil};
        
        guard let deadlineWithMonths = Calendar.current.date(byAdding: .month, value: taskData.numberOfMonths, to: deadlineWithYears) else { return nil};
        
        guard let deadlineWithWeeks = Calendar.current.date(byAdding: .weekOfYear, value: taskData.numberOfWeeks, to: deadlineWithMonths) else { return nil};
        
        guard let finalDeadline = Calendar.current.date(byAdding: .day, value: taskData.numberOfDays, to: deadlineWithWeeks) else { return nil};
        
        let newCustomModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: finalDeadline, taskType: .custom, taskPriority: taskPriority);
        
        modelContext.insert(newCustomModel)
        
        createCustomSubTasks(parentID: newCustomModel.id, taskData: taskData, taskPriority: taskPriority)
        
        return newCustomModel;
    }
    
    func createCustomSubTasks(parentID: String, taskData: TaskModelCreationData, taskPriority: TaskPriority){
        
        
        var subTaskStartDate = taskData.taskStartDate
        
        for _ in 0..<taskData.numberOfYears{
            
            guard let startDate = Calendar.current.date(byAdding: .year, value: 1, to: subTaskStartDate) else {break};
            
            let currentYear = Calendar.current.component(.year, from: subTaskStartDate)
            
            let subTaskData = TaskModelCreationData(name: "\(currentYear)", parentID: parentID, taskStartDate: subTaskStartDate)

            _ = createYear(taskData: subTaskData, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
        }
        
        var month = Calendar.current.component(.month, from: subTaskStartDate) - 1
        

        for _ in 0..<taskData.numberOfMonths{
            
            guard let startDate = Calendar.current.date(byAdding: .month, value: 1, to: subTaskStartDate) else {break};
            
            let currentMonth: String = DateFormatter().monthSymbols[month]

            createMonthByName(monthName: currentMonth, parentID: parentID, startDate: subTaskStartDate, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
            
            month = (month + 1) % 12;
        }
        

            
        for _ in 0..<taskData.numberOfWeeks{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 7, to: subTaskStartDate) else {break}
            
            let subTaskData = TaskModelCreationData(name: subTaskStartDate.weekRange(), parentID: parentID, taskStartDate: subTaskStartDate)
            
            _ = createWeek(taskData: subTaskData, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
        }
        
            
        for _ in 0..<taskData.numberOfDays{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 1, to: subTaskStartDate) else {break}
            
            let subTaskData = TaskModelCreationData(name: subTaskStartDate.getDayName(), parentID: parentID, taskStartDate: subTaskStartDate)
            
            _ = createDay(taskData: subTaskData, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
        }
    }
    
    
    func saveDataToDevice(){
        
        do{
            try modelContext.save()
            
        } catch{
            print("there was an error saving the task")
        }
    }
    
}

// MARK: Additions

extension TaskCreationManager{
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
}
