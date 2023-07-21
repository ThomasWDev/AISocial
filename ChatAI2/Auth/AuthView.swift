//
//  AuthView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 30/5/23.
//

import SwiftUI

struct AuthView: View {
    @State private var authView: SelectedAuth = .signup
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showSheet = false

    init() {
        setupSegmentedColors()
    }

    var body: some View {
        ScrollView {
            if FirebaseManager.shared.auth.currentUser != nil {
                ChatHomeView()
            } else if authViewModel.gotoHome {
                ChatHomeView()
            } else if authViewModel.loggedOut {
                chatAuthView
            } else {
                chatAuthView
            }
        }
        .navigationTitle( authView == .signup ? "Sign Up" : "Sign In")
        .showLoadingView(authViewModel.loading)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if FirebaseManager.shared.auth.currentUser != nil {
                        Button("Logout") {
                            authViewModel.logout()
                            UserDefaults.standard.removeObject(forKey: "username")
                        }
                    } else {

                    }
                }

            }
        }
    }

    var chatAuthView: some View {
        VStack(spacing: 32) {
            Picker("", selection: $authView) {
                Text("Sign in")
                    .tag(SelectedAuth.login)
                Text("Sign up")
                    .tag(SelectedAuth.signup)
            }
            .tint(AppColors.themeColor)
            .pickerStyle(.segmented)
            .alert(authViewModel.message, isPresented: $authViewModel.showAlert) {
                Button("OK", role: .cancel) {}
            }

            if authView == .login {
                loginView
            } else {
                signupView
            }
        }
        .padding()
    }

    var signupView: some View {
        VStack(spacing: 16) {
            profilePhoto
            TextField("First name", text: $authViewModel.firstName)
                .padding(12)
                .cornerRadius(8)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 1)
                        .foregroundColor(AppColors.themeColor)
                )
            TextField("Last name", text: $authViewModel.lastName)
                .padding(12)
                .cornerRadius(8)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 1)
                        .foregroundColor(AppColors.themeColor)
                )
            TextField("City name", text: $authViewModel.cityName)
                .padding(12)
                .cornerRadius(8)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 1)
                        .foregroundColor(AppColors.themeColor)
                )
            TextField("Email", text: $authViewModel.email)
                .padding(12)
                .cornerRadius(8)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 1)
                        .foregroundColor(AppColors.themeColor)
                )
            SecureInputView("Password", text: $authViewModel.password)

            Button {
                authViewModel.signup()
            } label: {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.themeColor)
                    .cornerRadius(8)
            }

        }
    }

    var loginView: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $authViewModel.email)
                .padding(12)
                .cornerRadius(8)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 1)
                        .foregroundColor(AppColors.themeColor)
                )
            SecureInputView("Password", text: $authViewModel.password)
            Button {
                authViewModel.signin()
            } label: {
                Text("Sign in")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.themeColor)
                    .cornerRadius(8)
            }

            HStack {
                Spacer()
                Text("Forgot password?")
                    .padding(16)
                    .foregroundColor(AppColors.themeColor)
                    .onTapGesture {
                        authViewModel.showForgotPassSheet = true
                    }
            }
        }
        .fullScreenCover(isPresented: $authViewModel.showForgotPassSheet) {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark")
                        .padding(20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            authViewModel.showForgotPassSheet = false
                        }
                }

                TextField("Email", text: $authViewModel.email)
                    .padding(12)
                    .cornerRadius(8)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(lineWidth: 1)
                            .foregroundColor(AppColors.themeColor)
                    )

                Button {
                    authViewModel.sendForgotPassEmail()
                } label: {
                    Text("Reset Password")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.themeColor)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Reset Password")
        }
    }

    private var profilePhoto: some View {
        VStack {
            if let image = authViewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .cornerRadius(50)
                    .frame(width: 100, height: 100)
                    .background(Color.black.opacity(0.2))
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person")
                    .font(.system(size: 80))
                    .aspectRatio(contentMode: .fill)
            }
            Text("Upload Photo")
                .font(.headline)
                .padding(8)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(AppColors.themeColor)
                .cornerRadius(16)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .onTapGesture {
                    showSheet = true
                }
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $authViewModel.image)
        }
    }

    func setupSegmentedColors() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(AppColors.themeColor)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    }
}

enum SelectedAuth {
    case login
    case signup
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}

struct SecureInputView: View {

    @Binding private var text: String
    @State private var isSecured: Bool = true
    private var title: String

    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }.padding(.trailing, 32)

            Button(action: {
                isSecured.toggle()
            }, label: {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            })
        }
        .padding(12)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundColor(AppColors.themeColor)
        )
    }
}
