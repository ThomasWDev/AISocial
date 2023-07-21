//
//  SignInView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 24/3/23.
//

import SwiftUI
import Firebase

struct SignInView: View {
    @StateObject var viewModel  = FireBaseLoginViewModel()
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Sign In")
                    .bold()
                    .font(.custom("", size: 30))
                    .foregroundColor(.blue)
                ScrollView {
                    VStack(spacing: 25) {
                        TextField("Email", text: $viewModel.email)
                            .padding(16)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke()
                            }
                        SecureField("Password", text: $viewModel.password)
                            .padding(16)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke()
                            }

                        HStack {
                            Spacer()
                            Button {

                            } label: {
                                Text("Forgot password?")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    VStack(spacing: 20) {
                        ButtonComponents(buttonName: "Sign Up", bgColor: .blue, onTap: {
                            viewModel.isLoading = true
                            viewModel.register()
                        })
                        .alert(viewModel.authStatusMessage, isPresented: $viewModel.showAlert) {
                            Button("OK", role: .cancel) { }
                        }
                        .showLoadingView(viewModel.isLoading)
                    }
                    Text("OR")
                    ButtonComponents(buttonName: "Login with Facebook", bgColor: AppColors.fbBackgroundColor, onTap: {})
                    ButtonComponents(buttonName: "Login with Apple", bgColor: .black, onTap: {})
                        .navigationDestination(isPresented: $viewModel.isLoading) {
                            Text("View 1")
                        }
                    /*  NavigationLink(destination: ChatGPTTabBar(), isActive: $vm.isLoggedIn) {
                     EmptyView()
                     } */
                }
            }
            .padding()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

struct LoadingModifer: ViewModifier {
    var isLoading: Bool
    var isWhite: Bool
    var text: String?
    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    if isLoading {
                        if let text = text {
                            Text(text)
                                .foregroundColor(.white)
                                .bold()
                                .padding(12)
                                .background(.black)
                                .cornerRadius(6)
                                .offset(y: -10)
                        }
                        LoadingDots(text: "", color: isWhite ? .white : .black, dotsCount: 3)
                    }
                }.frame(maxWidth: isLoading ? .infinity:0, maxHeight: isLoading ? .infinity:0)
            )
    }
}

extension View {
    func showLoadingView(_ isLoading: Bool, loadingText: String? = nil, isWhite: Bool = false) -> some View {
        modifier(LoadingModifer(isLoading: isLoading, isWhite: isWhite, text: loadingText))
    }
}
