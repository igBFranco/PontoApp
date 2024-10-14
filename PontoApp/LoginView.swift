//
//  LoginView.swift
//  PontoApp
//
//  Created by Igor Bueno Franco on 20/09/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isUserLoggedIn = false
    @State private var showRegisterView = false
    @State private var showForgotPasswordAlert = false
    
    var body: some View {
        VStack {
            Text("PontoApp")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top)
                .padding(.bottom)
            Text("E-mail")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.primary)
            TextField("Digite seu email", text: $email)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(Color(uiColor: .white))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemBlue), lineWidth: 2)
                )
                .cornerRadius(8)
                .padding(.bottom)
            VStack{
                HStack {
                    Text("Senha")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.primary)
                    Button(action: {forgotPassword()}, label: {
                        Text("Recuperar Senha")
                    })
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                HStack {
                        SecureField("Digite sua Senha", text: $password)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(Color(uiColor: .white))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemBlue), lineWidth: 2)
                )
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .alert(isPresented: $showForgotPasswordAlert) {
                    Alert(title: Text("Password Reset"),
                          message: Text("A password reset link has been sent to \(email)."),
                          dismissButton: .default(Text("OK")))
                }
            }
            .padding(.bottom, 20)

            Button(action: {loginUser()}, label: {
                Text("Entrar")
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color(.systemBlue))
                    .cornerRadius(8)
            })
            .padding(.bottom, 8)
            
            if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red)
            }
            HStack{
                Text("Não possui uma conta?")
                    .foregroundColor(.secondary)
                Button(action: {showRegisterView = true}, label: {
                    Text("Registrar")
                })

                .sheet(isPresented: $showRegisterView) {
                    RegisterView()
                }
            }
            .padding(.top, 8)
            .padding(.bottom)
        }
        .padding()
        .fullScreenCover(isPresented: $isUserLoggedIn) {
            ContentView()
        }
    }
    
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isUserLoggedIn = true
            }
        }
    }
    
    func forgotPassword() {
            guard !email.isEmpty else {
                errorMessage = "Please enter your email."
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    showForgotPasswordAlert = true
                }
            }
        }
}

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack {
                Text("Crie sua Conta")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top)
                    .padding(.bottom)
                Text("E-mail")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                TextField("Digite seu email", text: $email)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color(uiColor: .white))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemBlue), lineWidth: 2)
                    )
                    .cornerRadius(8)
                    .padding(.bottom)
                Text("Senha")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                SecureField("Digite sua Senha", text: $password)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(Color(uiColor: .white))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemBlue), lineWidth: 2)
                )
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom)
                Text("Confirmar Senha")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                SecureField("Digite Novamente sua Senha", text: $confirmPassword)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundColor(.secondary)
                
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(Color(uiColor: .white))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemBlue), lineWidth: 2)
                )
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .trailing)
                Button(action: {registerUser()}, label: {
                    Text("Criar Conta")
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color(.systemBlue))
                        .cornerRadius(8)
                })
                .padding(.top, 16)
                Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                }.padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            .padding()
        }
    }
    
    func registerUser() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Registration successful!"
                presentationMode.wrappedValue.dismiss()

            }
        }
    }
}

#Preview {
    LoginView()
}
