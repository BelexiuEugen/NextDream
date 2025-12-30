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
            ScrollView{
                ZStack{
                    
                    nameAndStartingPointRegion
                        .padding(.horizontal)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        .offset(x: vm.screenWidth - vm.currentWidth)
                        .id(1)
                    
                    templateSelectionRegion
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        .offset(x: 2 * vm.screenWidth - vm.currentWidth)
                        .id(2)
                        .padding(.horizontal, 4)
                    
                    taskDetailRegion
                        .padding(.horizontal)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        .offset(x: 3 * vm.screenWidth - vm.currentWidth)
                        .id(3)
                        .padding(.horizontal, 4)
                    
                    customElementsRegion
                        .padding(.horizontal)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        .offset(x: 4 * vm.screenWidth - vm.currentWidth)
                        .id(4)
                    
                }
            }
            Spacer()
            
            buttonsRegion
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .background(.thinMaterial)
        .ignoresSafeArea(edges: .bottom)
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
        HStack(spacing: 16){
            Button(role: .none) {
                vm.goBack()
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .font(.headline)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 16))
            
            Button {
                vm.goNext()
            } label: {
                Label("Next", systemImage: "chevron.right")
                    .font(.headline)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
        
    }
    
    private var templateSelectionRegion: some View{
        VStack(spacing: 24){
            
            Text("Select Your Goal Template: ")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .padding(.top)
            
            templateTypeComponent
        }
        .padding(.horizontal, 24)
    }
    
    private var taskDetailRegion: some View{
        
        VStack(spacing: 16){
            
            if vm.selectedType != .day && vm.selectedType != .week{
                
                HStack{
                    Text("First Day Of The Week: ")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    startingWeekdayComponent
                        .offset(x: 10)
                }
                
                HStack{
                    Text("Select Time Type:")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    calendarTypeComponent
                        .offset(x: 10)
                }
                
                HStack{
                    Text("Select Category: ")
                        .bold()
                        .foregroundStyle(.primary)
                    Spacer()
                    categoryTypeComponent
                        .offset(x: 10)
                }
                
                WeekDayList(selectedTask: $vm.selectedRestDays)
            }
            
            selectDataComponent
        }
        .padding(.vertical, 12)
    }
    
    private var customElementsRegion: some View{
        VStack{
            Spacer()
            customSelectionComponent
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private var nameAndStartingPointRegion: some View{
        VStack(alignment: .leading, spacing: 24){
            Text("Goal Details")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .padding(.top)

            VStack(alignment: .leading, spacing: 12) {
                Text("Goal Name")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                HStack{
                    TextField("Enter goal name", text: $vm.goalName)
                        .textFieldStyle(.roundedBorder)
                        .disabled(vm.goalIsSet)
                    
                    Image(systemName: vm.goalIsSet ? "checkmark.square.fill" : "square.dashed")
                        .animation(.easeInOut, value: vm.goalIsSet)
                        .onTapGesture {
                            vm.goalIsSet.toggle()
                        }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Starting Point questions")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                TextEditor(text: $vm.startingPointHelp)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay{
                        if vm.fetchingAIHelp{
                            ProgressView()
                        }
                    }
                
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Starting Point Answer")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                TextEditor(text: $vm.startingPoint)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .disabled(vm.goalName.isEmpty)

            Spacer()
        }
        .padding(.vertical, 12)
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
        .tint(.accentColor)
    }
    
    private var calendarTypeComponent: some View{
        Picker("Select calendar type", selection: $vm.selectedCreationModel){
            ForEach(CreationModelType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .tint(.accentColor)
    }
    
    private var startingWeekdayComponent: some View{
        Picker("Select first day", selection: $vm.selectedWeekFirstDay){
            ForEach(Weekday.allCases, id:\.self){ type in
                Text(type.dayName).tag(type)
            }
        }
        .tint(.accentColor)
    }
    
    private var templateTypeComponent: some View{
        Picker("Select an option", selection: $vm.selectedType) {
            ForEach(TaskType.allCases, id: \.self) { type in
                Text(type.displayName).tag(type)
            }
        }
        .pickerStyle(.wheel)
        .tint(.accentColor)
        .padding()
    }
    
    private var customSelectionComponent: some View{
        Group{
            Stepper("Years: \(vm.numberOfYears)", value: $vm.numberOfYears, in: 0...10)
                .bold()
                .foregroundStyle(.primary)
            
            Stepper("Months: \(vm.numberOfMonths)", value: $vm.numberOfMonths, in: 0...11)
                .bold()
                .foregroundStyle(.primary)
            
            Stepper("Weeks: \(vm.numberOfWeeks)", value: $vm.numberOfWeeks, in: 0...4)
                .bold()
                .foregroundStyle(.primary)
            
            Stepper("Days: \(vm.numberOfDays)", value: $vm.numberOfDays, in: 0...6)
                .bold()
                .foregroundStyle(.primary)
        }
    }
    
    private var selectDataComponent: some View{
        VStack(spacing: 16){
            DatePicker(
                "Start Date",
                selection: $vm.startDate,
                displayedComponents: .date
            )
            .bold()
            .foregroundStyle(.primary)
            
            if vm.selectedType == .byDate{
                DatePicker(
                    "End Date",
                    selection: $vm.endDate,
                    displayedComponents: .date
                )
                .bold()
                .foregroundStyle(.primary)
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

