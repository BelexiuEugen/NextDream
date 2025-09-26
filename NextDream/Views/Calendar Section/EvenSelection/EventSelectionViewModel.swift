//
//  EventSelectionViewModel.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 26.09.2025.
//

import Foundation
import SwiftData

@Observable
class EventSelectionViewModel{
    var taskToCalendar: [ItemDropdownModel] = []
    var exportType: calendarExportOption = .all{
        didSet(newValue){
            showTask = newValue == .select ? true : false
        }
    }
    
    var eventManager: EventManager = EventManager();
    var showTask: Bool = false;
    var taskList:[TaskModel] = []
    var queryDescriptorManager = QueryDescriptorManager()
    var taskRepository: DefaultTaskRepository
    
    init(modelContext: ModelContext){
        taskRepository = DefaultTaskRepository(modelContext: modelContext)
        self.fetchMainTasks()
    }
    
    func exportData(){
        if self.exportType == .all{
            self.checkAllTaskAsTrue()
        }
        
        self.sendDataToCalendar()
    }
    
    func fetchMainTasks(){
        taskList = taskRepository.fetchMainTasks()
    }
    
    func checkAllTaskAsTrue(){
        for task in taskToCalendar{
            task.isSelected = true
        }
    }
    
    func checkAllTaskAsFalse(){
        for task in taskToCalendar{
            task.isSelected = false
        }
    }
    
    func populateTaskCalendar(){
        
        taskToCalendar = taskList.map{item in
            ItemDropdownModel(task: item, isSelected: item.calendarIdentifier != nil ? true : false)
        }
    }
    
    func sendDataToCalendar(){
        
        eventManager.requestAccess(){ granted, error in
            if let error = error {
                print("Error requesting access: \(error.localizedDescription)")
                return
            }
            
            
            guard granted else {
                print("The access was not granted");
                return
            }
            
            self.createEvents();
        }
    }
    
    func createEvents(){
        
        for item in taskToCalendar{
            
            guard item.task.calendarIdentifier == nil else {
                
                guard !item.isSelected else {continue}
                
                if let identifier = item.task.calendarIdentifier{
                    if eventManager.deleteEvent(eventIdentifier: identifier){
                        item.task.calendarIdentifier = nil;
                    }
                }
                
                continue;
            }
            
            guard item.isSelected else { continue }
            
            let name = item.task.name
            let description = item.task.taskDescription ?? "Not found"
            let endDate: Date = item.task.deadline
            
            if let eventIdentifier =
                eventManager.createEvent(name: name, description: description, endDate: endDate){
                item.task.calendarIdentifier = eventIdentifier;
            }
        }
    }
}
