import SwiftUI

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    
    @ObservedObject var viewModel: LoginViewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuthBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Synapse")
                        .textCase(.uppercase)
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
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
                    }.navigationDestination(isPresented: $viewModel.isLogged){
                        TabsView()
                    }
                    
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
            .background(Color("LoginBG"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


#Preview {
    LoginView()
}
