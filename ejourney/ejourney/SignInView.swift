import SwiftUI
import Clerk

struct GoogleSignInButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "g.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
                
                Text("Sign in with Google")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.white)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.largeTitle)
                .bold()
            
            GoogleSignInButton {
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
            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
        }
        .padding()
    }
}
