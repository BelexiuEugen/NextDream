//
//  TaskMenu.swift
//  NextDream
//
//  Created by Jan on 04/02/2025.
//

import SwiftUI
import SwiftData

struct TaskMenu: View {
    
    @Environment(\.dismiss) var dismiss;
    @Environment(TaskViewModel.self) var vm;
    
    @State var taskToCalendar: [ItemDropdownSelection] = []
    
    @Bindable var path : NavigationViewModel
    @Binding var sheetDetent: PresentationDetent
    @Binding var isLoading: Bool;
    
    @State private var selectedPriority: TaskPriority = .low
    @State private var selectedOption: TaskType = .day;
    @State private var showTask: Bool = false;
    @State private var startDate: Date = firstDay(of: Date());
    @State private var numberOfYears = 1;
    @State private var numberOfMonths = 1 {
        didSet {updateMonthsAndYears()}
    };
    @State private var numberOfWeeks = 1{
        didSet {updateWeeksAndMonths()}
    };
    @State private var numberOfDays = 1;
    
    @State private var isPresented: Bool = false;
    
    var body: some View {
        VStack {
            
            HStack{
                
                Button {
                    createTask()
                } label: {
                    Text("Perform")
                }
                
                
                Picker("Select an option", selection: $selectedOption) {
                    ForEach(TaskType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.wheel)
                .padding()
                
            }
            
            HStack{
                
                Text("Priority Level: ")
                
                Picker("Priority", selection: $selectedPriority){
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        HStack{
                            Circle()
                                .frame(width: 20, height: 20)
                            Text(priority.rawValue)
                        }
                        .tag(priority);
                    }
                }
                .pickerStyle(.segmented)
            }
            
            
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .onChange(of: startDate) { oldValue, newValue in
                    if selectedOption == .year || selectedOption == .custom{
                        startDate = TaskMenu.firstDay(of: startDate)
                    }
                }
            
            if(selectedOption == .custom){
                
                Stepper("Years: \(numberOfYears)", value: $numberOfYears, in: 0...10)
                
                Stepper("Months: \(numberOfMonths)", value: $numberOfMonths, in: 0...12){ _ in
                    updateMonthsAndYears()
                }
                
                Stepper("Weeks: \(numberOfWeeks)", value: $numberOfWeeks, in: 0...5) { _ in
                    updateWeeksAndMonths()
                }
                
                Stepper("Days: \(numberOfDays)", value: $numberOfDays, in: 0...7){ _ in
                    if numberOfDays >= 7{
                        numberOfDays = 0;
                        numberOfWeeks += 1;
                    }
                }
            }
        }
        .padding(.horizontal)
        .onChange(of: selectedOption) { oldValue, newValue in
            if(newValue == .custom){
                sheetDetent = .medium
            }
            else{
                sheetDetent = .fraction(0.4)
            }
            
            startDate = TaskMenu.firstDay(of: startDate)
        }
    }
}

#Preview {
    
    TaskMenu(path: NavigationViewModel(), sheetDetent: .constant(.medium), isLoading: .constant(false))
        .environment(TaskViewModel())
}

extension TaskMenu{
    
    private func updateWeeksAndMonths(){
        
        if numberOfWeeks >= 5{
            numberOfWeeks = 0;
            
            if(numberOfMonths < 12){
                numberOfMonths += 1;
            }
        }
    }
    
    private func updateMonthsAndYears(){
        
        if numberOfMonths >= 12{
            numberOfMonths = 0
            
            if numberOfYears < 10{
                numberOfYears += 1;
            }
        }
    }
    
    static func firstDay(of date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
    
    func createTask(){
        
        let taskData = TaskModelCreationData(name: "Your Task Name", parentID: nil, taskStartDate: startDate, numberOfYears: numberOfYears, numberOfMonths: numberOfMonths, numberOfWeeks: numberOfWeeks, numberOfDays: numberOfDays)
            
            
        isLoading = true;

        Task{
            
            guard let
                    newTask = await vm.createTask(selectedOption: selectedOption, taskData: taskData, taskPriority: selectedPriority)
            else {return}
            path.modelView.append(newTask)
            isLoading = false;
        }
        dismiss()
    }
}
