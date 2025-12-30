//
//  StreakRow.swift
//  NextDream
//
//  Created by Jan on 07/07/2025.
//

import SwiftUI

struct StreakRowView: View {
    
    var dailyTaskAchieved: Int
    var monthlyTaskAchieved: Int
    var totalTaskAchieved: Int
    
    var body: some View {
        VStack{
            
            Text("Progress Overview")
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                ElementStreakCell(element: .todayTaskAchieved, count: dailyTaskAchieved, didCompleteATask: dailyTaskAchieved > 0)
                ElementStreakCell(element: .monthlyTaskAchieved, count: monthlyTaskAchieved, didCompleteATask: monthlyTaskAchieved > 0)
                ElementStreakCell(element: .totalTaskAchieved, count: totalTaskAchieved, didCompleteATask: totalTaskAchieved > 0)
            }
        }
        
        
        Spacer()
    }
}

#Preview {
    StreakRowView(
        dailyTaskAchieved: 3,
        monthlyTaskAchieved: 15,
        totalTaskAchieved: 100
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
