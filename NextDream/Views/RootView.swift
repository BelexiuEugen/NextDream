//
//  RootView.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 30.09.2025.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    
    @Environment(AuthViewModel.self) var auth: AuthViewModel
    
    var body: some View {
        if auth.user != nil && ((auth.user?.isEmailVerified) != nil) {
            HomeView()
        } else if auth.user != nil {
            EmailNotVerifiedView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    RootView()
        .environment(AuthViewModel())
}
