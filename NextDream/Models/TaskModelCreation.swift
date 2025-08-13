//
//  TaskModelCreation.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 12/08/2025.
//

import Foundation



struct TaskModelCreation{
    
    var name: String = "No Description"
    var parentID: String? = nil
    var taskStartDate: Date
    var weekDaysCount: Int? = nil
    var monthDaysCount: Int? = nil
    var taskPriority: TaskPriority
    var taskType: TaskType
    var startWeekDay: Weekday? = nil
    var numberOfYears: Int? = nil
    var numberOfMonths: Int? = nil
    var numberOfWeeks: Int? = nil
    var numberOfDays: Int? = nil
    var restDays: [Weekday]? = nil
}
//extension TaskModelCreation{
//    init(
//        name: String = "No Description",
//        parentID: String? = nil,
//        taskStartDate: Date,
//        weekDaysCount: Int? = nil,
//        monthDaysCount: Int? = nil,
//        taskPriority: TaskPriority,
//        taskType: TaskType,
//        startWeekDay: Weekday? = nil,
//        numberOfYears: Int? = nil,
//        numberOfMonths: Int? = nil,
//        numberOfWeeks: Int? = nil,
//        numberOfDays: Int? = nil
//    ) {
//        self.name = name
//        self.parentID = parentID
//        self.taskStartDate = taskStartDate
//        self.weekDaysCount = weekDaysCount
//        self.monthDaysCount = monthDaysCount
//        self.taskPriority = taskPriority
//        self.taskType = taskType
//        self.startWeekDay = startWeekDay
//        self.numberOfYears = numberOfYears
//        self.numberOfMonths = numberOfMonths
//        self.numberOfWeeks = numberOfWeeks
//        self.numberOfDays = numberOfDays
//    }
//}
