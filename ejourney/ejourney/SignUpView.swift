import SwiftUI
import Clerk

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var code = ""
    @State private var isVerifying = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle)
                .bold()
            
            if isVerifying {
                TextField("Verification Code", text: $code)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("Verify") {
                    Task { await verify(code: code) }
                }
                .buttonStyle(.borderedProminent)
            } else {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Continue") {
                    Task { await signUp(email: email, password: password) }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

extension SignUpView {
    func signUp(email: String, password: String) async {
        do {
            let signUp = try await SignUp.create(
                strategy: .standard(emailAddress: email, password: password)
            )
            
            try await signUp.prepareVerification(strategy: .emailCode)
            
            isVerifying = true
        } catch {
            dump(error)
        }
    }
    
    func verify(code: String) async {
        do {
            guard let signUp = Clerk.shared.client?.signUp else {
                isVerifying = false
                return
            }
            
            try await signUp.attemptVerification(strategy: .emailCode(code: code))
        } catch {
            dump(error)
        }
    }
}
