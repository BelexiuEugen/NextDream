//
//  TaskViewModel.swift
//  NextDream
//
//  Created by Jan on 01/07/2025.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
final class TaskViewModel{
    
    var tasks: [TaskModel] = []
    var task: TaskModel
    
    var newTaskName = ""
    var isEditing: Bool = true;
    var pdfURL: URL?
    
    var queryDescriptorManager: QueryDescriptorManager = QueryDescriptorManager()
    var taskRepository: TaskRepository
    var modelContext: ModelContext
    var exportManager: DataExportManager = DataExportManager.shared
    
    init(task: TaskModel, taskRepository: TaskRepository, modelContext: ModelContext){
        self.task = task
        self.taskRepository = taskRepository
        self.modelContext = modelContext
        self.fetchTaskByParentID(parentID: task.id)
    }
    
    func fetchTaskByParentID(parentID: String?){
        let descriptor = queryDescriptorManager.descriptorForParentID(parentID: parentID)
        do{
            tasks = try taskRepository.fetchTasks(descriptor: descriptor)
        } catch{
            print("Implement an error in here")
        }
    }
    
    func saveDataToDevice(){
        
        do{
            try modelContext.save()
            
        } catch{
            print("there was an error saving the task")
        }
    }
    
    func markTaskAsCompleted(task: TaskModel){
        
        task.isCompleted.toggle()
        
        saveDataToDevice()
        
    }
    
    func exportToPDFTree(){
        
        let taskDataForTree = TaskModelTreeData(id: task.id, title: task.name, isCompleted: task.isCompleted, deadline: task.deadline)
        
        if let url = pdfURL{
            exportManager.exportTaskTreePDF(to: url, root: taskDataForTree)
        }
    }
}

