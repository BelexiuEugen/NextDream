//
//  TaskModel.swift
//  NextDream
//
//  Created by Jan on 28/01/2025.
//

import Foundation
import SwiftData
import CoreGraphics


// Possible variables name :
// userID = for scalability in database.
// id : String? (if I plan to get Id from database)
// isVisible - I don't know it's purpose

@Model
class TaskModel: Identifiable, Codable{
    
    var id: String = UUID().uuidString
    var name: String
    var datePeriod: String
    var askedGoalQuestions: String? = nil;
    var taskDescription: String? = nil;
    var parentID : String? = nil;
    var mainTaskID : String?
    var calendarIdentifier: String? = nil;
    var creationDate:Date = Date.now
    var deadline: Date
    var progress: CGFloat = 0.0
    var isCompleted: Bool = false
    var isSelected: Bool = false
    var showAcceptOrRejectButton = false
    var isLoading: Bool = false
    var hasAName: Bool = false
    var taskTypeID: Int
    var taskCategory: TaskCategory
    var taskPriority: TaskPriority;
    
    var taskType: TaskType {
        TaskType(rawValue: taskTypeID) ?? .day
    }
    
    var temporaryName: String? = nil
    var temporaryDescription: String? = nil
    
    static var getCodingKeys: [String]{
        var result: [String] = []
        for key in CodingKeys.allCases{
            result.append(key.stringValue)
        }
        return result
    }

    
    init(
        id: String = UUID().uuidString,
        name: String,
        datePeriod: String,
        askedGoalQuestions: String? = nil,
        taskDescription: String? = nil,
        parentID: String? = nil,
        mainTaskID: String? = nil,
        calendarIdentifier: String? = nil,
        creationDate: Date,
        deadline: Date,
        progress: CGFloat = 0.0,
        isCompleted: Bool = false,
        isSelected: Bool = false,
        hasAName: Bool = false,
        taskTypeID: Int,
        taskCategory: TaskCategory,
        taskPriority: TaskPriority
    ) {
        self.id = id
        self.name = name
        self.datePeriod = datePeriod
        self.askedGoalQuestions = askedGoalQuestions
        self.taskDescription = taskDescription
        self.parentID = parentID
        self.mainTaskID = mainTaskID
        self.calendarIdentifier = calendarIdentifier
        self.creationDate = creationDate
        self.deadline = deadline
        self.progress = progress
        self.isCompleted = isCompleted
        self.isSelected = isSelected
        self.hasAName = hasAName
        self.taskTypeID = taskTypeID
        self.taskCategory = taskCategory
        self.taskPriority = taskPriority
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case name
        case datePeriod
        case taskDescription
        case parentID
        case mainTaskID
        case calendarIdentifier
        case creationDate
        case deadline
        case progress
        case isCompleted
        case isSelected
        case taskTypeID
        case taskCategory
        case taskPriority
    }

    // Custom Decodable to avoid @Model synthesized properties and to handle enums via raw values
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let datePeriod = try container.decode(String.self, forKey: .datePeriod)
        let taskDescription = try container.decodeIfPresent(String.self, forKey: .taskDescription)
        let parentID = try container.decodeIfPresent(String.self, forKey: .parentID)
        let mainTaskID = try container.decodeIfPresent(String.self, forKey: .mainTaskID)
        let calendarIdentifier = try container.decodeIfPresent(String.self, forKey: .calendarIdentifier)
        let creationDate = try container.decode(Date.self, forKey: .creationDate)
        let deadline = try container.decode(Date.self, forKey: .deadline)
        let progress = try container.decodeIfPresent(CGFloat.self, forKey: .progress) ?? 0.0
        let isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        let isSelected = try container.decodeIfPresent(Bool.self, forKey: .isSelected) ?? false
        let taskTypeID = try container.decode(Int.self, forKey: .taskTypeID)

        // Decode enums from their raw values using the enum's RawValue type
        let taskCategoryRaw = try container.decode(TaskCategory.RawValue.self, forKey: .taskCategory)
        let taskPriorityRaw = try container.decode(TaskPriority.RawValue.self, forKey: .taskPriority)

        guard let taskCategory = TaskCategory(rawValue: taskCategoryRaw) else {
            throw DecodingError.dataCorruptedError(forKey: .taskCategory, in: container, debugDescription: "Invalid TaskCategory raw value: \(taskCategoryRaw)")
        }
        guard let taskPriority = TaskPriority(rawValue: taskPriorityRaw) else {
            throw DecodingError.dataCorruptedError(forKey: .taskPriority, in: container, debugDescription: "Invalid TaskPriority raw value: \(taskPriorityRaw)")
        }

        self.init(
            id: id,
            name: name,
            datePeriod: datePeriod,
            taskDescription: taskDescription,
            parentID: parentID,
            mainTaskID: mainTaskID,
            calendarIdentifier: calendarIdentifier,
            creationDate: creationDate,
            deadline: deadline,
            progress: progress,
            isCompleted: isCompleted,
            isSelected: isSelected,
            taskTypeID: taskTypeID,
            taskCategory: taskCategory,
            taskPriority: taskPriority
        )
    }

    // Custom Encodable to match the CodingKeys and avoid @Model internals
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(datePeriod, forKey: .datePeriod)
        try container.encodeIfPresent(taskDescription, forKey: .taskDescription)
        try container.encodeIfPresent(parentID, forKey: .parentID)
        try container.encodeIfPresent(mainTaskID, forKey: .mainTaskID)
        try container.encodeIfPresent(calendarIdentifier, forKey: .calendarIdentifier)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(deadline, forKey: .deadline)
        try container.encode(progress, forKey: .progress)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(isSelected, forKey: .isSelected)
        try container.encode(taskTypeID, forKey: .taskTypeID)
        try container.encode(taskCategory.rawValue, forKey: .taskCategory)
        try container.encode(taskPriority.rawValue, forKey: .taskPriority)
    }
}

extension TaskModel{
    var removeParentID: TaskModel{
        return TaskModel(
            id: self.id,
            name: self.name,
            datePeriod: self.datePeriod,
            taskDescription: self.taskDescription,
            parentID: nil,
            mainTaskID: self.mainTaskID,
            calendarIdentifier: self.calendarIdentifier,
            creationDate: self.creationDate,
            deadline: self.deadline,
            progress: self.progress,
            isCompleted: self.isCompleted,
            isSelected: self.isSelected,
            taskTypeID: self.taskTypeID,
            taskCategory: self.taskCategory,
            taskPriority: self.taskPriority
        )
    }
}
