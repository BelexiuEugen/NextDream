//
//  TaskDropdown.swift
//  NextDream
//
//  Created by Jan on 14/05/2025.
//

import SwiftUI

struct TaskDropdown: View {
    
    @Bindable var container: ItemDropdownContainer
    
    var body: some View {
        List{
            ForEach(container.items["nil"] ?? []) { item in
                
                TaskRow(item: item, container: container)
                
                if item.showChildren {
                    SubTaskRegion(container: container, parentID: item.task.id)
                }
            }
        }
    }
}

struct SubTaskRegion: View {
    
    @Bindable var container: ItemDropdownContainer
    var level: Int
    var parentID: String
    
    init(container: ItemDropdownContainer, level: Int = 1, parentID: String) {
        self.container = container
        self.level = level
        self.parentID = parentID
    }
    
    var body: some View {
        ForEach(container.items[parentID] ?? []) { item in
            TaskRow(item: item, container: container)
            
            if item.showChildren {
                SubTaskRegion(container: container, level: level + 1, parentID: item.task.id)
            }
        }
        .padding(.leading, CGFloat(15 * level))
    }
}

#Preview {
    
    let container = ItemDropdownContainer( defaultTaskRepository: DefaultTaskRepository(modelContext: MockModels.container.mainContext))
    
    TaskDropdown(container: container)
}
