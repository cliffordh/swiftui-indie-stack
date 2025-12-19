//
//  LoginView.swift
//  MyApp
//
//  Sign-in screen with Apple and Google authentication options.
//

import AuthenticationServices
import GoogleSignInSwift
import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var authManager: AuthManager

    @StateObject private var googleButtonVM: GoogleSignInButtonViewModel

    // TODO: Update these URLs for your app
    let tosURL = "https://yourapp.com/terms"
    let privacyPolicyURL = "https://yourapp.com/privacy"

    init() {
        let viewModel = GoogleSignInButtonViewModel()
        viewModel.style = .wide
        viewModel.scheme = .light
        _googleButtonVM = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            // Header Section
            VStack(spacing: 16) {
                Text("sign in to")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                    .padding(.top)

                // TODO: Replace with your app name
                Text("Your App Name")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
            }

            Spacer()

            // Sign-in Buttons Section
            VStack(spacing: 16) {
                // Apple Sign-In Button
                SignInWithAppleButton(
                    onRequest: { request in
                        AppleSignInManager.shared.requestAppleAuthorization(request)
                    },
                    onCompletion: { result in
                        handleAppleID(result)
                    }
                )
                .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                .frame(width: 312, height: 48, alignment: .center)

                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    Text("or")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                }

                // Google Sign-In Button
                GoogleSignInButton(viewModel: googleButtonVM) {
                    Task {
                        await signInWithGoogle()
                    }
                }
                .frame(width: 312, height: 48, alignment: .center)

                // Terms and Privacy Links
                VStack(spacing: 0) {
                    Text("By signing in, you agree to our")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    HStack {
                        Text("Terms of Service")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                            .underline()
                            .onTapGesture {
                                if let url = URL(string: tosURL) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        Text("and")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text("Privacy Policy")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                            .underline()
                            .onTapGesture {
                                if let url = URL(string: privacyPolicyURL) {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .task {
            Analytics.track(event: "view.LoginView")
        }
    }

    // MARK: - Google Sign-In

    func signInWithGoogle() async {
        do {
            guard let user = try await GoogleSignInManager.shared.signInWithGoogle() else { return }

            let result = try await authManager.googleAuth(user)
            if result != nil {
                dismiss()
            }
        } catch {
            debugPrint("GoogleSignInError: \(error)")
        }
    }

    // MARK: - Apple Sign-In

    func handleAppleID(_ result: Result<ASAuthorization, Error>) {
        if case let .success(auth) = result {
            guard let appleIDCredentials = auth.credential as? ASAuthorizationAppleIDCredential else {
                debugPrint("AppleAuthorization failed: AppleID credential not available")
                return
            }

            Task {
                do {
                    let result = try await authManager.appleAuth(
                        appleIDCredentials,
                        nonce: AppleSignInManager.nonce
                    )
                    if result != nil {
                        dismiss()
                    }
                } catch {
                    debugPrint("AppleAuthorization failed: \(error)")
                }
            }
        } else if case let .failure(error) = result {
            debugPrint("AppleAuthorization failed: \(error)")
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}
