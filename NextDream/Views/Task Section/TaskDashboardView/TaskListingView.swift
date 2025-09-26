//
//  TaskListingView.swift
//  Next Step
//
//  Created by Jan on 03/12/2024.
//

// Change typo serchString

import SwiftUI
import SwiftData

struct TaskListingView: View {
    
    @Bindable var viewModel: TaskDashboardViewModel
    
    init(viewModel: Bindable<TaskDashboardViewModel>) {
        _viewModel = viewModel
        
        _viewModel.wrappedValue.fetchTaskByDescriptorAndSearchString()
    }
    
    var body: some View {
        
        if viewModel.isLoadingForDeletion{
            FullScreenLoadingView(taskCompleted: $viewModel.deletedTask, text: "Deleted Task: ")
        } else {
            
            List{
                ForEach(viewModel.tasks){ item in
                    HStack{
                        NavigationLink(value: item){
                            VStack(alignment: .leading){
                                Text(item.name)
                                    .font(.headline)
                                
                                Text(item.deadline.formatted(date: .long, time: .shortened))
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .onDelete(perform: viewModel.deleteTask)
            }
            .refreshable {
                viewModel.fetchTaskByDescriptorAndSearchString()
            }
        }
    }
}

#Preview {
//    TaskListingView(sort: .constant(SortDescriptor(\TaskModel.name)), searchString: .constant(""))
}
