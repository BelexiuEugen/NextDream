//  RegistrationViewModel.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 29.09.2025.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import SwiftUI

@Observable
final class RegistrationViewModel {
    var email: String = ""
    var password: String = ""
    var repeatPassword: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    var country: String = "Canada"
    var gender: String = ""
    var isSecure: Bool = true
    var errorMessage: String = ""
    var isLoading: Bool = false
    // Example country list
    let countryList = ["United States", "United Kingdom", "Canada", "Germany", "France", "Other"]
    let genderList = ["Male", "Female", "Other"]
    
    var seePassword = false
    var seeRepeatPassword = false

    func isFormValid() -> Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !country.isEmpty &&
        !gender.isEmpty &&
        !repeatPassword.isEmpty
    }
    
//    func isRegistrationValid() -> Bool{
//        guard checkFormValid() else {
//            errorMessage = "Please fill in all the fields and make sure your passwords match."
//            return false
//        }
//    }

    func handleRegister(dismiss: DismissAction) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            dismiss()
        }
    }
    
    func signInWithGoogle(){
        
    }
}
