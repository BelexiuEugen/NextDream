//
//  addTaskView.swift
//  Next Step
//
//  Created by Jan on 03/12/2024.
//

import SwiftUI
import SwiftData

struct TaskView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(TaskViewModel.self) var vm
    @State var eventManager: EventManager = EventManager()
    
    @Bindable var item : TaskModel
    @Bindable var path : NavigationViewModel
    @State private var newTaskName = ""
    @State private var isEditing: Bool = true;
    
    @State private var name: String = "";
    @State private var description: String = "";
    @State private var creation: Date = .now;
    @State private var deadline: Date = .now;
    
    var body: some View {
        
        Form{
            TextField("Task Name", text: $name)
                .disabled(isEditing)
//                .background(isEditing ? Color.clear : Color.gray.opacity(0.2))
                .foregroundColor(isEditing ? .gray : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            TextField("Details", text: $description)
                .disabled(isEditing)
                .foregroundColor(isEditing ? .gray : .primary)
            
//            DatePicker("Creation", selection: $creation)
//                .disabled(isEditing)
//                .foregroundStyle(isEditing ? .gray : .primary);
            
            DatePicker("deadline", selection: $deadline)
                .disabled(isEditing)
                .foregroundColor(isEditing ? .gray : .primary)
            
            //                createProgressView()
            //                .padding(.bottom, 16)
            
            
                            createTaskSection()
        }
        .navigationTitle(item.name)
        .frame(minWidth: 300, idealWidth: 400, maxWidth: 500)
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing) {
                
                Button {
                    isEditing.toggle()
                    
                    if isEditing
                    {
                        if checkForDifference(){
                            
                            if let identifier = item.calendarIdentifier{
                                if modifyEvent(identifier: identifier){
                                    print("The task was updated in the database.");
                                }
                            }
                            
                            item.name = name;
                            item.taskDescription = description;
                            item.deadline = deadline;
                            
                            vm.saveDataToDevice()
                        }
                    }
                    
                } label: {
                    Image(systemName: isEditing ? "square.and.pencil" : "checkmark.circle")
                }
                
            }
        }
        .onDisappear(){
            if(item.name.isEmpty){
                modelContext.delete(item) // Remove from database context
                path.modelView.removeAll { $0 == item }
            }
        }
        .onAppear(){
            name = item.name;
            description = item.taskDescription ?? "";
            creation = item.creationDate;
            deadline = item.deadline;
            vm.task = TaskViewModel.fetchTasksByParentID(parentID: item.id, modelContext: modelContext)
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
            TaskView(item: taskModel, path: pathExample)
                .modelContainer(container)
        }
        
    }catch{
        fatalError("Something wrong")
    }
}

extension TaskView{
    
    func checkForDifference() -> Bool{
        
        guard
            item.name == name,
            item.taskDescription == description,
            item.deadline == deadline
        else {return true}
        
        return false;
    }
    
    func modifyEvent(identifier: String) -> Bool{
        
        return eventManager.modifyEvent(eventIdentifier: identifier, name: name, description: description, deadline: deadline)
    }
}


// MARK: Body
extension TaskView{
    
    //    func createProgressView() -> some View{
    //        VStack(alignment: .leading, spacing: 8) {
    //            ProgressView(value: HelperClass.calculateProgress(task: task))
    //                .progressViewStyle(LinearProgressViewStyle())
    //
    //            Text("\(Int(HelperClass.calculateProgress(task: task) * 100))%") // Show percentage
    //                .font(.caption)
    //                .foregroundColor(.gray)
    //        }
    //    }
    
    func createTaskSection() -> some View{
        
        
        Section("Sub Task") {
            List{
                ForEach(vm.task){ subTask in
                    NavigationLink(value: subTask){
                        Text(subTask.name)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button("Complete"){
                                    //                                markTaskAsCompleted(task: subTask)
                                }
                                .tint(.green)
                            }
                    }
                }
            }
        }
    }
}

// MARK: Functions

extension TaskView{
    
//    func markTaskAsCompleted(task: TaskModel){
//        
//        task.isCompleted.toggle()
//        
//        TaskModel.saveDataToDevice(with: modelContext)
//        
//    }
    
//    func addTask(){
//        
//        guard newTaskName.isEmpty == false else {return}
//        
//        let newTask = TaskModel(taskName: newTaskName, isMain: false)
//        
//        task.subTasks.append(newTask)
//        
//        newTaskName = ""
//        
//        path.path.append(newTask)
//        
//        TaskModel.saveDataToDevice(with: modelContext)
//        
//        
//    }
//    
//    func deleteTask(_ indexSet: IndexSet){
//        for index in indexSet{
//            let task = taskList[index]
//            modelContext.delete(task)
//            
//            TaskModel.saveDataToDevice(with: modelContext)
//        }
//    }

}
