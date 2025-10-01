//
//  TaskViewModel+TaskCreation.swift
//  NextDream
//
//  Created by Jan on 27/03/2025.
//

import Foundation
import SwiftData

protocol TaskCreation{
    
    var taskCount: Int {get set}
    
    func createTask(taskData: TaskModelCreation, creationModelType: CreationModelType) -> TaskModel?
}

@Observable
class TaskCreationManager: TaskCreation{
    
    var taskCount: Int = 0
    
    internal var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createTask(taskData: TaskModelCreation, creationModelType: CreationModelType) -> TaskModel?{
        
        var result: TaskModel?;
        var newTaskData = taskData;
        
        switch taskData.taskType {
        case .day:
//            newTaskData.name = taskData.taskStartDate.getDayName()
            result = createDay(taskData: newTaskData);
        case .week:
//            newTaskData.name = taskData.taskStartDate.weekRange(7)
            result = createWeek(taskData: newTaskData)
        case .month:
            result = creationModelType == .calendar ? createCalendarMonth(taskData: taskData): createRegularMonth(taskData: taskData)
        case .year:
            newTaskData.name = "\(Calendar.current.component(.year, from: taskData.taskStartDate))"
            result = creationModelType == .calendar ? createCalendarYear(taskData: taskData) : createRegularYear(taskData: taskData)
        default:
            result = createCustom(taskData: taskData, creationModelType: creationModelType)
            break;
        }
        
        
        self.saveDataToDevice()
        taskCount = 0
        
        return result;
    }
    
    //MARK: Day
    
    func createDay(taskData: TaskModelCreation) -> TaskModel?{
        
        let newDayModel = TaskModel(
            name: taskData.name,
            askedGoalQuestions: taskData.askedQuestions,
            taskDescription: taskData.description,
            parentID: taskData.parentID,
            mainTaskID: taskData.mainTaskID,
            creationDate: taskData.taskStartDate,
            deadline: taskData.taskStartDate,
            taskTypeID: TaskType.day.rawValue,
            taskCategory: taskData.taskCategory,
            taskPriority: taskData.taskPriority
        );
        
        modelContext.insert(newDayModel);
        
//        self.saveDataToDevice()
        
        taskCount += 1;
        
        return newDayModel;
    }
    
    //MARK: Week
    
    func createWeek(taskData: TaskModelCreation) -> TaskModel?{
        
        guard
            let weekDaysCount = taskData.weekDaysCount,
            let deadline = Calendar.current.date(byAdding: .day, value: weekDaysCount - 1, to: taskData.taskStartDate),
            var currentDay = Weekday(date: taskData.taskStartDate)
        else { return nil }
        
        let restDays = taskData.restDays ?? []
        
        let newWeekModel = TaskModel(
            name: taskData.name,
            askedGoalQuestions: taskData.askedQuestions,
            taskDescription: taskData.description,
            parentID: taskData.parentID,
            mainTaskID: taskData.mainTaskID,
            creationDate: taskData.taskStartDate,
            deadline: deadline,
            taskTypeID: TaskType.week.rawValue,
            taskCategory: taskData.taskCategory,
            taskPriority: taskData.taskPriority
        );
        
        modelContext.insert(newWeekModel);
        
        var subTaskStartDate = taskData.taskStartDate
        
        for _ in 1...weekDaysCount{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 1, to: subTaskStartDate) else { break }
            
            let dayName = restDays.contains(currentDay) ? "Rest" : subTaskStartDate.getDayName()
            
            let subTaskData = TaskModelCreation(
                name: dayName,
                parentID: newWeekModel.id,
                mainTaskID: taskData.mainTaskID ?? newWeekModel.id,
                taskStartDate: subTaskStartDate,
                taskPriority: taskData.taskPriority,
                taskCategory: taskData.taskCategory,
                taskType: .day,
                startWeekDay: taskData.startWeekDay,
            )
            
            _ = createDay(taskData: subTaskData)
            
            subTaskStartDate = startDate
            currentDay.next()
        }
        
        return newWeekModel;
    }
    
    //MARK: Custom
    
    func createCustom(taskData: TaskModelCreation, creationModelType: CreationModelType) -> TaskModel?{
        
        guard
            let numberOfYears = taskData.numberOfYears,
            let numberOfMonths = taskData.numberOfMonths,
            let numberOfWeeks = taskData.numberOfWeeks,
            let numberOfDays = taskData.numberOfDays,
            let deadlineWithYears = Calendar.current.date(byAdding: .year, value: numberOfYears, to: taskData.taskStartDate),
            let deadlineWithMonths = Calendar.current.date(byAdding: .month, value: numberOfMonths, to: deadlineWithYears),
            let deadlineWithWeeks = Calendar.current.date(byAdding: .weekOfYear, value: numberOfWeeks, to: deadlineWithMonths),
            let finalDeadline = Calendar.current.date(byAdding: .day, value: numberOfDays, to: deadlineWithWeeks)
        else { return nil }
        
        let newCustomModel = TaskModel(
            name: taskData.name,
            askedGoalQuestions: taskData.askedQuestions,
            taskDescription: taskData.description,
            creationDate: taskData.taskStartDate,
            deadline: finalDeadline,
            taskTypeID: TaskType.custom.rawValue,
            taskCategory: taskData.taskCategory, taskPriority: taskData.taskPriority
        );
        
        modelContext.insert(newCustomModel)
        
        createCustomSubTasks(taskData: taskData, parentID: newCustomModel.id, CreationModelType: creationModelType)
        
        return newCustomModel;
    }
    
    func createCustomSubTasks(taskData: TaskModelCreation, parentID: String, CreationModelType: CreationModelType){
        
        
        guard
            let numberOfYears = taskData.numberOfYears,
            let numberOfMonths = taskData.numberOfMonths,
            let numberOfWeeks = taskData.numberOfWeeks,
            let numberOfDays = taskData.numberOfDays
        else { return }
        
        var subTaskStartDate = taskData.taskStartDate
        
        for _ in 0..<numberOfYears{
            
            guard let startDate = Calendar.current.date(byAdding: .year, value: 1, to: subTaskStartDate) else {break};
            
            let currentYear = Calendar.current.component(.year, from: subTaskStartDate)
            
            let subTaskData = TaskModelCreation(
                name: "\(currentYear)",
                parentID: parentID,
                mainTaskID: taskData.mainTaskID ?? parentID,
                taskStartDate: subTaskStartDate,
                taskPriority: taskData.taskPriority,
                taskCategory: taskData.taskCategory,
                taskType: .year,
                startWeekDay: taskData.startWeekDay,
                restDays: taskData.restDays
            )
            
            _ = CreationModelType == .calendar ? createCalendarYear(taskData: subTaskData) : createRegularYear(taskData: subTaskData)
            
            subTaskStartDate = startDate
        }
        
        var month = Calendar.current.component(.month, from: subTaskStartDate) - 1
        
        
        for i in 0..<numberOfMonths{
            
            guard let startDate = Calendar.current.date(byAdding: .month, value: 1, to: subTaskStartDate) else {break};
            
            let currentMonth = Months(date: subTaskStartDate)
            
            let subTaskData = TaskModelCreation(
                name: CreationModelType == .calendar ? currentMonth.monthName : "Month: \(i)",
                parentID: parentID,
                mainTaskID: taskData.mainTaskID ?? parentID,
                taskStartDate: subTaskStartDate,
                weekDaysCount: 7,
                monthDaysCount: CreationModelType == .calendar ? currentMonth.calculateDaysCount(date: subTaskStartDate) : 28,
                taskPriority: taskData.taskPriority,
                taskCategory: taskData.taskCategory,
                taskType: .month,
                startWeekDay: taskData.startWeekDay, restDays: taskData.restDays)
            
            _ = CreationModelType == .calendar ? createCalendarMonth(taskData: subTaskData) : createRegularMonth(taskData: subTaskData)
            
            subTaskStartDate = startDate
            
            month = (month + 1) % 12;
        }
        
        for _ in 0..<numberOfWeeks{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 7, to: subTaskStartDate) else {break}
            
            let subTaskData = TaskModelCreation(
                name: subTaskStartDate.weekRange(6),
                parentID: parentID,
                mainTaskID: taskData.mainTaskID ?? parentID,
                taskStartDate: subTaskStartDate,
                weekDaysCount: 7,
                taskPriority: taskData.taskPriority,
                taskCategory: taskData.taskCategory,
                taskType: .week,
                restDays: taskData.restDays)
            
            _ = createWeek(taskData: subTaskData)
            
            subTaskStartDate = startDate
        }
        
        for _ in 0..<numberOfDays{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 1, to: subTaskStartDate) else {break}
            
            let subTaskData = TaskModelCreation(
                name: subTaskStartDate.getDayName(),
                parentID: parentID,
                mainTaskID: taskData.mainTaskID ?? parentID,
                taskStartDate: subTaskStartDate,
                taskPriority: taskData.taskPriority,
                taskCategory: taskData.taskCategory,
                taskType: .day)
            
            _ = createDay(taskData: subTaskData)
            
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

// MARK: Regular Standard

//extension TaskCreationManager{
//    
//    func createRegularYear(taskData: TaskModelCreation) -> TaskModel?{
//        guard
//            let deadline = Calendar.current.date(byAdding: .year, value: 1, to: taskData.taskStartDate),
//            let deadline = Calendar.current.date(byAdding: .day, value: -1, to: deadline)
//            
//        else { return nil};
//        
//        let newRegularYear = TaskModel(
//            name: taskData.name,
//            parentID: taskData.parentID,
//            mainTaskID: taskData.mainTaskID,
//            creationDate: taskData.taskStartDate,
//            deadline: deadline,
//            taskTypeID: TaskType.year.rawValue,
//            taskCategory: taskData.taskCategory,
//            taskPriority: taskData.taskPriority
//        );
//        
//        modelContext.insert(newRegularYear)
//        
//        createRegularYearSubMonths(parentID: newRegularYear.id, taskData: taskData)
//        
//        return newRegularYear
//    }
//    
//    func createRegularYearSubMonths(parentID: String, taskData: TaskModelCreation){
//        
//        guard
//            let startWeekDay = taskData.startWeekDay
//        else { return }
//        
//        let daysCountFirstWeek = startWeekDay.calculateDaysCount(from: taskData.taskStartDate)
//        var daysCount = daysCountFirstWeek
//        var monthStartDate = taskData.taskStartDate
//        
//        for i in 1...13{
//            let newTaskData = TaskModelCreation(
//                name: "Month: \(i)",
//                parentID: parentID,
//                mainTaskID: taskData.mainTaskID ?? parentID,
//                taskStartDate: monthStartDate,
//                weekDaysCount: daysCount,
//                taskPriority: taskData.taskPriority,
//                taskCategory: taskData.taskCategory,
//                taskType: .month,
//                startWeekDay: startWeekDay,
//                restDays: taskData.restDays
//            )
//            
//            _ = createRegularMonth(taskData: newTaskData)
//            
//            monthStartDate = Calendar.current.date(byAdding: .day, value: daysCount + 21, to: monthStartDate) ?? .now
//            daysCount = 7
//        }
//        
//        daysCount = 7 - daysCountFirstWeek + 1
//        
//        guard let monthStartDate = Calendar.current.date(byAdding: .day, value: -1, to: monthStartDate) else { return }
//        
//        let subTaskData = TaskModelCreation(
//            name: "Progress Check",
//            parentID: parentID,
//            mainTaskID: taskData.mainTaskID ?? parentID,
//            taskStartDate: monthStartDate,
//            weekDaysCount: daysCount,
//            taskPriority: taskData.taskPriority,
//            taskCategory: taskData.taskCategory,
//            taskType: .week,
//            startWeekDay: taskData.startWeekDay,
//            restDays: taskData.restDays,
//        )
//        
//        _ = createWeek(taskData: subTaskData)
//        
//    }
//    
//    func createRegularMonth(taskData: TaskModelCreation) -> TaskModel?{
//        guard
//            let weekDaysCount = taskData.weekDaysCount,
//            var daysCount = taskData.weekDaysCount,
//            let deadline = Calendar.current.date(byAdding: .day, value: 21 + weekDaysCount - 1, to: taskData.taskStartDate)
//        else { return nil};
//        
//        let newRegularMonth = TaskModel(
//            name: taskData.name,
//            parentID: taskData.parentID,
//            mainTaskID: taskData.mainTaskID,
//            creationDate: taskData.taskStartDate,
//            deadline: deadline,
//            taskTypeID: TaskType.month.rawValue,
//            taskCategory: taskData.taskCategory,
//            taskPriority: taskData.taskPriority
//        );
//        modelContext.insert(newRegularMonth);
//        
//        
//        var subTaskStartDate = taskData.taskStartDate
//        
//        for _ in 1...4{
//            
//            let subTaskData = TaskModelCreation(
//                name: subTaskStartDate.weekRange(daysCount),
//                parentID: newRegularMonth.id,
//                mainTaskID: taskData.mainTaskID ?? newRegularMonth.id,
//                taskStartDate: subTaskStartDate,
//                weekDaysCount: daysCount,
//                taskPriority: taskData.taskPriority,
//                taskCategory: taskData.taskCategory,
//                taskType: .week,
//                startWeekDay: taskData.startWeekDay,
//                restDays: taskData.restDays
//            )
//            
//            _ = createWeek(taskData: subTaskData)
//            
//            subTaskStartDate = Calendar.current.date(byAdding: .day, value: daysCount, to: subTaskStartDate) ?? .now
//            
//            daysCount = 7
//            
//        }
//        
//        return newRegularMonth
//        
//    }
//    
//}

// MARK: Calendar

//extension TaskCreationManager{
//    
//    func createCalendarYear(taskData: TaskModelCreation) -> TaskModel?{
//        guard let deadline = Calendar.current.date(byAdding: .year, value: 1, to: taskData.taskStartDate),
//              let deadline = Calendar.current.date(byAdding: .day, value: -1, to: deadline) else { return nil};
//        
//        let newCalendarYear = TaskModel(
//            name: taskData.name,
//            parentID: taskData.parentID,
//            mainTaskID: taskData.mainTaskID,
//            creationDate: taskData.taskStartDate,
//            deadline: deadline,
//            taskTypeID: TaskType.year.rawValue,
//            taskCategory: taskData.taskCategory,
//            taskPriority: taskData.taskPriority
//        );
//        
//        modelContext.insert(newCalendarYear)
//        
//        createCalendarYearSubMonths(parentID: newCalendarYear.id, taskData: taskData)
//        
//        return newCalendarYear
//    }
//    
//    func createCalendarYearSubMonths(parentID: String, taskData: TaskModelCreation){
//
//        var currentDay = Calendar.current.component(.day, from: taskData.taskStartDate)
//        var currentMonth = Months(date: taskData.taskStartDate)
//        
//        var monthStartDate = taskData.taskStartDate
//        
//        for _ in 1...12{
//            let totalDays = currentMonth.calculateDaysCount(date: monthStartDate)
//            let difference = totalDays - currentDay + 1
//            
//            let newTaskData = TaskModelCreation(
//                name: currentMonth.monthName,
//                parentID: parentID,
//                mainTaskID: taskData.mainTaskID ?? parentID,
//                taskStartDate: monthStartDate,
//                weekDaysCount: 7,
//                monthDaysCount: difference,
//                taskPriority: taskData.taskPriority,
//                taskCategory: taskData.taskCategory,
//                taskType: .month,
//                startWeekDay: taskData.startWeekDay,
//                restDays: taskData.restDays)
//            
//            _ = createCalendarMonth(taskData: newTaskData)
//            
//            monthStartDate = Calendar.current.date(byAdding: .day, value: difference, to: monthStartDate) ?? .now
//            currentMonth.next()
//            currentDay = 1
//        }
//        
//        currentDay = Calendar.current.component(.day, from: taskData.taskStartDate)
//        
//        if currentDay > 1{
//            let newTaskData = TaskModelCreation(
//                name: currentMonth.monthName,
//                parentID: parentID,
//                mainTaskID: taskData.mainTaskID ?? parentID,
//                taskStartDate: monthStartDate,
//                weekDaysCount: 7,
//                monthDaysCount: currentDay - 1,
//                taskPriority: taskData.taskPriority,
//                taskCategory: taskData.taskCategory,
//                taskType: .month,
//                startWeekDay: taskData.startWeekDay,
//                restDays: taskData.restDays)
//            
//            _ = createCalendarMonth(taskData: newTaskData)
//        }
//    }
//    
//    func createCalendarMonth(taskData: TaskModelCreation) -> TaskModel?{
//        guard
//            let monthDaysCount = taskData.monthDaysCount,
//            let startWeekDay = taskData.startWeekDay,
//            let deadline = Calendar.current.date(byAdding: .day, value: monthDaysCount, to: taskData.taskStartDate),
//            let deadline = Calendar.current.date(byAdding: .day, value: -1, to: deadline)
//        else { return nil};
//        
//        var daysLeft = monthDaysCount
//        
//        let newCalendarMonth = TaskModel(
//            name: taskData.name,
//            parentID: taskData.parentID,
//            mainTaskID: taskData.mainTaskID,
//            creationDate: taskData.taskStartDate,
//            deadline: deadline,
//            taskTypeID: TaskType.month.rawValue,
//            taskCategory: taskData.taskCategory,
//            taskPriority: taskData.taskPriority
//        );
//        modelContext.insert(newCalendarMonth);
//        
//        var daysCount = startWeekDay.calculateDaysCount(from: taskData.taskStartDate)
//        
//        var subTaskStartDate = taskData.taskStartDate
//        
//        while daysLeft > 0{
//            
//            let subTaskData = TaskModelCreation(
//                name: daysCount == 1 ? subTaskStartDate.getDayName() : subTaskStartDate.weekRange(daysCount),
//                parentID: newCalendarMonth.id,
//                mainTaskID: taskData.mainTaskID ?? newCalendarMonth.id,
//                taskStartDate: subTaskStartDate,
//                weekDaysCount: daysCount,
//                taskPriority: taskData.taskPriority,
//                taskCategory: taskData.taskCategory,
//                taskType: daysCount == 1 ? .day : .week,
//                restDays: taskData.restDays,
//            )
//            
//            _ = daysCount == 1 ? createDay(taskData: subTaskData) : createWeek(taskData: subTaskData)
//            
//            subTaskStartDate = Calendar.current.date(byAdding: .day, value: daysCount, to: subTaskStartDate) ?? .now
//            
//            daysLeft -= daysCount
//            
//            daysCount = min(daysLeft, 7)
//        }
//        
//        return newCalendarMonth
//    }
//}
