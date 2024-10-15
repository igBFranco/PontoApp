//
//  LoginView.swift
//  PontoApp
//
//  Created by Igor Bueno Franco on 20/09/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isUserLoggedIn = false
    @State private var showRegisterView = false
    @State private var showForgotPasswordAlert = false
    
    let primaryColor = Color(hex: "5300FF")
    
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: "Icon") ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom)
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
                .background(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(primaryColor), lineWidth: 2)
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
                            .foregroundStyle(primaryColor)
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
                .background(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(primaryColor), lineWidth: 2)
                )
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .alert(isPresented: $showForgotPasswordAlert) {
                    Alert(title: Text("Resetar Senha"),
                          message: Text("Um link de reset de senha foi encaminhado para o endereço \(email)."),
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
                    .background(Color(primaryColor))
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
                        .foregroundStyle(primaryColor)
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
                errorMessage = "Digite o email para poder enviar o link de recuperação."
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
    @State private var fullName = ""
    @State private var registrationNumber = ""
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    let primaryColor = Color(hex: "5300FF")

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
                Text("Nome Completo")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                TextField("Digite seu nome completo", text: $fullName)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(primaryColor), lineWidth: 2)
                    )
                    .cornerRadius(8)
                    .padding(.bottom)
                
                Text("Número de Matrícula")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                TextField("Digite seu número de matrícula", text: $registrationNumber)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(primaryColor), lineWidth: 2)
                    )
                    .cornerRadius(8)
                    .padding(.bottom)
                Text("E-mail")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                TextField("Digite seu email", text: $email)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(primaryColor), lineWidth: 2)
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
                .background(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(primaryColor), lineWidth: 2)
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
                .background(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(primaryColor), lineWidth: 2)
                )
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .trailing)
                Button(action: {registerUser()}, label: {
                    Text("Criar Conta")
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color(primaryColor))
                        .cornerRadius(8)
                })
                .padding(.top, 16)
                Button(action: {presentationMode.wrappedValue.dismiss()}, label: {
                    Text("Cancelar")
                        .foregroundStyle(primaryColor)
                }).padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            .padding()
        }
    }
    
    func registerUser() {
        guard password == confirmPassword else {
            errorMessage = "As senhas não conferem!"
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Registrado com sucesso"
                guard let user = result?.user else { return }
                saveUserInfo(userID: user.uid)
                presentationMode.wrappedValue.dismiss()

            }
        }
    }
    
    func saveUserInfo(userID: String) {
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "fullName": fullName,
                "registrationNumber": registrationNumber,
                "email": email,
                "userID": userID
            ]
            
            db.collection("users").document(userID).setData(userData) { error in
                if let error = error {
                    print("Erro ao salvar informações do usuário: \(error.localizedDescription)")
                } else {
                    print("Informações do usuário salvas com sucesso.")
                }
            }
        }
}

#Preview {
    LoginView()
}
