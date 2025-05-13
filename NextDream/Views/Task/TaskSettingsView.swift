//
//  TaskSettingsView.swift
//  NextDream
//
//  Created by Jan on 31/03/2025.
//

import SwiftUI

struct TaskSettingsView: View {
    
    @Bindable var task: TaskModel
    @State private var details: String = ""
    @State private var color: Color = .blue
    
    var body: some View {
        
        ScrollView{
            
            VStack{
                TaskName()
                
                TaskDescription()
                
                DatePicker("Deadline", selection: $task.deadline).disabled(true)
                
                ColorPicker("Color", selection: $color)
                
                createTaskPriority()
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(task.name)
        .onAppear{
            details = task.taskDescription ?? "No Description"
        }
        .onDisappear{
            task.taskDescription = details;
        }
    }
}

#Preview {
    
    let newTask = TaskModel(name: "Task Name", deadline: .now, taskType: .day, taskPriority: .high)
    NavigationStack{
        TaskSettingsView(task: newTask)
    }
}

extension TaskSettingsView{
    
    fileprivate func TaskName() -> some View {
        return TextField("Task Name", text: $task.name)
            .font(.title)
            .fontWeight(.semibold)
            .padding()
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    fileprivate func TaskDescription() -> some View {
        return TextField("Task Description", text: $details)
            .font(.caption)
            .fontWeight(.semibold)
            .padding()
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    fileprivate func createTaskPriority() -> some View {
        return HStack{
            Text("Priority Level: ")
            
            Picker("Priority", selection: $task.taskPriority){
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    HStack{
                        Circle()
                            .frame(width: 20, height: 20)
                        Text(priority.rawValue)
                    }
                    .tag(priority);
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical)
    }
}
