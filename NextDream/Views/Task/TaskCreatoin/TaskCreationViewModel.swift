//
//  TaskCreationViewModel.swift
//  NextDream
//
//  Created by Jan on 27/06/2025.
//

import Foundation
import SwiftUI

final class TaskCreationViewModel{
    
    var taskToCalendar: [ItemDropdownSelection] = []
    var selectedPriority: TaskPriority = .low
    var selectedOption: TaskType = .day
    var showTask: Bool = false
    var startDate: Date = Date().firstDate()
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
    
    init(taskCreationManager: TaskCreation){
        self.taskCreationManager = taskCreationManager
    }
    
    func createTask(isLoading: Binding<Bool>, path: Bindable<NavigationViewModel>, dismiss: DismissAction){
        
        let taskData = TaskModelCreationData(
            name: "Your Task Name",
            parentID: nil,
            taskStartDate: startDate,
            numberOfYears: numberOfYears,
            numberOfMonths: numberOfMonths,
            numberOfWeeks: numberOfWeeks,
            numberOfDays: numberOfDays
        )
        
        
        isLoading.wrappedValue = true;
        
        Task{
            
            guard let
                    newTask = taskCreationManager.createTask(selectedOption: selectedOption, taskData: taskData, taskPriority: selectedPriority)
            else {return}
            path.wrappedValue.modelView.append(newTask)
            isLoading.wrappedValue = false;
        }
        dismiss()
    }
}
