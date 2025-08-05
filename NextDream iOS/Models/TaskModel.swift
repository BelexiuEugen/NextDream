//
//  TaskModel.swift
//  NextDream
//
//  Created by Jan on 28/01/2025.
//

import Foundation
import SwiftData


// Possible variables name :
// userID = for scalability in database.
// id : String? (if I plan to get Id from database)
// isVisible - I don't know it's purpose

@Model
class TaskModel: Identifiable{
    
    var id: String = UUID().uuidString
    var name: String
    var taskDescription: String? = nil;
    var parentID : String? = nil;
    var calendarIdentifier: String? = nil;
    var creationDate:Date = Date.now
    var deadline: Date
    var progress: CGFloat = 0.0
    var isCompleted: Bool = false
    var isSelected: Bool = false
    var taskType: TaskType;
    var taskPriority: TaskPriority;
    
    init(id: String, name: String, taskDescription: String? = nil, parentID: String? = nil, calendarIdentifier: String? = nil, creationDate: Date, deadline: Date, progress: CGFloat, isCompleted: Bool, isSelected: Bool, taskType: TaskType, taskPriority: TaskPriority) {
        self.id = id
        self.name = name
        self.taskDescription = taskDescription
        self.parentID = parentID
        self.calendarIdentifier = calendarIdentifier
        self.creationDate = creationDate
        self.deadline = deadline
        self.progress = progress
        self.isCompleted = isCompleted
        self.isSelected = isSelected
        self.taskType = taskType
        self.taskPriority = taskPriority;
    }
    
    init(name: String, deadline: Date, taskType: TaskType, taskPriority: TaskPriority){
        self.name = name;
        self.deadline = deadline;
        self.taskType = taskType;
        self.taskPriority = taskPriority;
    }
    
    init(name: String, parentID: String?, deadline: Date, taskType: TaskType, taskPriority: TaskPriority){
        self.name = name;
        self.parentID = parentID;
        self.deadline = deadline;
        self.taskType = taskType;
        self.taskPriority = taskPriority;
    }
    
    func createDictionary() -> [String: Any]{
        return [
            "name" : self.name,
            "taskDescription" : self.taskDescription as Any,
            "parentID" : self.parentID as Any,
            "calendarIdentifier" : self.calendarIdentifier as Any,
            "creationDate" : self.creationDate.convertToStringFormat(),
            "deadline" : self.deadline.convertToStringFormat(),
            "progress" : self.progress,
            "isCompleted" : self.isCompleted,
            "isSelected" : self.isSelected,
            "taskType" : self.taskType.rawValue,
            "taskPriority" : self.taskPriority.rawValue
        ]
    }
}


enum TaskPriority: String, Codable, CaseIterable{
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum TaskType: String, Codable, CaseIterable{
    case day = "Day Task"
    case week = "Week Task"
    case month = "Month Task"
    case year = "Year Task"
    case custom = "Custom Task"
}

struct TaskModelCreationData{
    
    var name: String
    let parentID: String?
    var taskStartDate: Date
    let totalWeekDays: Int
    let totalMonthDays: Int
    let numberOfYears: Int
    let numberOfMonths: Int
    let numberOfWeeks: Int
    let numberOfDays: Int
    let taskPriority: TaskPriority
    let taskType: TaskType
    let startWeekDay: Weekday
    
    init(name: String, parentID: String?, taskStartDate: Date, totalWeekDays: Int = 6, totalMonthDays: Int = 28, numberOfYears: Int = 0, numberOfMonths: Int = 0, numberOfWeeks: Int = 0, numberOfDays: Int = 0, taskPriority: TaskPriority, taskType: TaskType, startWeekday: Weekday) {
        self.name = name
        self.parentID = parentID
        self.taskStartDate = taskStartDate
        self.totalWeekDays = totalWeekDays
        self.totalMonthDays = totalMonthDays
        self.numberOfYears = numberOfYears
        self.numberOfMonths = numberOfMonths
        self.numberOfWeeks = numberOfWeeks
        self.numberOfDays = numberOfDays
        self.taskPriority = taskPriority
        self.taskType = taskType
        self.startWeekDay = startWeekday
    }
}

extension TaskModel{
    
    func toString() -> String{
        return self.name
    }
}
