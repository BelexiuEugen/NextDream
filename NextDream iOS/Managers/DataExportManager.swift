//
//  DataExportManager.swift
//  NextDream
//
//  Created by Jan on 14/05/2025.
//

import SwiftUI

class DataExportManager{
    
    static let shared = DataExportManager()
    
    private init(){}

    
    func convertToJSON(tasks: [TaskModel]) -> Data?{
        
        let newTasksArray = TaskDashboardViewModel.asDictionaryList(tasks: tasks)
        
        return try? JSONSerialization.data(withJSONObject: newTasksArray, options: .prettyPrinted)
    }
    
    func convertToCSV(tasks: [TaskModel]) -> Data?{
        
        let newTasksArray = TaskDashboardViewModel.asDictionaryList(tasks: tasks)
        
        let headers = Array(newTasksArray[0].keys)
        var csvString = headers.joined(separator: ",") + "\n"
        
        for dict in newTasksArray {
                let row = headers.map { key in
                    if let value = dict[key] {
                        return "\"\(value)\""
                    } else {
                        return ""
                    }
                }.joined(separator: ",")
                csvString += row + "\n"
            }
        
        print(csvString);

        // Convert the CSV string to Data using UTF-8 encoding
        return csvString.data(using: .utf8)
    }
    
    func convertToPDF(tasks: [TaskModel]) -> Data?{
        return nil;
    }
    
    func convertToJPG(tasks: [TaskModel]) -> Data?{
        return nil;
    }
}
