//
//  TaskCreationManager+Regular.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 26.09.2025.
//

import Foundation

extension TaskCreationManager{
    
    func createRegularYear(taskData: TaskModelCreation) -> TaskModel?{
        guard
            let deadline = Calendar.current.date(byAdding: .year, value: 1, to: taskData.taskStartDate),
            let deadline = Calendar.current.date(byAdding: .day, value: -1, to: deadline)
            
        else { return nil};
        
        let newRegularYear = TaskModel(
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
        
        modelContext.insert(newRegularYear)
        
        createRegularYearSubMonths(parentID: newRegularYear.id, taskData: taskData)
        
        return newRegularYear
    }
    
    func createRegularYearSubMonths(parentID: String, taskData: TaskModelCreation){
        
        guard
            let startWeekDay = taskData.startWeekDay
        else { return }
        
        let daysCountFirstWeek = startWeekDay.calculateDaysCount(from: taskData.taskStartDate)
        var daysCount = daysCountFirstWeek
        var monthStartDate = taskData.taskStartDate
        
        for i in 1...13{
            let newTaskData = TaskModelCreation(
                name: "Month: \(i)",
                parentID: parentID,
                mainTaskID: taskData.mainTaskID ?? parentID,
                taskStartDate: monthStartDate,
                weekDaysCount: daysCount,
                taskPriority: taskData.taskPriority,
                taskCategory: taskData.taskCategory,
                taskType: .month,
                startWeekDay: startWeekDay,
                restDays: taskData.restDays
            )
            
            _ = createRegularMonth(taskData: newTaskData)
            
            monthStartDate = Calendar.current.date(byAdding: .day, value: daysCount + 21, to: monthStartDate) ?? .now
            daysCount = 7
        }
        
        daysCount = 7 - daysCountFirstWeek + 1
        
        guard let monthStartDate = Calendar.current.date(byAdding: .day, value: -1, to: monthStartDate) else { return }
        
        let subTaskData = TaskModelCreation(
            name: "Progress Check",
            parentID: parentID,
            mainTaskID: taskData.mainTaskID ?? parentID,
            taskStartDate: monthStartDate,
            weekDaysCount: daysCount,
            taskPriority: taskData.taskPriority,
            taskCategory: taskData.taskCategory,
            taskType: .week,
            startWeekDay: taskData.startWeekDay,
            restDays: taskData.restDays,
        )
        
        _ = createWeek(taskData: subTaskData)
        
    }
    
    func createRegularMonth(taskData: TaskModelCreation) -> TaskModel?{
        guard
            let weekDaysCount = taskData.weekDaysCount,
            var daysCount = taskData.weekDaysCount,
            let deadline = Calendar.current.date(byAdding: .day, value: 21 + weekDaysCount - 1, to: taskData.taskStartDate)
        else { return nil};
        
        let newRegularMonth = TaskModel(
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
        modelContext.insert(newRegularMonth);
        
        
        var subTaskStartDate = taskData.taskStartDate
        
        for _ in 1...4{
            
            let subTaskData = TaskModelCreation(
                name: subTaskStartDate.weekRange(daysCount),
                parentID: newRegularMonth.id,
                mainTaskID: taskData.mainTaskID ?? newRegularMonth.id,
                taskStartDate: subTaskStartDate,
                weekDaysCount: daysCount,
                taskPriority: taskData.taskPriority,
                taskCategory: taskData.taskCategory,
                taskType: .week,
                startWeekDay: taskData.startWeekDay,
                restDays: taskData.restDays
            )
            
            _ = createWeek(taskData: subTaskData)
            
            subTaskStartDate = Calendar.current.date(byAdding: .day, value: daysCount, to: subTaskStartDate) ?? .now
            
            daysCount = 7
            
        }
        
        return newRegularMonth
        
    }
    
}
