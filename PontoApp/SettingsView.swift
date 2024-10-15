//
//  SettingsView.swift
//  PontoApp
//
//  Created by Igor Bueno Franco on 14/10/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    @State private var fullName: String = ""
    @State private var registrationNumber: String = ""
    @State private var email: String = ""
    @State private var showingLogoutAlert = false
    @State private var isUserLoggedOut = false
    let primaryColor = Color(hex: "5300FF")

    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Configurações")
                    .font(.title)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding(.bottom, 20)
                
                Group {
                    Text("Nome Completo:")
                        .font(.headline)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    Text("\(fullName)")
                    Text("Matrícula:")
                        .font(.headline)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    Text("\(registrationNumber)")
                    Text("Email:")
                        .font(.headline)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    Text("\(email)")
                }
                .font(.title2)
                
                Spacer()
                
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("Logout")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(
                        title: Text("Logout"),
                        message: Text("Deseja realmente sair?"),
                        primaryButton: .destructive(Text("Confirmar")) {
                            logout()
                        },
                        secondaryButton: .cancel(Text("Cancelar"))
                    )
                }
                
            }
            .padding()
            .onAppear {
                fetchUserData()
            }
            .fullScreenCover(isPresented: $isUserLoggedOut, content: {
                LoginView()
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .cornerRadius(8)
                        Text("PontoApp")
                            .font(.title2)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding(4)
                        Spacer()
                        NavigationLink(destination: InfoView()){
                            Image(systemName: "info.circle")
                                .padding(8)
                                .foregroundColor(Color(primaryColor))
                                .cornerRadius(8)
                            
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.fullName = data?["fullName"] as? String ?? "Nome não disponível"
                self.registrationNumber = data?["registrationNumber"] as? String ?? "Matrícula não disponível"
                self.email = data?["email"] as? String ?? "Email não disponível"
            } else {
                print("Erro ao buscar dados do usuário: \(error?.localizedDescription ?? "Desconhecido")")
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isUserLoggedOut = true
        } catch let signOutError as NSError {
            print("Erro ao fazer logout: \(signOutError)")
        }
    }
}

struct InfoView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Aplicativo criado utilizando SwiftUI, por Igor Bueno Franco na Disciplina de Desenvolvimento de Aplicativos iOS").padding(20).multilineTextAlignment(.center)
                Text("PUCPR").padding(20).fontWeight(Font.Weight.bold)
                Text("2024")
            }.navigationTitle("Informações")
        }
    }
}

#Preview {
    SettingsView()
}

