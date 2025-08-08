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
    
    init(sort: Binding<SortDescriptor<TaskModel>>, searchString: Binding<String>, viewModel: Bindable<TaskDashboardViewModel>) {
        _viewModel = viewModel
        
        viewModel.wrappedValue.fetchTaskByDescriptorAndSearchString(sort: sort.wrappedValue, serchString: searchString.wrappedValue);
    }
    
    var body: some View {
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
    }
}

#Preview {
//    TaskListingView(sort: .constant(SortDescriptor(\TaskModel.name)), searchString: .constant(""))
}
