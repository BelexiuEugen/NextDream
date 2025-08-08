//
//  StreakRow.swift
//  NextDream
//
//  Created by Jan on 07/07/2025.
//

import SwiftUI

struct StreakRowView: View {
    
    var streakCount: Int
    var todayTaskAchieved: Int
    var totalTaskAchieved: Int
    
    var didCompleteATask: Bool{
        todayTaskAchieved > 0
    }
    
    var body: some View {
        VStack{
            
            Text("Progress Overview")
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                ElementStreakCell(element: .streak, count: streakCount, didCompleteATask: didCompleteATask)
                ElementStreakCell(element: .todayTaskAchieved, count: todayTaskAchieved, didCompleteATask: true)
                ElementStreakCell(element: .totalTaskAchieved, count: totalTaskAchieved, didCompleteATask: true)
            }
        }
        
        
        Spacer()
    }
}

#Preview {
    StreakRowView(
        streakCount: 10,
        todayTaskAchieved:0,
        totalTaskAchieved: 10
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
