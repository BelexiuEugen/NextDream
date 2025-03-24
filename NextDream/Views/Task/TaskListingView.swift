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
    @Environment(TaskViewModel.self) var vm;
    
    @State private var taskList: [TaskModel] = []
    
    var body: some View {
        
        createList()
            .onAppear{
                taskList = TaskViewModel.fetchTasksByParentID(parentID: nil, modelContext: modelContext)
            }
    }
    
//    init(sort: SortDescriptor<TaskModel>, serchString: String){
//        
//        _taskList = Query(filter: #Predicate{
//            if serchString.isEmpty
//            {
//                return true
//            }
//            else{
//                return $0.name.localizedStandardContains(serchString)
//            }
//        }, sort: [sort])
//    }
}

#Preview {
    TaskListingView(/*sort: SortDescriptor(\TaskModel.name), serchString: ""*/)
}

// MARK: Body
extension TaskListingView{
    
    func createList() -> some View{
        List{
            ForEach(taskList){ item in
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
        
            let item = taskList[index]
            TaskViewModel.deleteTaskById(id: item.id, modelContext: modelContext)
            modelContext.delete(item)
            
            vm.saveDataToDevice()
            
            taskList = TaskViewModel.fetchTasksByParentID(parentID: nil, modelContext: modelContext);
            
            guard item.id != "" else {return}
            
        }
    }
    
    func deleteMainTask(_ itemToDelete : TaskModel){
        
        modelContext.delete(itemToDelete)
        
        vm.saveDataToDevice()
        
        guard itemToDelete.id != "" else {return}
        
    }
}
