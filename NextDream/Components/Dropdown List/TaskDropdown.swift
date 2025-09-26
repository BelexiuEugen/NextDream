//
//  TaskDropdown.swift
//  NextDream
//
//  Created by Jan on 14/05/2025.
//

import SwiftUI

struct TaskDropdown: View {
    
    @Bindable var taskToExport: ItemDropdownContainer
    
    var body: some View {
        List{
            ForEach(taskToExport.items.filter { $0.task.parentID == nil}) { item in
                
                TaskRow(item: item, container: taskToExport)
                
                if item.showChildren {
                    SubTaskRegion(allTasks: taskToExport, level: 1, parentID: item.task.id)
                }
            }
        }
    }
}

struct SubTaskRegion: View {
    
    @Bindable var allTasks: ItemDropdownContainer
    var level: Int = 1
    var parentID: String
    
    init(allTasks: ItemDropdownContainer, level: Int, parentID: String) {
        self.allTasks = allTasks
        self.level = level
        self.parentID = parentID
    }
    
    var body: some View {
        ForEach(allTasks.items.filter({$0.task.parentID == parentID})) { item in
            TaskRow(item: item, container: allTasks)
            
            if item.showChildren {
                SubTaskRegion(allTasks: allTasks, level: level + 1, parentID: item.task.id)
            }
        }
        .padding(.leading, CGFloat(15 * level))
    }
}

#Preview {
    
    let taskContainer = ItemDropdownContainer( defaultTaskRepository: DefaultTaskRepository(modelContext: MockModels.container.mainContext))
    
    TaskDropdown(taskToExport: taskContainer)
}
