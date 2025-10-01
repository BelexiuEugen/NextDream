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
    var isLoading: Bool = false;
    
    var queryDescriptorManager: QueryDescriptorManager = QueryDescriptorManager()
    var taskRepository: TaskRepository
    var modelContext: ModelContext
    var gemini: GeminiAIManager = GeminiAIManager()
    
    
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
    
    func generateDataForSubTasks() async{
        
        self.isLoading = true
        
        let data = await gemini.generateSubTasks(
            goalName: task.name,
            goalQuesetion: task.askedGoalQuestions ?? "No question asked",
            goalDescription: task.taskDescription ?? "No description Added",
            numberOfSubTasks: tasks.count,
            taskType: task.taskType
        )
        
        for (index, taskData) in data.enumerated(){
            self.tasks[index].temporaryName = taskData.name
            self.tasks[index].temporaryDescription = taskData.description
            self.tasks[index].showAcceptOrRejectButton = true
        }
        
        self.isLoading = false
    }
    
    func modifyTaskNameAndDescription(task: TaskModel){
        task.name = task.temporaryName ?? "No Name provided"
        task.taskDescription = task.temporaryDescription
        task.showAcceptOrRejectButton = false
        task.temporaryName = nil
        task.temporaryDescription = nil
    }
    
    func cancelChanges(task: TaskModel){
        task.temporaryName = nil
        task.temporaryDescription = nil
        task.showAcceptOrRejectButton = false
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
}

