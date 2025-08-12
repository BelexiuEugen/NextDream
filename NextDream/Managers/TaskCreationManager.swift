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
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createTask(taskData: TaskModelCreation, creationModelType: CreationModelType) -> TaskModel?{
        
        var result: TaskModel?;
        var newTaskData = taskData;
        
        switch taskData.taskType {
        case .day:
            newTaskData.name = taskData.taskStartDate.getDayName()
            result = createDay(taskData: newTaskData);
        case .week:
            newTaskData.name = taskData.taskStartDate.weekRange(7)
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
    
    func createDay(taskData: TaskModelCreation) -> TaskModel?{
        
        let newDayModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: taskData.taskStartDate, taskType: .day, taskPriority: taskData.taskPriority);
        
        modelContext.insert(newDayModel);
        
        self.saveDataToDevice()
        
        taskCount += 1;
        
        return newDayModel;
    }
    
    func createWeek(taskData: TaskModelCreation) -> TaskModel?{
        
        guard
            let weekDaysCount = taskData.weekDaysCount,
            let deadline = Calendar.current.date(byAdding: .day, value: weekDaysCount, to: taskData.taskStartDate)
        else { return nil }
        
        
        let newWeekModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline, taskType: .week, taskPriority: taskData.taskPriority);
        
        modelContext.insert(newWeekModel);
        
        var subTaskStartDate = taskData.taskStartDate
        
        for _ in 1...weekDaysCount{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 1, to: subTaskStartDate) else { break }
            
            let subTaskData = TaskModelCreation(
                name: subTaskStartDate.getDayName(),
                parentID: newWeekModel.id,
                taskStartDate: subTaskStartDate,
                taskPriority: taskData.taskPriority,
                taskType: .day,
                startWeekDay: taskData.startWeekDay,
            )
            
            _ = createDay(taskData: subTaskData)
            
            subTaskStartDate = startDate
        }
        
        return newWeekModel;
    }
    
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
        
        let newCustomModel = TaskModel(name: taskData.name, deadline: finalDeadline, taskType: .custom, taskPriority: taskData.taskPriority);
        
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
            
            let subTaskData = TaskModelCreation(name: "\(currentYear)", parentID: parentID, taskStartDate: subTaskStartDate, taskPriority: taskData.taskPriority, taskType: .year, startWeekDay: taskData.startWeekDay)
            
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
                taskStartDate: subTaskStartDate,
                weekDaysCount: 7,
                monthDaysCount: CreationModelType == .calendar ? currentMonth.calculateDaysCount(date: subTaskStartDate) : 28,
                taskPriority: taskData.taskPriority,
                taskType: .month,
                startWeekDay: taskData.startWeekDay)
            
            _ = CreationModelType == .calendar ? createCalendarMonth(taskData: subTaskData) : createRegularMonth(taskData: subTaskData)
            
            subTaskStartDate = startDate
            
            month = (month + 1) % 12;
        }
        
        for _ in 0..<numberOfWeeks{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 7, to: subTaskStartDate) else {break}
            
            let subTaskData = TaskModelCreation(name: subTaskStartDate.weekRange(6), parentID: parentID, taskStartDate: subTaskStartDate, weekDaysCount: 7, taskPriority: taskData.taskPriority, taskType: .week)
            
            _ = createWeek(taskData: subTaskData)
            
            subTaskStartDate = startDate
        }
        
        for _ in 0..<numberOfDays{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 1, to: subTaskStartDate) else {break}
            
            let subTaskData = TaskModelCreation(name: subTaskStartDate.getDayName(), parentID: parentID, taskStartDate: subTaskStartDate, taskPriority: taskData.taskPriority, taskType: .day)
            
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

extension TaskCreationManager{
    
    func createRegularMonth(taskData: TaskModelCreation) -> TaskModel?{
        guard
            let weekDaysCount = taskData.weekDaysCount,
            var daysCount = taskData.weekDaysCount,
            let deadline = Calendar.current.date(byAdding: .day, value: 21 + weekDaysCount, to: taskData.taskStartDate)
        else { return nil};
        
        let newRegularMonth = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline, taskType: .month, taskPriority: taskData.taskPriority);
        modelContext.insert(newRegularMonth);
        
        
        var subTaskStartDate = taskData.taskStartDate
        
        for _ in 1...4{
            
            let subTaskData = TaskModelCreation(
                name: subTaskStartDate.weekRange(daysCount),
                parentID: newRegularMonth.id,
                taskStartDate: subTaskStartDate,
                weekDaysCount: daysCount,
                taskPriority: taskData.taskPriority,
                taskType: .week,
                startWeekDay: taskData.startWeekDay,
            )
            
            _ = createWeek(taskData: subTaskData)
            
            subTaskStartDate = Calendar.current.date(byAdding: .day, value: daysCount, to: subTaskStartDate) ?? .now
            
            daysCount = 7
            
        }
        
        return newRegularMonth
        
    }
    
    func createRegularYear(taskData: TaskModelCreation) -> TaskModel?{
        guard let deadline = Calendar.current.date(byAdding: .year, value: 1, to: taskData.taskStartDate) else { return nil};
        
        let newRegularYear = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline, taskType: .year, taskPriority: taskData.taskPriority);
        
        modelContext.insert(newRegularYear)
        
        createRegularYearSubMonths(parentID: newRegularYear.id, taskData: taskData)
        
        return newRegularYear
    }
    
    func createRegularYearSubMonths(parentID: String, taskData: TaskModelCreation){
        
        guard let startWeekDay = taskData.startWeekDay else { return }
        
        let daysCountFirstWeek = calculateFirstWeekDayCount(date: taskData.taskStartDate, startWeekDay: startWeekDay)
        var daysCount = daysCountFirstWeek
        
        var monthStartDate = taskData.taskStartDate
        
        for i in 1...13{
            let newTaskData = TaskModelCreation(
                name: "Month: \(i)",
                parentID: parentID,
                taskStartDate: monthStartDate,
                weekDaysCount: daysCount,
                taskPriority: taskData.taskPriority,
                taskType: .month,
                startWeekDay: startWeekDay)
            
            _ = createRegularMonth(taskData: newTaskData)
            
            monthStartDate = Calendar.current.date(byAdding: .day, value: daysCount + 21, to: monthStartDate) ?? .now
            daysCount = 7
        }
        
        daysCount = 7 - daysCountFirstWeek + 1
        
        let subTaskData = TaskModelCreation(
            name: "Progress Check",
            parentID: parentID,
            taskStartDate: monthStartDate,
            weekDaysCount: daysCount,
            taskPriority: taskData.taskPriority,
            taskType: .week,
            startWeekDay: taskData.startWeekDay,
        )
        
        _ = createWeek(taskData: subTaskData)
        
    }
    
    func calculateFirstWeekDayCount(date: Date, startWeekDay: Weekday, calendar: Calendar = .current) -> Int{
        let weekdayIndex = calendar.component(.weekday, from: date)
        let userWeekDayIndex = startWeekDay.index
        
        guard weekdayIndex != userWeekDayIndex else { return 7}
        
        return userWeekDayIndex > weekdayIndex ? userWeekDayIndex - weekdayIndex : 7 - weekdayIndex + userWeekDayIndex
    }
}

// MARK: Calendar

extension TaskCreationManager{
    
    func createCalendarYear(taskData: TaskModelCreation) -> TaskModel?{
        guard let deadline = Calendar.current.date(byAdding: .year, value: 1, to: taskData.taskStartDate),
              let deadline = Calendar.current.date(byAdding: .day, value: -1, to: deadline) else { return nil};
        
        let newCalendarYear = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline, taskType: .year, taskPriority: taskData.taskPriority);
        
        modelContext.insert(newCalendarYear)
        
        createCalendarYearSubMonths(parentID: newCalendarYear.id, taskData: taskData)
        
        return newCalendarYear
    }
    
    func createCalendarYearSubMonths(parentID: String, taskData: TaskModelCreation){
        
        print(taskData)
        
        var currentDay = Calendar.current.component(.day, from: taskData.taskStartDate)
        var currentMonth = Months(date: taskData.taskStartDate)
        
        var monthStartDate = taskData.taskStartDate
        
        for _ in 1...12{
            let totalDays = currentMonth.calculateDaysCount(date: monthStartDate)
            let difference = totalDays - currentDay + 1
            
            let newTaskData = TaskModelCreation(
                name: currentMonth.monthName,
                parentID: parentID,
                taskStartDate: monthStartDate,
                weekDaysCount: 7,
                monthDaysCount: difference,
                taskPriority: taskData.taskPriority,
                taskType: .month,
                startWeekDay: taskData.startWeekDay)
            
            _ = createCalendarMonth(taskData: newTaskData)
            
            monthStartDate = Calendar.current.date(byAdding: .day, value: difference, to: monthStartDate) ?? .now
            currentMonth.next()
            currentDay = 1
        }
        
        currentDay = Calendar.current.component(.day, from: taskData.taskStartDate)
        
        if currentDay > 1{
            let newTaskData = TaskModelCreation(
                name: currentMonth.monthName,
                parentID: parentID,
                taskStartDate: monthStartDate,
                weekDaysCount: 7,
                monthDaysCount: currentDay - 1,
                taskPriority: taskData.taskPriority,
                taskType: .month,
                startWeekDay: taskData.startWeekDay)
            
            _ = createCalendarMonth(taskData: newTaskData)
        }
    }
    
    func createCalendarMonth(taskData: TaskModelCreation) -> TaskModel?{
        guard
            let monthDaysCount = taskData.monthDaysCount,
            let startWeekDay = taskData.startWeekDay,
            let deadline = Calendar.current.date(byAdding: .day, value: monthDaysCount, to: taskData.taskStartDate),
            let deadline = Calendar.current.date(byAdding: .day, value: -1, to: deadline)
        else { return nil};
        
        var daysLeft = monthDaysCount
        
        let newCalendarMonth = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline, taskType: .month, taskPriority: taskData.taskPriority);
        modelContext.insert(newCalendarMonth);
        
        var daysCount = startWeekDay.calculateDaysCount(from: taskData.taskStartDate)
        
        var subTaskStartDate = taskData.taskStartDate
        
        while daysLeft > 0{
            
            let subTaskData = TaskModelCreation(
                name: daysCount == 1 ? subTaskStartDate.getDayName() : subTaskStartDate.weekRange(daysCount),
                parentID: newCalendarMonth.id,
                taskStartDate: subTaskStartDate,
                weekDaysCount: daysCount,
                taskPriority: taskData.taskPriority,
                taskType: daysCount == 1 ? .day : .week,
            )
            
            _ = daysCount == 1 ? createDay(taskData: subTaskData) : createWeek(taskData: subTaskData)
            
            subTaskStartDate = Calendar.current.date(byAdding: .day, value: daysCount, to: subTaskStartDate) ?? .now
            
            daysLeft -= daysCount
            
            daysCount = min(daysLeft, 7)
        }
        
        return newCalendarMonth
    }
}

// MARK: Additions

extension TaskCreationManager{
//    func createFreeWeek(_ daysToSkip: inout Int,totalMonthDays: Int, parentID: String, startDate: Date, taskPriority: TaskPriority) {
//        // Create Free & Plan Week
//        switch totalMonthDays{
//        case 31:
//             daysToSkip += 3;
//        case 30:
//             daysToSkip += 2;
//        case 29:
//             daysToSkip += 1;
//        default:
//            return
//        }
//        
//        let subTaskData = TaskModelCreation(name: "Rest & Plan", parentID: parentID, taskStartDate: startDate, weekDaysCount: daysToSkip - 1)
//        
//        _ = createWeek(taskData: subTaskData, taskPriority: taskPriority)
//    }
    
//    func createMonthByName(monthName: String, parentID: String, startDate: Date, taskPriority: TaskPriority){
//        
//        let currentYear = Calendar.current.component(.year, from: startDate)
//        
//        var numberOfDays = 0;
//        
//        switch monthName{
//        case "January", "March", "May", "July", "August", "October", "December" :
//            numberOfDays = 31;
//        case "April", "June", "September", "November":
//            numberOfDays = 30;
//        default:
//            if isLeapYear(currentYear){
//                numberOfDays = 29;
//            } else{
//                numberOfDays = 28;
//            }
//        }
//        
//        let taskData: TaskModelCreation = TaskModelCreation(name: monthName, parentID: parentID, taskStartDate: startDate, totalMonthDays: numberOfDays)
//        
//        _ = createMonth(taskData: taskData, taskPriority: taskPriority)
//    }
    
//    func getNumberOfDays(_ monthName: String, currentYear: Int) -> Int{
//        
//        switch monthName{
//        case "January", "March", "May", "July", "August", "October", "December" :
//            return 31;
//        case "April", "June", "September", "November":
//            return 30;
//        default:
//            if isLeapYear(currentYear){
//                return 29;
//            } else{
//                return 28;
//            }
//        }
//    }
}

// #region oldImplementation

extension TaskCreationManager{
//    func createMonth(taskData: TaskModelCreation) -> TaskModel?{
//        
//        guard let deadline = Calendar.current.date(byAdding: .day, value: taskData.totalMonthDays - 1, to: taskData.taskStartDate) else { return nil};
//        
//        let newMonthModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline, taskType: .month, taskPriority: taskData.taskPriority);
//        
//        modelContext.insert(newMonthModel);
//        
//        var daysToSkip = 0;
//        
//        createFreeWeek(&daysToSkip, totalMonthDays: taskData.totalMonthDays, parentID: newMonthModel.id, startDate: taskData.taskStartDate, taskPriority: taskPriority)
//        
//        guard var subTaskStartDate = Calendar.current.date(byAdding: .day, value: daysToSkip, to: taskData.taskStartDate) else { return nil}
//        
//        for _ in 0...3{
//            
//            guard let startDate = Calendar.current.date(byAdding: .day, value: 7, to: subTaskStartDate) else { break }
//            
//            let subTaskData = TaskModelCreation(
//                name: subTaskStartDate.weekRange(),
//                parentID: newMonthModel.id,
//                taskStartDate: subTaskStartDate
//            )
//            
//            _ = createWeek(taskData: subTaskData, taskPriority: taskPriority)
//            
//            subTaskStartDate = startDate
//        }
//        
//        return newMonthModel;
//    }
//    
//    func createYear(taskData: TaskModelCreation, taskPriority: TaskPriority) -> TaskModel?{
//        
//        guard let deadline = Calendar.current.date(byAdding: .year, value: 1, to: taskData.taskStartDate) else { return nil};
//        
//        let newYearModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline - 1, taskType: .year, taskPriority: taskPriority);
//        
//        modelContext.insert(newYearModel)
//        
//        createYearSubTasks(parentID: newYearModel.id, taskData: taskData, taskPriority: taskPriority)
//        
//        return newYearModel;
//        
//    }
//    
//    func createYearSubTasks(parentID: String, taskData: TaskModelCreation, taskPriority: TaskPriority){
//        
//        let month = Calendar.current.component(.month, from: taskData.taskStartDate) - 1
//        
//        var subTaskStartTime = taskData.taskStartDate;
//        let currentYear = Calendar.current.component(.year, from: subTaskStartTime)
//        
//        for i in 0...11 {
//            
//            let currentMonth: String = DateFormatter().monthSymbols[(month + i) % 12]
//            
//            guard let startDate = Calendar.current.date(byAdding: .day, value: getNumberOfDays(currentMonth, currentYear: currentYear), to: subTaskStartTime) else {break}
//            
//            createMonthByName(monthName: currentMonth, parentID: parentID, startDate: subTaskStartTime, taskPriority: taskPriority);
//            
//            subTaskStartTime = startDate
//        }
//    }
    //
    //    func createCustomSubTasks(parentID: String, taskData: TaskModelCreation){
    //
    //
    //        var subTaskStartDate = taskData.taskStartDate
    //
    //        for _ in 0..<taskData.numberOfYears{
    //
    //            guard let startDate = Calendar.current.date(byAdding: .year, value: 1, to: subTaskStartDate) else {break};
    //
    //            let currentYear = Calendar.current.component(.year, from: subTaskStartDate)
    //
    //            let subTaskData = TaskModelCreation(name: "\(currentYear)", parentID: parentID, taskStartDate: subTaskStartDate)
    //
    //            _ = createYear(taskData: subTaskData, taskPriority: taskPriority)
    //
    //            subTaskStartDate = startDate
    //        }
    //
    //        var month = Calendar.current.component(.month, from: subTaskStartDate) - 1
    //
    //
    //        for _ in 0..<taskData.numberOfMonths{
    //
    //            guard let startDate = Calendar.current.date(byAdding: .month, value: 1, to: subTaskStartDate) else {break};
    //
    //            let currentMonth: String = DateFormatter().monthSymbols[month]
    //
    //            createMonthByName(monthName: currentMonth, parentID: parentID, startDate: subTaskStartDate, taskPriority: taskPriority)
    //
    //            subTaskStartDate = startDate
    //
    //            month = (month + 1) % 12;
    //        }
    //
    //
    //
    //        for _ in 0..<taskData.numberOfWeeks{
    //
    //            guard let startDate = Calendar.current.date(byAdding: .day, value: 7, to: subTaskStartDate) else {break}
    //
    //            let subTaskData = TaskModelCreation(name: subTaskStartDate.weekRange(), parentID: parentID, taskStartDate: subTaskStartDate)
    //
    //            _ = createWeek(taskData: subTaskData, taskPriority: taskPriority)
    //
    //            subTaskStartDate = startDate
    //        }
    //
    //
    //        for _ in 0..<taskData.numberOfDays{
    //
    //            guard let startDate = Calendar.current.date(byAdding: .day, value: 1, to: subTaskStartDate) else {break}
    //
    //            let subTaskData = TaskModelCreation(name: subTaskStartDate.getDayName(), parentID: parentID, taskStartDate: subTaskStartDate)
    //
    //            _ = createDay(taskData: subTaskData, taskPriority: taskPriority)
    //
    //            subTaskStartDate = startDate
    //        }
    //    }
}
