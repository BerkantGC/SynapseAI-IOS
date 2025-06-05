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
                    
                    TextField("Username", text: $viewModel.username)
                        .autocapitalization(.none)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal, 5)
                    
                    SecureField("Password", text: $viewModel.password)
                        .autocapitalization(.none)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
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
                            Text("Sign in")
                                .font(.headline)
                                .foregroundColor(.text)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(.blue)
                                .cornerRadius(10)
                                .padding(.horizontal, 5)
                        }
                    }
                    
                    HStack{
                        CustomGoogleSigninButton {
                            viewModel.signInWithGoogle()
                        }
                        
                        AppleSignInButton { token in
                            viewModel.signInWithApple(idToken: token)
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
    Main()
}
