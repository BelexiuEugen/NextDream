//
//  addTaskView.swift
//  Next Step
//
//  Created by Jan on 03/12/2024.
//

import SwiftUI
import SwiftData

struct TaskView: View {

    @State private var vm: TaskViewModel
    
    init(taskRepository: TaskRepository, modelContext: ModelContext, task: TaskModel, path: NavigationViewModel){
        _vm = State(wrappedValue: TaskViewModel(task: task, taskRepository: taskRepository, modelContext: modelContext))
    }
    
    var body: some View {
        
        VStack{
            
            Form{
                createTaskSection
                
                createSubTaskSection
                
            }
            
        }
        .navigationTitle(vm.task.name)
        .frame(minWidth: 300, idealWidth: 400, maxWidth: 500)
        .toolbar {

            if vm.task.mainTaskID == nil{
                statsButton
            }
            settingsButton
        }
    }
}

#Preview {
    do{
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        let container = try ModelContainer(for: TaskModel.self, configurations: config)
        
        let taskModel = MockModels.firstModel
        
        let pathExample = NavigationViewModel()
        
        return NavigationStack {
            TaskView(taskRepository: DefaultTaskRepository(modelContext: container.mainContext), modelContext: container.mainContext, task: taskModel, path: pathExample)
                .modelContainer(container)
        }
        
    }catch{
        fatalError("Something wrong")
    }
}

// MARK: Body
extension TaskView{
    
    private var createTaskSection: some View{
        Group{
            Text(vm.task.name)
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(vm.task.taskDescription ?? "No Description")
                .foregroundColor(.primary)
            
            HStack{
                Text("Deadline:")
                Spacer()
                Text(vm.task.deadline.showDate())
            }
        }
    }
    
    private var createSubTaskSection: some View{
        Section {
            if vm.isLoading{
                ProgressView()
            } else {
                List{
                    ForEach(vm.tasks){ subTask in
                        HStack{
                            
                            HStack{
                                Image(systemName: "sparkles")
                                    .foregroundStyle(
                                        LinearGradient(colors: [.purple, .blue],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                    )
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .background(.thickMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        subTask.showAcceptOrRejectButton.toggle()
                                        print("Generating code ...")
                                    }
                                
                            }
                            
                            NavigationLink(value: subTask){
                                Text(subTask.temporaryName ?? subTask.name)
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button("Complete"){
                                            vm.markTaskAsCompleted(task: subTask)
                                        }
                                        .tint(.green)
                                    }
                            }
                            
                            if subTask.showAcceptOrRejectButton{
                                
                                Image(systemName: "checkmark.square.fill")
                                    .foregroundStyle(.green)
                                    .background(.white)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .onTapGesture {
                                        vm.modifyTaskNameAndDescription(task: subTask)
                                    }
                                
                                Image(systemName: "xmark.square.fill")
                                    .foregroundStyle(.red)
                                    .background(.white)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .onTapGesture {
                                        vm.cancelChanges(task: subTask)
                                    }
                            }
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text("Sub Task")
                
                Spacer()
                Button {
                    Task{
                        await vm.generateDataForSubTasks()
                    }
                } label: {
                    Text("Generate With AI")
                        .font(.body)
                        .fontWeight(.semibold)
                }
                .padding()
                .background(.purple)
                .foregroundColor(.primary)
                .cornerRadius(16)
            }
        }
    }
    
    private var settingsButton: ToolbarItem<Void, some View>{
        ToolbarItem(placement: .topBarTrailing) {
            
            NavigationLink {
                TaskSettingsView(task: vm.task)
            } label: {
                Image(systemName: "gear")
            }
        }
    }
    
    private var statsButton: ToolbarItem<Void, some View>{
        ToolbarItem(placement: .topBarTrailing){
            NavigationLink{
                TaskStatisticView(modelContext: vm.modelContext, taskID: vm.task.id, taskStartDate: vm.task.creationDate)
            } label: {
                Image(systemName: "chart.bar")
            }
        }
    }
    
    private var pdfExporter: ToolbarItem<Void, some View>{
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink{
                TaskStatisticView(modelContext: vm.modelContext, taskID: vm.task.id, taskStartDate: vm.task.creationDate)
            } label: {
                Image(systemName: "doc.text")
            }
        }
    }
}
