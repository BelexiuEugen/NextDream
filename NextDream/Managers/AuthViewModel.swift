import SwiftUI
import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore


@Observable
@MainActor
final class AuthViewModel {
    var user: FirebaseAuth.User?
    var isLoading = true
    var errorMessage: String? = nil
    
    nonisolated(unsafe) private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                self?.isLoading = false
            }
        }
    }
    
    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func deleteAccount() {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    print("Error deleting account:", error.localizedDescription)
                } else {
                    print("User account deleted successfully")
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            // The listener above will set user = nil automatically.
        } catch {
            print("Sign out failed: \(error)")
        }
    }
    
    func createPresentingVC() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController
    }
    
    func signInWithGoogle() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Missing Firebase clientID.")
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Find a presenting UIViewController from the key window.
        guard let presentingVC = createPresentingVC() else {
            print("Unable to find a presenting UIViewController for Google Sign-In.")
            return
        }
        
        // Start the sign in flow.
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
            if let error = error {
                print("Google Sign-In failed: \(error)")
                return
            }
            
            guard
                let result = signInResult,
                let idToken = result.user.idToken?.tokenString
            else {
                print("Google Sign-In missing tokens.")
                return
            }
            
            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // Sign in to Firebase with the Google credential.
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    print("Firebase sign-in with Google credential failed: \(error)")
                } else {
                    print("The user was succesfully Connected")
                }
            }
        }
    }
    
    
    func saveUserData(uid: String, name: String, familyName: String, country: String, birthDay: Date, gender: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "name": name,
            "familyName": familyName,
            "country": country,
            "birthDay": birthDay,
            "gender": gender,
            "createdAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error saving user data:", error.localizedDescription)
            } else {
                print("User data saved successfully!")
            }
        }
    }
    
    func checkIfEmailIsVerified(user: User){
        user.reload { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signInWithEmailAndPassword(email: String, password: String) async -> String{
        
        await withCheckedContinuation {  continuation in
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    continuation.resume(returning: error.localizedDescription)
                    return
                }
                
                guard let user = result?.user else { return }

                    // Check if email is verified
                user.reload { error in
                    if let error = error {
                        continuation.resume(returning: error.localizedDescription)
                    }
                    
                    if user.isEmailVerified {
                        print("Email verified — allow access")
                        // Proceed to dashboard / main app
                    } else {
                        print("Email not verified — block access")
                        // Show alert: "Please verify your email first"
                    }
                }
                
                continuation.resume(returning: "Succefully Logged In")
            }
        }
    }
    
    func createAccountWithEmailAndPassword(email: String, password: String, name: String, familyName: String, country: String, birthDay: Date, gender: String) async -> String{
        await withCheckedContinuation {  continuation in
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    continuation.resume(returning: error.localizedDescription)
                    return
                }
                
                if let userID = result?.user.uid{
                    self.saveUserData(uid: userID, name: name, familyName: familyName, country: country, birthDay: birthDay, gender: gender)
                }
                
                continuation.resume(returning: "Succefully Logged In")
            }
        }
    }

    // MARK: - Password Validation (Firebase Auth policy)
    private static let allowedNonAlphanumericCharacters: CharacterSet = CharacterSet(charactersIn: "^$*.[]{}()?\"!@#%&/\\,><':;|_~")
    private static let allowedNonAlphanumericDescription: String = "^ $ * . [ ] { } ( ) ? \" ! @ # % & / \\ , > < ' : ; | _ ~"

    /// Validates a password against Firebase Authentication password policies.
    /// - Parameters:
    ///   - password: The password to validate.
    ///   - minLength: Minimum length (6–30; defaults to 6). Values below 6 are clamped to 6; values above 30 are clamped to 30.
    ///   - maxLength: Maximum length (up to 4096; defaults to 4096). Values above 4096 are clamped to 4096.
    /// - Returns: An array of human-readable error messages. If empty, the password satisfies all requirements.
    func checkPassword(_ password: String, minLength: Int = 6, maxLength: Int = 4096) -> String {
        // Clamp policy bounds per Firebase Auth limits
        let effectiveMin = max(6, min(minLength, 30))
        let effectiveMax = min(maxLength, 4096)

        var issues: [String] = []

        let length = password.count
        if length < effectiveMin {
            issues.append("Password must be at least \(effectiveMin) characters.")
        }
        if length > effectiveMax {
            issues.append("Password must be at most \(effectiveMax) characters.")
        }

        let scalars = password.unicodeScalars

        let hasLowercase = scalars.contains { CharacterSet.lowercaseLetters.contains($0) }
        if !hasLowercase {
            issues.append("Password must include at least one lowercase letter.")
        }

        let hasUppercase = scalars.contains { CharacterSet.uppercaseLetters.contains($0) }
        if !hasUppercase {
            issues.append("Password must include at least one uppercase letter.")
        }

        let hasDigit = scalars.contains { CharacterSet.decimalDigits.contains($0) }
        if !hasDigit {
            issues.append("Password must include at least one numeric digit.")
        }

        let hasAllowedSpecial = scalars.contains { AuthViewModel.allowedNonAlphanumericCharacters.contains($0) }
        if !hasAllowedSpecial {
            issues.append("Password must include at least one non-alphanumeric character from: \(AuthViewModel.allowedNonAlphanumericDescription)")
        }
        
        var returnedString: String = ""
        
        for issue in issues {
            returnedString += issue + "\n"
        }

        return returnedString
    }

    /// Convenience boolean check: returns true if the password satisfies all requirements.
    func isPasswordValid(_ password: String, minLength: Int = 6, maxLength: Int = 4096) -> Bool {
        return checkPassword(password, minLength: minLength, maxLength: maxLength).isEmpty
    }
}
