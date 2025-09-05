//
//  ContentView.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 6/11/25.
//

import SwiftUI
import Clerk

struct ContentView: View {
    @Environment(Clerk.self) private var clerk
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if let user = clerk.user {
                    HStack {
                        Spacer()
                        Button("Sign Out") {
                            Task { try? await clerk.signOut() }
                        }
                        .foregroundColor(.red)
                        .padding()
                    }
                }
                
                Text("Welcome!")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Text("Have you already started your entrepreneurial journey?")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                NavigationLink(destination: WannapreneurView()) {
                    Text("Not yet")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: EntrepreneurView()) {
                    Text("Yes I have")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
            }
        }
    }
}

#Preview {
    ContentView()
}
