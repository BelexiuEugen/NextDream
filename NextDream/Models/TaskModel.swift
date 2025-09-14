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
    var mainTaskID : String?
    var calendarIdentifier: String? = nil;
    var creationDate:Date = Date.now
    var deadline: Date
    var progress: CGFloat = 0.0
    var isCompleted: Bool = false
    var isSelected: Bool = false
    var taskType: TaskType;
    var taskCategory: TaskCategory
    var taskPriority: TaskPriority;
    
    init(
        id: String = UUID().uuidString,
        name: String,
        taskDescription: String? = nil,
        parentID: String? = nil,
        mainTaskID: String? = nil,
        calendarIdentifier: String? = nil,
        creationDate: Date,
        deadline: Date,
        progress: CGFloat = 0.0,
        isCompleted: Bool = false,
        isSelected: Bool = false,
        taskType: TaskType,
        taskCategory: TaskCategory,
        taskPriority: TaskPriority
    ) {
        self.id = id
        self.name = name
        self.taskDescription = taskDescription
        self.parentID = parentID
        self.mainTaskID = mainTaskID
        self.calendarIdentifier = calendarIdentifier
        self.creationDate = creationDate
        self.deadline = deadline
        self.progress = progress
        self.isCompleted = isCompleted
        self.isSelected = isSelected
        self.taskType = taskType
        self.taskCategory = taskCategory
        self.taskPriority = taskPriority
    }
}

//MARK: Dictionary
extension TaskModel{
    
    func createDictionary() -> [String: Any]{
        return [
            "name" : self.name,
            "taskDescription" : self.taskDescription as Any,
            "parentID" : self.parentID as Any,
            "mainTaskID" : self.mainTaskID as Any,
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
    
    func toString() -> String{
        return self.name
    }
}
