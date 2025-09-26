//
//  HomeView.swift
//  Next Step
//
//  Created by Jan on 28/11/2024.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) var modelContext;
    
    @State private var selectedTab = 2
    
    private var taskRepository: DefaultTaskRepository {
        DefaultTaskRepository(modelContext: modelContext)
    }
    private var taskCreationManager: TaskCreationManager{
        TaskCreationManager(modelContext: modelContext)
    }
    
    
    var body: some View {
        
        VStack{
            TabView(selection: $selectedTab){
                
                Tab("Task List", systemImage: "checklist", value: 1) {
                    TaskDashboardView(
                        modelContext: modelContext,
                        taskRepository: taskRepository,
                        taskCreationManager: taskCreationManager
                    )
                }
                
                Tab("DashBoard", systemImage: "square.grid.2x2", value: 2){
                    NavigationStack{
                        DashboardView(modelContext: modelContext, taskRepository: taskRepository)
                    }
                }

                Tab("Calendar", systemImage: "calendar", value: 3){
                    NavigationStack{
                        CalendarView(modelContext: modelContext, taskRepository: taskRepository)
                    }
                }
                
            }
        }
    }
}


#Preview {
    HomeView()
}
