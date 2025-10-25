//
//  SettingsView.swift
//  ejourney
//
//  Created by Claude on 10/25/25.
//

import SwiftUI
import Clerk

struct SettingsView: View {
    @Environment(Clerk.self) private var clerk
    @Bindable var userSettings = UserSettings.shared
    
    let themes = ["Default", "Blue", "Green", "Purple"]
    
    var body: some View {
        Form {
            Section("Account") {
                if let user = clerk.user {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(user.emailAddresses.first?.emailAddress ?? "No email")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Sign Out") {
                        Task { try? await clerk.signOut() }
                    }
                    .foregroundColor(.red)
                }
            }
            
            Section("Profile") {
                Toggle("I am an Entrepreneur", isOn: $userSettings.isEntrepreneur)
                
                HStack {
                    Text("Current Status")
                    Spacer()
                    Text(userSettings.userTypeDisplayName)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Preferences") {
                Toggle("Enable Notifications", isOn: $userSettings.notificationsEnabled)
                
                Toggle("Dark Mode", isOn: $userSettings.darkModeEnabled)
                
                Picker("Theme", selection: $userSettings.selectedTheme) {
                    ForEach(themes, id: \.self) { theme in
                        Text(theme).tag(theme)
                    }
                }
            }
            
            Section("App") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                NavigationLink(destination: AboutView()) {
                    Text("About")
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
