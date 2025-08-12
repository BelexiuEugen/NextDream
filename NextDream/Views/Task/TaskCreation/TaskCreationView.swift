//
//  TaskMenu.swift
//  NextDream
//
//  Created by Jan on 04/02/2025.
//

import SwiftUI
import SwiftData

struct TaskCreationView: View {
    
    @Environment(\.dismiss) var dismiss;
    @State private var vm: TaskCreationViewModel
    
    init(
        taskCreationManager: TaskCreation,
        path: NavigationViewModel,
        sheetDetent: Binding<PresentationDetent>,
        isLoading: Binding<Bool>
    ) {
        
        _vm = State(
            wrappedValue: TaskCreationViewModel(
                taskCreationManager: taskCreationManager,
                sheetDetent: sheetDetent,
                isLoading: isLoading,
                path: path
            )
        )
    }
    
    var body: some View {
        @Bindable var vm = vm;
        VStack {
            
            taskCreationRegion
            
            priorityRegion
            
            selectDataRegion
            
            if(vm.selectedType == .custom || vm.selectedType == .byDate){
                customSelectionRegion
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
}

extension TaskCreationView{
    
    private var taskCreationRegion: some View{
        HStack{
            
            Button {
                vm.createTask(isLoading: $vm.isLoading.wrappedValue, path: $vm.path.wrappedValue, dismiss: dismiss)
            } label: {
                Text("Perform")
            }
            
            VStack{
                
                Picker("Select calendar type", selection: $vm.selectedCreationModel){
                    ForEach(CreationModelType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.wheel)
                .padding()
                
                
                Picker("Select an option", selection: $vm.selectedType) {
                    ForEach(TaskType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.wheel)
                .padding()
            }
            
        }
    }
    
    private var priorityRegion: some View{
        HStack{
            
            Text("Priority Level: ")
            
            Picker("Priority", selection: $vm.selectedPriority){
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
    }
    
    private var selectDataRegion: some View{
        VStack{
            DatePicker(
                "Start Date",
                selection: $vm.startDate,
                displayedComponents: .date
            )
            
            DatePicker(
                "Start Date",
                selection: $vm.endDate,
                displayedComponents: .date
            )
        }
    }
    
    private var customSelectionRegion: some View{
        Group{
            Stepper("Years: \(vm.numberOfYears)", value: $vm.numberOfYears, in: 0...10)
            
            Stepper("Months: \(vm.numberOfMonths)", value: $vm.numberOfMonths, in: 0...12){ _ in
                vm.updateMonthsAndYears()
            }
            
            Stepper("Weeks: \(vm.numberOfWeeks)", value: $vm.numberOfWeeks, in: 0...5) { _ in
                vm.updateWeeksAndMonths()
            }
            
            Stepper("Days: \(vm.numberOfDays)", value: $vm.numberOfDays, in: 0...7){ _ in
                if vm.numberOfDays >= 7{
                    vm.numberOfDays = 0;
                    vm.numberOfWeeks += 1;
                }
            }
        }
    }
}
