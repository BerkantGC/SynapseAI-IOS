import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    
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
                    
                    TextField("Kullanıcı Adı", text: $viewModel.username)
                        .autocapitalization(.none)
                        .padding(15)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(5.0)
                        .padding(.horizontal, 5)
                    
                    SecureField("Şifre", text: $viewModel.password)
                        .autocapitalization(.none)
                        .padding(15)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(5.0)
                        .padding(.horizontal, 5)
                    
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        if false {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(15)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10.0)
                                .padding(.horizontal, 5)
                        } else{
                            Text("Giriş Yap")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(15)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10.0)
                                .padding(.horizontal, 5)
                        }
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
