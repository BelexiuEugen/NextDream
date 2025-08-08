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
    var selectedPriority: TaskPriority = .low
    var selectedOption: TaskType = .custom{
        didSet{
            updateSheetSize()
        }
    }
    var showTask: Bool = false
    var startDate: Date = Date()
    var numberOfYears = 1
    var numberOfDays = 1
    var isPresented: Bool = false;
    var numberOfMonths = 1 {
        didSet {updateMonthsAndYears()}
    }
    var numberOfWeeks = 1{
        didSet {updateWeeksAndMonths()}
    }
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
        
        let taskData = TaskModelCreationData(
            name: "Your Task Name",
            parentID: nil,
            taskStartDate: startDate,
            numberOfYears: numberOfYears,
            numberOfMonths: numberOfMonths,
            numberOfWeeks: numberOfWeeks,
            numberOfDays: numberOfDays,
            taskPriority: selectedPriority,
            taskType: selectedOption,
            startWeekday: .monday,
            currentMonth: .january
        )
        
        
        isLoading.wrappedValue = true;
        
        Task{
            
            guard let
                    newTask = taskCreationManager.createTask(taskData: taskData)
            else {return}
            path.modelView.append(newTask)
            isLoading.wrappedValue = false;
        }
        dismiss()
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
        if(selectedOption == .custom){
            sheetDetent.wrappedValue = .medium
        }
        else{
            sheetDetent.wrappedValue = .fraction(0.4)
        }
    }
}
