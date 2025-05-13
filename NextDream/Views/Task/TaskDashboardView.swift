//
//  TaskView.swift
//  Next Step
//
//  Created by Jan on 29/11/2024.
//

import SwiftUI
import SwiftData



struct TaskDashboardView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(TaskViewModel.self) var vm;
    
    @State private var path: NavigationViewModel = NavigationViewModel()
    
    @State private var isLoading = false;
    @State private var searchText = ""
    @State private var isPresented: Bool = false;
    @State private var sheetDetent: PresentationDetent = .fraction(0.4)
    
    @State private var sortOrder = SortDescriptor(\TaskModel.name)
    
    var body: some View {
        
        @Bindable var vm = vm;
        
        if isLoading{
            FullScreenLoadingView(taskCompleted: $vm.taskCount)
        } else{
            
            NavigationStack(path: $path.modelView){
                TaskListingView(sort: $sortOrder, searchString:$searchText)
                    .navigationTitle("Your Task")
                    .navigationDestination(for: TaskModel.self){ task in
                        TaskView(item: task, path: path)
                    }
                    .searchable(text: $searchText)
                    .toolbar{
                        
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
//                                vm.deleteAllTask(with: modelContext);
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                            
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add destination", systemImage: "plus")
                            {
                                isPresented.toggle()
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu("Sort", systemImage: "slider.horizontal.3"){
                                Picker("Sort", selection: $sortOrder){
                                    Text("Name")
                                        .tag(SortDescriptor(\TaskModel.name))
                                    
                                    Text("Dead Line")
                                        .tag(SortDescriptor(\TaskModel.deadline))
                                    
                                    Text("Progress")
                                        .tag(SortDescriptor(\TaskModel.progress))
                                    
                                }
                                .pickerStyle(.inline)
                            }
                        }
                    }
            }
            .sheet(isPresented: $isPresented, content: {
                TaskMenu(path: path, sheetDetent: $sheetDetent, isLoading: $isLoading)
                    .presentationDetents([.fraction(0.4), .medium, .large], selection: $sheetDetent)
            })
        }
    }
}


#Preview {
    TaskDashboardView()
        .environment(TaskViewModel())
}

// MARK: Body
extension TaskDashboardView{

}

// MARK: Functions
extension TaskDashboardView{
    
    func addTask() {
        
        let taskModel = TaskModel(name: "", deadline: .now + 3600, taskType: TaskType.day, taskPriority: .low)
        
//        let task = TaskViewModel(task: taskModel)
        modelContext.insert(taskModel)
        
        vm.saveDataToDevice()
        
        withAnimation {
            path.modelView.append(taskModel) // Add task to the navigation stack
        }
    }
}
