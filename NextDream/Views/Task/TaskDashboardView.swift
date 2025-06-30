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
    
    @State private var vm: TaskViewModel;
    
    @State private var path: NavigationViewModel = NavigationViewModel()
    
    @State private var isLoading = false;
    @State private var searchText = ""
    @State private var isPresented: Bool = false;
    @State private var sheetDetent: PresentationDetent = .fraction(0.4)
    
    @State private var sortOrder = SortDescriptor(\TaskModel.name)
    
    init(modelContext: ModelContext){
        _vm = State(wrappedValue: TaskViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        
        @Bindable var vm = vm;
        
        if isLoading{
            FullScreenLoadingView(taskCompleted: $vm.taskCount)
        } else{
            
            NavigationStack(path: $path.modelView){
                TaskListingView(sort: $sortOrder, searchString:$searchText, viewModel: $vm)
                    .environment(vm)
                    .navigationTitle("Your Task")
                    .navigationDestination(for: TaskModel.self){ task in
                        TaskView(item: task, path: path)
                            .environment(vm)
                    }
                    .searchable(text: $searchText)
                    .toolbar{
                        
                        ToolbarItem(placement: .topBarLeading) {
                            
                            NavigationLink {
                                TaskExport()
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
            .sheet(isPresented: $isPresented){
                    
                    TaskMenu(
                        taskCreationManager: TaskCreationManager(
                            modelContext: modelContext
                        ),
                        path: path,
                        sheetDetent: $sheetDetent,
                        isLoading: $isLoading
                    )
                    .presentationDetents([.fraction(0.4), .medium, .large], selection: $sheetDetent)
            }
        }
    }
}


#Preview {
    HomeView()
}
