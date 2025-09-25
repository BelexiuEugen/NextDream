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
    
    var taskToExport: [ItemDropdownSelection] = []
    var selectedType: ExportType = .JSON
    var isExporting: Bool = false;
    var exportedData: Data? = nil
    var modelContext: ModelContext

    var queryDescriptorManager: QueryDescriptorManager = QueryDescriptorManager()
    var taskRepository: TaskRepository
    
    var errorData: Data {
        let dictionary = ["error": "something went wrong, try again."] as [String: Any]
        return try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
    }
    
    init(modelContext: ModelContext, taskRepository: TaskRepository){
        self.modelContext = modelContext
        self.taskRepository = taskRepository
        self.fetchMainTasks()
        self.addTaskToExport()
    }
    
    func fetchMainTasks(){
        
        let descriptor = queryDescriptorManager.descriptorForMainTasks()
        
        do{
            tasks = try taskRepository.fetchTasks(descriptor: descriptor)
        } catch{
            print("There was an error \(error.localizedDescription)")
        }
    }
    
    func addTaskToExport(){
        
        taskToExport = tasks.map { task in
            ItemDropdownSelection(item: task, isSelected: false)
        }
    }
    
    func exportData(){
        
        let taskData: [TaskModel] = taskToExport.filter { $0.isSelected }.map { $0.item }
        
        guard !taskData.isEmpty else {
            print("No data presented")
            return
        }
        
        do{
            switch selectedType{
                
            case .JSON:
                exportedData = try JSONEncoder().encode(self.tasks)
            case .CSV:
                exportedData = try CSVEncoder().encode(self.tasks)
            }
        }catch{
            print("There was an error: \(error.localizedDescription)")
        }
        
        if exportedData != nil{
            isExporting = true
        }
        
    }
}
