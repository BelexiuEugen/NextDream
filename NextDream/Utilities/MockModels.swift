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
        taskType: .year,
        taskCategory: .hobbies,
        taskPriority: .high
    )
    
    static var container = try! ModelContainer(
            for: TaskModel.self, // add any @Model types your manager needs
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
}
