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
    var isPresented: Bool = false;
    var modelContext: ModelContext
    
    var selectedDate: Date = Date(){
        didSet{
            self.updateTasksForSelectedDate()
        }
    }
    var currentPage: Date = Date(){
        didSet{
            self.createMonthTask()
        }
    }
    
    var queryDescriptorManager: QueryDescriptorManager = QueryDescriptorManager()
    var taskRepository: TaskRepository
    
    init(modelContext: ModelContext, taskRepository: TaskRepository) {
        self.modelContext = modelContext
        self.taskRepository = taskRepository
        self.updateTasksForSelectedDate()
    }
    
    func fetchTaskByInterval(startDate: Date, endDate: Date){
        let descriptor = queryDescriptorManager.fetchTaskByInterval(startDate: startDate, endDate: endDate)
        do {
            tasks = try taskRepository.fetchTasks(descriptor: descriptor)
        } catch{
            print("Implement an error in here")
        }
    }
    
    func updateTasksForSelectedDate() {
        createMonthTask()
        tasksForSelectedDate = tasks.filter { Calendar.current.isDate( $0.deadline, inSameDayAs: selectedDate) }
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
