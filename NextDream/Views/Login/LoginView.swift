//  LoginView.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 29.09.2025.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct LoginView: View {

    @State var viewModel: LoginViewModel = .init()
    @State private var showRegistration = false
    @Environment(AuthViewModel.self) var auth
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("isEmailVerified") var emailVerified: Bool = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {

                Text("Next Dream")
                    .font(.largeTitle.bold())
                    .padding(.top, 48)

                loginSection

                signInWithOtherProvidersSection
                    .padding(.horizontal, 24)

                Spacer()

                registrationFooter
                    .padding(.bottom, 24)
                
            }
        }
        .sheet(isPresented: $showRegistration) {
            ScrollView{
                RegistrationView()
            }   
        }
    }
}

#Preview {
    LoginView()
}

extension LoginView{
    
    private var loginSection: some View{
        // Login Card
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.title.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                // Email
                emailField
                
                // Password
                passwordField
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            loginButton
        }
        .padding(24)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 8)
        .padding(.horizontal, 24)
    }
    
    private var emailField: some View{
        TextField("Email", text: $viewModel.email)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding(14)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var passwordField: some View{
        Group {
            if viewModel.isSecure {
                SecureField("Password", text: $viewModel.password)
                    .padding(14)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                TextField("Password", text: $viewModel.password)
                    .padding(14)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .overlay(
            Button(action: { viewModel.isSecure.toggle() }) {
                Image(systemName: viewModel.isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 12)
            , alignment: .trailing
        )
    }
    
    private var loginButton: some View{
        
        Button {
            if viewModel.checkEmailAndPassword(){
                Task{
                    let results = await viewModel.handleLogin()
                    isLoggedIn = results.0
                    emailVerified = results.1
                }
//                viewModel.errorMessage =  auth.signInWithEmailAndPassword(email: viewModel.email, password: viewModel.password)
            }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Log In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .disabled(viewModel.isLoading)
    }
    
    private var signInWithOtherProvidersSection: some View{
        VStack(spacing: 8) {
            signInWithAppleButton

            signInWithGoogleButton
        }
    }

    private var signInWithAppleButton: some View{
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                // Configure request here if needed
            },
            onCompletion: { result in
                // Handle result here if needed
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .cornerRadius(8)
    }

    private var signInWithGoogleButton: some View{
        GoogleSignInButton(scheme: .dark, style: .standard, state: .normal) {
            auth.signInWithGoogle()
        }
    }

    private var registrationFooter: some View {
        HStack(spacing: 8) {
            Text("Don't have an account?")
                .foregroundColor(.secondary)
            Button(action: { showRegistration = true }) {
                Text("Register")
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
