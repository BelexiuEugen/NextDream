//
//  TaskModelCreation.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 12/08/2025.
//

import Foundation



struct TaskModelCreation{
    
    var name: String = "No Description"
    var askedQuestions: String? = nil
    var description: String? = nil
    var parentID: String? = nil
    var mainTaskID: String? = nil
    var taskStartDate: Date
    var weekDaysCount: Int? = nil
    var monthDaysCount: Int? = nil
    var taskPriority: TaskPriority
    var taskCategory: TaskCategory
    var taskType: TaskType
    var startWeekDay: Weekday? = nil
    var numberOfYears: Int? = nil
    var numberOfMonths: Int? = nil
    var numberOfWeeks: Int? = nil
    var numberOfDays: Int? = nil
    var restDays: [Weekday]? = nil
}
