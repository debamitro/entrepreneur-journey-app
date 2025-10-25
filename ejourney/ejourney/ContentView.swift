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
                
                Text("Welcome!")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                HStack {
                    NavigationLink(destination: BusinessIdeasView()) {
                        Text("Ideas")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(width: 150, height: 150)
                            .background(Color.yellow)
                            .cornerRadius(20)
                    }
                    
                    NavigationLink(destination: DiaryView()) {
                        Text("Diary")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(width: 150, height: 150)
                            .background(Color.green)
                            .cornerRadius(20)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
