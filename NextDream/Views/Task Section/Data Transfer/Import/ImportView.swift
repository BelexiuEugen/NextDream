//
//  TaskImport.swift
//  NextDream
//
//  Created by Jan on 13/05/2025.
//

import SwiftUI
import SwiftData
import CodableCSV

@Observable
class ImportViewModel {
    var isImporting = false
    var tasks: [TaskModel] = []
    var modelContext: ModelContext
    var selectedType: ExportType = .JSON
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addTasksToApp(result: Result<URL, any Error>) {
        
        do {
            let selectedFile: URL = try result.get()
            guard selectedFile.startAccessingSecurityScopedResource() else {
                print("No permission to access file")
                return
            }
            
            let data = try Data(contentsOf: selectedFile)
            
            defer { selectedFile.stopAccessingSecurityScopedResource() }
            
            let decoder = CSVDecoder {
                $0.headerStrategy = .firstLine
            }
            
            var returnedTasks: [TaskModel] = []
            
            switch self.selectedType {
                
            case .JSON:
                returnedTasks = try JSONDecoder().decode([TaskModel].self, from: data)
            case .CSV:
                returnedTasks = try decoder.decode([TaskModel].self, from: data)
            }
            
            for task in returnedTasks{
                modelContext.insert(task)
            }
            
            print("Task were added succesfully")
            
        } catch {
            print("Failed to import file: \(error.localizedDescription)")
        }
    }
}

struct ImportView: View {
    
    @Environment(\.dismiss) var dismiss;
    @State var viewModel: ImportViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = State(wrappedValue: ImportViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        
        VStack{
            
            importOptions
            
            Button("Import Tasks") {
                viewModel.isImporting.toggle()
            }
            .fileImporter(isPresented: $viewModel.isImporting,
                          allowedContentTypes: [.json, .commaSeparatedText],
                          onCompletion: { result in
                viewModel.addTasksToApp(result: result)
                
            })
            .toolbar {
                dismissButton
            }
        }
    }
}

#Preview {
    NavigationStack{
        ImportView(modelContext: MockModels.container.mainContext)
    }
}

extension ImportView{
    private var dismissButton: ToolbarItem<Void, some View>{
        ToolbarItem {
            Button {
                dismiss()
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            
        }
    }
    
    private var importOptions: some View{
        VStack{
            
            Text("Selected Import Type: ")
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
