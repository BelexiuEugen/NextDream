//
//  TaskExport.swift
//  NextDream
//
//  Created by Jan on 13/05/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct JSONExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

struct TaskExport: View {
    
    @State var taskToExport: [ItemDropdownSelection] = []
    
    @Environment(TaskViewModel.self) var viewModel
    @State var selectedType: ExportType = .JSON
    @State var isExporting: Bool = false;
    @State private var exportedData: Data? = nil
    
    var errorData: Data {
            // Example JSON data for export
            let dictionary = ["error": "something went wrong, try again."] as [String: Any]
            return try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        }
    
    var body: some View {
        
        VStack{
            
            Spacer()
            
            exportOption
            
            Spacer()
            
            TaskDropdown(taskToExport: $taskToExport)
            
            Spacer()
            
            Button {
                exportData()
            } label: {
                Text("Export")
            }
            
            Spacer()
            
        }
        .background(Color.gray.opacity(0.1))
        .toolbar {
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
        .onAppear{
            viewModel.fetchMainTasks()
            
            addTaskToExport()
        }
        .fileExporter(isPresented: $isExporting, document: JSONExportDocument(data: exportedData ?? errorData)){ result in
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
    
    NavigationStack{
        TaskExport()
            .environment(TaskViewModel())
    }
}

extension TaskExport{
    
    var exportOption: some View{
        VStack{
            
            Text("Selected Export Type: ")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Select an option", selection: $selectedType) {
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

extension TaskExport{
    
    func addTaskToExport(){
        
        taskToExport = viewModel.task.map { task in
            ItemDropdownSelection(item: task, isSelected: false)
        }
    }
    
    func exportData(){
        
        let taskData: [TaskModel] = taskToExport.filter { $0.isSelected }.map { $0.item }
        
        guard !taskData.isEmpty else {
            print("No data presented");
            return }
        
        
        
        switch selectedType{
            
        case .JSON:
            exportedData = DataExportManager.shared.convertToJSON(tasks: taskData)
        case .CSV:
            exportedData = DataExportManager.shared.convertToCSV(tasks: taskData)
        case .PDF:
            exportedData = DataExportManager.shared.convertToPDF(tasks: taskData)
        default:
            exportedData = DataExportManager.shared.convertToJPG(tasks: taskData)
        }
        
        if exportedData != nil{
            isExporting = true
        }
        
    }
}









/*
 
 do {
     
     guard let dataToExport = dataToExport else { return }
         // Try to convert the data to a JSON object
         let jsonObject = try JSONSerialization.jsonObject(with: dataToExport, options: [])
         
         // Convert JSON object to pretty-printed data
         let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
         
         // Convert pretty-printed data to a string
         if let jsonString = String(data: prettyData, encoding: .utf8) {
             print("JSON Output:\n\(jsonString)")
         } else {
             print("Error: Unable to convert data to string.")
         }
     } catch {
         print("Error: \(error.localizedDescription)")
     }
 
 */ // Code to see JSON form data
