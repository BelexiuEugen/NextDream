//
//  ExportViewModel.swift
//  NextDream
//
//  Created by Jan on 30/06/2025.
//

import Foundation
import SwiftData

@Observable
final class ExportViewModel{
    
    var tasks: [TaskModel] = []
    
    var taskToExport: [ItemDropdownSelection] = []
    var selectedType: ExportType = .JSON
    var isExporting: Bool = false;
    var exportedData: Data? = nil
    var modelContext: ModelContext
    
    var errorData: Data {
        // Example JSON data for export
        let dictionary = ["error": "something went wrong, try again."] as [String: Any]
        return try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
    }
    
    init(modelContext: ModelContext){
        self.modelContext = modelContext
    }
    
    func fetchMainTasks(){
        
        do{
            let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate { $0.parentID == nil})
            
            tasks = try modelContext.fetch(descriptor)
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
            print("No data presented");
            return }
        
        
        
        switch selectedType{
            
        case .JSON:
            exportedData = DataExportManager.shared.convertToJSON(tasks: taskData)
        case .CSV:
            exportedData = DataExportManager.shared.convertToCSV(tasks: taskData)
        case .PDF:
            exportedData = DataExportManager.shared.convertToPDF(tasks: taskData)
        default:
            exportedData = DataExportManager.shared.convertToJPG(tasks: taskData)
        }
        
        if exportedData != nil{
            isExporting = true
        }
        
    }
}
