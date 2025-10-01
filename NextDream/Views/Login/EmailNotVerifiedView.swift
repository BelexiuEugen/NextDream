//
//  EmailNotVerifiedView.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 30.09.2025.
//

import SwiftUI
import FirebaseAuth

struct EmailNotVerifiedView: View {
    @Environment(AuthViewModel.self) private var auth: AuthViewModel

    @State private var isSending = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)

            Image(systemName: "envelope.badge")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.orange)
                .padding(.bottom, 4)

            Text("Email not verified")
                .font(.title2).bold()

            VStack(spacing: 6) {
                Text("Your email address isn't verified yet.")
                    .multilineTextAlignment(.center)
                if let email = Auth.auth().currentUser?.email, !email.isEmpty {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            // Link-style resend action
            Button(action: resendVerification) {
                Text(isSending ? "Sending…" : "Resend verification email")
            }
//            .buttonStyle(.link)
            .disabled(isSending)

            // Refresh button to re-check verification status
            Button("I've verified — Refresh status") {
                refreshStatus()
            }
            .buttonStyle(.bordered)

            Spacer()

            Text("Didn't get the email? Check your spam folder or try resending.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .alert("Verification email sent", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Check your inbox for a verification email. If you don't see it, look in your spam folder.")
        }
        .alert("Couldn't send email", isPresented: $showError) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Please try again in a moment.")
        }
    }

    private func resendVerification() {
        guard let user = Auth.auth().currentUser ?? auth.user else { return }
        isSending = true
        user.sendEmailVerification { error in
            DispatchQueue.main.async {
                isSending = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                } else {
                    showSuccess = true
                }
            }
        }
    }

    private func refreshStatus() {
        if let user = auth.user {
            auth.checkIfEmailIsVerified(user: user)
        } else {
            Auth.auth().currentUser?.reload(completion: { _ in })
        }
    }
}

#Preview {
    EmailNotVerifiedView()
        .environment(AuthViewModel())
}
