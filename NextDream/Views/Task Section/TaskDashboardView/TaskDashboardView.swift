//
//  TaskView.swift
//  Next Step
//
//  Created by Jan on 29/11/2024.
//

import SwiftUI
import SwiftData



struct TaskDashboardView: View {
    
    @State private var vm: TaskDashboardViewModel;
    
    init(modelContext: ModelContext, taskRepository: TaskRepository, taskCreationManager: TaskCreation){
        _vm = State(
            wrappedValue: TaskDashboardViewModel(
                modelContext: modelContext,
                taskRepository: taskRepository,
                taskCreationManager: taskCreationManager
            )
        )
    }
    
    var body: some View {
        
        @Bindable var vm = vm;
        
        if vm.isLoading{
            FullScreenLoadingView(taskCompleted: $vm.taskCreationManager.taskCount, text: "Task Created: ")
        } else{
            
            NavigationStack(path: $vm.path.modelView){
                TaskListingView(viewModel: $vm)
                    .environment(vm)
                    .navigationTitle("Your Task")
                    .navigationDestination(for: TaskModel.self){ task in
                        TaskView(taskRepository: vm.taskRepository, modelContext: vm.modelContext, task: task, path: vm.path)
                    }
                    .searchable(text: $vm.searchText)
                    .toolbar{
                        exportButton
                        newTaskButton
                        filterButton
                    }
            }
            .sheet(isPresented: $vm.isPresented){
                    
                    TaskCreationView(
                        taskCreationManager: vm.taskCreationManager,
                        path: vm.path,
                        sheetDetent: $vm.sheetDetent,
                        isLoading: $vm.isLoading,
                    )
                    .presentationDetents([.fraction(0.4), .medium, .large], selection: $vm.sheetDetent)
            }
        }
    }
}


#Preview {
    HomeView()
}

extension TaskDashboardView{
    private var exportButton: ToolbarItem<Void, some View>{
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink {
                ExportView(modelContext: vm.modelContext, taskRepository: vm.taskRepository)
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
    }
    
    private var newTaskButton: ToolbarItem<Void, some View>{
        ToolbarItem(placement: .topBarTrailing) {
            Button("Add destination", systemImage: "plus")
            {
                vm.isPresented.toggle()
            }
        }
    }
    
    private var filterButton: ToolbarItem<Void, some View>{
        ToolbarItem(placement: .topBarTrailing) {
            Menu("Sort", systemImage: "slider.horizontal.3"){
                Picker("Sort", selection: $vm.sortOrder){
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
