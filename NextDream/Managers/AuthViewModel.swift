import SwiftUI
import AuthenticationServices
import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import CryptoKit


@Observable
@MainActor
final class AuthViewModel: NSObject, ASAuthorizationControllerPresentationContextProviding {
    var user: FirebaseAuth.User?
    var isLoading = true
    var errorMessage: String? = nil
    
    nonisolated(unsafe) private var handle: AuthStateDidChangeListenerHandle?
    var currentNonce: String?
    
    override init() {
        super.init()
        setUpAuthStateListener()
    }
    
    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    nonisolated(unsafe) private func setUpAuthStateListener() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                self?.isLoading = false
            }
        }
    }
    
    func deleteAccount() {
        
        if let user = Auth.auth().currentUser {
            
            let isAppleLogin = user.providerData.contains { $0.providerID == "apple.com" }
            
            if isAppleLogin{
                deleteCurrentUser()
            }
            else {
                user.delete { error in
                    if let error = error {
                        print("Error deleting account:", error.localizedDescription)
                    } else {
                        print("User account deleted successfully")
                    }
                }
            }
        }
    }

    private func deleteCurrentUser() {

        let nonce = self.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = self.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
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
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Use the key window as the presentation anchor
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window
        }
        // Fallback to a new window if key window isn't available
        return ASPresentationAnchor()
    }
    
    func signInWithGoogle(){
        
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
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(true, forKey: "isEmailVerified")
                    print("The user was succesfully Connected")
                }
            }
        }
    }

    func handleAppleResult(authorization: ASAuthorization) {
  

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Retrieve the nonce we stored during the request
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // 3. Create Firebase Credential
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            
            // 4. Sign in to Firebase
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Firebase Sign In Error: \(error.localizedDescription)")
                    return
                }
                
                print("User is signed in to Firebase with Apple.")
                // Handle success (e.g., set isLoggedIn = true)
            }
        }
    }

    func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    @available(iOS 13, *)
    func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
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
    
    func checkIfEmailIsVerified(user: User) async -> Bool{
        await withCheckedContinuation { continuation in
            user.reload { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                }
                
                continuation.resume(returning: user.isEmailVerified)
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
    
    func sendVerificationMail(){
        
        guard let user = Auth.auth().currentUser else { return }
        
        user.sendEmailVerification { error in
            if let error = error {
                print("Error sending email verification: \(error.localizedDescription)")
            } else {
                print("Email verification sent.")
            }
        }
    }
    
    func createAccountWithEmailAndPassword(email: String, password: String, name: String, familyName: String, country: String, birthDay: Date, gender: String) async -> (Bool, String){
        await withCheckedContinuation {  continuation in
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    continuation.resume(returning: (false, error.localizedDescription))
                    return
                }
                
                if let userID = result?.user.uid{
                    self.saveUserData(uid: userID, name: name, familyName: familyName, country: country, birthDay: birthDay, gender: gender)
                }
                
                self.sendVerificationMail()
                
                continuation.resume(returning: (true, "User Successfully Created"))
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


@available(iOS 13.0, *)
extension AuthViewModel: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      // Prefer using authorizationCode for revocation when deleting account; fall back to identityToken for sign-in
      if let appleAuthCode = appleIDCredential.authorizationCode, let authCodeString = String(data: appleAuthCode, encoding: .utf8) {
        // Attempt to revoke and delete the current Firebase user
        Task { [weak self] in
          do {
            try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
            try await self?.user?.delete()
          } catch {
            print("Error revoking token or deleting user: \(error)")
          }
        }
        return
      }

      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential, including the user's full name.
      let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                     rawNonce: nonce,
                                                     fullName: appleIDCredential.fullName)
      // Sign in with Firebase.
      Auth.auth().signIn(with: credential) { (authResult, error) in
        if let error = error {
          // Error. If error.code == .MissingOrInvalidNonce, make sure
          // you're sending the SHA256-hashed nonce as a hex string with
          // your request to Apple.
          print(error.localizedDescription)
          return
        }
        // User is signed in to Firebase with Apple.
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}

