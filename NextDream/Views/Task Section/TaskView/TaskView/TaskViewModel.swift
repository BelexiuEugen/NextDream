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
    
    func getOtherTasksName(except: TaskModel) -> String{
        var result: String = ""
        
        for task in self.tasks{
            if task == except{
                result += "This is the main task:"
            }
            result += task.name + " " + task.datePeriod + ", "
        }
        
        return result
    }
    
    func GeneratedDataForATask(selectedTask: TaskModel) async {
        
        let otherTasksName: String = getOtherTasksName(except: selectedTask)
        
        let result = await gemini
            .generateSubTask(
                goalName: task.name,
                goalQuestion: task.askedGoalQuestions ?? "No question asked",
                goalDescription: task.taskDescription ?? "No responses",
                otherTaskName: otherTasksName,
                mainParentType: task.taskType,
                childrenTaskType: selectedTask.taskType
            )
        
        selectedTask.temporaryName = result.name
        selectedTask.temporaryDescription = result.description
        selectedTask.showAcceptOrRejectButton = true
    }
    
    func generateSubTasksInformation() -> String{
        var result: String = ""
        
        for task in self.tasks{
            result += task.creationDate.convertToDayAndMonth() + "+"
            result += task.deadline.convertToDayAndMonth() + "+"
            result += task.taskType.displayName + ","
        }
        
        return result
    }
    
    func generateDataForSubTasks() async{
        
        self.isLoading = true
        let taskData = generateSubTasksInformation()
        
        let data = await gemini.generateSubTasks(
            goalName: task.name,
            goalQuesetion: task.askedGoalQuestions ?? "No question asked",
            goalDescription: task.taskDescription ?? "No description Added",
            numberOfSubTasks: tasks.count,
            taskData: taskData,
            taskType: task.taskType
        )
        
        for (index, taskData) in data.enumerated(){
            
            if index >= tasks.count || (index == 13 && task.taskType == .year) { continue }
            
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
        task.hasAName = true
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

