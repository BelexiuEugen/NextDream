//
//  MockModels.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 14.09.2025.
//

import Foundation
import SwiftData

struct MockModels {
    static var firstModel = TaskModel(
        id: UUID().uuidString,
        name: "Mock Task",
        creationDate: .now,
        deadline: .distantFuture,
        progress: .pi,
        isCompleted: false,
        isSelected: false,
        taskTypeID: 1,
        taskCategory: .hobbies,
        taskPriority: .high
    )
    
    static var container = try! ModelContainer(
            for: TaskModel.self, // add any @Model types your manager needs
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    static let mockSubTasks: [TaskModel] = [
        firstModel,
        firstModel,
        firstModel,
        firstModel,
        firstModel,
        firstModel,
    ]
    static let allTasks: [(date: Date, count: Int)] = [
        (Date().addingTimeInterval(-5*86400), 5),
        (Date().addingTimeInterval(-4*86400), 8),
        (Date().addingTimeInterval(-3*86400), 6),
        (Date().addingTimeInterval(-2*86400), 10),
        (Date().addingTimeInterval(-1*86400), 7),
        (Date(), 9)
    ]

    static let completedTasks: [(date: Date, count: Int)] = [
        (Date().addingTimeInterval(-5*86400), 2),
        (Date().addingTimeInterval(-4*86400), 4),
        (Date().addingTimeInterval(-3*86400), 3),
        (Date().addingTimeInterval(-2*86400), 6),
        (Date().addingTimeInterval(-1*86400), 5),
        (Date(), 7)
    ]
}
