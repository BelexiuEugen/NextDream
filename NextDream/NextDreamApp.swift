//
//  NextDreamApp.swift
//  NextDream
//
//  Created by Jan on 14/01/2025.
//

import SwiftUI
import SwiftData

@main
struct NextDreamApp: App {
    
    @State var vm: TaskViewModel = TaskViewModel();
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(vm);
        }
        .modelContainer(for: TaskModel.self)
    }
}
