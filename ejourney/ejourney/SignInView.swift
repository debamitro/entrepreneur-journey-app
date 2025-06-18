import SwiftUI
import Clerk

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Continue") {
                Task { await submit(email: email, password: password) }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Sign in with Google") {
                Task {
                    do {
                        print("signing in with Google...")
                        let auth = try await SignIn.create(strategy: .oauth(provider: .google))
                        let result = try await auth.authenticateWithRedirect()
                        switch result {
                         case .signIn(let signIn):
                             print("Proceed with sign-in: \(signIn)")
                         case .signUp(let signUp):
                             print("Transferred to sign-up: \(signUp)")
                        }
                        print("signed in with Google...")
                    } catch {
                        print("Google sign-in error: \(error)")
                    }
                }
            }
        }
        .padding()
    }
    
    private func signInWithGoogle() {
    }
}

extension SignInView {
    func submit(email: String, password: String) async {
        do {
            try await SignIn.create(
                strategy: .identifier(email, password: password)
            )
        } catch {
            dump(error)
        }
    }
}
