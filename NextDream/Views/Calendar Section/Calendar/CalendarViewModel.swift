//
//  CalendarViewModel.swift
//  NextDream
//
//  Created by Jan on 27/06/2025.
//

import Foundation
import SwiftData

@Observable
final class CalendarViewModel {
    
    var tasks: [TaskModel] = []
    
    var tasksForSelectedDate: [TaskModel] = []
    var selectedDate: Date = Date()
    var currentPage: Date = Date()
    var isPresented: Bool = false;
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchTaskByInterval(startDate: Date, endDate: Date){
        
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{endDate > $0.deadline && $0.deadline >= startDate})
        
        do{
            tasks = try modelContext.fetch(descriptor)
        } catch{
            print("There was an error \(error.localizedDescription)")
        }
    }
    
    func updateTasksForSelectedDate() {
        
        createMonthTask()
        
        tasksForSelectedDate = tasks
            .filter {
                Calendar.current.isDate(
                    $0.deadline,
                    inSameDayAs: selectedDate
                )
            }
    }
    
    func createMonthTask(){
        
        guard let startDate = Calendar.current.date(
            from: Calendar.current.dateComponents(
                [
                    .year,
                    .month
                ],
                from: currentPage
            )
        ) else {
            return
        }
        
        guard let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) else { return }
        
        fetchTaskByInterval(startDate: startDate, endDate: endDate)
    }
    
}
