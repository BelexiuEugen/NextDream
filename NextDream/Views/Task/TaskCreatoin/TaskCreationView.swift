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
    @State private var viewModel: TaskCreationViewModel
    
    @Bindable var path : NavigationViewModel
    @Binding var sheetDetent: PresentationDetent
    @Binding var isLoading: Bool;
    
    init( taskCreationManager: TaskCreationManager,
        path: NavigationViewModel,
        sheetDetent: Binding<PresentationDetent>,
        isLoading: Binding<Bool>) {
        
        _viewModel = State(wrappedValue: TaskCreationViewModel( taskCreationManager: taskCreationManager))
        self.path = path
        _sheetDetent = sheetDetent
        _isLoading = isLoading
    }
    
    var body: some View {
        VStack {
            
            taskCreationRegion
            
            priorityRegion
            
            selectDataRegion
            
            if(viewModel.selectedOption == .custom){
                customSelectionRegion
            }
        }
        .padding(.horizontal)
        .onChange(of: viewModel.selectedOption) { oldValue, newValue in
            if(newValue == .custom){
                sheetDetent = .medium
            }
            else{
                sheetDetent = .fraction(0.4)
            }
            
            viewModel.startDate = viewModel.startDate.firstDate()
        }
    }
}

#Preview {
    HomeView()
}

extension TaskCreationView{
    
    private var taskCreationRegion: some View{
        HStack{
            
            Button {
                viewModel.createTask(isLoading: $isLoading, path: $path, dismiss: dismiss)
            } label: {
                Text("Perform")
            }
            
            
            Picker("Select an option", selection: $viewModel.selectedOption) {
                ForEach(TaskType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.wheel)
            .padding()
            
        }
    }
    
    private var priorityRegion: some View{
        HStack{
            
            Text("Priority Level: ")
            
            Picker("Priority", selection: $viewModel.selectedPriority){
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
        DatePicker(
            "Start Date",
            selection: $viewModel.startDate,
            displayedComponents: .date
        )
        .onChange(of: viewModel.startDate) { oldValue, newValue in
            if viewModel.selectedOption == .year || viewModel.selectedOption == .custom{
                viewModel.startDate = viewModel.startDate.firstDate()
                }
            }
    }
    
    private var customSelectionRegion: some View{
        Group{
            Stepper("Years: \(viewModel.numberOfYears)", value: $viewModel.numberOfYears, in: 0...10)
            
            Stepper("Months: \(viewModel.numberOfMonths)", value: $viewModel.numberOfMonths, in: 0...12){ _ in
                viewModel.updateMonthsAndYears()
            }
            
            Stepper("Weeks: \(viewModel.numberOfWeeks)", value: $viewModel.numberOfWeeks, in: 0...5) { _ in
                viewModel.updateWeeksAndMonths()
            }
            
            Stepper("Days: \(viewModel.numberOfDays)", value: $viewModel.numberOfDays, in: 0...7){ _ in
                if viewModel.numberOfDays >= 7{
                    viewModel.numberOfDays = 0;
                    viewModel.numberOfWeeks += 1;
                }
            }
        }
    }
}
