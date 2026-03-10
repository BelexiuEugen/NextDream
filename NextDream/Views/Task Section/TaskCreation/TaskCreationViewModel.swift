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
    
    
    
    // Task Data
    var selectedCreationModel: CreationModelType = .calendar
    var selectedWeekFirstDay: Weekday = .monday
    var selectedPriority: TaskPriority = .low
    var selectedCategory: TaskCategory = .personal
    var selectedType: TaskType = .custom
    var showTask: Bool = false
    var startDate: Date = Date()
    var endDate: Date = Date()
    var numberOfYears = 1
    var numberOfDays = 1
    var numberOfMonths = 1
    var numberOfWeeks = 1
    var isPresented: Bool = false;
    var selectedRestDays: [Weekday: Bool] = Dictionary(uniqueKeysWithValues: Weekday.allCases.map { ($0, false) })
    
    // User-provided meta
    var goalName: String = ""
    
    var goalIsSet: Bool = false {
        didSet{
            if goalIsSet{
                debounceSearch()
            }
        }
    }
    
    var fetchingAIHelp: Bool = false
    
    var startingPointHelp: String = ""
    var startingPoint: String = ""
    
    var taskCreationManager: TaskCreation
    var sheetDetent: Binding<PresentationDetent>
    var isLoading: Binding<Bool>
    var path : NavigationViewModel
    var dismiss: DismissAction?
    var gemini: GeminiAIManager = GeminiAIManager()
    
    
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    var currentWidth: CGFloat = UIScreen.main.bounds.width
    
    
    init(taskCreationManager: TaskCreation,
         sheetDetent: Binding<PresentationDetent>,
         isLoading: Binding<Bool>,
         path: NavigationViewModel
        ) {
        self.taskCreationManager = taskCreationManager
        self.sheetDetent = sheetDetent
        self.isLoading = isLoading
        self.path = path
    }
    
    private var pendingRequestWorkItem: DispatchWorkItem?

    private func debounceSearch() {
        // Cancel the previous work item if it exists
        pendingRequestWorkItem?.cancel()
        
        // Re-assign with a new work item
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            Task{
                self.fetchingAIHelp = true
                self.startingPointHelp = await self.gemini.generateText(goalName: self.goalName)
                self.fetchingAIHelp = false
            }
        }
        
        pendingRequestWorkItem = workItem
        
        // Execute after 0.5 seconds if not cancelled
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func goNext(){
        
        if  currentWidth == screenWidth * 4 || (currentWidth == 3 * screenWidth && selectedType != .custom){
            createTask()
            return;
        }
//        
        withAnimation(.easeInOut(duration: 0.5)) {
            currentWidth = min(screenWidth * 4, currentWidth + screenWidth)
        }
    }
    
    func goBack(){
        withAnimation(.easeInOut(duration: 0.5)) {
            currentWidth = max(screenWidth, currentWidth - screenWidth)
        }
    }
    
    func createTask(){
        let taskData = createTaskCreationModel()

        isLoading.wrappedValue = true;
        Task(priority: .high){
            guard let
                    newTask = taskCreationManager.createTask(taskData: taskData, creationModelType: selectedCreationModel)
            else {return}
            path.modelView.append(newTask)
            isLoading.wrappedValue = false;
        }
        
        if let dismiss{
            dismiss()
        }
    }
    
    func createTaskCreationModel() -> TaskModelCreation{
        
        var monthDaysCount: Int = 28
        
        if selectedCreationModel == .calendar {
            let currentMonth = Months(date: startDate)
            monthDaysCount = currentMonth.calculateDaysCount(date: startDate)
        }
        
        if selectedType == .byDate{
            calculateComponents()
        }
        
//        let resolvedName: String = {
//            if !goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                return goalName
//            }
//            switch selectedType {
//            case .day:
//                return startDate.getDayName()
//            case .week:
//                return startDate.weekRange(7)
//            case .year:
//                return "\(Calendar.current.component(.year, from: startDate))"
//            case .month:
//                let m = Months(date: startDate)
//                return m.monthName
//            default:
//                return "Custom Goal"
//            }
//        }()
        
        
        
        return TaskModelCreation(
            name: self.goalName,
            description: self.startingPoint,
            taskStartDate: startDate,
            weekDaysCount: 7,
            monthDaysCount: monthDaysCount,
            taskPriority: selectedPriority,
            taskCategory: selectedCategory,
            taskType: selectedType,
            startWeekDay: selectedWeekFirstDay,
            numberOfYears: numberOfYears,
            numberOfMonths: numberOfMonths,
            numberOfWeeks: numberOfWeeks,
            numberOfDays: numberOfDays,
            restDays: createRestDays()
        )
    }
    
    func createRestDays() -> [Weekday]{
        selectedRestDays.filter { $0.value }.map { $0.key }
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
        
        if numberOfWeeks >= 4{
            numberOfWeeks = 0;

        }
    }
    
    func updateMonthsAndYears(){
        
        if numberOfMonths >= 12{
            numberOfMonths = 0
            
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

