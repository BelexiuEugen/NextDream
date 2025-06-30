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
            .onDelete(perform: deleteTask)
        }
    }
}

#Preview {
//    TaskListingView(sort: .constant(SortDescriptor(\TaskModel.name)), searchString: .constant(""))
}

// MARK: Body
extension TaskListingView{
    
    private var createList: some View{
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
            .onDelete(perform: deleteTask)
        }
    }
    
    func createButton(task: TaskModel) -> some View{
        Button
        {
            deleteMainTask(task)
        } label: {
            Text("Delete")
                .font(.body)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(.red)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(width: 80, height: 50)
        .buttonStyle(.plain)
    }
}

//MARK: Functions.
extension TaskListingView{
    func deleteTask(_ indexSet: IndexSet){
        for index in indexSet{
        
            let item = viewModel.tasks[index]
            TaskViewModel.deleteTaskById(id: item.id, modelContext: modelContext)
            modelContext.delete(item)
            
            viewModel.saveDataToDevice()
            
            viewModel.tasks = viewModel.fetchTasksByParentID(parentID: nil);
            
            guard item.id != "" else {return}
            
        }
    }
    
    func deleteMainTask(_ itemToDelete : TaskModel){
        
        modelContext.delete(itemToDelete)
        
        viewModel.saveDataToDevice()
        
        guard itemToDelete.id != "" else {return}
        
    }
}
