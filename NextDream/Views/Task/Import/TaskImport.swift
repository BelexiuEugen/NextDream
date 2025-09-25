//
//  TaskImport.swift
//  NextDream
//
//  Created by Jan on 13/05/2025.
//

import SwiftUI

struct TaskImport: View {
    
    @Environment(\.dismiss) var dismiss;
    
    var body: some View {
        Text("Import")
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    
                }
            }
    }
}

#Preview {
    NavigationStack{
        TaskImport()
    }
}
