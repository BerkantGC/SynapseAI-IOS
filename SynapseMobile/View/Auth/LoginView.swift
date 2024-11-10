// Login.swift

import SwiftUI

struct LoginView: View {
    @State var username: String = "";
    @State var password: String = "";
    @ObservedObject var viewModel: LoginViewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            AuthBackground()
             
            VStack(spacing: 20) {
                Text("Synapse")
                    .textCase(.uppercase)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .bold()
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading) // Full width and aligned to the left
                
                TextField("Kullanıcı Adı", text: $username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.horizontal)

                SecureField("Şifre", text: $password)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.horizontal)

                Button(action: {
                    viewModel.login(username: username, password: password)
                }) {
                    Text("Giriş Yap")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10.0)
                        .padding(.horizontal)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

            }
            
        }
        .background(
         Color("LoginBG")
        .ignoresSafeArea(.all)
        )
        .frame(width: .infinity,
               height: .infinity,
               alignment: .center
        )
        .alert(isPresented: $viewModel.isLogged) {
            Alert(title: Text("Welcome"), message: Text("Login successful!"), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    LoginView()
}
