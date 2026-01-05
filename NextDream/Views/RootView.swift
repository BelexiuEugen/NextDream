//
//  RootView.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 30.09.2025.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    
//    @Environment(AuthViewModel.self) var auth: AuthViewModel
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("isEmailVerified") var emailVerified: Bool = false
    
    var body: some View {
        if isLoggedIn && emailVerified {
            HomeView()
        } else if isLoggedIn {
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
