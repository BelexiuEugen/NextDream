//
//  EventSelectionView.swift
//  NextDream
//
//  Created by Jan on 15/01/2025.
//

import SwiftUI
import SwiftData
import EventKit

struct EventSelectionView: View {
    
    @State var taskToCalendar: [ItemCalendarSelection] = []
    
    @State var values:[String] = [
    "Select task to add",
    "Add all of them"
]
    
    @State var eventManager: EventManager = EventManager();
    
    @State private var selectedOption = "Add all of them";
    @State private var showTask: Bool = false;
    
    @Query var taskList:[TaskModel]
    
    var body: some View {
        VStack{
            
            HStack{
                
                Button {
                    if(selectedOption == values[0])
                    {
                        showTask.toggle()
                    }
                    else
                    {
                        checkAllTaskAsTrue()
                        sendDataToCalendar()
                    }
                } label: {
                    Text("Perform")
                }

                
                Picker("Select an option", selection: $selectedOption) {
                    ForEach(values, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(.wheel)
                .padding()
                
            }
            .padding(.horizontal)
            
            Spacer()
            
            if(selectedOption == values[0]){
                
                List(taskToCalendar){ task in
                    
                    HStack{
                        Text(task.item.name)
                        
                        Spacer()
                        
                        
                        Image(systemName: task.isSelected ? "checkmark.square.fill" : "square.dashed")
                    }
                    .onTapGesture {
                        task.isSelected.toggle()
                    }
                    
                }
                
                Button {
                    sendDataToCalendar()
                } label: {
                    Text("Submit");
                }
                
            }
            
            Spacer()
        }
        .onAppear(){
            populateTaskCalendar()
        }
    }
}

#Preview {
    NavigationStack{
        EventSelectionView()
    }
}


extension EventSelectionView{
    
    func populateTaskCalendar(){
        
        taskToCalendar = taskList.map{item in
            ItemCalendarSelection(item: item, isSelected: item.calendarIdentifier != nil ? true : false)
        }
    }
    
    func checkAllTaskAsTrue(){
        
        for task in taskToCalendar{
            task.isSelected = true;
        }
    }
}

//MARK: Calendar

extension EventSelectionView{
    
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
            
            createEvents();
        }
    }
    
    func createEvents(){
        
        for task in taskToCalendar{
            
            guard task.item.calendarIdentifier == nil else {
                
                guard !task.isSelected else {continue}
                
                if let identifier = task.item.calendarIdentifier{
                    if eventManager.deleteEvent(eventIdentifier: identifier){
                        task.item.calendarIdentifier = nil;
                    }
                }
                
                continue;
            }
            
            guard task.isSelected else { continue }
            
            let name = task.item.name
            let description = task.item.taskDescription ?? "Not found"
            let endDate: Date = task.item.deadline
            
            if let eventIdentifier =
                eventManager.createEvent(name: name, description: description, endDate: endDate){
                task.item.calendarIdentifier = eventIdentifier;
            }
        }
    }
}
