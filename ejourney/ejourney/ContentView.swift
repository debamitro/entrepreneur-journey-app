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
    @Environment(UserSettings.self) private var userSettings
    
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
                
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                Text("Welcome!")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                NavigationLink(destination: BusinessIdeasView()) {
                    Text("Ideas")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: DiaryView()) {
                    Text("Diary")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
            }
            .navigationTitle("Home")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
