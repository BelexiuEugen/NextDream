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
    
    @State var viewModel: EventSelectionViewModel
    
    init(modelContext: ModelContext){
        _viewModel = State(wrappedValue: EventSelectionViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        VStack{
            
            selectionRegion
            
            Spacer()
            
            if(viewModel.exportType == .select){
                showTaskRegion
            }
            
            Spacer()
            
            exportButton
        }
        .onAppear(){
            viewModel.populateTaskCalendar()
        }
    }
}

#Preview {
    NavigationStack{
        EventSelectionView(modelContext: MockModels.container.mainContext)
    }
}

extension EventSelectionView{
    
    private var selectionRegion: some View{
        VStack{
            
            Picker("Select an option", selection: $viewModel.exportType) {
                ForEach(calendarExportOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.wheel)
            
        }
        .padding()
    }
    
    private var exportButton: some View{
        Button{
            viewModel.exportData()
        } label: {
            Text("Export")
                .fontWeight(.semibold)
        }
    }
    
    private var showTaskRegion: some View {
        Group{
            List(viewModel.taskToCalendar){ item in
                
                HStack{
                    Text(item.task.name)
                    
                    Spacer()
                    
                    
                    Image(systemName: item.task.isSelected ? "checkmark.square.fill" : "square.dashed")
                }
                .onTapGesture {
                    item.task.isSelected.toggle()
                }
                
            }
            
            HStack{
                Button{
                    viewModel.checkAllTaskAsTrue()
                } label: {
                    Text("Select All")
                }
                
                Spacer()
                
                Button {
                    viewModel.checkAllTaskAsFalse()
                } label: {
                    Text("Deselect All")
                }
            }
        }
    }
}
