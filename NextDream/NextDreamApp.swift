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
        
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: TaskModel.self)
    }
}
