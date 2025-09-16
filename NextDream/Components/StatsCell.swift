//
//  StatsCell.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 16.09.2025.
//

import SwiftUI

struct StatsCell: View {
    
    let completed: Int
        let total: Int
    var color: Color
        @State var showPercentage: Bool = false
    
        var progress: Double {
            guard total > 0 else { return 0 }
            return Double(completed) / Double(total)
        }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
            .frame(height: 200)
            .overlay(
                ZStack {
                    // Background circle (unfinished part)
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    
                    // Progress arc (thicker, from top-left)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            color,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90)) // start from top-left
                    
                    // Text inside
                    if showPercentage {
                        Text("\(Int(progress * 100))%")
                            .font(.headline)
                    } else{
                        Text("\(completed)/\(total)")
                            .font(.headline)
                    }
                }
                    .padding(24)
            )
//            .padding(.horizontal, 16)
            .onTapGesture {
                showPercentage.toggle()
            }
    }
}

#Preview {
    StatsCell(completed: 362, total: 365, color: .red)
}
