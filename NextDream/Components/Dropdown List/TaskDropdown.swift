//
//  TaskDropdown.swift
//  NextDream
//
//  Created by Jan on 14/05/2025.
//

import SwiftUI

struct TaskDropdown: View {
    
    @Binding var taskToExport: [ItemDropdownSelection];
    
    var body: some View {
        List{
            ForEach(taskToExport) { task in
                
                HStack{
                    
                    Text(task.item.name)
                    
                    Spacer()
                    
                    Image(systemName: task.isSelected ? "checkmark.square.fill" : "square.dashed")
                }
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture {
                    task.isSelected.toggle()
                }
            }
        }
    }
}

#Preview {
    
    let firstTask = TaskModel(name: "Example", deadline: .now, taskType: .day, taskPriority: .low)
    
    var taskToExport: [ItemDropdownSelection] = [
        ItemDropdownSelection(item: firstTask, isSelected: false)
    ];
    
    TaskDropdown(taskToExport: .constant(taskToExport))
        .environment(TaskViewModel())
}
