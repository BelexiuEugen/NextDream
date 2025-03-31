//
//  FullScreenLoadingView.swift
//  NextDream
//
//  Created by Jan on 27/03/2025.
//

import SwiftUI

struct FullScreenLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                
                Text("Loading...")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.top, 10)
            }
        }
    }
}

#Preview {
    FullScreenLoadingView()
}
