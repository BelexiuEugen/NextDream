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
                TaskName
                
                TaskDescription
                
                DatePicker("Deadline", selection: $task.deadline).disabled(true)
                
                ColorPicker("Color", selection: $color)
                
                createTaskPriority
                
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
    
    let newTask = MockModels.firstModel
    NavigationStack{
        TaskSettingsView(task: newTask)
    }
}

extension TaskSettingsView{
    
    private var TaskName: some View {
        TextField("Task Name", text: $task.name)
            .font(.title)
            .fontWeight(.semibold)
            .padding()
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var TaskDescription: some View {
        TextField("Task Description", text: $details)
            .font(.caption)
            .fontWeight(.semibold)
            .padding()
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var createTaskPriority: some View {
        HStack{
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
