//
//  ExportViewModel.swift
//  NextDream
//
//  Created by Jan on 30/06/2025.
//

import Foundation
import SwiftData
import CodableCSV

@Observable
final class ExportViewModel{
    
    var tasks: [TaskModel] = []
    
    var taskToExport: [ItemDropdownModel] = []
    var selectedType: ExportType = .JSON
    var isExporting: Bool = false;
    var exportedData: Data? = nil
    var modelContext: ModelContext

    var queryDescriptorManager: QueryDescriptorManager = QueryDescriptorManager()
    var taskRepository: TaskRepository
    var taskContainer: ItemDropdownContainer
    
    var errorData: Data {
        let dictionary = ["error": "something went wrong, try again."] as [String: Any]
        return try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
    }
    
    init(modelContext: ModelContext, taskRepository: TaskRepository){
        self.modelContext = modelContext
        self.taskRepository = taskRepository
        self.taskContainer = ItemDropdownContainer(defaultTaskRepository: taskRepository)
        self.fetchMainTasks()
        self.addTaskToExport()
    }
    
    func fetchMainTasks(){
        tasks = []
        let descriptor = queryDescriptorManager.descriptorForMainTasks()
        
        tasks = taskRepository.fetchTasks(descriptor: descriptor)
    }
    
    func addTaskToExport(){
        
        taskToExport = tasks.map { task in
            ItemDropdownModel(task: task, isSelected: false)
        }
    }
    
    func loadAllSubTasks(parentID: String){
        let descriptor = queryDescriptorManager.descriptorForParentID(parentID: parentID)
        
        let subTasks: [TaskModel] =  taskRepository.fetchTasks(descriptor: descriptor)
        for task in subTasks{
            tasks.append(task)
            loadAllSubTasks(parentID: task.id)
        }
    }
    
    func exportData(){
        
        let taskData: [TaskModel] = taskToExport.filter { $0.isSelected }.map { $0.task }
        
        for task in taskData{
            loadAllSubTasks(parentID: task.id)
        }
        
        guard !taskData.isEmpty else {
            print("No data presented")
            return
        }
        
        do{
            switch selectedType{
                    
            case .JSON:
                exportedData = try JSONEncoder().encode(self.tasks)
            case .CSV:
                let encoder = CSVEncoder {
                    $0.headers = TaskModel.getCodingKeys
                }
                exportedData = try encoder.encode(self.tasks)
            }
        }catch{
            print("There was an error: \(error.localizedDescription)")
        }
        
        if exportedData != nil{
            isExporting = true
        }
        
    }
}
