//
//  LoginViewModel.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 29.09.2025.
//

import Foundation
import FirebaseAuth

@Observable
final class LoginViewModel{
    var email: String = ""
    var password: String = ""
    var isSecure: Bool = true
    var errorMessage: String?
    var isLoading: Bool = false
    
    func checkEmailAndPassword() -> Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    func handleLogin() async -> (Bool, Bool){
        
        await withCheckedContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let user = result?.user else {
                    continuation.resume(returning: (false, false))
                    return
                }
                
                if !user.emailVerified() {
                    
                    continuation.resume(returning: (true, false))
                    return
                }
                
                continuation.resume(returning: (true, true))
                
                self.errorMessage = nil
            }
        }
    }
}
