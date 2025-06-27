//
//  DashboardViewModel.swift
//  NextDream
//
//  Created by Jan on 27/06/2025.
//

import Foundation
import SwiftData

@Observable
final class DashboardViewModel{
    
    var tasks: [TaskModel] = []
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchTaskByDeadline(date: Date){
        
        let calendar = Calendar.current
        let startDate: Date? = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate ?? .now)
        
        guard let startDate = startDate, let endDate = endDate else { return }
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{ endDate > $0.deadline && $0.deadline >= startDate })
        
        do{
            tasks = try modelContext.fetch(descriptor)
        }catch{
            print("There was an error \(error.localizedDescription)")
        }
    }
}
