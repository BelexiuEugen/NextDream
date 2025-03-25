//
//  UserClass.swift
//  Next Step
//
//  Created by Jan on 21/11/2024.
//

import Foundation
import SwiftData

@Observable
class TaskViewModel{
    
    var task: [TaskModel] = []
    
    var modelContext: ModelContext? = nil
    
    func saveDataToDevice(){
        
        guard let modelContext = modelContext else { return }
        
        do{
            try modelContext.save()
            
        } catch{
            print("there was an error saving the task")
        }
    }
    
}

@Observable
class NavigationViewModel{
    var modelView: [TaskModel] = []
}

// MARK: Task Fetching

extension TaskViewModel{
    
    static func fetchTasksByParentID(parentID: String?, modelContext: ModelContext) -> [TaskModel]{
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{ $0.parentID == parentID})
        
        do{
            let taskList = try modelContext.fetch(descriptor)
            return taskList;
        } catch{
            print("There was an error \(error.localizedDescription)")
        }
        
        return [];
    }
    
    static func getTaskByID(id: String, modelContext: ModelContext) -> TaskModel?{
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{ $0.id == id})
        
        do{
            let taskResult: TaskModel? = try modelContext.fetch(descriptor).first ?? nil
            return taskResult;
        } catch{
            print("Error fetch the task with ID: \(id)");
        }
        
        return nil;
    }
    func fetchTaskByDeadline(date: Date){
        
        guard let modelContext = modelContext else { return }
        
        let calendar = Calendar.current
        let startDate: Date? = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate ?? .now)
        
        guard let startDate = startDate, let endDate = endDate else { return }
        
        let descriptor = FetchDescriptor<TaskModel>(predicate: #Predicate{ endDate > $0.deadline && $0.deadline >= startDate })
        
        do{
            let taskList = try modelContext.fetch(descriptor)

            task = taskList;
        }catch{
            print("There was an error \(error.localizedDescription)")
        }
    }
    
    func fetchAllTask(){
        
        guard let modelContext = modelContext else { return }
        
        do{
            let descriptor = FetchDescriptor<TaskModel>();
            let taskList = try modelContext.fetch(descriptor);
            
            task = taskList;
            
        }catch{
            print("There was an error \(error.localizedDescription)");
        }
        
        
    }
    
    func fetchTaskByDescriptorAndSearchString(sort: SortDescriptor<TaskModel>, serchString: String){
        
        guard let modelContext = modelContext else { return }
        
        do{
            var descriptor = FetchDescriptor<TaskModel>()
            
            descriptor.predicate = #Predicate<TaskModel> { task in
                (serchString.isEmpty || task.name.localizedStandardContains(serchString))
                    && task.parentID == nil
            }
            
            descriptor.sortBy = [sort];
            
            task = try modelContext.fetch(descriptor);
            
        } catch{
            print("There was an error \(error.localizedDescription)");
        }
    }
    
}


//MARK: Task Deletion

extension TaskViewModel{
    
    static func deleteTaskById(id: String, modelContext: ModelContext){
        
        let subTask: [TaskModel] = fetchTasksByParentID(parentID: id, modelContext: modelContext);
        
        for task in subTask{
            
            if task.taskType != .day{
                deleteTaskById(id: task.id, modelContext: modelContext)
            }

            modelContext.delete(task)
        }
    }
    
    func deleteAllTask(with context: ModelContext){
        
        do{
            let allTasks = try context.fetch(FetchDescriptor<TaskModel>())
            
            // Delete each task
            for task in allTasks {
                context.delete(task)
            }
            
            self.saveDataToDevice()
            
        }catch{
            print("There was an error deleting the data")
        }
    }
    
}

// MARK: Task Creation

extension TaskViewModel{
    
    func createTask(selectedOption: TaskType, taskData: TaskModelCreationData, taskPriority: TaskPriority = .low) -> TaskModel?{
        
        guard modelContext != nil else { return nil}
        
        var result: TaskModel?;
        var newTaskData = taskData;
        
        switch selectedOption {
        case .day:
            newTaskData.name = getDayName(taskData.taskStartDate);
            result = createDay(taskData: newTaskData, taskPriority: taskPriority);
        case .week:
            newTaskData.name = weekRange(for: taskData.taskStartDate);
            result = createWeek(taskData: newTaskData, taskPriority: taskPriority)
        case .month:
            result = createMonth(taskData: taskData, taskPriority: taskPriority)
        case .year:
            newTaskData.name = "\(Calendar.current.component(.year, from: taskData.taskStartDate))"
            result = createYear(taskData: taskData, taskPriority: taskPriority)
        default:
            result = createCustom(taskData: taskData, taskPriority: taskPriority)
            break;
        }
        
        self.saveDataToDevice()
        
        return result;
    }
    
    func createDay(taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?{
        
        guard let modelContext = modelContext else { return nil}
        
        let newDayModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: taskData.taskStartDate, taskType: .day, taskPriority: taskPriority);
        
        modelContext.insert(newDayModel);
        
        self.saveDataToDevice()
        
        return newDayModel;
    }
    
    func createWeek(taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?{
        
        guard let modelContext = modelContext else { return nil}
        
        guard let deadline = Calendar.current.date(byAdding: .day, value: taskData.totalWeekDays, to: taskData.taskStartDate) else { return nil};
        
        let newWeekModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline, taskType: .week, taskPriority: taskPriority);
        
        modelContext.insert(newWeekModel);
        
        var subTaskStartDate = taskData.taskStartDate
        
        for _ in 0...taskData.totalWeekDays{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 1, to: subTaskStartDate) else { break }
            
            let subTaskData = TaskModelCreationData(
                name: getDayName(subTaskStartDate),
                parentID: newWeekModel.id,
                taskStartDate: subTaskStartDate)
            
            _ = createDay(taskData: subTaskData, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
        }
        
        return newWeekModel;
    }
    
    func createMonth(taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?{
        
        guard let modelContext = modelContext else { return nil}
        
        guard let deadline = Calendar.current.date(byAdding: .day, value: taskData.totalMonthDays - 1, to: taskData.taskStartDate) else { return nil};
        
        let newMonthModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline, taskType: .month, taskPriority: taskPriority);
        
        modelContext.insert(newMonthModel);
        
        var daysToSkip = 0;
        
        createFreeWeek(&daysToSkip, totalMonthDays: taskData.totalMonthDays, parentID: newMonthModel.id, startDate: taskData.taskStartDate, taskPriority: taskPriority)
        
        guard var subTaskStartDate = Calendar.current.date(byAdding: .day, value: daysToSkip, to: taskData.taskStartDate) else { return nil}
        
        for _ in 0...3{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 7, to: subTaskStartDate) else { break }
            
            let subTaskData = TaskModelCreationData(
                name: weekRange(for: subTaskStartDate),
                parentID: newMonthModel.id,
                taskStartDate: subTaskStartDate
            )
            
            _ = createWeek(taskData: subTaskData, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
        }
        
        return newMonthModel;
    }
    
    func createYear(taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?{
        
        guard let modelContext = modelContext else { return nil}
        
        guard let deadline = Calendar.current.date(byAdding: .year, value: 1, to: taskData.taskStartDate) else { return nil};
        
        let newYearModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: deadline - 1, taskType: .year, taskPriority: taskPriority);
        
        let month = Calendar.current.component(.month, from: taskData.taskStartDate) - 1
        
        modelContext.insert(newYearModel)
        
        var subTaskStartTime = taskData.taskStartDate;
        let currentYear = Calendar.current.component(.year, from: subTaskStartTime)
        
        for i in 0...11 {
            
            let currentMonth: String = DateFormatter().monthSymbols[(month + i) % 12]
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: getNumberOfDays(currentMonth, currentYear: currentYear), to: subTaskStartTime) else {break}
            
            createMonthByName(monthName: currentMonth, parentID: newYearModel.id, startDate: subTaskStartTime, taskPriority: taskPriority);
            
            subTaskStartTime = startDate
        }
        
        return newYearModel;
    }
    
    func createCustom(taskData: TaskModelCreationData, taskPriority: TaskPriority) -> TaskModel?{
        
        guard let modelContext = modelContext else { return nil}
        
        guard let deadlineWithYears = Calendar.current.date(byAdding: .year, value: taskData.numberOfYears, to: taskData.taskStartDate) else { return nil};
        
        guard let deadlineWithMonths = Calendar.current.date(byAdding: .month, value: taskData.numberOfMonths, to: deadlineWithYears) else { return nil};
        
        guard let deadlineWithWeeks = Calendar.current.date(byAdding: .weekOfYear, value: taskData.numberOfWeeks, to: deadlineWithMonths) else { return nil};
        
        guard let finalDeadline = Calendar.current.date(byAdding: .day, value: taskData.numberOfDays, to: deadlineWithWeeks) else { return nil};
        
        
        let newCustomModel = TaskModel(name: taskData.name, parentID: taskData.parentID, deadline: finalDeadline, taskType: .custom, taskPriority: taskPriority);
        
        modelContext.insert(newCustomModel)
        
        var subTaskStartDate = taskData.taskStartDate
        
        for _ in 0..<taskData.numberOfYears{
            
            guard let startDate = Calendar.current.date(byAdding: .year, value: 1, to: subTaskStartDate) else {break};
            
            let currentYear = Calendar.current.component(.year, from: subTaskStartDate)
            
            let subTaskData = TaskModelCreationData(name: "\(currentYear)", parentID: newCustomModel.id, taskStartDate: subTaskStartDate)

            _ = createYear(taskData: subTaskData, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
        }
        
        var month = Calendar.current.component(.month, from: subTaskStartDate) - 1
        

        for _ in 0..<taskData.numberOfMonths{
            
            guard let startDate = Calendar.current.date(byAdding: .month, value: 1, to: subTaskStartDate) else {break};
            
            let currentMonth: String = DateFormatter().monthSymbols[month]

            createMonthByName(monthName: currentMonth, parentID: newCustomModel.id, startDate: subTaskStartDate, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
            
            month = (month + 1) % 12;
        }
        

            
        for _ in 0..<taskData.numberOfWeeks{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 7, to: subTaskStartDate) else {break}
            
            let subTaskData = TaskModelCreationData(name: weekRange(for: subTaskStartDate), parentID: newCustomModel.id, taskStartDate: subTaskStartDate)
            
            _ = createWeek(taskData: subTaskData, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
        }
        
            
        for _ in 0..<taskData.numberOfDays{
            
            guard let startDate = Calendar.current.date(byAdding: .day, value: 1, to: subTaskStartDate) else {break}
            
            let subTaskData = TaskModelCreationData(name: getDayName(subTaskStartDate), parentID: newCustomModel.id, taskStartDate: subTaskStartDate)
            
            _ = createDay(taskData: subTaskData, taskPriority: taskPriority)
            
            subTaskStartDate = startDate
        }
         
        return newCustomModel;
    }
    
}

// MARK: Task Creation (Tools)

extension TaskViewModel{
    fileprivate func createFreeWeek(_ daysToSkip: inout Int,totalMonthDays: Int, parentID: String, startDate: Date, taskPriority: TaskPriority) {
        // Create Free & Plan Week
        switch totalMonthDays{
        case 31:
             daysToSkip += 3;
        case 30:
             daysToSkip += 2;
        case 29:
             daysToSkip += 1;
        default:
            return
        }
        
        let subTaskData = TaskModelCreationData(name: "Rest & Plan", parentID: parentID, taskStartDate: startDate, totalWeekDays: daysToSkip - 1)
        
        _ = createWeek(taskData: subTaskData, taskPriority: taskPriority)
    }
    
    fileprivate func createMonthByName(monthName: String, parentID: String, startDate: Date, taskPriority: TaskPriority){
        
        let currentYear = Calendar.current.component(.year, from: startDate)
        
        var numberOfDays = 0;
        
        switch monthName{
        case "January", "March", "May", "July", "August", "October", "December" :
            numberOfDays = 31;
        case "April", "June", "September", "November":
            numberOfDays = 30;
        default:
            if isLeapYear(currentYear){
                numberOfDays = 29;
            } else{
                numberOfDays = 28;
            }
        }
        
        let taskData: TaskModelCreationData = TaskModelCreationData(name: monthName, parentID: parentID, taskStartDate: startDate, totalMonthDays: numberOfDays)
        
        _ = createMonth(taskData: taskData, taskPriority: taskPriority)
    }
    
    fileprivate func getNumberOfDays(_ monthName: String, currentYear: Int) -> Int{
        
        switch monthName{
        case "January", "March", "May", "July", "August", "October", "December" :
            return 31;
        case "April", "June", "September", "November":
            return 30;
        default:
            if isLeapYear(currentYear){
                return 29;
            } else{
                return 28;
            }
        }
    }
    
    fileprivate func isLeapYear(_ year: Int) -> Bool{
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
    
    fileprivate func getDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
    
    fileprivate func weekRange(for weekStart: Date) -> String {
        let calendar = Calendar.current
        // Get the start and end of the week
        
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        
        // Format day numbers (12, 17) and month name (February)
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let startDay = dayFormatter.string(from: weekStart)
        let endDay = dayFormatter.string(from: weekEnd)
        let month = monthFormatter.string(from: weekStart)
        
        return "\(startDay) - \(endDay) \(month)"
    }
}
