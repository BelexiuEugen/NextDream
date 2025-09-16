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
        
        VStack{
            ZStack{
                
                templateSelectionRegion
                    .offset(x: vm.screenWidth - vm.currentWidth)
                
                taskDetailRegion
                    .offset(x: 2 * vm.screenWidth - vm.currentWidth)
                    .id(2)
                
                customElementsRegion
                    .offset(x: 3 * vm.screenWidth - vm.currentWidth)
                    .id(3)
            }
            Spacer()
            
            buttonsRegion
        }
        .onAppear{
            vm.dismiss = dismiss
        }
    }
}

#Preview {
    
    let container = try! ModelContainer(
            for: TaskModel.self, // add any @Model types your manager needs
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        // 2. Create the manager with the context
    let manager = TaskCreationManager(modelContext: container.mainContext)
    
    let path: NavigationViewModel = NavigationViewModel()
    
    TaskCreationView(taskCreationManager: manager, path: path, sheetDetent: .constant(.large), isLoading: .constant(false))
}

//MARK: Region

extension TaskCreationView{
    
    private var buttonsRegion: some View{
        HStack{
            Button {
                vm.goBack()
            } label: {
                Text("Back")
            }
            
            Spacer()
            
            Button {
                vm.goNext()
            } label: {
                Text("Next")
            }


        }
        .padding()
    }
    
    private var templateSelectionRegion: some View{
        VStack{
            Spacer()
            
            Text("Select Your Goal Template: ")
                .font(.headline)
                .fontWeight(.semibold)
            
            templateTypeComponent
            
            Spacer()
        }
    }
    
    private var taskDetailRegion: some View{
        
        VStack{
            
            if vm.selectedType != .day && vm.selectedType != .week{
                
                HStack{
                    Text("First Day Of The Week: ")
                        .fontWeight(.bold)
                    Spacer()
                    startingWeekdayComponent
                        .offset(x: 10)
                }
                
                HStack{
                    Text("Select Time Type:")
                        .fontWeight(.bold)
                    Spacer()
                    calendarTypeComponent
                        .offset(x: 10)
                }
                
                HStack{
                    Text("Select Category: ")
                        .bold()
                    Spacer()
                    categoryTypeComponent
                        .offset(x: 10)
                }
                
                WeekDayList(selectedTask: $vm.selectedRestDays)
            }
            
            selectDataComponent
            categoryTypeComponent
        }
        .padding()
    }
    
    private var customElementsRegion: some View{
        VStack{
            Spacer()
            customSelectionComponent
                .padding(.horizontal)
            Spacer()
        }
    }
}

//MARK: Components

extension TaskCreationView{
    
    private var categoryTypeComponent: some View{
        Picker("Select Category Type", selection: $vm.selectedCategory){
            ForEach(TaskCategory.allCases, id:\.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
    }
    
    private var calendarTypeComponent: some View{
        Picker("Select calendar type", selection: $vm.selectedCreationModel){
            ForEach(CreationModelType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
    }
    
    private var startingWeekdayComponent: some View{
        Picker("Select first day", selection: $vm.selectedWeekFirstDay){
            ForEach(Weekday.allCases, id:\.self){ type in
                Text(type.dayName).tag(type)
            }
        }
    }
    
    private var templateTypeComponent: some View{
        Picker("Select an option", selection: $vm.selectedType) {
            ForEach(TaskType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.wheel)
        .padding()
    }
    
    private var customSelectionComponent: some View{
        Group{
            Stepper("Years: \(vm.numberOfYears)", value: $vm.numberOfYears, in: 0...10)
                .bold()
            
            Stepper("Months: \(vm.numberOfMonths)", value: $vm.numberOfMonths, in: 0...11)
                .bold()
            
            Stepper("Weeks: \(vm.numberOfWeeks)", value: $vm.numberOfWeeks, in: 0...4)
                .bold()
            
            Stepper("Days: \(vm.numberOfDays)", value: $vm.numberOfDays, in: 0...6)
                .bold()
        }
    }
    
    private var selectDataComponent: some View{
        VStack{
            DatePicker(
                "Start Date",
                selection: $vm.startDate,
                displayedComponents: .date
            )
            .bold()
            
            if vm.selectedType == .byDate{
                DatePicker(
                    "End Date",
                    selection: $vm.endDate,
                    displayedComponents: .date
                )
                .bold()
            }
        }
    }
    
    private var priorityComponent: some View{
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
    
    
}
