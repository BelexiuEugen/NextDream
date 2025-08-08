//
//  TaskExport.swift
//  NextDream
//
//  Created by Jan on 13/05/2025.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct ExportView: View {
    
    @State private var viewModel: ExportViewModel
    
    init(modelContext: ModelContext, taskRepository: TaskRepository) {
        _viewModel = State(wrappedValue: ExportViewModel(modelContext: modelContext, taskRepository: taskRepository))
    }
    
    var body: some View {
        
        @Bindable var viewModel = viewModel
        
        VStack{
            
            Spacer()
            
            exportOption
            
            Spacer()
            
            TaskDropdown(taskToExport: $viewModel.taskToExport)
            
            Spacer()
            
            Button {
                viewModel.exportData()
            } label: {
                Text("Export")
            }
            
            Spacer()
            
        }
        .background(Color.gray.opacity(0.1))
        .toolbar {
            taskImportButton
        }
        .fileExporter(isPresented: $viewModel.isExporting, document: JSONExportDocument(data: viewModel.exportedData ?? viewModel.errorData)){ result in
            switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
}

#Preview {
    
//    NavigationStack{
//        TaskExport()
//            .environment(TaskViewModel())
//    }
}

extension ExportView{
    
    var taskImportButton: ToolbarItem<Void, some View>{
        ToolbarItem {
            NavigationLink {
                TaskImport()
            } label: {
                VStack{
                    Image(systemName: "square.and.arrow.down")
                    
                    Text("Import")
                }
            }
            
        }
    }
    
    var exportOption: some View{
        VStack{
            
            Text("Selected Export Type: ")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Select an option", selection: $viewModel.selectedType) {
                ForEach(ExportType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
        }
        .padding(.horizontal)
    }
}
