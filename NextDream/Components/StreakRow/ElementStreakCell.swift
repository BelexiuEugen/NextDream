//
//  ElementStreak.swift
//  NextDream
//
//  Created by Jan on 07/07/2025.
//

import SwiftUI

struct ElementStreakCell: View {
    
    var element: ElementStreak
    var count: Int
    var didCompleteATask: Bool
    
    var body: some View {
        VStack(spacing: 8) {
                    element.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(didCompleteATask ? element.color: .gray)
                    
                    Text("\(count)")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    
                    Text("\(element.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
    }
}

#Preview {
    HStack{
        ElementStreakCell(element: .streak, count: 10, didCompleteATask: false)
        ElementStreakCell(element: .todayTaskAchieved, count: 10, didCompleteATask: true)
        ElementStreakCell(element: .totalTaskAchieved, count: 10, didCompleteATask: true)
    }
}
