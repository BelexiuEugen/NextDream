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
    
    @State private var selectedTab = 2 // Set the initial tab index or tag
    
    var body: some View {
        
        VStack{
            TabView(selection: $selectedTab){
                
                Tab("Task List", systemImage: "checklist", value: 1) {
                    TaskDashboardView()
                }
                
                Tab("DashBoard", systemImage: "square.grid.2x2", value: 2){
                    DashboardView(modelContext: modelContext)
                }

                Tab("Calendar", systemImage: "calendar", value: 3){
                    NavigationStack{
                        CalendarView(modelContext: modelContext)
                    }
                }
                
            }
        }
    }
}


#Preview {
    HomeView()
        .environment(TaskViewModel())
}
