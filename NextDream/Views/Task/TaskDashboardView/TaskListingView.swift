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
    
    @Environment(\.modelContext) var modelContext
    
    @Bindable var viewModel: TaskViewModel
    @Binding var sort: SortDescriptor<TaskModel>;
    @Binding var searchString: String;
    
    init(sort: Binding<SortDescriptor<TaskModel>>, searchString: Binding<String>, viewModel: Bindable<TaskViewModel>) {
        _sort = sort
        _searchString = searchString
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
