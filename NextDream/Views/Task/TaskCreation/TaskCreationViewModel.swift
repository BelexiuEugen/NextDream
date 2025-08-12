//
//  TaskCreationViewModel.swift
//  NextDream
//
//  Created by Jan on 27/06/2025.
//

import Foundation
import SwiftUI

@Observable
final class TaskCreationViewModel{
    
    var taskToCalendar: [ItemDropdownSelection] = []
    var selectedCreationModel: CreationModelType = .calendar
    var selectedWeekFirstDay: Weekday = .monday
    var selectedPriority: TaskPriority = .low
    var selectedType: TaskType = .custom{
        didSet{
            updateSheetSize()
        } 
    }
    var showTask: Bool = false
    var startDate: Date = Date()
    var endDate: Date = Date()
    var numberOfYears = 1
    var numberOfDays = 1
    var isPresented: Bool = false;
    var numberOfMonths = 1
    var numberOfWeeks = 1
    var taskCreationManager: TaskCreation
    var sheetDetent: Binding<PresentationDetent>
    var isLoading: Binding<Bool>
    var path : NavigationViewModel
    
    init(taskCreationManager: TaskCreation,
         sheetDetent: Binding<PresentationDetent>,
         isLoading: Binding<Bool>,
         path: NavigationViewModel) {
        self.taskCreationManager = taskCreationManager
        self.sheetDetent = sheetDetent
        self.isLoading = isLoading
        self.path = path
    }
    
    
    func createTask(isLoading: Binding<Bool>, path: NavigationViewModel, dismiss: DismissAction){
        let taskData = createTask()

        isLoading.wrappedValue = true;
        
        Task{
            
            guard let
                    newTask = taskCreationManager.createTask(taskData: taskData, creationModelType: selectedCreationModel)
            else {return}
            path.modelView.append(newTask)
            isLoading.wrappedValue = false;
        }
        dismiss()
    }
    
    func createTask() -> TaskModelCreation{
        
        var monthDaysCount: Int = 28
        
        if selectedCreationModel == .calendar {
            let currentMonth = Months(date: startDate)
            monthDaysCount = currentMonth.calculateDaysCount(date: startDate)
        }
        
        if selectedType == .byDate{
            calculateComponents()
        }
        
        return TaskModelCreation(
            taskStartDate: startDate,
            weekDaysCount: 7,
            monthDaysCount: monthDaysCount,
            taskPriority: selectedPriority,
            taskType: selectedType,
            startWeekDay: selectedWeekFirstDay,
            numberOfYears: numberOfYears,
            numberOfMonths: numberOfMonths,
            numberOfWeeks: numberOfWeeks,
            numberOfDays: numberOfDays
        )
    }
    
    func calculateComponents(calendar: Calendar = .current){

        let components = calendar.dateComponents([.year, .month, .weekOfMonth, .day], from: startDate, to: endDate)

        if let years = components.year,
           let months = components.month,
           let weeks = components.weekOfMonth,
           let days = components.day {
            numberOfYears = years
            numberOfMonths = months
            numberOfWeeks = weeks
            numberOfDays = days
        }
    }
}

// MARK: UI Updates

extension TaskCreationViewModel{
    func updateWeeksAndMonths(){
        
        if numberOfWeeks >= 5{
            numberOfWeeks = 0;
            
            if(numberOfMonths < 12){
                numberOfMonths += 1;
            }
        }
    }
    
    func updateMonthsAndYears(){
        
        if numberOfMonths >= 12{
            numberOfMonths = 0
            
            if numberOfYears < 10{
                numberOfYears += 1;
            }
        }
    }
    
    func updateSheetSize(){
        if(selectedType == .custom){
            sheetDetent.wrappedValue = .medium
        }
        else{
            sheetDetent.wrappedValue = .fraction(0.4)
        }
    }
}
