//
//  ejourneyApp.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 6/11/25.
//

import SwiftUI
import Clerk

@main
struct ejourneyApp: App {
    @State private var clerk = Clerk.shared
    @State private var userSettings = UserSettings.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if clerk.isLoaded {
                    ContentView()
                } else {
                    ProgressView()
                }
            }
            .environment(clerk)
            .environment(userSettings)
            .task {
                print("[Debug] Configuring Clerk...")
                clerk.configure(publishableKey: Bundle.main.object(forInfoDictionaryKey: "CLERK_PUBLISHABLE_KEY") as! String)
                do {
                    print("[Debug] Loading Clerk...")
                    try await clerk.load()
                    print("[Debug] Clerk loaded successfully")
                } catch {
                    print("[Debug] Error loading Clerk: \(error)")
                }
            }
        }
    }
}
