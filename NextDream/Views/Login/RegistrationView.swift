//  RegistrationView.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 29.09.2025.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct RegistrationView: View {
    
    @State private var model = RegistrationViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(AuthViewModel.self) var auth
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Next Dream")
                    .font(.title2.bold())
                    .padding(.top, 48)

                VStack(spacing: 16) {
                    Text("Register")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    userInformationSection
                    
                    Text(model.errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    registerButton
                    
                    Spacer().frame(height: 10)
                }
                .padding(16)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(radius: 8)
                .padding(.horizontal, 12)
                
                signInWithOtherProvidersSection
                .padding()

                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    RegistrationView()
}

extension RegistrationView{
    
    private var userInformationSection: some View {
        VStack(spacing: 12) {
            
            nameAndFamilyNameField

            emailField

            passwordField

            dateField

            countryField

            genderField
        }
    }
    
    private var signInWithOtherProvidersSection: some View{
        VStack(spacing: 8) {
            signInWithAppleButton

            signInWithGoogleButton
        }
    }
}

//MARK: User Info Elements

extension RegistrationView{
    private var nameAndFamilyNameField: some View{
        HStack{
            
            TextField("First Name", text: $model.firstName)
                .font(.callout)
                .autocapitalization(.words)
                .padding(10)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            TextField("Family Name", text: $model.lastName)
                .font(.callout)
                .autocapitalization(.words)
                .padding(10)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
    
    private var emailField: some View {
        return TextField("Email", text: $model.email)
            .font(.callout)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(10)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    @ViewBuilder
    private func createPasswordField(placeholder: String,
                             password: Binding<String>, seePassword: Binding<Bool>) -> some View {
        Group{
            if seePassword.wrappedValue {
                SecureField(placeholder, text: password)
                    .font(.callout)
                    .padding(10)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                TextField(placeholder, text: password)
                    .font(.callout)
                    .padding(10)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .overlay(
            Button(action: { seePassword.wrappedValue.toggle() }) {
                Image(systemName: seePassword.wrappedValue ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 12)
            , alignment: .trailing
        )
    }
    
    private var passwordField: some View {
        return HStack{
            
            createPasswordField(
                placeholder: "Password",
                password: $model.password,
                seePassword: $model.seePassword
            )
            createPasswordField(
                placeholder: "Repeat Password",
                password: $model.repeatPassword,
                seePassword: $model.seeRepeatPassword
            )
        }
    }
    
    private var dateField: some View{
        DatePicker("Date of Birth", selection: $model.dateOfBirth, displayedComponents: .date)
            .font(.callout)
            .padding(10)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    private var countryField: some View{
        HStack(spacing: 4) {
            Text("Country")
                .font(.callout.weight(.semibold))
            
            Spacer()
            
            Picker(selection: $model.country) {
                ForEach(model.countryList, id: \.self) { Text($0).font(.callout) }
            } label: {
                EmptyView()
            }
            .pickerStyle(.menu)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
    
    private var genderField: some View{
        VStack(alignment: .leading, spacing: 4) {
            Text("Gender")
                .font(.callout.weight(.semibold))
            Picker(selection: $model.gender) {
                ForEach(model.genderList, id: \.self) { Text($0).font(.callout) }
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var registerButton: some View{
        Button {
            
            if model.password != model.repeatPassword {
                model.errorMessage = "Passwords do not match"
                return
            }
            
            let errorMessage = auth.checkPassword(model.password)
            
            guard errorMessage.isEmpty else {
                model.errorMessage = errorMessage
                return
            }
            Task{
                (isLoggedIn, model.errorMessage) = await auth
                    .createAccountWithEmailAndPassword(
                        email: model.email,
                        password: model.password,
                        name: model.firstName,
                        familyName: model.lastName,
                        country: model.country,
                        birthDay: model.dateOfBirth,
                        gender: model.gender
                    )
            }
            
        } label: {
            HStack {
                if model.isLoading {
                    ProgressView()
                } else {
                    Text("Register")
                        .font(.callout.bold())
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .disabled(!model.isFormValid() || model.isLoading)
    }
}

//MARK: Sign In Buttons

extension RegistrationView{
    
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
}

