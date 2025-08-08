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
        Form{
            createTaskSection
            createSubTaskSection
        }
        .navigationTitle(vm.task.name)
        .frame(minWidth: 300, idealWidth: 400, maxWidth: 500)
        .toolbar {
            settingsButton
        }
    }
}

#Preview {
    do{
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        let container = try ModelContainer(for: TaskModel.self, configurations: config)
        
        let taskModel = TaskModel(name: "Test", deadline: .now + 3600, taskType: TaskType.day, taskPriority: .low)
        
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
        
        Section("Sub Task") {
            List{
                ForEach(vm.tasks){ subTask in
                    NavigationLink(value: subTask){
                        Text(subTask.name)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button("Complete"){
                                    vm.markTaskAsCompleted(task: subTask)
                                }
                                .tint(.green)
                            }
                    }
                }
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
}
