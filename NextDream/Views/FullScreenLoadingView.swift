//
//  FullScreenLoadingView.swift
//  NextDream
//
//  Created by Jan on 27/03/2025.
//

import SwiftUI

struct FullScreenLoadingView: View {
    
    @Binding var taskCompleted: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                
                Text("Task Created: \(taskCompleted)")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.top, 10)
            }
        }
    }
}

#Preview {
    FullScreenLoadingView( taskCompleted: .constant(12))
}
