//
//  TaskCreationManager+Calendar.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 26.09.2025.
//

import Foundation

extension TaskCreationManager{
    
    func createCalendarYear(taskData: TaskModelCreation) -> TaskModel?{
        guard let deadline = Calendar.current.date(byAdding: .year, value: 1, to: taskData.taskStartDate),
              let deadline = Calendar.current.date(byAdding: .day, value: -1, to: deadline) else { return nil};
        
        let newCalendarYear = TaskModel(
            name: taskData.name,
            askedGoalQuestions: taskData.askedQuestions,
            taskDescription: taskData.description,
            parentID: taskData.parentID,
            mainTaskID: taskData.mainTaskID,
            creationDate: taskData.taskStartDate,
            deadline: deadline,
            taskTypeID: TaskType.year.rawValue,
            taskCategory: taskData.taskCategory,
            taskPriority: taskData.taskPriority
        );
        
        modelContext.insert(newCalendarYear)
        
        createCalendarYearSubMonths(parentID: newCalendarYear.id, taskData: taskData)
        
        return newCalendarYear
    }
    
    func createCalendarYearSubMonths(parentID: String, taskData: TaskModelCreation){

        var currentDay = Calendar.current.component(.day, from: taskData.taskStartDate)
        var currentMonth = Months(date: taskData.taskStartDate)
        
        var monthStartDate = taskData.taskStartDate
        
        for _ in 1...12{
            let totalDays = currentMonth.calculateDaysCount(date: monthStartDate)
            let difference = totalDays - currentDay + 1
            
            let newTaskData = TaskModelCreation(
                name: currentMonth.monthName,
                parentID: parentID,
                mainTaskID: taskData.mainTaskID ?? parentID,
                taskStartDate: monthStartDate,
                weekDaysCount: 7,
                monthDaysCount: difference,
                taskPriority: taskData.taskPriority,
                taskCategory: taskData.taskCategory,
                taskType: .month,
                startWeekDay: taskData.startWeekDay,
                restDays: taskData.restDays)
            
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
                mainTaskID: taskData.mainTaskID ?? parentID,
                taskStartDate: monthStartDate,
                weekDaysCount: 7,
                monthDaysCount: currentDay - 1,
                taskPriority: taskData.taskPriority,
                taskCategory: taskData.taskCategory,
                taskType: .month,
                startWeekDay: taskData.startWeekDay,
                restDays: taskData.restDays)
            
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
        
        let newCalendarMonth = TaskModel(
            name: taskData.name,
            askedGoalQuestions: taskData.askedQuestions,
            taskDescription: taskData.description,
            parentID: taskData.parentID,
            mainTaskID: taskData.mainTaskID,
            creationDate: taskData.taskStartDate,
            deadline: deadline,
            taskTypeID: TaskType.month.rawValue,
            taskCategory: taskData.taskCategory,
            taskPriority: taskData.taskPriority
        );
        modelContext.insert(newCalendarMonth);
        
        var daysCount = startWeekDay.calculateDaysCount(from: taskData.taskStartDate)
        
        var subTaskStartDate = taskData.taskStartDate
        
        while daysLeft > 0{
            
            let subTaskData = TaskModelCreation(
                name: daysCount == 1 ? subTaskStartDate.getDayName() : subTaskStartDate.weekRange(daysCount),
                parentID: newCalendarMonth.id,
                mainTaskID: taskData.mainTaskID ?? newCalendarMonth.id,
                taskStartDate: subTaskStartDate,
                weekDaysCount: daysCount,
                taskPriority: taskData.taskPriority,
                taskCategory: taskData.taskCategory,
                taskType: daysCount == 1 ? .day : .week,
                restDays: taskData.restDays,
            )
            
            _ = daysCount == 1 ? createDay(taskData: subTaskData) : createWeek(taskData: subTaskData)
            
            subTaskStartDate = Calendar.current.date(byAdding: .day, value: daysCount, to: subTaskStartDate) ?? .now
            
            daysLeft -= daysCount
            
            daysCount = min(daysLeft, 7)
        }
        
        return newCalendarMonth
    }
}
