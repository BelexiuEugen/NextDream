//
//  TaskRow.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 26.09.2025.
//

import SwiftUI

struct TaskRow: View {
    
    @Bindable var item: ItemDropdownModel;
    @Bindable var container: ItemDropdownContainer;
    
    var body: some View {
        HStack {
            checkMarkButton
            
            nameAndArrow
        }
    }
}

extension TaskRow{
    private var checkMarkButton: some View{
        Image(systemName: item.isSelected ? "checkmark.square.fill" : "square.dashed")
            .onTapGesture {
                item.isSelected.toggle()
                Task(priority: .high) {
                    await container.markChildrenAsFather(parentID: item.task.id, isSelected: item.isSelected)
                }
            }
    }
    
    private var nameAndArrow: some View{
        HStack{
            
            Text(item.task.name)
            
            Spacer()
            
            if item.task.taskType != .day{
                Image(systemName: "arrow.right")
                    .rotationEffect(.degrees(item.showChildren ? 90 : 0))
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            if item.task.taskType != .day{
                withAnimation(.easeInOut) {
                    item.showChildren.toggle()
                }
            }
        }
    }
}

//#Preview {
//    TaskRow(item: ItemDropdownModel(task: MockModels.firstModel, isSelected: true, showChildren: false), container: <#ItemDropdownContainer#>)
//}
