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
        
        Task(priority: .high){
            await self.taskContainer.getTasks()
            taskContainer.taskAreLoading = false
        }
    }
    
    func refreshView() async{
        taskContainer.taskAreLoading = true
        self.taskContainer.items.removeAll()
        taskContainer.taskAreLoading = false
        await self.taskContainer.getTasks()
    }
    
    func createParentIDSet(items: [ItemDropdownModel]) -> Set<String>{
        var parentIDSet: Set<String> = Set<String>()
        
        for item in items {
            parentIDSet.insert(item.task.id)
        }
        
        return parentIDSet
    }
    
    func createTasksToExport(items: [ItemDropdownModel], parentIDSet: Set<String>) -> [TaskModel]{
        var taskToExport: [TaskModel] = []
        
        for item in items{
            guard let parentID = item.task.parentID else { taskToExport.append(item.task); continue }
            guard parentIDSet.contains(parentID) else { taskToExport.append(item.task.removeParentID); continue }
            
            taskToExport.append(item.task)
        }
        
        return taskToExport
    }
    
    func createSelectedItemsList() -> [ItemDropdownModel]{
        var items: [ItemDropdownModel] = []
        
        for (parentID, childrens) in self.taskContainer.items{
            for child in childrens where child.isSelected{
                items.append(child)
            }
        }
        
        return items
    }
    
    func exportData(){
        
        let items = createSelectedItemsList()

        let parentIDSet: Set<String> = createParentIDSet(items: items)

        let taskToExport: [TaskModel] = createTasksToExport(items: items, parentIDSet: parentIDSet)
        
        guard !taskToExport.isEmpty else {
            print("No data presented")
            return
        }
        
        do{
            switch selectedType{
                    
            case .JSON:
                exportedData = try JSONEncoder().encode(taskToExport)
            case .CSV:
                let encoder = CSVEncoder {
                    $0.headers = TaskModel.getCodingKeys
                }
                exportedData = try encoder.encode(taskToExport)
            }
        }catch{
            print("There was an error: \(error.localizedDescription)")
        }
        
        if exportedData != nil{
            isExporting = true
        }
        
    }
}
